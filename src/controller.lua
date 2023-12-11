--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
]]--

--// defines
type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;

local library: table = require(script.Parent);
local runService: RunService = game:GetService("RunService");

local controller: table = {};
--// functions
function controller:Create(instance: Instance, property: string, easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, target: positionType): table
    --#region // default
    if (not easeOption) then
        warn("Tween-V - Warning // empty easeOptions has been given, using default");

        easeOption = {
            style = "Linear",
            direction = "In",
            duration = 1
        };
    elseif (not easeOption.style) then
        warn("Tween-V - Warning // easeOptions has given a empty style, using default");

        easeOption.style = "Linear";
    elseif (not easeOption.direction) then
        warn("Tween-V - Warning // easeOptions has given a empty direction, using default");

        easeOption.direction = "In";
    elseif (not easeOption.duration) then
        warn("Tween-V - Warning // easeOptions has given a empty duration, using default");

        easeOption.duration = 1;
    end;
    --#endregion
    local object: table = {};

    local meta: table = {};
    meta.__index = meta;

    meta.instance = {
        self = instance;
        property = property;
        recentValue = instance[property];
        target = target;
        easeOption = easeOption;
    };
    meta.options = {
        recycle = false;
        timer = 60;
        yield = false;
        threads = {};
    };
    --#region // Continue
    function object:Continue()
        meta = getmetatable(self) :: table;

        local options: table = meta.options;

        options.yield = false;
        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Replay
    function object:Replay()
        meta = getmetatable(self) :: table;

        local options: table = meta.options;

        local threads: table = options.threads;

        if (not options.tween) then return end;

        threads[2]:Disconnect();
        local connection: RBXScriptConnection = runService.Heartbeat:Connect(options.tween);
        threads[2] = connection;

        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Start
    function object:Start()
        meta = getmetatable(self) :: table;

        local instance: table = meta.instance;
        local options: table = meta.options;

        local threads: table = options.threads;
        --#region // timer
        local timer: number = options.timer;

        local function main()
            local recycleTime: number = 0;

            while (task.wait(1)) do
                if (timer > 0) then
                    timer -= 1;
                elseif (recycleTime < 10) then
                    recycleTime += 1;
                else
                    setmetatable(self, {});
                    self = nil;
                    break;
                end;
            end;
        end;

        local thread: thread = task.spawn(main);
        threads[#threads + 1] = thread;
        --#endregion
        --#region // tween
        local nowTime: number = 0;

        local function tween(deltaTime: number)
            if (options.yield) then return end;

            if (nowTime > easeOption.duration) then
                meta = getmetatable(self);
                threads[2]:Disconnect();
                nowTime = easeOption.duration;
            end;

            instance.self[instance.property] = library:Lerp(easeOption, instance.recentValue, instance.target, nowTime / easeOption.duration);
            nowTime += deltaTime;
            timer = 60;
        end;

        local connection: RBXScriptConnection = runService.Heartbeat:Connect(tween);
        threads[#threads + 1] = connection;
        options.tween = tween;
        --#endregion
        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Stop
    function object:Stop()
        meta = getmetatable(self) :: table;

        local options: table = meta.options;

        options.yield = true;
        setmetatable(self, meta);
    end;
    --#endregion
    setmetatable(object, meta);
    return object;
end;

return controller;
