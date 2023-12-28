--!strict

--[[
    Mkk-Tween, easier to operate than TweenService

    @Author: VoID, smallpenguin666
    @Contributor: HarukaTea
]]

local RS = game:GetService("RunService")

local MKKTween = {}
local library = require(script.Lib)
local typeTable = {
    CFrame = CFrame.new,
    Color3 = Color3.new,
    UDim = UDim.new,
    UDim2 = UDim2.new,
    Vector2 = Vector2.new,
    Vector3 = Vector3.new
}

local cancel, spawn = task.cancel, task.spawn

export type EaseType = "Linear" | "Quad" | "Cubic" | "Quart" | "Quint" | "Sine" | "Expo" | "Circ" | "Elastic" | "Back" | "Bounce"
export type EaseDirection = "In" | "Out" | "InOut" | "OutIn"

function MKKTween:createTween(targetInstance: Instance, targetProperty: string, easeStyle: EaseType, easeDirection: EaseDirection, target, duration: number)
    local object = {}

    object.instance = targetInstance
    object.property = targetProperty
    object.suspendedTime = 0

    local propertyType = typeof(targetInstance[targetProperty])
    local lastProperty = library:transformTarget(targetInstance[targetProperty], propertyType)
    local targetResult = library:transformTarget(target, propertyType)

    local function tween()
        local nowTime = 0
        local lerpResult = {}
        local options = {easeStyle, easeDirection, {}}
        local transform = typeTable[propertyType]

        local onHeartbeat
        local common = function(deltaTime: number)
            if (nowTime >= duration) then
                object.connection:Disconnect()
                nowTime = duration
            end
            for number, index in ipairs(targetResult) do
                lerpResult[number] = library:lerpResult(options, lastProperty[number], index - lastProperty[number], duration, nowTime)
            end
            nowTime += deltaTime
            object.suspendedTime = 0
        end
        if (propertyType == "number") then
            onHeartbeat = function(deltaTime: number)
                common(deltaTime)

                targetInstance[targetProperty] = unpack(lerpResult)
            end
        else
            onHeartbeat = function(deltaTime: number)
                common(deltaTime)

                targetInstance[targetProperty] = transform(unpack(lerpResult))
            end
        end

        object.connection = RS.Heartbeat:Connect(onHeartbeat)
    end

    function object:clear()
        self:stop()
        table.clear(self)
    end
    function object:replay()
        self:stop()
        self.suspendedTime = 0
        if (self.newFunction) then
            self.thread = spawn(self.newFunction)
        else
            self.thread = spawn(tween)
        end
    end
    function object:stop()
        self.connection:Disconnect()
        cancel(self.thread)
    end
    function object:update(targetFunction)
        self.newFunction = targetFunction
    end

    local findResult = library:findTween(targetInstance, targetProperty)
    if (findResult) then
        findResult:update(tween)
        findResult:replay()
        return findResult

    else
        local resumeResult = library:resumeTween(targetInstance, targetProperty, tween)
        if (resumeResult) then
            return resumeResult

        else
            object.thread = spawn(tween)
            table.insert(library.active, object)
            return object
        end
    end
end

return MKKTween