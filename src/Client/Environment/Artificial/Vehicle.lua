--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))

local VehicleControl = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("VehicleControl"))
--types
export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}

type Maid = Maid.Maid
--constants
local ENV_BOAT_CLASS_KEY = "EnvironmentBoat"
local CAR_CLASS_KEY = "Vehicle"
local BOAT_CLASS_KEY = "Boat"

local CUSTOM_THROTTLE_KEY = "CustomThrottle"
local CUSTOM_STEER_KEY = "CustomSteer"
--remotes
local ON_VEHICLE_CONTROL_EVENT = "OnVehicleControlEvent"
--variables
local KEY_VALUE_NAME = "KeyValue"
--references
local Player = Players.LocalPlayer
local SpawnedVehiclesParent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end

local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild(KEY_VALUE_NAME) :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class"),
        IsSpawned = model:IsDescendantOf(SpawnedVehiclesParent),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId"),
        DestroyLocked = model:GetAttribute("DestroyLocked")
    }
end

local function vehicleMovementUpdate(maid : Maid, vehicleModel : Model, movementType : "Throttle" | "Steer", movementQuantity : number ?)
    local seat = vehicleModel:FindFirstChildWhichIsA("VehicleSeat")
    local speedLimit = vehicleModel:GetAttribute("Speed") or 45

    assert(seat and vehicleModel.PrimaryPart)

    if movementType == "Throttle" then
        if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
            local customThrottleNum = movementQuantity or (if seat:IsA("VehicleSeat") then seat.Throttle else 0) :: number

            vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, customThrottleNum)
            local wheels = vehicleModel:FindFirstChild("Wheels") :: Model

            if seat and wheels then
                for _,v in pairs(wheels:GetDescendants()) do
                    if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
                        --v.MotorMaxTorque = 1--999999999999
                        v.AngularVelocity = customThrottleNum*convertionKpHtoVelocity((speedLimit)*(if math.sign(customThrottleNum) == 1 then 1 else 0.5))
                        local accDir = vehicleModel.PrimaryPart.CFrame:VectorToObjectSpace(vehicleModel.PrimaryPart.AssemblyLinearVelocity).Z
                        --task.spawn(function() task.wait(1); v.MotorMaxTorque = 1--[[550000000]]; end)
                        if customThrottleNum ~= 0 then
                            v.MotorMaxTorque = 5--999999999999
                            v.MotorMaxAcceleration = if math.sign(accDir*customThrottleNum) == 1 then 60 else 25
                            if math.sign(accDir*customThrottleNum) == 1 then
                                v.AngularVelocity = 0
                            end
                        else
                            v.MotorMaxTorque = 999999999999
                            v.MotorMaxAcceleration = 5
                            v.AngularVelocity = 0
                        end
                    end
                end
            end
        end
    else
        local customSteer =  movementQuantity or (if seat:IsA("VehicleSeat") then seat.Steer else 0) :: number

        if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
            local wheels = vehicleModel:FindFirstChild("Wheels") :: Model ?

            if seat and wheels then
                for _,v in pairs(wheels:GetDescendants()) do
                    if v:IsA("HingeConstraint")  and v.ActuatorType == Enum.ActuatorType.Servo then    
                        local velocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude

                        local targetAngle 
                        local angularSpeed
                        if velocity < convertionKpHtoVelocity(10) then
                            
                            targetAngle = 60*customSteer
                            angularSpeed = 1
                        elseif velocity < convertionKpHtoVelocity(20) then
                            targetAngle = 55*customSteer
                            angularSpeed = 1*2
                        elseif velocity >= convertionKpHtoVelocity(20) and velocity < convertionKpHtoVelocity(40) then
                            targetAngle = 42*customSteer
                            angularSpeed = 2*2
                        elseif velocity >= convertionKpHtoVelocity(40) and velocity < convertionKpHtoVelocity(60) then
                            targetAngle = 30*customSteer
                            angularSpeed = 3*2
                        elseif velocity >= convertionKpHtoVelocity(60) and velocity < convertionKpHtoVelocity(80) then
                            targetAngle = 25*customSteer
                            angularSpeed = 3*2
                        elseif velocity >= convertionKpHtoVelocity(80) then
                            targetAngle = 10*customSteer
                            angularSpeed = 3*2
                        end

                
                        local tweenTime = 1
                        if math.round(targetAngle) == 0 then angularSpeed = 25; tweenTime = 0.05 end 
                        local tween  = TweenService:Create(v, TweenInfo.new(tweenTime), {TargetAngle = targetAngle, AngularSpeed = angularSpeed})
                        tween:Play()
                    end
                end
            end
        elseif vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
            if customSteer ~= 0 then
                maid.OnRotate = RunService.Stepped:Connect(function()
                    local customThrottle = customSteer*vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
                    seat.AssemblyAngularVelocity += Vector3.new(0,0.03,0)*(-customSteer*(if customThrottle ~= 0 then customSteer*customThrottle else 1))
                end)     
            else
                maid.OnRotate = nil 
            end
        end
    end
end

local function onCharacterAdded(char : Model)
    local _maid = Maid.new()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid

    local vehicleControlMaid = _maid:GiveTask(Maid.new())
    _maid:GiveTask(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart
        if seat and seat:IsDescendantOf(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")) then
            local vehicleModel = seat.Parent :: Model?
            assert(vehicleModel and vehicleModel.PrimaryPart)
            local speedLimit = vehicleModel:GetAttribute("Speed") or 45

            local vehicleData = getVehicleData(vehicleModel)
            Player.CameraMaxZoomDistance = 26;
            if vehicleModel:GetAttribute("Class") ~= "Vehicle" then
                return
            end
            if vehicleModel:GetAttribute("isLocked") --[[and vehicleData.OwnerId ~= Player.UserId]] then
                return
            end
            vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0)


            local hornSignal = vehicleControlMaid:GiveTask(Signal.new())
            local headlightSignal = vehicleControlMaid:GiveTask(Signal.new())
            local leftSignal = vehicleControlMaid:GiveTask(Signal.new())
            local rightSignal = vehicleControlMaid:GiveTask(Signal.new())
            local hazardSignal = vehicleControlMaid:GiveTask(Signal.new())
            local waterSpraySignal = vehicleControlMaid:GiveTask(Signal.new())

            local onMove  = vehicleControlMaid:GiveTask(Signal.new())

            local vehicleControl = VehicleControl(
                vehicleControlMaid,
                
                hornSignal,
                headlightSignal,
                leftSignal,
                rightSignal,

                hazardSignal,
                if vehicleModel:WaitForChild("Body"):WaitForChild("Body"):FindFirstChild("WaterEmitter") then waterSpraySignal else nil,

                onMove
            )


            vehicleControlMaid:GiveTask(seat:GetPropertyChangedSignal("Throttle"):Connect(function()
                vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Throttle")
            end))

            vehicleControlMaid:GiveTask(seat:GetPropertyChangedSignal("Steer"):Connect(function()
                vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Steer")
            end))

            vehicleControl.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

            vehicleControlMaid:GiveTask(hornSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Horn")
            end))

            vehicleControlMaid:GiveTask(headlightSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Headlight")
            end))
            
            vehicleControlMaid:GiveTask(leftSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "LeftSignal")
            end))
            
            vehicleControlMaid:GiveTask(rightSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "RightSignal")
            end))

            vehicleControlMaid:GiveTask(hazardSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "HazardSignal")
            end))

            vehicleControlMaid:GiveTask(waterSpraySignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "WaterSpraySignal")
            end))

            vehicleControlMaid:GiveTask(onMove:Connect(function(directionStr : string)
                if directionStr == "Forward" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Throttle", 1)
                elseif directionStr == "Brake" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Throttle", 0)
                elseif directionStr =="Backward" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Throttle", -1)
                elseif directionStr == "Left" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Steer", -1)
                elseif directionStr == "Right" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Steer", 1)
                elseif directionStr == "Straight" then
                    vehicleMovementUpdate(vehicleControlMaid, vehicleModel, "Steer", 0)
                end
                --NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Move", directionStr)
            end))

            if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY or vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                local vectorMaxForce = vehicleModel:GetAttribute("Power") or 30000
                local VectorForce = vehicleModel.PrimaryPart:FindFirstChild("GeneratedVectorForce") :: VectorForce;
                vehicleControlMaid:GiveTask(RunService.Stepped:Connect(function()
                    local customThrottleNum = vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat

                    if seat then
                        local direction = math.sign(seat.CFrame.LookVector:Dot(seat.AssemblyLinearVelocity.Unit))
                        local currentVelocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude

                        VectorForce.Force = Vector3.new(0,0,-customThrottleNum*(math.clamp(vectorMaxForce - ((vectorMaxForce)*(((currentVelocity)/ speedLimit))), 0, vectorMaxForce)))
                        if customThrottleNum ~= 0 and direction ~= customThrottleNum then
                            VectorForce.Force = Vector3.new(0,0, direction*vectorMaxForce)
                        end
                    else
                        _maid:Destroy()
                    end
                end))
            end
        else
            Player.CameraMaxZoomDistance = 8
            vehicleControlMaid:DoCleaning()
        end
    end))
end
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
    local char = Player.Character or Player.CharacterAdded:Wait()
    onCharacterAdded(char)
    
    maid:GiveTask(Player.CharacterAdded:Connect(onCharacterAdded))
    return
end
return Vehicle