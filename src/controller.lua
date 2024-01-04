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

local library = require(script.library)
local runService = game:GetService("RunService")

local controller = {}

--// functions
function controller:Create(
	instance: Instance,
	property: string,
	easeOptions: { style: easeStyle?, direction: easeDirection?, duration: number? }?,
	target: sourceType
): table
	--#region // default
	if not easeOptions then
		warn("Tween-V - Warning // empty easeOptions has been given, using default")

		easeOptions = {
			style = "Linear",
			direction = "In",
			duration = 1,
		}
	elseif not easeOptions.style then
		warn("Tween-V - Warning // easeOptions has given a empty style, using default")

		easeOptions.style = "Linear"
	elseif not easeOptions.direction then
		warn("Tween-V - Warning // easeOptions has given a empty direction, using default")

		easeOptions.direction = "In"
	elseif not easeOptions.duration then
		warn("Tween-V - Warning // easeOptions has given a empty duration, using default")

		easeOptions.duration = 1
	end
	--#endregion
	local object = {}

	object.funcs = nil
	object.thread = nil

	object.info = {
		instance = instance,
		property = property,
		target = target,
		value = instance[property],
		easeOptions = easeOptions,
	}
	object.status = {
		running = false,
		started = false,
		yield = false,
	}
	--#region // Replay
	function object:Replay()
		if not self.funcs then
			return
		end

		self.thread:Disconnect()
		local connection = runService.Heartbeat:Connect(self.funcs)
		self.thread = connection :: RBXScriptConnection
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
		local info = self.info :: table
		local status = self.status :: table

		if status.started then
			return
		end

		status.started = true

		local easeOptions = info.easeOptions :: table
		local nowTime = 0

		local function tween(deltaTime: number)
			if status.yield then
				return
			end

			status.running = true

			if nowTime > easeOptions.duration then
				status.running = false
				self.thread:Disconnect()
				nowTime = easeOptions.duration :: number
			end

			info.instance[info.property] =
				library:Lerp(easeOptions, info.value, info.target, nowTime / easeOptions.duration)
			nowTime += deltaTime
		end

		self.funcs = tween
		local connection = runService.Heartbeat:Connect(tween)
		self.thread = connection :: RBXScriptConnection

		self.info = info
		self.status = status
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
