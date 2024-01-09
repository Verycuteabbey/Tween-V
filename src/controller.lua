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
	easeOptions: { style: Enum.EasingStyle?, direction: Enum.EasingDirection?, duration: number? }?,
	target: table
): table
	--#region // default
	if not easeOptions then
		easeOptions = {
			style = Enum.EasingStyle.Linear,
			direction = Enum.EasingDirection.InOut,
			duration = 1,
		}
	elseif not easeOptions.style then
		easeOptions.style = Enum.EasingStyle.Linear
	elseif not easeOptions.direction then
		easeOptions.direction = Enum.EasingDirection.InOut
	elseif not easeOptions.duration then
		easeOptions.duration = 1
	end
	--#endregion
	local object = {}

	object.func = nil
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
		local status = self.status

		if not status.started then return end

		local __tween = self.func

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

		if not status.started then return end

		status.yield = false

		self.status = status
	end
	--#endregion
	--#region // Start
	function object:Start()
		--#region // check
		local status = self.status

		if status.started then return end

		status.started = true
		self.status = status
		--#endregion
		local info = self.info
		--#region // convert
		local temp = {}

		for K, V in pairs(target) do
			K = tostring(K)

			info.properties[K] = info.instance[K]
			temp[K] = V
		end

		target = temp
		self.info = info
		--#endregion
		easeOptions = info.easeOptions
		info = self.info

		local nowTime = 0

		local function __tween(deltaTime: number, property: string)
			status = self.status

			if status.yield then return end

			if nowTime > easeOptions.duration then
				self.threads[property]:Disconnect()
				nowTime = easeOptions.duration
			end

			local variant = library:Lerp(
				easeOptions,
				info.properties[property],
				target[property],
				nowTime / easeOptions.duration
			)
			instance[property] = variant

			nowTime += deltaTime
		end

		self.func = __tween

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
