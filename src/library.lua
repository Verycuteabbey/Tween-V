--[[
    Tween-V // The next generation of "VCA's Tween"

    A library for controller


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--!strict

--// defines
abs = math.abs;
asin = math.abs;
cos = math.cos;
pi = math.pi;
pow = math.pow;
sin = math.sin;
sqrt = math.sqrt;

type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut" | "OutIn";
type startPos = CFrame | Color3 | BrickColor | Vector2 | Vector3;
type endPos = CFrame | Color3 | BrickColor | Vector2 | Vector3;

active = {};
library = {};
suspended = {};

library.active = active;
library.suspended = suspended;

--// functions
function __getAlpha(style: easeStyle, direction: easeDirection, schedule: number)
    local function bounceOut(schedule: number): number
        local A: number = 7.5625;
        local B: number = 2.75;

        if (schedule < 1 / B) then
            return A * schedule * schedule;
        elseif (schedule < 2 / B) then
            schedule -= 1.5 / B;

            return A * schedule * schedule + 0.75;
        elseif (schedule < 2.5 / B) then
            schedule -= 2.25 / B;

            return A * schedule * schedule + 0.9375;
        else
            schedule -= 2.625 / B;

            return A * schedule * schedule + 0.984375;
        end;
    end;

    if (style == "Linear") then
        return schedule;
    elseif (style == "Quad") then
        if (direction == "In") then
            return schedule * schedule;
        elseif (direction == "Out") then
            return 1 - (1 - schedule) * (1 - schedule);
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return 2 * schedule * schedule;
            else
                return 1 - pow(-2 * schedule + 2, 2) / 2;
            end;
        end;
    elseif (style == "Cubic") then
        if (direction == "In") then
            return schedule * schedule * schedule;
        elseif (direction == "Out") then
            return 1 - pow(1 - schedule, 3);
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return 4 * schedule * schedule * schedule;
            else
                return 1 - pow(-2 * schedule + 2, 3) / 2;
            end;
        end;
    elseif (style == "Quart") then
        if (direction == "In") then
            return schedule * schedule * schedule * schedule;
        elseif (direction == "Out") then
            return 1 - pow(1 - schedule, 4);
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return 8 * schedule * schedule * schedule * schedule;
            else
                return 1 - pow(-2 * schedule + 2, 4) / 2;
            end;
        end;
    elseif (style == "Quint") then
        if (direction == "In") then
            return schedule * schedule * schedule * schedule * schedule;
        elseif (direction == "Out") then
            return 1 - pow(1 - schedule, 5);
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return 16 * schedule * schedule * schedule * schedule * schedule;
            else
                return 1 - pow(-2 * schedule + 2, 5) / 2;
            end;
        end;
    elseif (style == "Sine") then
        if (direction == "In") then
            return 1 - cos((schedule * pi) / 2);
        elseif (direction == "Out") then
            return sin((schedule * pi) / 2);
        elseif (direction == "InOut") then
            return -(cos(schedule * pi) - 1) / 2;
        end;
    elseif (style == "Expo") then
        if (direction == "In") then
            if (schedule == 0) then
                return 0;
            else
                return pow(2, 10 * schedule - 10);
            end;
        elseif (direction == "Out") then
            if (schedule == 1) then
                return 1;
            else
                return 1 - pow(2, -10 * schedule);
            end;
        elseif (direction == "InOut") then
            if (schedule == 0) then
                return 0;
            elseif (schedule == 1) then
                return 1;
            end;

            if (schedule < 0.5) then
                return pow(2, 20 * schedule - 10) / 2;
            else
                return (2 - pow(2, -20 * schedule + 10)) / 2;
            end;
        end;
    elseif (style == "Circ") then
        if (direction == "In") then
            return 1 - sqrt(1 - pow(schedule, 2));
        elseif (direction == "Out") then
            return sqrt(1 - pow(schedule - 1, 2));
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return (1 - sqrt(1 - pow(2 * schedule, 2))) / 2;
            else
                return (sqrt(1 - pow(-2 * schedule, 2)) + 1) / 2;
            end;
        end;
    elseif (style == "Elastic") then
        local A: number = (2 * pi) / 3;

        if (direction == "In") then
            if (schedule == 0) then
                return 0;
            elseif (schedule == 1) then
                return 1;
            else
                return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A);
            end;
        elseif (direction == "Out") then
            if (schedule == 0) then
                return 0;
            elseif (schedule == 1) then
                return 1;
            else
                return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1;
            end;
        elseif (direction == "InOut") then
            local A: number = (2 * pi) / 4.5;

            if (schedule == 0) then
                return 0;
            elseif (schedule == 1) then
                return 1;
            end;

            if (schedule < 0.5) then
                return -(pow(2, 20 * schedule - 10) * sin((20 * schedule - 11.125) * A)) / 2;
            else
                return (pow(2, -20 * schedule + 10) * sin((20 * schedule - 11.125) * A)) / 2 + 1;
            end;
        end;
    elseif (style == "Back") then
        local A: number = 1.70158;
        local B: number = A + 1;

        if (direction == "In") then
            return B * schedule * schedule * schedule - A * schedule * schedule;
        elseif (direction == "Out") then
            return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2);
        elseif (direction == "InOut") then
            local B: number = A * 1.525;

            if (schedule < 0.5) then
                return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2;
            else
                return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2;
            end;
        end;
    elseif (style == "Bounce") then
        if (direction == "In") then
            return 1 - bounceOut(1 - schedule);
        elseif (direction == "Out") then
            return bounceOut(schedule);
        elseif (direction == "InOut") then
            if (schedule < 0.5) then
                return (1 - bounceOut(1 - 2 * schedule)) / 2;
            else
                return (1 + bounceOut(1 - 2 * schedule)) / 2;
            end;
        end;
    end;
end;

function library:Lerp(easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, startPos: startPos, endPos: endPos, schedule: number?)
    if (not easeOption) then
        easeOption = {
            style = "Linear",
            direction = "In",
            duration = 1
        };
    end;

    if (not schedule) then
        schedule = 0;
    end;

    local style: easeStyle, direction: easeDirection, duration: number = unpack(easeOption);

    local alpha: number = __getAlpha(style, direction, schedule);

    if (typeof(startPos) == typeof(endPos)) then
        
    end;
end;
