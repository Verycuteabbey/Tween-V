--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]
--

--// defines
local runService = game:GetService("RunService")

--// libraries
local library = require(script.Library)

local controller = {}

--// functions
function controller:Create(
	instance: Instance,
	easeOption: {
		style: string | Enum.EasingStyle?,
		direction: string | Enum.EasingDirection?,
		duration: number?
	}?,
	target: table
): table
	--#region // init
	local default = library.default :: table

	easeOption = easeOption or default
	easeOption.style = easeOption.style or default.style
	easeOption.direction = easeOption.direction or default.direction
	easeOption.duration = easeOption.duration or default.duration

	local object = {}
	object.current = {}
	object.status = {
		started = false,
		yield = false
	}
	object.threads = {}

	for K, _ in pairs(target) do object.current[K] = instance[K] end
	--#endregion
	--#region // Replay
	function object:Replay()
		--#region // check
		local status = self.status

		if not status.started then return end
		status.yield = false
		--#endregion
		local current = self.current
		local duration = easeOption.duration
		local threads = self.threads

		local nowTime = 0

		local function __tween(deltaTime: number, property: string)
			nowTime = nowTime
			status = self.status

			if status.yield then return end

			if nowTime > duration then
				threads[property]:Disconnect()
				nowTime = duration
			end

			local variant = library:Lerp(easeOption, current[property], target[property], nowTime / duration)
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

		if not status.started then return end
		status.yield = false
	end
	--#endregion
	--#region // Start
	function object:Start()
		--#region // check
		local status = self.status

		if status.started then return end
		status.started = true
		--#endregion
		local current = self.current
		local duration = easeOption.duration

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
				library:Lerp(easeOption, current[property], target[property], nowTime / duration)
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
	end
	--#endregion
	return object
end

return controller
