--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A library for controller


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local asin, cos, pi, sin, sqrt = math.asin, math.cos, math.pi, math.sin, math.sqrt
local fromUnixTimestampMillis = DateTime.fromUnixTimestampMillis
local newColor3 = Color3.new
local newColorSequenceKeypoint = ColorSequenceKeypoint.new
local newNumberRange = NumberRange.new
local newNumberSequenceKeypoint = NumberSequenceKeypoint.new
local newRay = Ray.new
local newRect = Rect.new
local newRegion3 = Region3.new
local newVector2 = Vector2.new
local newVector3 = Vector3.new
local match = string.match

type sourceType =
    CFrame
    | Color3
    | ColorSequenceKeypoint
    | DateTime
    | number
    | NumberRange
    | NumberSequenceKeypoint
    | Ray
    | Rect
    | Region3
    | UDim2
    | Vector2
    | Vector3

local library = {}
--#region // style
local function __linear(schedule: number): number return schedule end
local function __quad(schedule: number): number return schedule * schedule end
local function __cubic(schedule: number): number return schedule * schedule * schedule end
local function __quart(schedule: number): number return schedule * schedule * schedule * schedule end
local function __quint(schedule: number): number return schedule * schedule * schedule * schedule * schedule end
local function __sine(schedule: number): number return -cos(schedule * (pi * 0.5)) + 1 end
local function __expo(schedule: number): number return 2 ^ (10 * (schedule - 1)) end
local function __circ(schedule: number): number return -(sqrt(1 - schedule * schedule) - 1) end
local function __back(schedule: number): number return schedule * schedule * (2.7 * schedule - 1.7) end

local function __elastic(schedule: number, amplitude: number, period: number): number
    if schedule == 0 then return 0 end
    if schedule == 1 then return 1 end

    local A: number

    period = period or 0.3

    if not amplitude or amplitude < 1 then
        amplitude = 1
        A = period / 4
    else
        A = period / (2 * pi) * asin(1 / amplitude)
    end

    schedule -= 1

    return -(amplitude * 2 ^ (10 * schedule) * sin((schedule - A) * (2 * pi) / period))
end
local function __bounce(schedule: number): number
    if schedule < 1 / 2.75 then
        return 7.5625 * schedule * schedule
    elseif schedule < 2 / 2.75 then
        schedule -= 1.5 / 2.75

        return 7.5625 * schedule * schedule + 0.75
    elseif schedule < 2.5 / 2.75 then
        schedule -= 2.25 / 2.75

        return 7.5625 * schedule * schedule + 0.9375
    else
        schedule -= 2.625 / 2.75

        return 7.5625 * schedule * schedule + 0.984375
    end
end
--#endregion
--#region // direction
local function __in(func, schedule, ...): number return func(schedule, ...) end
local function __out(func, schedule, ...): number return 1 - func(1 - schedule, ...) end

local function __inOut(func, schedule, ...): number
    if schedule < 0.5 then
        return 0.5 * func(schedule * 2, ...)
    else
        schedule = 1 - schedule

        return 0.5 * (1 - func(schedule * 2, ...)) + 0.5
    end
end
local function __outIn(func, schedule, ...): number
    if schedule < 0.5 then
        return 0.5 * (1 - func(1 - schedule * 2, ...))
    else
        schedule = 1 - schedule

        return 0.5 * (1 - (1 - func(1 - schedule * 2, ...))) + 0.5
    end
end
--#endregion
--#region // lerp
local function __cframe(A: CFrame, B: CFrame, alpha: number): CFrame return A:Lerp(B, alpha) end
local function __number(A: number, B: number, alpha: number): number return A + (B - A) * alpha end
local function __udim2(A: UDim2, B: UDim2, alpha: number): UDim2 return A:Lerp(B, alpha) end
local function __vector2(A: Vector2, B: Vector2, alpha: number): Vector2 return A:Lerp(B, alpha) end
local function __vector3(A: Vector3, B: Vector3, alpha: number): Vector3 return A:Lerp(B, alpha) end

local function __color3(A: Color3, B: Color3, alpha: number): Color3
    local R1, G1, B1 = A.R, A.G, A.B
    local R2, G2, B2 = B.R, B.G, B.B

    return newColor3(
        __number(R1, R2, alpha),
        __number(G1, G2, alpha),
        __number(B1, B2, alpha)
    )
end
local function __colorSequenceKeypoint(A: ColorSequenceKeypoint, B: ColorSequenceKeypoint, alpha: number): ColorSequenceKeypoint
    local T1, T2 = A.Time, B.Time
    local R1, G1, B1 = A.Value.R, A.Value.G, A.Value.B
    local R2, G2, B2 = B.Value.R, B.Value.G, B.Value.B

    local color = newColor3(
        __number(R1, R2, alpha),
        __number(G1, G2, alpha),
        __number(B1, B2, alpha)
    )

    return newColorSequenceKeypoint(__number(T1, T2, alpha), color)
end
local function __dateTime(A: DateTime, B: DateTime, alpha: number): DateTime
    local T1, T2 = A.UnixTimestampMillis, B.UnixTimestampMillis

    return fromUnixTimestampMillis(__number(T1, T2, alpha))
end
local function __numberRange(A: NumberRange, B: NumberRange, alpha: number): NumberRange
    local Min1, Min2 = A.Min, B.Min
    local Max1, Max2 = A.Max, B.Max

    return newNumberRange(__number(Min1, Min2, alpha), __number(Max1, Max2, alpha))
end
local function __numberSequenceKeypoint(A: NumberSequenceKeypoint, B: NumberSequenceKeypoint, alpha: number): NumberSequenceKeypoint
    local E1, E2 = A.Envelope, B.Envelope
    local T1, T2 = A.Time, B.Time
    local V1, V2 = A.Value, B.Value

    return newNumberSequenceKeypoint(
        __number(T1, T2, alpha),
        __number(V1, V2, alpha),
        __number(E1, E2, alpha)
    )
end
local function __ray(A: Ray, B: Ray, alpha: number): Ray
    local D1, D2 = A.Direction, B.Direction
    local O1, O2 = A.Origin, B.Origin

    local V1 = newVector3(
        __number(O1.X, O2.X, alpha),
        __number(O1.Y, O2.Y, alpha),
        __number(O1.Z, O2.Z, alpha)
    )
    local V2 = newVector3(
        __number(D1.X, D2.X, alpha),
        __number(D1.Y, D2.Y, alpha),
        __number(D1.Z, D2.Z, alpha)
    )

    return newRay(V1, V2)
end
local function __rect(A: Rect, B: Rect, alpha: number): Rect
    local Min1, Min2 = A.Min, B.Min
    local Max1, Max2 = A.Max, B.Max

    local V1 = newVector2(__number(Min1.X, Min2.X, alpha), __number(Min1.Y, Min2.Y, alpha))
    local V2 = newVector2(__number(Max1.X, Max2.X, alpha), __number(Max1.Y, Max2.Y, alpha))

    return newRect(V1, V2)
end
local function __region3(A: Region3, B: Region3, alpha: number): Region3
    local position = A.CFrame.Position:Lerp(B.CFrame.Position, alpha)
    local halfSize = A.Size:Lerp(B.Size, alpha) / 2

    return newRegion3(position - halfSize, position + halfSize)
end
--#endregion
local map = {
    ["Linear"] = __linear,
    ["Quad"] = __quad,
    ["Cubic"] = __cubic,
    ["Quart"] = __quart,
    ["Quint"] = __quint,
    ["Sine"] = __sine,
    ["Exponential"] = __expo,
    ["Circular"] = __circ,
    ["Elastic"] = __elastic,
    ["Back"] = __back,
    ["Bounce"] = __bounce,

    ["In"] = __in,
    ["Out"] = __out,
    ["InOut"] = __inOut,
    ["OutIn"] = __outIn,

    ["CFrame"] = __cframe,
    ["Color3"] = __color3,
    ["ColorSequenceKeypoint"] = __colorSequenceKeypoint,
    ["DateTime"] = __dateTime,
    ["number"] = __number,
    ["NumberRange"] = __numberRange,
    ["NumberSequenceKeypoint"] = __numberSequenceKeypoint,
    ["Ray"] = __ray,
    ["Rect"] = __rect,
    ["Region3"] = __region3,
    ["UDim2"] = __udim2,
    ["Vector2"] = __vector2,
    ["Vector3"] = __vector3
}

--// functions
function library:Lerp(
    easeOptions: {
        style: string | Enum.EasingStyle?,
        direction: string | Enum.EasingDirection?,
        extra: { amplitude: number?, period: number? }?
    }?,
    A: sourceType,
    B: sourceType,
    schedule: number
): sourceType | nil
    --#region // init
    easeOptions = easeOptions or { style = "Linear", direction = "InOut", extra = { amplitude = 1, period = 0.3 }}
    easeOptions.style = easeOptions.style or "Linear"
    easeOptions.direction = easeOptions.direction or "InOut"
    easeOptions.extra = easeOptions.extra or { amplitude = 1, period = 0.3 }
    --#endregion
    local style, direction, extra = easeOptions.style, easeOptions.direction, easeOptions.extra
    local amplitude, period = extra.amplitude, extra.period
    local typeA, typeB = typeof(A), typeof(B)

    local variant1 = if typeof(style) == "Enum" then match(tostring(style), "^Enum.EasingStyle%.([^-]+)$") else style
    local variant2 = if typeof(direction) == "Enum" then match(tostring(direction), "^Enum.EasingDirection%.([^-]+)$") else direction

    local alpha = map[variant2](map[variant1], schedule, amplitude, period)

    if typeA ~= typeB then return end

    return map[typeA or typeB](A, B, alpha)
end

return library
