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

local CAR_CAMERA_ZOOM_DIST = 25
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
            local hasChassis = vehicleModel:FindFirstChild("Chassis")
            if hasChassis then return end

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

local function onCarSuspensionCheck()
    local _maid = Maid.new()

    local character = Player.Character 
    if not character then return end 

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid

    local vehicleSeat = humanoid.SeatPart
    if not vehicleSeat then return end 

    local vehicle = vehicleSeat.Parent
    assert(vehicle)
    local chassisModel = vehicle:FindFirstChild("Chassis") :: Model?
    assert(chassisModel)
    local wheels = chassisModel:FindFirstChild("Wheels") 
    assert(wheels)
    local chassis = chassisModel.PrimaryPart
    assert(chassis)
   
    local mass = 0

    local height = vehicle:GetAttribute("Height") 
    local suspension = vehicle:GetAttribute("Suspension") 
    local bounce = vehicle:GetAttribute("Bounce") 
    local turnSpeed = vehicle:GetAttribute("TurnSpeed") 
    local maxSpeed = vehicle:GetAttribute("Speed") 

    local throttlespeed = 0

    --local rotation = 0
    local linearVelocity = chassis:FindFirstChild("LinearVelocity") :: LinearVelocity
    local angularVelocity = chassis:FindFirstChild("AngularVelocity") :: AngularVelocity

    local alignPosition = chassis:FindFirstChild("AlignPosition") :: AlignPosition
    local alignOrientation = chassis:FindFirstChild("AlignOrientation") :: AlignOrientation

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {vehicle}

    for i, v in pairs(vehicle:GetDescendants()) do
        if v:IsA("BasePart") and not v.Massless then
            mass = mass + (v:GetMass() * 196.2)
        end
    end


    local function updateWheel(wheelModel : Model)
        local wheelPart = wheelModel:FindFirstChild("WheelPart") :: BasePart
        local thruster = wheelModel:FindFirstChild("Thruster") :: BasePart

        local realThrusterHeight = math.huge
        assert(wheelPart and thruster)

        local vectorForce = thruster:FindFirstChild("VectorForce") :: VectorForce or Instance.new("VectorForce")

        local attachment = vectorForce.Attachment0 ::Attachment or Instance.new("Attachment")
        vectorForce.Attachment0 = attachment
        vectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        vectorForce.Parent = thruster
        attachment.Parent = thruster


        local raycastResult = workspace:Raycast(thruster.Position, thruster.CFrame.UpVector*Vector3.new(0, -height, 0), raycastParams)
        if raycastResult and raycastResult.Instance.CanCollide and vehicleSeat.Occupant then
            local force = mass * suspension
            realThrusterHeight = (raycastResult.Position - thruster.Position).Magnitude--math.abs(thruster.CFrame:PointToObjectSpace(raycastResult.Position).Y)
            --local pos, normal = raycast.Position, raycast.Normal
            --local chassisWeld = thruster:FindFirstChild("ChassisWeld") :: Weld
            local damping = force/bounce -- 100 is bounce
            local rawForce = Vector3.new(0,((height - realThrusterHeight)^2) * (force / height^2),0)
            local thrusterDamping = thruster.CFrame:ToObjectSpace(CFrame.new(thruster.AssemblyLinearVelocity + thruster.Position)).Position * damping
            vectorForce.Force = rawForce - Vector3.new(0, thrusterDamping.Y, 0)	
        else
            vectorForce.Force = Vector3.new()
        end
        local wheelWeld = thruster:FindFirstChild("WheelWeld") :: Weld

        local speed = chassis.CFrame:VectorToObjectSpace(chassis.AssemblyLinearVelocity)

        local wheelIsInFront = (chassis.CFrame:Inverse()*thruster.CFrame).Position.Z < 0
        local direction = -math.sign(speed.Z)
        --if wheelIsInFront then
        --	local turnVel = (chassis.CFrame:VectorToObjectSpace(chassis.AssemblyAngularVelocity).Y*40)*direction
        --	wheelWeld.C0 = wheelWeld.C0*CFrame.Angles(0, math.rad(turnVel), 0)
        --end
        local turnVel = (chassis.CFrame:VectorToObjectSpace(chassis.AssemblyAngularVelocity).Y*20)*direction
        local c0 = CFrame.new(0, -math.min(realThrusterHeight, height*(if vehicleSeat.Occupant then 1 else 0.6)) + wheelPart.Size.Y*0.5, 0)*(if wheelIsInFront then CFrame.Angles(0, math.rad(turnVel), 0) else CFrame.new())
        wheelWeld.C0 = wheelWeld.C0:Lerp(c0, 0.1) --*CFrame.Angles(math.pi/2, 0, 0)
        wheelWeld.C1 = CFrame.Angles(0, math.pi, 0)

        return
    end

    local function onCarResetSpecs()

        linearVelocity.MaxAxesForce = Vector3.new()
        angularVelocity.MaxTorque = 0
        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        angularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        
    end

    local function onClientCarCleanup()
        onCarResetSpecs()
        
        --game.Players.LocalPlayer.PlayerGui.LocalScript:Destroy()
    end

    _maid:GiveTask(RunService.Stepped:Connect(function()
        if vehicleSeat.Occupant then
            if alignPosition.Enabled then return end 
            if alignOrientation.Enabled then return end

            linearVelocity.MaxAxesForce = Vector3.new()  --Vector3.one*math.huge

            local raycastResult = workspace:Raycast(chassis.Position, chassis.CFrame.UpVector*Vector3.new(0, -height*1.2, 0), raycastParams)
            if raycastResult then 
                local position, normal = raycastResult.Position, raycastResult.Normal
                local chassisHeight = math.abs(chassis.CFrame:PointToObjectSpace(raycastResult.Position).Y) --(position - chassis.Position).Magnitude

                local forwardV3 = chassis.CFrame.LookVector  -- normal:Cross(chassis.CFrame.RightVector).Unit

                local speed = chassis.CFrame:VectorToObjectSpace(chassis.AssemblyLinearVelocity)

                if vehicleSeat.Throttle ~= 0 then

                --[[local velocity = chassis.CFrame.lookVector * vehicleSeat.Throttle * maxSpeed
                chassis.AssemblyLinearVelocity = car.Chassis.AssemblyLinearVelocity:Lerp(velocity, 0.1)
                linearVelocity.MaxAxesForce = Vector3.new(0, 0, 0)]]
                    throttlespeed = math.clamp(
                        (if math.abs(speed.Z) < 3 then -speed.Z else throttlespeed) 
                            + (if math.abs(speed.Z) < 3 then 5 else 0.3)*vehicleSeat.Throttle*(1 - throttlespeed/maxSpeed), -maxSpeed*0.4, maxSpeed)
                    -- local velocity = forwardV3*throttlespeed
                    -- chassis.AssemblyLinearVelocity = chassis.AssemblyLinearVelocity:Lerp(velocity, 0.1)
                    -- linearVelocity.MaxAxesForce = Vector3.new()
                    local velocity = forwardV3*throttlespeed
                    local lerped_velocity = chassis.AssemblyLinearVelocity:Lerp(velocity, 0.1)
                    lerped_velocity = chassis.CFrame:VectorToObjectSpace(lerped_velocity)
                    lerped_velocity = chassis.CFrame:VectorToWorldSpace(Vector3.new(chassis.CFrame:VectorToObjectSpace(velocity).X, lerped_velocity.Y, lerped_velocity.Z))
                    chassis.AssemblyLinearVelocity = lerped_velocity
                    linearVelocity.MaxAxesForce = Vector3.new()
                else
                    throttlespeed = throttlespeed*0.95
                    --chassis.AssemblyLinearVelocity = car.Chassis.AssemblyLinearVelocity:Lerp(Vector3.new(), 0.05)
                    local velocity = forwardV3*throttlespeed
                    if velocity.Magnitude < 1 then
                        velocity = Vector3.new()
                    end
                    chassis.AssemblyLinearVelocity = velocity
                    --linearVelocity.VectorVelocity = Vector3.new() --chassis.CFrame:VectorToObjectSpace(velocity)
                    --linearVelocity.MaxAxesForce = Vector3.new(mass/2, mass/4, mass/2)
                end


                local rotVelocity = chassis.CFrame:VectorToWorldSpace(
                    Vector3.new(
                        vehicleSeat.Throttle * maxSpeed / 50, 
                        0, 
                        -chassis.AssemblyAngularVelocity.Y * 5 * vehicleSeat.Throttle
                    )
                )*0.3

                if math.abs(-speed.Z) > 1 then
                    rotVelocity = rotVelocity + chassis.CFrame:VectorToWorldSpace((Vector3.new(0, -vehicleSeat.Steer * (math.clamp(-speed.Z, -maxSpeed*0.5, maxSpeed*0.5)/(maxSpeed)) * turnSpeed, 0)))
                    --angularVelocity.MaxTorque = math.huge
                else
                    --angularVelocity.MaxTorque = mass/((4+2+4)/3) --math.huge --mass*12 --
                end
                angularVelocity.MaxTorque = 0
                chassis.AssemblyAngularVelocity = chassis.AssemblyAngularVelocity:Lerp(rotVelocity, 0.1)

            else
                onCarResetSpecs()
            end
            
            for _,wheelModel : Model in pairs(wheels:GetChildren()) do 
                updateWheel(wheelModel)
            end
        else
            onClientCarCleanup()
        end
    end))
    
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

            local hasChassis = false 
            if vehicleData.Class == CAR_CLASS_KEY and vehicleModel:FindFirstChild("Chassis") then
                hasChassis = true 
                onCarSuspensionCheck()
            end

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
            if vehicleData.Class == BOAT_CLASS_KEY or vehicleData.Class == CAR_CLASS_KEY then
                local VectorForce = vehicleModel.PrimaryPart:FindFirstChild("GeneratedVectorForce") :: VectorForce?
                if hasChassis == false and VectorForce then 
                    local vectorMaxForce = vehicleModel:GetAttribute("Power") or 30000
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
            end
        else
            Player.CameraMaxZoomDistance = CAR_CAMERA_ZOOM_DIST
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