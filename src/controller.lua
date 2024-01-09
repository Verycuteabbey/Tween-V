--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]
--

--// defines
type positionType =
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

local library = require(script.library)
local runService = game:GetService("RunService")

local controller = {}

--// functions
function controller:Create(
	instance: Instance,
	easeOptions: {
		style: Enum.EasingStyle | string?,
		direction: Enum.EasingDirection | string?,
		duration: number?,
		extra: { amplitude: number?, period: number? }?
	}?,
	target: table
): table
	--#region // default
	if not easeOptions then
		easeOptions = { Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1, { amplitude = 1, period = 0.3 }}
	elseif not easeOptions[1] then
		easeOptions[1] = Enum.EasingStyle.Linear
	elseif not easeOptions[2] then
		easeOptions[2] = Enum.EasingDirection.InOut
	elseif not easeOptions[3] then
		easeOptions[3] = 1
	elseif not easeOptions[4] then
		easeOptions[4] = { amplitude = 1, period = 0.3 }
	end
	--#endregion
	local object = {}

	object.threads = {}

	object.info = {
		instance = instance,
		easeOptions = easeOptions,
		properties = {},
		target = target
	}
	object.status = {
		started = false,
		yield = false
	}
	--#region // Replay
	function object:Replay()
		--#region // check
		local status = self.status

		if not status.started then return end

		status.yield = false

		self.status = status
		--#endregion
		local info = self.info
		local properties = info.properties
		local threads = self.threads

		easeOptions = info.easeOptions
		local duration = easeOptions[3]

		local nowTime = 0

		local function __tween(deltaTime: number, property: string)
			nowTime = nowTime
			status = self.status

			if status.yield then return end

			if nowTime > duration then
				threads[property]:Disconnect()
				nowTime = duration
			end

			local variant = library:Lerp(easeOptions, properties[property], target[property], nowTime / duration)
			instance[property] = variant

			nowTime += deltaTime
		end

		for K, _ in pairs(target) do
			local function __main(deltaTime: number)
				__tween(deltaTime, K)
			end

			local connection = runService.Heartbeat:Connect(__main)

			self.threads[K] = connection
		end
	end
	--#endregion
	--#region // Resume
	function object:Resume()
		local status = self.status
		local started = status.started

		if not started then return end

		self.status.yield = false
	end
	--#endregion
	--#region // Start
	function object:Start()
		--#region // check
		local status = self.status
		local started = status.started

		if started then return end

		self.status.started = true
		--#endregion
		--#region // convert
		local temp = {}

		for K, V in pairs(target) do
			K = tostring(K)

			self.info.properties[K] = self.info.instance[K]
			temp[K] = V
		end

		target = temp
		--#endregion
		local info = self.info

		easeOptions = info.easeOptions
		local duration = easeOptions[3]
		local properties = info.properties

		local nowTime = 0

		local function __tween(deltaTime: number, property: string)
			nowTime = nowTime
			status = self.status

			if status.yield then return end

			if nowTime > duration then
				self.threads[property]:Disconnect()
				nowTime = duration
			end

			local variant =
				library:Lerp(easeOptions, properties[property], target[property], nowTime / easeOptions.duration)
			instance[property] = variant

			nowTime += deltaTime
		end

		for K, _ in pairs(target) do
			local function __main(deltaTime: number)
				__tween(deltaTime, K)
			end

			local connection = runService.Heartbeat:Connect(__main)

			self.threads[K] = connection
		end
	end
	--#endregion
	--#region // Yield
	function object:Yield()
		local status = self.status

		if not status.started then return end

		status.yield = true

		self.status = status
	end
	--#endregion
	return object
end

return controller
