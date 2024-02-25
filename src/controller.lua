--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A controller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// libraries
local controller = {}
local library = require()

--// defines
local deferTask, delayTask, spawnTask, waitTask = task.defer, task.delay, task.spawn, task.wait

type object = { [string]: table }
type target = { [string]: library.source }
type tweens = { table }

local tweens: tweens = {}

--// functions
function controller:Create(instance: Instance, easeOption: library.easeOption, target: target, schedule: number?): object | nil
    --#region // init
    schedule = schedule :: number or 0

    local object: object = {}
    object.properties = {
        cycles = 0,
        reverse = false,
        saved = {}
    }
    object.status = {
        cycled = 0,
        flagged = false,
        ended = false,
        reversed = false,
        schedule = schedule,
        started = false,
        yielding = false
    }

    local properties = object.properties

    for property, _ in pairs(target) do
        if not instance then return end

        properties.saved[property] = instance[property]
    end
    --#endregion
    --#region // functions
    local funcs = {}
    funcs.__index = funcs

    --#region // Kill(delay: number?)
    function funcs:Kill(delay: number)
        local status = object.status

        delay = delay :: number or 0

        delayTask(delay, function()
            status.ended = true
        end)
    end
    --#endregion
    --#region // Restart(delay: number?, cycles: number?, reverse: boolean)
    function funcs:Restart(delay: number?, cycles: number?, reverse: boolean)
        local status = object.status
        local reversed, started = status.reversed, status.started
        local saved = properties.saved

        if not started then return end
        if reversed then
            local temp = saved
            properties.stored = target
            target = temp
        end

        object.status = {
            cycled = 0,
            flagged = false,
            ended = false,
            reversed = false,
            schedule = schedule,
            started = false,
            yielding = false
        }

        properties.delay = delay :: number or 0
        properties.cycles = cycles :: number or 0
        properties.reverse = reverse :: boolean or false

        delay = properties.delay
        status = object.status

        delayTask(delay, function()
            status.started = true
        end)
    end
    --#endregion
    --#region // Resume(delay: number?)
    function funcs:Resume(delay: number?)
        local status = object.status

        delay = delay :: number or 0

        delayTask(delay, function()
            status.yielding = false
        end)
    end
    --#endregion
    --#region // Start(delay: number?, cycles: number?, reverse: boolean)
    function funcs:Start(delay: number?, cycles: number?, reverse: boolean)
        local status = object.status
        local started = status.started

        if started then return end

        properties.delay = delay :: number or 0
        properties.cycles = cycles :: number or 0
        properties.reverse = reverse :: boolean or false

        delay = properties.delay

        delayTask(delay, function()
            status.flagged = false
            status.started = true
        end)
    end
    --#endregion
    --#region // Update(deltaTime: number)
    function funcs:Update(deltaTime: number)
        local status = object.status
        local started, ended = status.started, status.ended

        if not started or ended then return end
        if not instance then status.ended = true end

        local cycled, reversed, nowSchedule = status.cycled, status.reversed, status.schedule
        local duration = easeOption[3] :: number
        local cycles, reverse, saved = properties.cycles, properties.reverse, properties.saved

        if nowSchedule > duration then
            if reverse and not reversed then
                status.reversed = true

                local temp = saved
                properties.saved = target
                target = temp

                status.schedule = schedule
            elseif cycled < cycles or cycles == -1 then
                status.cycled += 1

                if status.reversed then
                    status.reversed = false

                    local temp = saved
                    properties.saved = target
                    target = temp
                end

                status.schedule = schedule
            else
                status.ended = true
                status.schedule = duration
            end
        end

        for property, value in pairs(target) do
            local variant = library:Lerp(easeOption, saved[property], value, schedule / duration)
            instance[property] = variant
        end

        status.schedule += deltaTime
    end
    --#endregion
    --#region // Yield(delay: number?, duration: number?)
    function funcs:Yield(delay: number?, duration: number?)
        local status = object.status
        local started = status.started

        if not started then return end

        delay = delay :: number or 0
        duration = duration :: number or 0

        delayTask(delay, function()
            status.yielding = true

            if duration == 0 then return end

            local count = 0

            spawnTask(function()
                while true do
                    waitTask(1)

                    if count >= duration then break end

                    count += 1
                end

                status.yielding = false
            end)
        end)
    end
    --#endregion
    setmetatable(object, funcs)
    --#endregion
    tweens[#tweens + 1] = object
    return object
end

function controller:EaseOption(
	style: string | Enum.EasingStyle?,
	direction: string | Enum.EasingDirection?,
    duration: number?,
	extra: library.extra?
): library.easeOption
	local default = library.default

	if extra then
		extra.amplitude = extra.amplitude or default.extra.amplitude
		extra.period = extra.period or default.extra.period
	end

    style = if typeof(style) == "EnumItem" then style.Name else style :: string
	direction = if typeof(direction) == "EnumItem" then direction.Name else direction :: string

	return {
		[1] = style :: string or default.style,
		[2] = direction :: string or default.direction,
        [3] = duration :: number or default.duration,
		[4] = extra :: library.extra or default.extra
	}
end

spawnTask(function()
    while true do
        local deltaTime = waitTask()

        for _, tween in pairs(tweens) do
            local status = tween.status
            local yielding = status.yielding

            if not yielding then
                tween:Update(deltaTime)
            end
        end
    end
end)

deferTask(function()
    while true do
        waitTask(60)

        for position, tween in pairs(tweens) do
            local status = tween.status
            local flagged, started, ended = status.flagged, status.started, status.ended

            if not started and not flagged then
                status.flagged = true
            elseif flagged then
                tweens[position] = nil
            end

            if ended then
                tweens[position] = nil
            end
        end
    end
end)

return controller
