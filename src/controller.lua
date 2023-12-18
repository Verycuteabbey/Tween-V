--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local defer = task.defer;
local remove = table.remove;

type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;

local library = require(script.library);
local runService = game:GetService("RunService");

local controller = {};
controller.tweens = {};

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
    --#region // reuse
    local result = controller:Find(instance, property);

    if (result) then
        local info = result.info :: table;
        local status = result.status :: table;

        info.recentValue = instance[property] :: positionType;
        info.target = target :: positionType;
        info.easeOption = easeOption :: table;
        result.funcs = nil;
        result.thread = nil;
        status.started = false;

        result.info = info;
        result.status = status;
        return result;
    end;
    --#endregion
    local object = {};

    object.funcs = nil;
    object.thread = nil;

    object.info = {
        instance = instance;
        property = property;
        target = target;
        easeOption = easeOption;
    };
    object.status = {
        running = false;
        started = false;
        yield = false;
    };
    --#region // Replay
    function object:Replay()
        if (not self.funcs) then return end;

        self.thread:Disconnect();
        local connection = runService.Heartbeat:Connect(self.funcs);
        self.thread = connection :: RBXScriptConnection;
    end;
    --#endregion
    --#region // Resume
    function object:Resume()
        local status = self.status :: table;

        status.yield = false;

        self.status = status;
    end;
    --#endregion
    --#region // Start
    function object:Start()
        local info = self.info :: table;
        local status = self.status :: table;

        if (status.started) then return end;

        status.started = true;

        local easeOption = info.easeOption :: table;
        local nowTime = 0;

        local function tween(deltaTime: number)
            if (status.yield) then return end;

            status.running = true;

            if (nowTime > easeOption.duration) then
                status.running = false;
                self.thread:Disconnect();
                nowTime = easeOption.duration :: number;
            end;

            info.instance[info.property] = library:Lerp(easeOption, info.recentValue, info.target, nowTime / easeOption.duration);
            nowTime += deltaTime;
        end;

        self.funcs = tween;
        local connection = runService.Heartbeat:Connect(tween);
        self.thread = connection :: RBXScriptConnection;

        self.info = info;
        self.status = status;
    end;
    --#endregion
    --#region // Yield
    function object:Yield()
        local status = self.status :: table;

        status.yield = true;

        self.status = status;
    end;
    --#endregion
    __insert(controller.tweens, object);
    return object;
end;

function controller:Find(instance: Instance, property: string): table?
    for _, V in pairs(controller.tweens) do
        local info = V.info;

        if (info.instance == instance) and (info.property == property) then
            return V;
        end;
    end;

    return;
end;

function __collector()
    while (task.wait(60)) do
        for N, V in pairs(controller.tweens) do
            local status = V.status;

            if (not status.running) then
                remove(V, N);
            end;
        end;
    end;
end;

function __insert(target: table, value: any)
    for I = 1, #target do
        if (target[I] == nil) then
            target[I] = value;
            return;
        end;
    end;

    target[#target + 1] = value;
end;

defer(__collector);

return controller;
