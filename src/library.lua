--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A library for controller


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]
--

--// defines
local cos, pi, pow, sin, sqrt = math.cos, math.pi, math.pow, math.sin, math.sqrt
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
library.default = {
	style = "Linear",
	direction = "InOut",
	duration = 1
}

--// functions
local function __getAlpha(style: Enum.EasingStyle | string, direction: Enum.EasingDirection | string, schedule: number)
	--#region // Linear
	local function __linear()
		return schedule
	end
	--#endregion
	--#region // Quad
	local function __quadIn()
		return schedule * schedule
	end

	local function __quadOut()
		return 1 - (1 - schedule) * (1 - schedule)
	end

	local function __quadInOut()
		if schedule < 0.5 then
			return 2 * schedule * schedule
		else
			return 1 - pow(-2 * schedule + 2, 2) / 2
		end
	end
	--#endregion
	--#region // Cubic
	local function __cubicIn()
		return schedule * schedule * schedule
	end

	local function __cubicOut()
		return 1 - pow(1 - schedule, 3)
	end

	local function __cubicInOut()
		if schedule < 0.5 then
			return 4 * schedule * schedule * schedule
		else
			return 1 - pow(-2 * schedule + 2, 3) / 2
		end
	end
	--#endregion
	--#region // Quart
	local function __quartIn()
		return schedule * schedule * schedule * schedule
	end

	local function __quartOut()
		return 1 - pow(1 - schedule, 4)
	end

	local function __quartInOut()
		if schedule < 0.5 then
			return 8 * schedule * schedule * schedule * schedule
		else
			return 1 - pow(-2 * schedule + 2, 4) / 2
		end
	end
	--#endregion
	--#region // Quint
	local function __quintIn()
		return schedule * schedule * schedule * schedule * schedule
	end

	local function __quintOut()
		return 1 - pow(1 - schedule, 5)
	end

	local function __quintInOut()
		if schedule < 0.5 then
			return 16 * schedule * schedule * schedule * schedule * schedule
		else
			return 1 - pow(-2 * schedule + 2, 5) / 2
		end
	end
	--#endregion
	--#region // Sine
	local function __sineIn()
		return 1 - cos((schedule * pi) / 2)
	end

	local function __sineOut()
		return sin((schedule * pi) / 2)
	end

	local function __sineInOut()
		return -(cos(schedule * pi) - 1) / 2
	end
	--#endregion
	--#region // Expo
	local function __expoIn()
		if schedule == 0 then
			return 0
		else
			return pow(2, 10 * schedule - 10)
		end
	end

	local function __expoOut()
		if schedule == 1 then
			return 1
		else
			return 1 - pow(2, -10 * schedule)
		end
	end

	local function __expoInOut()
		if schedule == 0 then
			return 0
		elseif schedule == 1 then
			return 1
		end

		if schedule < 0.5 then
			return pow(2, 20 * schedule - 10) / 2
		else
			return (2 - pow(2, -20 * schedule + 10)) / 2
		end
	end
	--#endregion
	--#region // Circ
	local function __circIn()
		return 1 - sqrt(1 - pow(schedule, 2))
	end

	local function __circOut()
		return sqrt(1 - pow(schedule - 1, 2))
	end

	local function __circInOut()
		if schedule < 0.5 then
			return (1 - sqrt(1 - pow(2 * schedule, 2))) / 2
		else
			return (sqrt(1 - pow(-2 * schedule, 2)) + 1) / 2
		end
	end
	--#endregion
	--#region // Elastic
	local function __elasticIn()
		local A = (2 * pi) / 3

		if schedule == 0 then
			return 0
		elseif schedule == 1 then
			return 1
		else
			return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A)
		end
	end

	local function __elasticOut()
		local A = (2 * pi) / 3

		if schedule == 0 then
			return 0
		elseif schedule == 1 then
			return 1
		else
			return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1
		end
	end

	local function __elasticInOut()
		local A = (2 * pi) / 4.5

		if schedule == 0 then
			return 0
		elseif schedule == 1 then
			return 1
		end

		if schedule < 0.5 then
			return -(pow(2, 20 * schedule - 10) * sin((20 * schedule - 11.125) * A)) / 2
		else
			return (pow(2, -20 * schedule + 10) * sin((20 * schedule - 11.125) * A)) / 2 + 1
		end
	end
	--#endregion
	--#region // Back
	local function __backIn()
		local A = 1.70158
		local B = A + 1

		return B * schedule * schedule * schedule - A * schedule * schedule
	end

	local function __backOut()
		local A = 1.70158
		local B = A + 1

		return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2)
	end

	local function __backInOut()
		local A = 1.70158
		local B = A * 1.525

		if schedule < 0.5 then
			return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2
		else
			return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2
		end
	end
	--#endregion
	--#region // Bounce
	local function __bounceOut(_schedule: number)
		local A, B = 7.5625, 2.75

		if _schedule < 1 / B then
			return A * _schedule * _schedule
		elseif _schedule < 2 / B then
			_schedule -= 1.5 / B

			return A * _schedule * _schedule + 0.75
		elseif _schedule < 2.5 / B then
			_schedule -= 2.25 / B

			return A * _schedule * _schedule + 0.9375
		else
			_schedule -= 2.625 / B

			return A * _schedule * _schedule + 0.984375
		end
	end

	local function __bounceIn()
		return 1 - __bounceOut(1 - schedule)
	end

	local function __bounceInOut()
		if schedule < 0.5 then
			return (1 - __bounceOut(1 - 2 * schedule)) / 2
		else
			return (1 + __bounceOut(1 - 2 * schedule)) / 2
		end
	end
	--#endregion
	local map = {
		["LinearIn"] = __linear,
		["LinearOut"] = __linear,
		["LinearInOut"] = __linear,
		["QuadIn"] = __quadIn,
		["QuadOut"] = __quadOut,
		["QuadInOut"] = __quadInOut,
		["CubicIn"] = __cubicIn,
		["CubicOut"] = __cubicOut,
		["CubicInOut"] = __cubicInOut,
		["QuartIn"] = __quartIn,
		["QuartOut"] = __quartOut,
		["QuartInOut"] = __quartInOut,
		["QuintIn"] = __quintIn,
		["QuintOut"] = __quintOut,
		["QuintInOut"] = __quintInOut,
		["SineIn"] = __sineIn,
		["SineOut"] = __sineOut,
		["SineInOut"] = __sineInOut,
		["ExponentialIn"] = __expoIn,
		["ExponentialOut"] = __expoOut,
		["ExponentialInOut"] = __expoInOut,
		["CircularIn"] = __circIn,
		["CircularOut"] = __circOut,
		["CircularInOut"] = __circInOut,
		["ElasticIn"] = __elasticIn,
		["ElasticOut"] = __elasticOut,
		["ElasticInOut"] = __elasticInOut,
		["BackIn"] = __backIn,
		["BackOut"] = __backOut,
		["BackInOut"] = __backInOut,
		["BounceIn"] = __bounceIn,
		["BounceOut"] = __bounceOut,
		["BounceInOut"] = __bounceInOut
	}

	local variant = format("%s%s", style, direction)

	return map[variant](schedule)
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
	easeOption: { style: string | Enum.EasingStyle?, direction: string | Enum.EasingDirection? }?,
	A: sourceType,
	B: sourceType,
	schedule: number
): sourceType | nil
	--#region // init
	local default = library.default

	easeOption = easeOption or default
	easeOption.style = easeOption.style or default.style
	easeOption.direction = easeOption.direction or default.direction
	--#endregion
	local style, direction = easeOption.style, easeOption.direction
	local typeA, typeB = typeof(A), typeof(B)

	style, direction =
		if typeof(style) == "EnumItem" then style.Name else style,
		if typeof(direction) == "EnumItem" then direction.Name else direction

	local alpha = __getAlpha(style, direction, schedule)

	if typeA ~= typeB then return end

	return __getLerp(typeA or typeB, A, B, alpha)
end

return library
