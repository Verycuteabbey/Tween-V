--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A controller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local runService = game:GetService("RunService")

local clear = table.clear
local create = table.create
local delay = task.delay

local controller = {}

--// libraries
local library = require(script.Parent.Library)

--// functions
function controller:Create(
    instance: Instance,
    easeOptions: {
        style: string | Enum.EasingStyle?,
        direction: string | Enum.EasingDirection?,
        duration: number?,
        extra: { amplitude: number?, period: number? }?
    }?,
    target: table
): table
    --#region // init
    easeOptions = easeOptions or { style = "Linear", direction = "InOut", duration = 1, extra = { amplitude = 1, period = 0.3 }}
    easeOptions.style = easeOptions.style or "Linear"
    easeOptions.direction = easeOptions.direction or "InOut"
    easeOptions.duration = easeOptions.duration or 1
    easeOptions.extra = easeOptions.extra or { amplitude = 1, period = 0.3 }

    local object = {}
    object.threads = create(#target)
    object.info = {
        _delay = nil,
        _repeat = nil,
        reverse = nil,
        properties = {}
    }
    object.status = {
        killed = false,
        looped = 0,
        reversed = false,
        started = false,
        yielding = false
    }
    --#endregion
    --#region // function - Kill()
    function object:Kill()
        local status = self.status
        local started = status.started

        if not started then return end

        status.killed = true
    end
    --#endregion
    --#region // function - Replay(_delay: number?, _repeat: number?, reverse: boolean?)
    function object:Replay(_delay: number?, _repeat: number?, reverse: boolean?)
        --#region // init
        local status = self.status
        local started = status.started

        if not started then return end

        self.status = {
            killed = false,
            looped = 0,
            reversed = false,
            started = true,
            yielding = false
        }

        local info = self.info
        local properties = info.properties

        _delay = _delay or info._delay
        _repeat = _repeat or info._repeat
        reverse = reverse or info.reverse
        info._delay = _delay
        info._repeat = _repeat
        info.reverse = reverse

        properties.now = properties.backup
        target.now = target.backup
        --#endregion
        --#region // tween
        local duration = easeOptions.duration
        local threads = self.threads

        local nowTime = 0

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed or not instance then threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if reverse and not status.reversed then
                    status.reversed = true

                    local temp = properties.now
                    properties.now = target.now
                    target.now = temp

                    nowTime = 0
                elseif status.looped < _repeat or _repeat == -1 then
                    status.looped += 1

                    if status.reversed then
                        status.reversed = false

                        properties.now = properties.backup
                        target.now = target.backup
                    end

                    nowTime = 0
                else
                    threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties.now[property], target.now[property], nowTime / duration)

            instance[property] = variant
            nowTime += deltaTime
        end
        --#endregion
        delay(_delay, function()
            for K, _ in pairs(target.now) do
                local function __main(deltaTime: number) __tween(deltaTime, K) end
                local connection = runService.Heartbeat:Connect(__main)

                threads[K] = connection
            end
        end)
    end
    --#endregion
    --#region // function - Resume()
    function object:Resume()
        local status = self.status
        local killed = status.killed
        local started = status.started

        if not started then return end
        if killed then return end

        status.yielding = false
    end
    --#endregion
    --#region // function - Start(_delay: number?, _repeat: number?, reverse: boolean?)
    function object:Start(_delay: number?, _repeat: number?, reverse: boolean?)
        --#region // init
        local info = self.info
        local status = self.status
        local started = status.started

        if started then return end

        status.started = true

        _delay = _delay or 0
        _repeat = _repeat or 0
        reverse = reverse or false
        info._delay = _delay
        info._repeat = _repeat
        info.reverse = reverse

        local newProperties, newTarget = create(#target), create(#target)

        for K, V in pairs(target) do
            K = tostring(K)

            newProperties[K] = instance[K]
            newTarget[K] = V
        end

        clear(target)
        target.backup = newTarget
        target.now = newTarget

        info.properties.backup = newProperties
        info.properties.now = newProperties
        --#endregion
        --#region // tween
        local duration = easeOptions.duration
        local properties = info.properties
        local threads = self.threads

        local nowTime = 0

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed or not instance then threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if reverse and not status.reversed then
                    status.reversed = true

                    local temp = properties.now
                    properties.now = target.now
                    target.now = temp

                    nowTime = 0
                elseif status.looped < _repeat or _repeat == -1 then
                    status.looped += 1

                    if status.reversed then
                        status.reversed = false

                        properties.now = properties.backup
                        target.now = target.backup
                    end

                    nowTime = 0
                else
                    threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties.now[property], target.now[property], nowTime / duration)

            instance[property] = variant
            nowTime += deltaTime
        end
        --#endregion
        delay(_delay, function()
            for K, _ in pairs(target.now) do
                local function __main(deltaTime: number) __tween(deltaTime, K) end
                local connection = runService.Heartbeat:Connect(__main)

                threads[K] = connection
            end
        end)
    end
    --#endregion
    --#region // function - Yield()
    function object:Yield()
        local status = self.status
        local killed = status.killed
        local started = status.started

        if not started then return end
        if killed then return end

        status.yielding = true
    end
    --#endregion
    return object
end

return controller
