--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
]]--

--// defines
local defer = task.defer;

type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;

local library = require(script.Parent);
local runService = game:GetService("RunService");

local controller = {};
controller.tweens = {};

--// functions
--#region // controller
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
    --#region // reuse
    local result = controller:Find(instance, property);

    if (result) then
        local meta = getmetatable(result);

        meta.instance.recentValue = instance[property] :: positionType;
        meta.instance.target = target :: positionType;
        meta.instance.easeOption = easeOption :: table;

        meta.funcs = nil;
        meta.thread = nil;
        meta.status.started = false;

        setmetatable(result, meta);
        return result;
    end;
    --#endregion
    local object = {};

    local meta = {};
    meta.__index = meta;

    meta.instance = {
        self = instance;
        property = property;
        recentValue = instance[property];
        target = target;
        easeOption = easeOption;
    };
    meta.status = {
        running = false;
        started = false;
        yield = false;
    };
    --#region // Replay
    function object:Replay()
        local meta = getmetatable(self);

        if (not meta.funcs) then return end;

        meta.thread:Disconnect();
        local connection = runService.Heartbeat:Connect(meta.funcs);
        meta.thread = connection :: RBXScriptConnection;

        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Resume
    function object:Resume()
        local meta = getmetatable(self);

        meta.options.yield = false;
        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Start
    function object:Start()
        local meta = getmetatable(self);

        if (meta.status.started) then return end;

        meta.status.started = true;

        local easeOption = meta.instance.easeOption :: table;
        local nowTime = 0;

        local function tween(deltaTime: number)
            if (meta.status.yield) then return end;

            meta.status.running = true;

            if (nowTime > easeOption.duration) then
                meta.status.running = false;
                meta.thread:Disconnect();
                nowTime = easeOption.duration :: number;
            end;

            meta.instance.self[meta.instance.property] = library:Lerp(easeOption, meta.instance.recentValue, meta.instance.target, nowTime / easeOption.duration);
            nowTime += deltaTime;
            setmetatable(self, meta);
        end;

        local connection = runService.Heartbeat:Connect(tween);
        meta.thread = connection :: RBXScriptConnection;
        meta.funcs = tween;

        setmetatable(self, meta);
    end;
    --#endregion
    --#region // Yield
    function object:Yield()
        local meta = getmetatable(self);

        meta.options.yield = true;
        setmetatable(self, meta);
    end;
    --#endregion
    setmetatable(object, meta);
    controller.tweens[#controller.tweens + 1] = object :: table;

    return object;
end;

function controller:Find(instance: Instance, property: string): table?
    local result: table?;

    for _, V in pairs(controller.tweens) do
        local meta = getmetatable(V);

        if (meta.instance.self == instance) and (meta.instance.property == property) then
            result = V;
        end;
    end;

    return result;
end;
--#endregion
--#region // collector
function __collector()
    while (task.wait(60)) do
        for N, V in pairs(controller.tweens) do
            local meta = getmetatable(V);

            if (not meta.status.running) then
                setmetatable(V, {});
                controller.tweens[N] = nil;
            end;
        end;
    end;
end;

defer(__collector);
--#endregion

return controller;
