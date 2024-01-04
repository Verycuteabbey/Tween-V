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

--// functions
local function __getAlpha(style: Enum.EasingStyle, direction: Enum.EasingDirection, schedule: number)
	--#region // Linear
	local function __linear()
		return schedule
	end
	--#endregion
	--#region // Quad
	local function __quad()
		local function __in()
			return schedule * schedule
		end
		local function __out()
			return 1 - (1 - schedule) * (1 - schedule)
		end
		local function __inOut()
			if schedule < 0.5 then
				return 2 * schedule * schedule
			else
				return 1 - pow(-2 * schedule + 2, 2) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Cubic
	local function __cubic()
		local function __in()
			return schedule * schedule * schedule
		end
		local function __out()
			return 1 - pow(1 - schedule, 3)
		end
		local function __inOut()
			if schedule < 0.5 then
				return 4 * schedule * schedule * schedule
			else
				return 1 - pow(-2 * schedule + 2, 3) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Quart
	local function __quart()
		local function __in()
			return schedule * schedule * schedule * schedule
		end
		local function __out()
			return 1 - pow(1 - schedule, 4)
		end
		local function __inOut()
			if schedule < 0.5 then
				return 8 * schedule * schedule * schedule * schedule
			else
				return 1 - pow(-2 * schedule + 2, 4) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Quint
	local function __quint()
		local function __in()
			return schedule * schedule * schedule * schedule * schedule
		end
		local function __out()
			return 1 - pow(1 - schedule, 5)
		end
		local function __inOut()
			if schedule < 0.5 then
				return 16 * schedule * schedule * schedule * schedule * schedule
			else
				return 1 - pow(-2 * schedule + 2, 5) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Sine
	local function __sine()
		local function __in()
			return 1 - cos((schedule * pi) / 2)
		end
		local function __out()
			return sin((schedule * pi) / 2)
		end
		local function __inOut()
			return -(cos(schedule * pi) - 1) / 2
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Expo
	local function __expo()
		local function __in()
			if schedule == 0 then
				return 0
			else
				return pow(2, 10 * schedule - 10)
			end
		end
		local function __out()
			if schedule == 1 then
				return 1
			else
				return 1 - pow(2, -10 * schedule)
			end
		end
		local function __inOut()
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

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Circ
	local function __circ()
		local function __in()
			return 1 - sqrt(1 - pow(schedule, 2))
		end
		local function __out()
			return sqrt(1 - pow(schedule - 1, 2))
		end
		local function __inOut()
			if schedule < 0.5 then
				return (1 - sqrt(1 - pow(2 * schedule, 2))) / 2
			else
				return (sqrt(1 - pow(-2 * schedule, 2)) + 1) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Elastic
	local function __elastic()
		local A = (2 * pi) / 3

		local function __in()
			if schedule == 0 then
				return 0
			elseif schedule == 1 then
				return 1
			else
				return pow(2, 10 * schedule - 10) * sin((schedule * 10 - 10.75) * A)
			end
		end
		local function __out()
			if schedule == 0 then
				return 0
			elseif schedule == 1 then
				return 1
			else
				return pow(2, -10 * schedule) * sin((schedule * 10 - 0.75) * A) + 1
			end
		end
		local function __inOut()
			A = (2 * pi) / 4.5

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

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Back
	local function __back()
		local A = 1.70158
        local B = A + 1

		local function __in()
			return B * schedule * schedule * schedule - A * schedule * schedule
		end
		local function __out()
			return 1 + B * pow(schedule - 1, 3) + A * pow(schedule - 1, 2)
		end
		local function __inOut()
			A, B = 1.70158, A * 1.525

			if schedule < 0.5 then
				return (pow(2 * schedule, 2) * ((B + 1) * 2 * schedule - B)) / 2
			else
				return (pow(2 * schedule - 2, 2) * ((B + 1) * (2 * schedule - 2) + B) + 2) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	--#region // Bounce
	local function __bounce()
		local function __out(bSchedule: number)
			local A, B = 7.5625, 2.75

			if bSchedule < 1 / B then
				return A * bSchedule * bSchedule
			elseif bSchedule < 2 / B then
				bSchedule -= 1.5 / B

				return A * bSchedule * bSchedule + 0.75
			elseif bSchedule < 2.5 / B then
				bSchedule -= 2.25 / B

				return A * bSchedule * bSchedule + 0.9375
			else
				bSchedule -= 2.625 / B

				return A * bSchedule * bSchedule + 0.984375
			end
		end
		local function __in()
			return 1 - __out(1 - schedule)
		end
		local function __inOut()
			if schedule < 0.5 then
				return (1 - __out(1 - 2 * schedule)) / 2
			else
				return (1 + __out(1 - 2 * schedule)) / 2
			end
		end

		local map = {
			[Enum.EasingDirection.In] = __in,
			[Enum.EasingDirection.Out] = __out,
			[Enum.EasingDirection.InOut] = __inOut,
		}

		return map[direction]()
	end
	--#endregion
	local map = {
		[Enum.EasingStyle.Linear] = __linear,
		[Enum.EasingStyle.Quad] = __quad,
		[Enum.EasingStyle.Cubic] = __cubic,
		[Enum.EasingStyle.Quart] = __quart,
		[Enum.EasingStyle.Quint] = __quint,
		[Enum.EasingStyle.Sine] = __sine,
		[Enum.EasingStyle.Exponential] = __expo,
		[Enum.EasingStyle.Circular] = __circ,
		[Enum.EasingStyle.Elastic] = __elastic,
		[Enum.EasingStyle.Back] = __back,
		[Enum.EasingStyle.Bounce] = __bounce,
	}

	return map[style]()
end

local function __getLerp(variant: string, A: sourceType, B: sourceType, alpha: number): sourceType
	--#region // Color3
	local function color3()
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
	local function colorSequenceKeypoint()
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
	local function dateTime()
		A, B = A :: DateTime, B :: DateTime

		local T1, T2 = A.UnixTimestampMillis, B.UnixTimestampMillis

		return fromUnixTimestampMillis(__getLerp("number", T1, T2, alpha))
	end
	--#endregion
	--#region // number
	local function number()
		A, B = A :: number, B :: number

		return A + (B - A) * alpha
	end
	--#endregion
	--#region // NumberRange
	local function numberRange()
		A, B = A :: NumberRange, B :: NumberRange

		local Min1, Min2 = A.Min, B.Min
		local Max1, Max2 = A.Max, B.Max

		return newNumberRange(__getLerp("number", Min1, Min2, alpha), __getLerp("number", Max1, Max2, alpha))
	end
	--#endregion
	--#region // NumberSequenceKeypoint
	local function numberSequenceKeypoint()
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
	local function ray()
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
	local function rect()
		A, B = A :: Rect, B :: Rect

		local Min1, Min2 = A.Min, B.Min
		local Max1, Max2 = A.Max, B.Max

		local V1 = newVector2(__getLerp("number", Min1.X, Min2.X, alpha), __getLerp("number", Min1.Y, Min2.Y, alpha))
		local V2 = newVector2(__getLerp("number", Max1.X, Max2.X, alpha), __getLerp("number", Max1.Y, Max2.Y, alpha))

		return newRect(V1, V2)
	end
	--#endregion
	--#region // Region3
	local function region3()
		A, B = A :: Region3, B :: Region3

		local position = A.CFrame.Position:Lerp(B.CFrame.Position, alpha)
		local halfSize = A.Size:Lerp(B.Size, alpha) / 2

		return newRegion3(position - halfSize, position + halfSize)
	end
	--#endregion
	--#region // CFrame
	local function cframe()
		A, B = A :: CFrame, B :: CFrame

		return A:Lerp(B, alpha)
	end
	--#endregion
	--#region // UDim2
	local function udim2()
		A, B = A :: UDim2, B :: UDim2

		return A:Lerp(B, alpha)
	end
	--#endregion
	--#region // Vector2
	local function vector2()
		A, B = A :: Vector2, B :: Vector2

		return A:Lerp(B, alpha)
	end
	--#endregion
	--#region // Vector3
	local function vector3()
		A, B = A :: Vector3, B :: Vector3

		return A:Lerp(B, alpha)
	end
	--#endregion
	local map = {
		["CFrame"] = cframe,
		["Color3"] = color3,
		["ColorSequenceKeypoint"] = colorSequenceKeypoint,
		["DateTime"] = dateTime,
		["number"] = number,
		["NumberRange"] = numberRange,
		["NumberSequenceKeypoint"] = numberSequenceKeypoint,
		["Ray"] = ray,
		["Rect"] = rect,
		["Region3"] = region3,
		["UDim2"] = udim2,
		["Vector2"] = vector2,
		["Vector3"] = vector3,
	}

	return map[variant]()
end

function library:Lerp(
	easeOptions: { style: Enum.EasingStyle?, direction: Enum.EasingDirection? }?,
	A: sourceType,
	B: sourceType,
	schedule: number
): sourceType | nil
	--#region // default
	if not easeOptions then
		easeOptions = {
			style = Enum.EasingStyle.Linear,
			direction = Enum.EasingDirection.InOut
		}
	elseif not easeOptions.style then
		easeOptions.style = Enum.EasingStyle.Linear
	elseif not easeOptions.direction then
		easeOptions.direction = Enum.EasingDirection.InOut
	end
	--#endregion
	local alpha = __getAlpha(easeOptions.style, easeOptions.direction, schedule)

	local typeA, typeB = typeof(A), typeof(B)
	local positionType = typeA or typeB

	if typeA ~= typeB then return end

	return __getLerp(positionType, A, B, alpha)
end

return library
