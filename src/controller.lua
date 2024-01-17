--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A controller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
local create = table.create
local delay = task.delay

local library = require(script.library)
local runService = game:GetService("RunService")

local controller = {}

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
    object.threads = {}
    object.info = {
        _delay = nil,
        _repeat = nil,
        properties = nil,
        reverse = nil
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

        self.status.killed = true
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
            started = false,
            yielding = false
        }

        self.status.started = true

        local info = self.info

        _delay = _delay or info._delay
        _repeat = _repeat or info._repeat
        reverse = reverse or info.reverse

        self.info._delay = _delay
        self.info._repeat = _repeat
        self.info.reverse = reverse
        --#endregion
        --#region // tween
        local properties = info.properties
        local duration = easeOptions.duration

        local nowTime = 0

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed then self.threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if status.looped < _repeat or _repeat == -1 then
                    self.status.looped += 1
                    nowTime = 0
                elseif reverse and not status.reversed then
                    self.status.reversed = true

                    local temp = properties
                    properties = target
                    target = temp

                    nowTime = 0
                else
                    self.threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties[property], target[property], nowTime / duration)

            instance[property] = variant
            nowTime += deltaTime
        end
        --#endregion
        delay(_delay, function()
            for K, _ in pairs(target) do
                local function __main(deltaTime: number) __tween(deltaTime, K) end
                local connection = runService.Heartbeat:Connect(__main)

                self.threads[K] = connection
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

        self.status.yielding = false
    end
    --#endregion
    --#region // function - Start(_delay: number?, _repeat: number?, reverse: boolean?)
    function object:Start(_delay: number?, _repeat: number?, reverse: boolean?)
        --#region // init
        local status = self.status
        local started = status.started

        if started then return end

        self.status.started = true

        _delay = _delay or 0
        _repeat = _repeat or 0
        reverse = reverse or false

        self.info._delay = _delay
        self.info._repeat = _repeat
        self.info.reverse = reverse

        local _table = create(#target)
        local newProperties, newTarget = _table, _table

        for K, V in pairs(target) do
            K = tostring(K)

            newProperties[K] = instance[K]
            newTarget[K] = V
        end

        target = newTarget

        self.info.properties = newProperties
        --#endregion
        --#region // tween
        local info = self.info
        local properties = info.properties
        local duration = easeOptions.duration

        local nowTime = 0

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed then self.threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if status.looped < _repeat or _repeat == -1 then
                    self.status.looped += 1
                    nowTime = 0
                elseif reverse and not status.reversed then
                    self.status.reversed = true

                    local temp = properties
                    properties = target
                    target = temp

                    nowTime = 0
                else
                    self.threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties[property], target[property], nowTime / duration)

            instance[property] = variant
            nowTime += deltaTime
        end
        --#endregion
        delay(_delay, function()
            for K, _ in pairs(target) do
                local function __main(deltaTime: number) __tween(deltaTime, K) end
                local connection = runService.Heartbeat:Connect(__main)

                self.threads[K] = connection
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

        self.status.yielding = true
    end
    --#endregion
    return object
end

return controller
