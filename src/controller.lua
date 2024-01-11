--!strict

--[[
    Tween-V // The next generation of "VCA's Tween"

    A contoller for main


    Author // VoID(@Verycuteabbey)
    Contributor // ChinoHTea(@HarukaTea), smallpenguin666
]]--

--// defines
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
    target: table,
    loop: number?,
    reverse: boolean?
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

    if not loop then
        loop = 0
    end

    if not reverse then
        reverse = false
    end
    --#endregion
    local object = {}

    object.threads = {}

    object.info = {
        instance = instance,
        loop = loop,
        reverse = reverse,
        easeOptions = easeOptions,
        properties = {},
        target = target
    }
    object.status = {
        killed = false,
        looped = 0,
        reversed = false,
        started = false,
        yielding = false
    }
    --#region // Kill
    function object:Kill()
        local status = self.status
        local started = status.started

        if not started then return end

        self.status.killed = true
    end
    --#endregion
    --#region // Replay
    function object:Replay()
        --#region // check
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
        --#endregion
        --#region // tween
        local info = self.info
        local properties = self.properties

        easeOptions = info.easeOptions
        local direction = easeOptions[2]
        local duration = easeOptions[3]

        loop = info.loop
        reverse = info.reverse

        local nowTime = 0
        local temp: table

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed then self.threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if status.looped < loop or loop == -1 then
                    self.status.looped += 1
                    nowTime = 0
                elseif reverse and not status.reversed then
                    self.status.reversed = true

                    temp = properties
                    properties = target
                    target = temp

                    if direction == "In" then
                        easeOptions[2] = "Out"
                    elseif direction == "Out" then
                        easeOptions[2] = "In"
                    elseif direction == "InOut" then
                        easeOptions[2] = "OutIn"
                    elseif direction == "OutIn" then
                        easeOptions[2] = "InOut"
                    end

                    nowTime = 0
                else
                    self.threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties[property], target[property], nowTime / easeOptions.duration)
            instance[property] = variant

            nowTime += deltaTime
        end
        --#endregion
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
        local killed = status.killed
        local started = status.started

        if not started then return end
        if killed then return end

        self.status.yielding = false
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
        --#region // tween
        local info = self.info
        local properties = self.properties

        easeOptions = info.easeOptions
        local direction = easeOptions[2]
        local duration = easeOptions[3]

        loop = info.loop
        reverse = info.reverse

        local nowTime = 0

        local function __tween(deltaTime: number, property: string)
            nowTime = nowTime
            status = self.status

            if status.killed then self.threads[property]:Disconnect() end
            if status.yielding then return end

            if nowTime > duration then
                if status.looped < loop or loop == -1 then
                    self.status.looped += 1
                    nowTime = 0
                elseif reverse and not status.reversed then
                    self.status.reversed = true

                    temp = properties
                    properties = target
                    target = temp

                    if direction == "In" then
                        easeOptions[2] = "Out"
                    elseif direction == "Out" then
                        easeOptions[2] = "In"
                    elseif direction == "InOut" then
                        easeOptions[2] = "OutIn"
                    elseif direction == "OutIn" then
                        easeOptions[2] = "InOut"
                    end

                    nowTime = 0
                else
                    self.threads[property]:Disconnect()
                    nowTime = duration
                end
            end

            local variant =
                library:Lerp(easeOptions, properties[property], target[property], nowTime / easeOptions.duration)
            instance[property] = variant

            nowTime += deltaTime
        end
        --#endregion
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
