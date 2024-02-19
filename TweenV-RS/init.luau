--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A controller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--// defines
local spawn, wait = task.spawn, task.wait
local yield, create, resume = coroutine.yield, coroutine.create, coroutine.resume

local controller = {}

--// libraries
local library = require(script.Library)

--// functions
local freeThread: thread? = nil

local function functionPasser(callback, ...)
    local acquiredThread = freeThread
    freeThread = nil

    callback(...)
    freeThread = acquiredThread
end

local function functionYielder()
    while true do
        functionPasser(yield())
    end
end

local function Spawn(callback: (T...) -> (), ...: T...)
    if not freeThread then
        freeThread = create(functionYielder)

        resume(freeThread :: any)
    end

    spawn(freeThread :: thread, callback, ...)
end

--[[
    Create a new `Tween` given the object whose properties are to be tweened,
    a `TweenInfo` and a dictionary of goal property values.
]]
function controller:Create(
    instance: Instance,
    tweenInfo: TweenInfo,
    target: { [string]: any }
): table
	--#region // init
	local schedule = tweenInfo.DelayTime

	local object = {}
	object.info = {
		current = {}
	}
	object.status = {
		ended = false,
		looped = 0,
		reversed = false,
		started = false,
		yielding = false,
        uid = ""
	}

	local funcs = {}
	funcs.__index = funcs

	local info = object.info

	for K, _ in target do info.current[K] = instance[K] end

	--#region // function - Play()
	function funcs:Play()
		--#region // init
		local status = object.status

		if status.started then return end
		status.started = true

		info._delay = tweenInfo.DelayTime
		info._repeat = tweenInfo.RepeatCount
		info.reverse = tweenInfo.Reverses
		--#endregion
		--#region // tween
		local current = info.current
		local duration = tweenInfo.Time

        local nowTime = schedule :: number

		local function __tween(deltaTime)
            if not instance then return end

            if nowTime > duration then
                if info.reverse and not status.reversed then
                    status.reversed = true

                    local temp = current
                    current = target
                    target = temp

                    nowTime = schedule

                elseif status.looped < info._repeat or info._repeat == -1 then
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

            for K, V in target do
                local variant = library:Lerp(tweenInfo, current[K], V, nowTime / duration)

                instance[K] = variant
            end

            if status.ended and status.reversed then
                status.reversed = false

                local temp = current
                current = target
                target = temp

                RunService:UnbindFromRenderStep("TweenV-"..object.uid)

                return
            end

            nowTime += deltaTime
		end
		--#endregion

        --[[
            Halts playback of a Tween and resets the tween variables.
        ]]
        function funcs:Cancel()
            RunService:UnbindFromRenderStep("TweenV-"..object.uid)
        end

		Spawn(function()
            wait(schedule)
            object.uid = HttpService:GenerateGUID()

            RunService:BindToRenderStep("TweenV-"..object.uid, Enum.RenderPriority.First.Value, __tween)
		end)
	end
	--#endregion

	setmetatable(object, funcs)
	return object
end

return controller