--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A library for controller


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local cos = math.cos;
local format = string.format;
local pi = math.pi;
local pow = math.pow;
local sin = math.sin;
local sqrt = math.sqrt;

type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce";
type easeDirection = "In" | "Out" | "InOut";
type result = CFrame | Color3 | Vector2 | Vector3 | UDim2;

local library: table = {};

--// functions
function __getAlpha(style: easeStyle, direction: easeDirection, schedule: number): number
    local function Linear(): number
        return schedule;
    end;

    local function QuadIn(): number
        return schedule * schedule;
    end;

    local function QuadOut(): number
        return 1 - (1 - schedule) * (1 - schedule);
    end;

    local function QuadInOut(): number
        if (schedule < 0.5) then
            return 2 * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 2) / 2;
        end;
    end;

    local function CubicIn(): number
        return schedule * schedule * schedule;
    end;

    local function CubicOut(): number
        return 1 - pow(1 - schedule, 3);
    end;

    local function CubicInOut(): number
        if (schedule < 0.5) then
            return 4 * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 3) / 2;
        end;
    end;

    local function QuartIn(): number
        return schedule * schedule * schedule * schedule;
    end;

    local function QuartOut(): number
        return 1 - pow(1 - schedule, 4);
    end;

    local function QuartInOut(): number
        if (schedule < 0.5) then
            return 8 * schedule * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 4) / 2;
        end;
    end;

    local function QuintIn(): number
        return schedule * schedule * schedule * schedule * schedule;
    end;

    local function QuintOut(): number
        return 1 - pow(1 - schedule, 5);
    end;

    local function QuintInOut(): number
        if (schedule < 0.5) then
            return 16 * schedule * schedule * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 5) / 2;
        end;
    end;

    local function SineIn(): number
        return 1 - cos((schedule * pi) / 2);
    end;

    local function SineOut(): number
        return sin((schedule * pi) / 2);
    end;

    local function SineInOut(): number
        return -(cos(schedule * pi) - 1) / 2;
    end;

    local function ExpoIn(): number
        if (schedule == 0) then
            return 0;
        else
            return pow(2, 10 * schedule - 10);
        end;
    end;

    local function ExpoOut(): number
        if (schedule == 1) then
            return 1;
        else
            return 1 - pow(2, -10 * schedule);
        end;
    end;

    local function ExpoInOut(): number
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

    local function CircIn(): number
        return 1 - sqrt(1 - pow(schedule, 2));
    end;

    local function CircOut(): number
        return sqrt(1 - pow(schedule - 1, 2));
    end;

    local function CircInOut(): number
        if (schedule < 0.5) then
            return (1 - sqrt(1 - pow(2 * schedule, 2))) / 2;
        else
            return (sqrt(1 - pow(-2 * schedule, 2)) + 1) / 2;
        end;
    end;

    local function ElasticIn(): number
        local A: number = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A);
        end;
    end;

    local function ElasticOut(): number
        local A: number = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1;
        end;
    end;

    local function ElasticInOut(): number
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

    local function BackIn(): number
        local A: number = 1.70158;
        local B: number = A + 1;

        return B * schedule * schedule * schedule - A * schedule * schedule;
    end;

    local function BackOut(): number
        local A: number = 1.70158;
        local B: number = A + 1;

        return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2);
    end;

    local function BackInOut(): number
        local A: number = 1.70158;
        local B: number = A * 1.525;

        if (schedule < 0.5) then
            return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2;
        else
            return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2;
        end;
    end;

    local function BounceOut(bSchedule: number?): number
        if (not bSchedule) then
            bSchedule = schedule;
        end;

        local A: number = 7.5625;
        local B: number = 2.75;

        if (bSchedule < 1 / B) then
            return A * bSchedule * bSchedule;
        elseif (bSchedule < 2 / B) then
            bSchedule -= 1.5 / B;

            return A * bSchedule * bSchedule + 0.75;
        elseif (bSchedule < 2.5 / B) then
            bSchedule -= 2.25 / B;

            return A * bSchedule * bSchedule + 0.9375;
        else
            bSchedule -= 2.625 / B;

            return A * bSchedule * bSchedule + 0.984375;
        end;
    end;

    local function BounceIn(): number
        return 1 - BounceOut(1 - schedule);
    end;

    local function BounceInOut(): number
        if (schedule < 0.5) then
            return (1 - BounceOut(1 - 2 * schedule)) / 2;
        else
            return (1 + BounceOut(1 - 2 * schedule)) / 2;
        end;
    end;

    local map: table = {
        ["LinearIn"] = Linear;
        ["LinearOut"] = Linear;
        ["LinearInOut"] = Linear;
        ["QuadIn"] = QuadIn;
        ["QuadOut"] = QuadOut;
        ["QuadInOut"] = QuadInOut;
        ["CubicIn"] = CubicIn;
        ["CubicOut"] = CubicOut;
        ["CubicInOut"] = CubicInOut;
        ["QuartIn"] = QuartIn;
        ["QuartOut"] = QuartOut;
        ["QuartInOut"] = QuartInOut;
        ["QuintIn"] = QuintIn;
        ["QuintOut"] = QuintOut;
        ["QuintInOut"] = QuintInOut;
        ["SineIn"] = SineIn;
        ["SineOut"] = SineOut;
        ["SineInOut"] = SineInOut;
        ["ExpoIn"] = ExpoIn;
        ["ExpoOut"] = ExpoOut;
        ["ExpoInOut"] = ExpoInOut;
        ["CircIn"] = CircIn;
        ["CircOut"] = CircOut;
        ["CircInOut"] = CircInOut;
        ["ElasticIn"] = ElasticIn;
        ["ElasticOut"] = ElasticOut;
        ["ElasticInOut"] = ElasticInOut;
        ["BackIn"] = BackIn;
        ["BackOut"] = BackOut;
        ["BackInOut"] = BackInOut;
        ["BounceIn"] = BounceIn;
        ["BounceOut"] = BounceOut;
        ["BounceInOut"] = BounceInOut;
    };

    local variant: string = format("%s%s", style, direction);

    return map[variant]();
end;

function __getLerp(var: string, A: result, B: result, C: number): result
    local function general(A: number, B: number, C:number): number
        return A + (B - A) * C;
    end;

    local function color3(): result
        local A: Color3 = A;
        local B: Color3 = B;

        local R1: number, G1: number, B1: number = A.R, A.G, A.B;
        local R2: number, G2: number, B2: number = B.R, B.G, B.B;

        return Color3.new(general(R1, R2, C), general(G1, G2, C), general(B1, B2, C));
    end;

    local function cframe(): result
        local A: CFrame = A;
        local B: CFrame = B;

        return A:Lerp(B, C);
    end;

    local function udim2(): result
        local A: UDim2 = A;
        local B: UDim2 = B;

        return A:Lerp(B, C);
    end;

    local function vector2(): result
        local A: Vector2 = A;
        local B: Vector2 = B;

        return A:Lerp(B, C);
    end;

    local function vector3(): result
        local A: Vector3 = A;
        local B: Vector3 = B;

        return A:Lerp(B, C);
    end;

    local map: table = {
        ["CFrame"] = cframe;
        ["Color3"] = color3;
        ["UDim2"] = udim2;
        ["Vector2"] = vector2;
        ["Vector3"] = vector3;
    };

    return map[var]();
end;

function library:Lerp(easeOption: {style: easeStyle?, direction: easeDirection?, duration: number?}?, startPos: result, endPos: result, schedule: number): result
    if (not easeOption) then
        easeOption = {
            style = "Linear",
            direction = "In",
            duration = 1
        };
    end;

    local style: easeStyle, direction: easeDirection, duration: number = unpack(easeOption);

    local alpha: number = __getAlpha(style, direction, schedule) / duration;
    local startType: string, endType: string = typeof(startPos), typeof(endPos);

    if (startType == endType) then
        return __getLerp(startType, startPos, endPos, alpha);
    end;

    error("Tween-V // Only same types position can send it!");
end;

return library;
