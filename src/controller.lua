--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]
--

--// defines
local freeze = table.freeze

type easeStyle = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce"
type easeDirection = "In" | "Out" | "InOut"
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
	easeOption: { style: easeStyle?, direction: easeDirection?, duration: number? }?,
	target: table
): table
	--#region // default
	if not easeOption then
		warn("Tween-V - Warning // empty easeOptions has been given, using default")

		easeOption = {
			style = "Linear",
			direction = "In",
			duration = 1,
		}
	elseif not easeOption.style then
		warn("Tween-V - Warning // easeOptions has given a empty style, using default")

		easeOption.style = "Linear"
	elseif not easeOption.direction then
		warn("Tween-V - Warning // easeOptions has given a empty direction, using default")

		easeOption.direction = "In"
	elseif not easeOption.duration then
		warn("Tween-V - Warning // easeOptions has given a empty duration, using default")

		easeOption.duration = 1
	end
	--#endregion
	local object = {}

	object.funcs = nil
	object.threads = {}

	object.info = {
		instance = instance,
		target = target,
		easeOption = easeOption,
		properties = {},
	}
	object.status = {
		running = false,
		started = false,
		yield = false,
	}
	--#region // Replay
	function object:Replay()
        local status = self.status

		if not status.started then
			return
		end

        self.status.running = false

        local __tween = self.funcs

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
		local status = self.status :: table

		if status.running then
			return
		end

		status.yield = false

		self.status = status
	end
	--#endregion
	--#region // Start
	function object:Start()
		local info = self.info
		local instance = info.instance
		local target = info.target

		local status = self.status

		if status.started then
			return
		end

		self.status.started = true

		for K, _ in pairs(target) do
			self.properties[K] = instance[K]
		end

		local easeOption = self.info.easeOption :: table
		local properties = self.properties :: table
		local nowTime = 0

		local function __tween(deltaTime: number, property: string)
			if self.status.yield then
				return
			end

			self.status.running = true

			if nowTime > easeOption.duration then
				self.status.running = false
				self.threads[property]:Disconnect()
				nowTime = easeOption.duration :: number
			end

			instance[property] =
				library:Lerp(easeOption, properties[property], target[property], nowTime / easeOption.duration)
			nowTime += deltaTime
		end

		self.funcs = __tween

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
		local status = self.status :: table

		if not status.running then
			return
		end

		status.yield = true

		self.status = status
	end
	--#endregion
	return object
end

return freeze(controller)
