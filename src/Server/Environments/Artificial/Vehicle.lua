--!strict
--services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))

local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
--types
type Maid = Maid.Maid
--constants
local VEHICLE_TAG = "Vehicle"

local BOAT_CLASS_KEY = "Boat"
local CAR_CLASS_KEY = "Vehicle"

--remotes
local SPAWN_VEHICLE = "SpawnVehicle"
--variables
--references
local CarSpawns = workspace:WaitForChild("Miscs"):WaitForChild("CarSpawns")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function playSound(soundId : number, target : Instance, isLoop : boolean)
    local _maid = Maid.new()

    local sound = Instance.new("Sound")
    sound.Looped = isLoop
    sound.Parent = target
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound:Play()

    _maid:GiveTask(sound.Ended:Connect(function()
        _maid:Destroy()
    end))
    _maid:GiveTask(sound.Destroying:Connect(function()
        _maid:Destroy()
    end))

    return sound
end

local function setupSpawnedCar(vehicleModel : Model)
    local body = vehicleModel:FindFirstChild("Body")
    if vehicleModel.PrimaryPart and body then
        for _,v in pairs(body:GetDescendants()) do
            if v:IsA("BasePart") then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = v
                weld.Part1 = vehicleModel.PrimaryPart
                weld.Parent = vehicleModel.PrimaryPart
                v.CanCollide = false
            elseif v:IsA("WeldConstraint") then
                v:Destroy()
            end
        end
    end
end

local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
    local function vehicleSetup(vehicleModel : Instance)
        local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
        local vehicleSpeed = vehicleModel:GetAttribute("Speed") or 45
        
        if vehicleModel:IsA("Model") and vehicleSeat and vehicleSeat:IsA("VehicleSeat") and vehicleModel.PrimaryPart then
            setupSpawnedCar(vehicleModel)
            
            local _maid = Maid.new()
            
            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
                if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    vehicleSeat.AssemblyLinearVelocity += vehicleSeat.CFrame.LookVector*vehicleSeat.Throttle*6 
                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then 
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model

                    if seat and wheels then
                        for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
                                v.AngularVelocity = seat.Throttle*convertionKpHtoVelocity((vehicleSpeed)*(if math.sign(seat.Throttle) == 1 then 1 else 0.5))
                                print(vehicleModel.PrimaryPart.CFrame:VectorToObjectSpace(vehicleModel.PrimaryPart.AssemblyLinearVelocity), " heh? ")
                                local accDir = vehicleModel.PrimaryPart.CFrame:VectorToObjectSpace(vehicleModel.PrimaryPart.AssemblyLinearVelocity).Z
                                if seat.Throttle ~= 0 then
                                    v.MotorMaxAcceleration = if math.sign(accDir*seat.Throttle) == 1 then 60 else 15
                                    if math.sign(accDir*seat.Throttle) == 1 then
                                        v.AngularVelocity = 0
                                    end
                                else
                                    v.MotorMaxAcceleration = 1
                                end
                            end
                        end
                    end
                end
            end))

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function()
                if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    vehicleSeat.AssemblyAngularVelocity += Vector3.new(0,0.5,0)*-vehicleSeat.Steer
                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat ?
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model ?

                    if seat and wheels then
                        for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint")  and v.ActuatorType == Enum.ActuatorType.Servo then    
                                local velocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude
                                
                                if velocity < convertionKpHtoVelocity(10) then
                                    v.TargetAngle = 60*seat.Steer
                                    v.AngularSpeed = 1*3
                                elseif velocity < convertionKpHtoVelocity(20) then
                                    v.TargetAngle = 55*seat.Steer
                                    v.AngularSpeed = 1*4
                                elseif velocity >= convertionKpHtoVelocity(20) and velocity < convertionKpHtoVelocity(40) then
                                    v.TargetAngle = 42*seat.Steer
                                    v.AngularSpeed = 3*2
                                elseif velocity >= convertionKpHtoVelocity(40) and velocity < convertionKpHtoVelocity(60) then
                                    v.TargetAngle = 30*seat.Steer
                                    v.AngularSpeed = 3*2
                                elseif velocity >= convertionKpHtoVelocity(60) and velocity < convertionKpHtoVelocity(80) then
                                    v.TargetAngle = 25*seat.Steer
                                    v.AngularSpeed = 3*2
                                elseif velocity >= convertionKpHtoVelocity(80) then
                                    v.TargetAngle = 10*seat.Steer
                                    v.AngularSpeed = 3*2
                                end
                            end
                        end
                    end

                end
            end))

            if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                --ship physics check
                local spawnPositionValue = vehicleModel:FindFirstChild("SpawnPosition") :: CFrameValue
                if spawnPositionValue then
                    _maid:GiveTask(RunService.Stepped:Connect(function()
                        if (math.abs(vehicleModel.PrimaryPart.Orientation.Z) >= 90) then
                            --vehicleModel:PivotTo(CFrame.new(vehicleModel.PrimaryPart.Position)*CFrame.Angles(vehicleModel.PrimaryPart.Orientation.X, vehicleModel.PrimaryPart.Orientation.Y, 0))
                            vehicleModel:PivotTo(spawnPositionValue.Value)
                        end
                    end))   
                end   
                
                --create border with ship
                local defaultCollisionKey = "Default"
                local vipPlayerCollisionKey = "VIPPlayerCollision"
                local shipCollisionKey = "Ship"
                local borderCollisionKey = "Border2"

                PhysicsService:RegisterCollisionGroup(borderCollisionKey)
                PhysicsService:CollisionGroupSetCollidable(borderCollisionKey, shipCollisionKey, true)
                PhysicsService:CollisionGroupSetCollidable(defaultCollisionKey, borderCollisionKey, false)
                PhysicsService:CollisionGroupSetCollidable(vipPlayerCollisionKey, borderCollisionKey, false)

            elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                local occupantMaid = _maid:GiveTask(Maid.new())

                _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                    occupantMaid:DoCleaning()
                    
                    if vehicleSeat.Occupant then
                        playSound(912961304, vehicleModel.PrimaryPart, false)
                    
                        task.spawn(function()
                            task.wait(1)
                            local sound = occupantMaid:GiveTask(playSound(532147820, vehicleModel.PrimaryPart, true))
                            occupantMaid:GiveTask(RunService.Stepped:Connect(function()
                                sound.PlaybackSpeed = 1 + math.sqrt(vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude)/4
                            end))
                        end)
                    end
                end)) 
            end

            _maid:GiveTask(vehicleModel.Destroying:Connect(function()
                _maid:Destroy()
            end))
        end
    end
    
    --local carSpawnZone = Zone.new(CarSpawns:GetChildren(), maid)

    for _,vehicleModel in pairs(CollectionService:GetTagged(VEHICLE_TAG)) do
        vehicleSetup(vehicleModel)
    end

    CollectionService:GetInstanceAddedSignal(VEHICLE_TAG):Connect(function(inst)
        vehicleSetup(inst)
    end)


    NetworkUtil.onServerInvoke(SPAWN_VEHICLE, function(plr : Player, key : number, vehicleName : string, partZones : Instance ?)
        local plrInfo = PlayerManager.get(plr)
       -- print(carSpawnZone.ItemIsInside(v, plr.Character.PrimaryPart), " is insoide or nahhh", v)
        plrInfo:SpawnVehicle(key, true, vehicleName, partZones)
        NotificationUtil.Notify(plr, "You spawned " .. tostring(plrInfo.Vehicles[key].Name))

        MidasEventTree.Gameplay.EquipVehicle(plr)

        return nil
    end)

end

return Vehicle