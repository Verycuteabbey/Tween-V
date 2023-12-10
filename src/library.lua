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
type positionType = CFrame | Color3 | ColorSequenceKeypoint | DateTime | number | NumberRange | NumberSequenceKeypoint | Ray | Rect | Region3 | UDim2 | Vector2 | Vector3;

local library: table = {};

--// functions
function __getAlpha(style: easeStyle, direction: easeDirection, schedule: number): number
    local function linear(): number
        return schedule;
    end;

    local function quadIn(): number
        return schedule * schedule;
    end;

    local function quadOut(): number
        return 1 - (1 - schedule) * (1 - schedule);
    end;

    local function quadInOut(): number
        if (schedule < 0.5) then
            return 2 * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 2) / 2;
        end;
    end;

    local function cubicIn(): number
        return schedule * schedule * schedule;
    end;

    local function cubicOut(): number
        return 1 - pow(1 - schedule, 3);
    end;

    local function cubicInOut(): number
        if (schedule < 0.5) then
            return 4 * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 3) / 2;
        end;
    end;

    local function quartIn(): number
        return schedule * schedule * schedule * schedule;
    end;

    local function quartOut(): number
        return 1 - pow(1 - schedule, 4);
    end;

    local function quartInOut(): number
        if (schedule < 0.5) then
            return 8 * schedule * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 4) / 2;
        end;
    end;

    local function quintIn(): number
        return schedule * schedule * schedule * schedule * schedule;
    end;

    local function quintOut(): number
        return 1 - pow(1 - schedule, 5);
    end;

    local function quintInOut(): number
        if (schedule < 0.5) then
            return 16 * schedule * schedule * schedule * schedule * schedule;
        else
            return 1 - pow(-2 * schedule + 2, 5) / 2;
        end;
    end;

    local function sineIn(): number
        return 1 - cos((schedule * pi) / 2);
    end;

    local function sineOut(): number
        return sin((schedule * pi) / 2);
    end;

    local function sineInOut(): number
        return -(cos(schedule * pi) - 1) / 2;
    end;

    local function expoIn(): number
        if (schedule == 0) then
            return 0;
        else
            return pow(2, 10 * schedule - 10);
        end;
    end;

    local function expoOut(): number
        if (schedule == 1) then
            return 1;
        else
            return 1 - pow(2, -10 * schedule);
        end;
    end;

    local function expoInOut(): number
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

    local function circIn(): number
        return 1 - sqrt(1 - pow(schedule, 2));
    end;

    local function circOut(): number
        return sqrt(1 - pow(schedule - 1, 2));
    end;

    local function circInOut(): number
        if (schedule < 0.5) then
            return (1 - sqrt(1 - pow(2 * schedule, 2))) / 2;
        else
            return (sqrt(1 - pow(-2 * schedule, 2)) + 1) / 2;
        end;
    end;

    local function elasticIn(): number
        local A: number = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A);
        end;
    end;

    local function elasticOut(): number
        local A: number = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1;
        end;
    end;

    local function elasticInOut(): number
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

    local function backIn(): number
        local A: number = 1.70158;
        local B: number = A + 1;

        return B * schedule * schedule * schedule - A * schedule * schedule;
    end;

    local function backOut(): number
        local A: number = 1.70158;
        local B: number = A + 1;

        return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2);
    end;

    local function backInOut(): number
        local A: number = 1.70158;
        local B: number = A * 1.525;

        if (schedule < 0.5) then
            return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2;
        else
            return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2;
        end;
    end;

    local function bounceOut(bSchedule: number?): number
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

    local function bounceIn(): number
        return 1 - bounceOut(1 - schedule);
    end;

    local function bounceInOut(): number
        if (schedule < 0.5) then
            return (1 - bounceOut(1 - 2 * schedule)) / 2;
        else
            return (1 + bounceOut(1 - 2 * schedule)) / 2;
        end;
    end;

    local map: table = {
        ["LinearIn"] = linear;
        ["LinearOut"] = linear;
        ["LinearInOut"] = linear;
        ["QuadIn"] = quadIn;
        ["QuadOut"] = quadOut;
        ["QuadInOut"] = quadInOut;
        ["CubicIn"] = cubicIn;
        ["CubicOut"] = cubicOut;
        ["CubicInOut"] = cubicInOut;
        ["QuartIn"] = quartIn;
        ["QuartOut"] = quartOut;
        ["QuartInOut"] = quartInOut;
        ["QuintIn"] = quintIn;
        ["QuintOut"] = quintOut;
        ["QuintInOut"] = quintInOut;
        ["SineIn"] = sineIn;
        ["SineOut"] = sineOut;
        ["SineInOut"] = sineInOut;
        ["ExpoIn"] = expoIn;
        ["ExpoOut"] = expoOut;
        ["ExpoInOut"] = expoInOut;
        ["CircIn"] = circIn;
        ["CircOut"] = circOut;
        ["CircInOut"] = circInOut;
        ["ElasticIn"] = elasticIn;
        ["ElasticOut"] = elasticOut;
        ["ElasticInOut"] = elasticInOut;
        ["BackIn"] = backIn;
        ["BackOut"] = backOut;
        ["BackInOut"] = backInOut;
        ["BounceIn"] = bounceIn;
        ["BounceOut"] = bounceOut;
        ["BounceInOut"] = bounceInOut;
    };

    local variant: string = format("%s%s", style, direction);

    return map[variant]();
end;

function __getLerp(variant: string, A: positionType, B: positionType, alpha: number): positionType
    local function general(A: number, B: number): number
        return A + (B - A) * alpha;
    end;

    local function color3(): positionType
        local A: Color3 = A;
        local B: Color3 = B;

        local R1: number, G1: number, B1: number = A.R, A.G, A.B;
        local R2: number, G2: number, B2: number = B.R, B.G, B.B;

        return Color3.new(general(R1, R2), general(G1, G2), general(B1, B2));
    end;

    local function colorSequenceKeypoint(): positionType
        local A: ColorSequenceKeypoint = A;
        local B: ColorSequenceKeypoint = B;

        local T1: number, T2: number = A.Time, B.Time;
        local R1: number, G1: number, B1: number = A.Value.R, A.Value.G, A.Value.B;
        local R2: number, G2: number, B2: number = B.Value.R, B.Value.G, B.Value.B;

        local color: Color3 = Color3.new(general(R1, R2), general(G1, G2), general(B1, B2));

        return ColorSequenceKeypoint.new(general(T1, T2), color);
    end;

    local function dateTime(): positionType
        local A: DateTime = A;
        local B: DateTime = B;

        local T1: number, T2: number = A.UnixTimestampMillis, B.UnixTimestampMillis;

        return DateTime.fromUnixTimestampMillis(general(T1, T2));
    end;

    local function numberRange(): positionType
        local A: NumberRange = A;
        local B: NumberRange = B;

        local Min1: number, Min2: number = A.Min, B.Min;
        local Max1: number, Max2: number = A.Max, B.Max;

        return NumberRange.new(general(Min1, Min2), general(Max1, Max2));
    end;

    local function numberSequenceKeypoint(): positionType
        local A: NumberSequenceKeypoint = A;
        local B: NumberSequenceKeypoint = B;

        local E1: number, E2: number = A.Envelope, B.Envelope;
        local T1: number, T2: number = A.Time, B.Time;
        local V1: number, V2: number = A.Value, B.Value;

        return NumberSequenceKeypoint.new(general(T1, T2), general(V1, V2), general(E1, E2));
    end;

    local function ray(): positionType
        local A: Ray = A;
        local B: Ray = B;

        local D1: Vector3, D2: Vector3 = A.Direction, B.Direction;
        local O1: Vector3, O2: Vector3 = A.Origin, B.Origin;

        local V1: Vector3 = Vector3.new(general(D1.X, D2.X), general(D1.Y, D2.Y), general(D1.Z, D2.Z));
        local V2: Vector3 = Vector3.new(general(O1.X, O2.X), general(O1.Y, O2.Y), general(O1.Z, O2.Z));

        return Ray.new(V2, V1);
    end;

    local function rect(): positionType
        local A: Rect = A;
        local B: Rect = B;

        local Min1: Vector2, Min2: Vector2 = A.Min, B.Min;
        local Max1: Vector2, Max2: Vector2 = A.Max, B.Max;

        local V1: Vector2 = Vector2.new(general(Min1.X, Min2.X), general(Min1.Y, Min2.Y));
        local V2: Vector2 = Vector2.new(general(Max1.X, Max2.X), general(Max1.Y, Max2.Y));

        return Rect.new(V1, V2);
    end;

    local function region3(): positionType
        local A: Region3 = A;
        local B: Region3 = B;

        local position: Vector3 = A.CFrame.Position:Lerp(B.CFrame.Position, alpha);
        local halfSize: Vector3 = A.Size:Lerp(B.Size, alpha) / 2;

        return Region3.new(position - halfSize, position + halfSize);
    end;

    local function cframe(): positionType
        local A: CFrame = A;
        local B: CFrame = B;

        return A:Lerp(B, alpha);
    end;

    local function udim2(): positionType
        local A: UDim2 = A;
        local B: UDim2 = B;

        return A:Lerp(B, alpha);
    end;

    local function vector2(): positionType
        local A: Vector2 = A;
        local B: Vector2 = B;

        return A:Lerp(B, alpha);
    end;

    local function vector3(): positionType
        local A: Vector3 = A;
        local B: Vector3 = B;

        return A:Lerp(B, alpha);
    end;

    local map: table = {
        ["CFrame"] = cframe;
        ["Color3"] = color3;
        ["ColorSequenceKeypoint"] = colorSequenceKeypoint;
        ["DateTime"] = dateTime;
        ["number"] = general;
        ["NumberRange"] = numberRange;
        ["NumberSequenceKeypoint"] = numberSequenceKeypoint;
        ["Ray"] = ray;
        ["Rect"] = rect;
        ["Region3"] = region3;
        ["UDim2"] = udim2;
        ["Vector2"] = vector2;
        ["Vector3"] = vector3;
    };

    return map[variant](A, B);
end;

function library:Lerp(easeOption: {style: easeStyle?, direction: easeDirection?}?, A: positionType, B: positionType, schedule: number): positionType
    if (not easeOption) then
        warn("Tween-V - Warning // A empty easeOption has been given, using default");

        easeOption = {
            style = "Linear",
            direction = "In"
        };
    elseif (not easeOption.style) then
        warn("Tween-V - Warning // easeOption has given a empty style, using default");

        easeOption.style = "Linear";
    elseif (not easeOption.direction) then
        warn("Tween-V - Warning // easeOption has given a empty direction, using default");

        easeOption.direction = "In";
    end;

    local style: easeStyle, direction: easeDirection = unpack(easeOption);

    local alpha: number = __getAlpha(style, direction, schedule);
    local typeA: string, typeB: string = typeof(A), typeof(B);

    if (typeA == typeB) then
        return __getLerp(typeA, A, B, alpha);
    end;

    error("Tween-V - Error // Only same types of position can lerp!");
end;

return library;
