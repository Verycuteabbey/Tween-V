--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A controller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local delay, spawn, wait = task.delay, task.spawn, task.wait

local controller = {}
controller.tween = {}

--// libraries
local parent = script.Parent
local library = require(parent.Library)

--// functions
function controller:Create(
    instance: Instance,
    easeOption: { [number]: Enum | number | string | table },
    target: table,
    schedule: number?
): table
	--#region // init
	schedule = schedule or 0

	local object = {}
	object.info = {
		current = {}
	}
	object.status = {
		ended = false,
		looped = 0,
		reversed = false,
		started = false,
		yielding = false
	}

	local funcs = {}
	funcs.__index = funcs

	local info = object.info

	for K, _ in pairs(target) do info.current[K] = instance[K] end
	--#endregion
	--#region // function - Kill(_delay: number?)
	function funcs:Kill(_delay: number?)
		local status = self.status

		if not status.started then return end

		delay(_delay, function()
			status.ended = true
		end)
	end
	--#endregion
	--#region // function - Replay(_delay: number?, _repeat: number?, reverse: boolean?)
	function funcs:Replay(_delay: number?, _repeat: number?, reverse: boolean?)
		--#region // init
		local status = self.status

		if not status.started then return end

		self.status = {
            ended = false,
            looped = 0,
            reversed = false,
            started = false,
            yielding = false
        }

		_delay = _delay or info._delay
		_repeat = _repeat or info._repeat
		reverse = reverse or info.reverse
		info._delay = _delay
		info._repeat = _repeat
		info.reverse = reverse
		--#endregion
		--#region // tween
		local current = info.current
		local duration = easeOption[3] :: number

        local nowTime = schedule :: number

		local function __tween()
			status = self.status

            if not instance or status.yielding then return end

            if nowTime > duration then
                if reverse and not status.reversed then
                    status.reversed = true

                    local temp = current
                    current = target
                    target = temp

                    nowTime = schedule
                elseif status.looped < _repeat or _repeat == -1 then
                    status.looped += 1

                    if status.reversed then
                        status.reversed = false

                        local temp = current
                        current = target
                        target = temp
                    end

                    nowTime = schedule
                else
                    status.ended = true
                    nowTime = duration
                end
            end

            for K, V in pairs(target) do
                local variant = library:Lerp(easeOption, current[K], V, nowTime / duration)
                instance[K] = variant
            end

            if status.ended and status.reversed then
                status.reversed = false

                local temp = current
                current = target
                target = temp

                return
            end

            local deltaTime = wait()
            nowTime += deltaTime
		end
		--#endregion
		delay(_delay, function()
			self.Update = __tween
		end)
	end
	--#endregion
	--#region // function - Resume(_delay: number?)
	function funcs:Resume(_delay: number?)
		local status = self.status

		if not status.started then return end
		if status.killed then return end

		delay(_delay, function()
			status.yielding = false
		end)
	end
	--#endregion
	--#region // function - Start(_delay: number?, _repeat: number?, reverse: boolean?)
	function funcs:Start(_delay: number?, _repeat: number?, reverse: boolean?)
		--#region // init
		local status = self.status

		if status.started then return end
		status.started = true

		_delay = _delay or 0
		_repeat = _repeat or 0
		reverse = reverse or false
		info._delay = _delay
		info._repeat = _repeat
		info.reverse = reverse
		--#endregion
		--#region // tween
		local current = info.current
		local duration = easeOption[3] :: number

        local nowTime = schedule :: number

		local function __tween()
			status = self.status

            if not instance or status.yielding then return end

            if nowTime > duration then
                if reverse and not status.reversed then
                    status.reversed = true

                    local temp = current
                    current = target
                    target = temp

                    nowTime = schedule
                elseif status.looped < _repeat or _repeat == -1 then
                    status.looped += 1

                    if status.reversed then
                        status.reversed = false

                        local temp = current
                        current = target
                        target = temp
                    end

                    nowTime = schedule
                else
                    status.ended = true
                    nowTime = duration
                end
            end

            for K, V in pairs(target) do
                local variant = library:Lerp(easeOption, current[K], V, nowTime / duration)
                instance[K] = variant
            end

            if status.ended and status.reversed then
                status.reversed = false

                local temp = current
                current = target
                target = temp

                return
            end

            local deltaTime = wait()
            nowTime += deltaTime
		end
		--#endregion
		delay(_delay, function()
			self.Update = __tween
		end)
	end
	--#endregion
	--#region // function - Yield(_delay: number?)
	function funcs:Yield(_delay: number?)
		local status = self.status

		if not status.started then return end

		delay(_delay, function()
			status.yielding = true
		end)
	end
	--#endregion
	setmetatable(object, funcs)
	controller.tween[#controller.tween + 1] = object

	return object
end

function controller:EaseOption(
	style: string | Enum.EasingStyle?,
	direction: string | Enum.EasingDirection?,
	duration: number?,
	extra: { amplitude: number?, period: number? }?
): table
	return library:EaseOption(style, direction, duration, extra)
end

spawn(function()
	while true do
		for position, tween in pairs(controller.tween) do
			local status = tween.status

			if status.ended then
				controller.tween[position] = nil
			end

			tween:Update()
		end

		wait()
	end
end)

return controller
