--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A library for controller


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]
--

--// defines
local asin, cos, pi, pow, sin, sqrt = math.asin, math.cos, math.pi, math.pow, math.sin, math.sqrt
local format = string.format
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

--// functions
local function __getAlpha(style: Enum.EasingStyle | string, direction: Enum.EasingDirection | string, schedule: number, ...)
    --#region // style
    local function __linear(_schedule: number) return _schedule end
    local function __quad(_schedule: number) return _schedule * _schedule end
    local function __cubic(_schedule: number) return _schedule * _schedule * _schedule end
    local function __quart(_schedule: number) return _schedule * _schedule * _schedule * _schedule end
    local function __quint(_schedule: number) return _schedule * _schedule * _schedule * _schedule * _schedule end
    local function __sine(_schedule: number) return -cos(_schedule * (pi * 0.5)) + 1 end
    local function __expo(_schedule: number) return 2 ^ (10 * (_schedule - 1)) end
    local function __circ(_schedule: number) return -(sqrt(1 - _schedule * _schedule) - 1) end
    local function __elastic(_schedule: number, amplitude: number, period: number)
        if _schedule == 0 then return 0 end
        if _schedule == 1 then return 1 end

        local A: number

        period = period or 0.3

        if not amplitude or amplitude < 1 then
            amplitude = 1
            A = period / 4
        else
            A = period / (2 * pi) * asin(1 / amplitude)
        end

        _schedule -= 1

        return -(amplitude * 2 ^ (10 * _schedule) * sin((_schedule - A) * (2 * pi) / period))
    end
    local function __back(_schedule: number) return _schedule * _schedule * (2.7 * _schedule - 1.7) end
    local function __bounce(_schedule: number)
        if _schedule < 1 / 2.75 then
            return 7.5625 * _schedule * _schedule
        elseif _schedule < 2 / 2.75 then
            _schedule -= 1.5 / 2.75

            return 7.5625 * _schedule * _schedule + 0.75
        elseif _schedule < 2.5 / 2.75 then
            _schedule -= 2.25 / 2.75

            return 7.5625 * _schedule * _schedule + 0.9375
        else
            _schedule -= 2.625 / 2.75

            return 7.5625 * _schedule * _schedule + 0.984375
        end
    end
    --#endregion
    --#region // direction
    local function __in(func, ...) return func(schedule, ...) end
    local function __out(func, ...) return 1 - func(1 - schedule, ...) end
    local function __inOut(func, ...)
        if schedule < 0.5 then
            return 0.5 * func(schedule * 2, ...)
        else
            schedule = 1 - schedule

            return 0.5 * (1 - func(schedule * 2, ...)) + 0.5
        end
    end
    local function __outIn(func, ...)
        if schedule < 0.5 then
            return 0.5 * (1 - func(1 - schedule * 2, ...))
        else
            schedule = 1 - schedule

            return 0.5 * (1 - (1 - func(1 - schedule * 2, ...))) + 0.5
        end
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
        ["OutIn"] = __outIn
    }

    local variant1 = if typeof(style) == "Enum" then match(style, "^Enum.EasingStyle%.([^-]+)$") else style
    local variant2 = if typeof(direction) == "Enum" then match(direction, "^Enum.EasingDirection%.([^-]+)$") else direction

    return map[variant2](map[variant1], ...)
end

local function __getLerp(variant: string, A: sourceType, B: sourceType, alpha: number): sourceType
    --#region // Color3
    local function __color3()
        A, B = A :: Color3, B :: Color3

        local R1, G1, B1 = A.R, A.G, A.B
        local R2, G2, B2 = B.R, B.G, B.B

        return newColor3(
            __getLerp("number", R1, R2, alpha),
            __getLerp("number", G1, G2, alpha),
            __getLerp("number", B1, B2, alpha)
        )
    end
    --#endregion
    --#region // ColorSequenceKeypoint
    local function __colorSequenceKeypoint()
        A, B = A :: ColorSequenceKeypoint, B :: ColorSequenceKeypoint

        local T1, T2 = A.Time, B.Time
        local R1, G1, B1 = A.Value.R, A.Value.G, A.Value.B
        local R2, G2, B2 = B.Value.R, B.Value.G, B.Value.B

        local color = newColor3(
            __getLerp("number", R1, R2, alpha),
            __getLerp("number", G1, G2, alpha),
            __getLerp("number", B1, B2, alpha)
        )

        return newColorSequenceKeypoint(__getLerp("number", T1, T2, alpha), color)
    end
    --#endregion
    --#region // DateTime
    local function __dateTime()
        A, B = A :: DateTime, B :: DateTime

        local T1, T2 = A.UnixTimestampMillis, B.UnixTimestampMillis

        return fromUnixTimestampMillis(__getLerp("number", T1, T2, alpha))
    end
    --#endregion
    --#region // number
    local function __number()
        A, B = A :: number, B :: number

        return A + (B - A) * alpha
    end
    --#endregion
    --#region // NumberRange
    local function __numberRange()
        A, B = A :: NumberRange, B :: NumberRange

        local Min1, Min2 = A.Min, B.Min
        local Max1, Max2 = A.Max, B.Max

        return newNumberRange(__getLerp("number", Min1, Min2, alpha), __getLerp("number", Max1, Max2, alpha))
    end
    --#endregion
    --#region // NumberSequenceKeypoint
    local function __numberSequenceKeypoint()
        A, B = A :: NumberSequenceKeypoint, B :: NumberSequenceKeypoint

        local E1, E2 = A.Envelope, B.Envelope
        local T1, T2 = A.Time, B.Time
        local V1, V2 = A.Value, B.Value

        return newNumberSequenceKeypoint(
            __getLerp("number", T1, T2, alpha),
            __getLerp("number", V1, V2, alpha),
            __getLerp("number", E1, E2, alpha)
        )
    end
    --#endregion
    --#region // Ray
    local function __ray()
        A, B = A :: Ray, B :: Ray

        local D1, D2 = A.Direction, B.Direction
        local O1, O2 = A.Origin, B.Origin

        local V1 = newVector3(
            __getLerp("number", O1.X, O2.X, alpha),
            __getLerp("number", O1.Y, O2.Y, alpha),
            __getLerp("number", O1.Z, O2.Z, alpha)
        )
        local V2 = newVector3(
            __getLerp("number", D1.X, D2.X, alpha),
            __getLerp("number", D1.Y, D2.Y, alpha),
            __getLerp("number", D1.Z, D2.Z, alpha)
        )

        return newRay(V1, V2)
    end
    --#endregion
    --#region // Rect
    local function __rect()
        A, B = A :: Rect, B :: Rect

        local Min1, Min2 = A.Min, B.Min
        local Max1, Max2 = A.Max, B.Max

        local V1 = newVector2(__getLerp("number", Min1.X, Min2.X, alpha), __getLerp("number", Min1.Y, Min2.Y, alpha))
        local V2 = newVector2(__getLerp("number", Max1.X, Max2.X, alpha), __getLerp("number", Max1.Y, Max2.Y, alpha))

        return newRect(V1, V2)
    end
    --#endregion
    --#region // Region3
    local function __region3()
        A, B = A :: Region3, B :: Region3

        local position = A.CFrame.Position:Lerp(B.CFrame.Position, alpha)
        local halfSize = A.Size:Lerp(B.Size, alpha) / 2

        return newRegion3(position - halfSize, position + halfSize)
    end
    --#endregion
    --#region // CFrame
    local function __cframe()
        A, B = A :: CFrame, B :: CFrame

        return A:Lerp(B, alpha)
    end
    --#endregion
    --#region // UDim2
    local function __udim2()
        A, B = A :: UDim2, B :: UDim2

        return A:Lerp(B, alpha)
    end
    --#endregion
    --#region // Vector2
    local function __vector2()
        A, B = A :: Vector2, B :: Vector2

        return A:Lerp(B, alpha)
    end
    --#endregion
    --#region // Vector3
    local function __vector3()
        A, B = A :: Vector3, B :: Vector3

        return A:Lerp(B, alpha)
    end
    --#endregion
    local map = {
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

    return map[variant]()
end

function library:Lerp(
    easeOptions: {
        style: Enum.EasingStyle | string?,
        direction: Enum.EasingDirection | string?,
        extra: { amplitude: number?, period: number? }?
    }?,
    A: sourceType,
    B: sourceType,
    schedule: number
): sourceType | nil
    --#region // default
    if not easeOptions then
        easeOptions = { Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, { amplitude = 1, period = 0.3 } }
    elseif not easeOptions[1] then
        easeOptions[1] = Enum.EasingStyle.Linear
    elseif not easeOptions[2] then
        easeOptions[2] = Enum.EasingDirection.InOut
    elseif not easeOptions[3] then
        easeOptions[3] = { amplitude = 1, period = 0.3 }
    end
    --#endregion
    local style, direction, extra = easeOptions[1], easeOptions[2], easeOptions[3]
    local alpha = __getAlpha(style, direction, schedule, extra.amplitude, extra.period)

    local typeA, typeB = typeof(A), typeof(B)

    if typeA ~= typeB then return end

    return __getLerp(typeA or typeB, A, B, alpha)
end

return library
