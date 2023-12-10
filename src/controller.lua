--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type positionType = CFrame | Color3 | number | Vector2 | Vector3 | UDim2;

local RunService = game:GetService("RunService");

local library: table = {};
--// functions
function library:Create(easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, A: positionType, B: positionType): table
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

    local object = {};

    object.easeOption = easeOption;

    function object:Start()
        
    end;

    return object;
end;

return library;
