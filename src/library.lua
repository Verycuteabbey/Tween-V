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
    local A: number, B: number;
    --#region // Linear
    local function linear(): number
        return schedule;
    end;
    --#endregion
    --#region // Quad
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
    --#endregion
    --#region // Cubic
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
    --#endregion
    --#region // Quart
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
    --#endregion
    --#region // Quint
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
    --#endregion
    --#region // Sine
    local function sineIn(): number
        return 1 - cos((schedule * pi) / 2);
    end;

    local function sineOut(): number
        return sin((schedule * pi) / 2);
    end;

    local function sineInOut(): number
        return -(cos(schedule * pi) - 1) / 2;
    end;
    --#endregion
    --#region // Expo
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
    --#endregion
    --#region // Circ
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
    --#endregion
    --#region // Elastic
    local function elasticIn(): number
        A = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A);
        end;
    end;

    local function elasticOut(): number
        A = (2 * pi) / 3;

        if (schedule == 0) then
            return 0;
        elseif (schedule == 1) then
            return 1;
        else
            return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1;
        end;
    end;

    local function elasticInOut(): number
        A = (2 * pi) / 4.5;

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
    --#endregion
    --#region // Back
    local function backIn(): number
        A, B = 1.70158, A + 1;

        return B * schedule * schedule * schedule - A * schedule * schedule;
    end;

    local function backOut(): number
        A, B = 1.70158, A + 1;

        return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2);
    end;

    local function backInOut(): number
        A, B = 1.70158, A * 1.525;

        if (schedule < 0.5) then
            return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2;
        else
            return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2;
        end;
    end;
    --#endregion
    --#region // Bounce
    local function bounceOut(bSchedule: number): number
        A, B = 7.5625, 2.75;

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
    --#endregion
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
    --#region // Color3
    local function color3(): Color3
        A, B = A :: Color3, B :: Color3;

        local R1: number, G1: number, B1: number = A.R, A.G, A.B;
        local R2: number, G2: number, B2: number = B.R, B.G, B.B;

        return Color3.new(__getLerp("number", R1, R2, alpha), __getLerp("number", G1, G2, alpha), __getLerp("number", B1, B2, alpha));
    end;
    --#endregion
    --#region // ColorSequenceKeypoint
    local function colorSequenceKeypoint(): ColorSequenceKeypoint
        A, B = A :: ColorSequenceKeypoint, B :: ColorSequenceKeypoint;

        local T1: number, T2: number = A.Time, B.Time;
        local R1: number, G1: number, B1: number = A.Value.R, A.Value.G, A.Value.B;
        local R2: number, G2: number, B2: number = B.Value.R, B.Value.G, B.Value.B;

        local color: Color3 = Color3.new(__getLerp("number", R1, R2, alpha), __getLerp("number", G1, G2, alpha), __getLerp("number", B1, B2, alpha));

        return ColorSequenceKeypoint.new(__getLerp("number", T1, T2, alpha), color);
    end;
    --#endregion
    --#region // DateTime
    local function dateTime(): DateTime
        A, B = A :: DateTime, B :: DateTime;

        local T1: number, T2: number = A.UnixTimestampMillis, B.UnixTimestampMillis;

        return DateTime.fromUnixTimestampMillis(__getLerp("number", T1, T2, alpha));
    end;
    --#endregion
    --#region // number
    local function number(): number
        A, B = A :: number, B :: number;

        return A + (B - A) * alpha;
    end;
    --#endregion
    --#region // NumberRange
    local function numberRange(): NumberRange
        A, B = A :: NumberRange, B :: NumberRange;

        local Min1: number, Min2: number = A.Min, B.Min;
        local Max1: number, Max2: number = A.Max, B.Max;

        return NumberRange.new(__getLerp("number", Min1, Min2, alpha), __getLerp("number", Max1, Max2, alpha));
    end;
    --#endregion
    --#region // NumberSequenceKeypoint
    local function numberSequenceKeypoint(): NumberSequenceKeypoint
        A, B = A :: NumberSequenceKeypoint, B :: NumberSequenceKeypoint;

        local E1: number, E2: number = A.Envelope, B.Envelope;
        local T1: number, T2: number = A.Time, B.Time;
        local V1: number, V2: number = A.Value, B.Value;

        return NumberSequenceKeypoint.new(__getLerp("number", T1, T2, alpha), __getLerp("number", V1, V2, alpha), __getLerp("number", E1, E2, alpha));
    end;
    --#endregion
    --#region // Ray
    local function ray(): Ray
        A, B = A :: Ray, B :: Ray;

        local D1: Vector3, D2: Vector3 = A.Direction, B.Direction;
        local O1: Vector3, O2: Vector3 = A.Origin, B.Origin;

        local V1: Vector3 = Vector3.new(__getLerp("number", O1.X, O2.X, alpha), __getLerp("number", O1.Y, O2.Y, alpha), __getLerp("number", O1.Z, O2.Z, alpha));
        local V2: Vector3 = Vector3.new(__getLerp("number", D1.X, D2.X, alpha), __getLerp("number", D1.Y, D2.Y, alpha), __getLerp("number", D1.Z, D2.Z, alpha));

        return Ray.new(V1, V2);
    end;
    --#endregion
    --#region // Rect
    local function rect(): Rect
        A, B = A :: Rect, B :: Rect;

        local Min1: Vector2, Min2: Vector2 = A.Min, B.Min;
        local Max1: Vector2, Max2: Vector2 = A.Max, B.Max;

        local V1: Vector2 = Vector2.new(__getLerp("number", Min1.X, Min2.X, alpha), __getLerp("number", Min1.Y, Min2.Y, alpha));
        local V2: Vector2 = Vector2.new(__getLerp("number", Max1.X, Max2.X, alpha), __getLerp("number", Max1.Y, Max2.Y, alpha));

        return Rect.new(V1, V2);
    end;
    --#endregion
    --#region // Region3
    local function region3(): Region3
        A, B = A :: Region3, B :: Region3;

        local position: Vector3 = A.CFrame.Position:Lerp(B.CFrame.Position, alpha);
        local halfSize: Vector3 = A.Size:Lerp(B.Size, alpha) / 2;

        return Region3.new(position - halfSize, position + halfSize);
    end;
    --#endregion
    --#region // CFrame
    local function cframe(): CFrame
        A, B = A :: CFrame, B :: CFrame;

        return A:Lerp(B, alpha);
    end;
    --#endregion
    --#region // UDim2
    local function udim2(): UDim2
        A, B = A :: UDim2, B :: UDim2;

        return A:Lerp(B, alpha);
    end;
    --#endregion
    --#region // Vector2
    local function vector2(): Vector2
        A, B = A :: Vector2, B :: Vector2;

        return A:Lerp(B, alpha);
    end;
    --#endregion
    --#region // Vector3
    local function vector3(): Vector3
        A, B = A :: Vector3, B :: Vector3;

        return A:Lerp(B, alpha);
    end;
    --#endregion
    local map: table = {
        ["CFrame"] = cframe;
        ["Color3"] = color3;
        ["ColorSequenceKeypoint"] = colorSequenceKeypoint;
        ["DateTime"] = dateTime;
        ["number"] = number;
        ["NumberRange"] = numberRange;
        ["NumberSequenceKeypoint"] = numberSequenceKeypoint;
        ["Ray"] = ray;
        ["Rect"] = rect;
        ["Region3"] = region3;
        ["UDim2"] = udim2;
        ["Vector2"] = vector2;
        ["Vector3"] = vector3;
    };

    return map[variant]();
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

    local alpha: number = __getAlpha(easeOption.style, easeOption.direction, schedule);

    if (typeof(A) == typeof(B)) then
        local positionType: string = typeof(A) or typeof(B);

        return __getLerp(positionType, A, B, alpha);
    end;

    error("Tween-V - Error // Only same types of position can lerp!");
end;

return library;
