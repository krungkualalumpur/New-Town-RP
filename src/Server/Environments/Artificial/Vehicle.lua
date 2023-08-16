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
--types
type Maid = Maid.Maid
--constants
local VEHICLE_TAG = "Vehicle"

local BOAT_CLASS_KEY = "Boat"

--remotes
local SPAWN_VEHICLE = "SpawnVehicle"
local DELETE_VEHICLE = "DeleteVehicle"
--variables
--references
local CarSpawns = workspace:WaitForChild("Miscs"):WaitForChild("CarSpawns")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
    local function vehicleSetup(vehicleModel)
        local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
        if vehicleModel:IsA("Model") and vehicleSeat and vehicleSeat:IsA("VehicleSeat") and vehicleModel.PrimaryPart then
            local _maid = Maid.new()
            
            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
                vehicleSeat.AssemblyLinearVelocity += vehicleSeat.CFrame.LookVector*vehicleSeat.Throttle*6 
            end))

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function()
                vehicleSeat.AssemblyAngularVelocity += Vector3.new(0,0.5,0)*-vehicleSeat.Steer
            end))

            if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                _maid:GiveTask(RunService.Stepped:Connect(function()
                    if math.abs(vehicleModel.PrimaryPart.Orientation.Z) >= 90 then
                        vehicleModel:PivotTo(CFrame.new(vehicleModel.PrimaryPart.Position)*CFrame.Angles(vehicleModel.PrimaryPart.Orientation.X, vehicleModel.PrimaryPart.Orientation.Y, 0))
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

    --create border with ship
    local defaultCollisionKey = "Default"
    local shipCollisionKey = "Ship"
    local borderCollisionKey = "Border2"

    PhysicsService:RegisterCollisionGroup(borderCollisionKey)
    PhysicsService:CollisionGroupSetCollidable(borderCollisionKey, shipCollisionKey, true)
    PhysicsService:CollisionGroupSetCollidable(defaultCollisionKey, borderCollisionKey, false)

    NetworkUtil.onServerInvoke(SPAWN_VEHICLE, function(plr : Player, key : number, vehicleName : string, partZones : Instance ?)
        print(vehicleName, " mueng")
        local plrInfo = PlayerManager.get(plr)
       -- print(carSpawnZone.ItemIsInside(v, plr.Character.PrimaryPart), " is insoide or nahhh", v)
        plrInfo:SpawnVehicle(key, true, vehicleName, partZones)
        print(key)

        return nil
    end)

    NetworkUtil.onServerInvoke(DELETE_VEHICLE, function(plr : Player, key : number)
        local plrInfo = PlayerManager.get(plr)

        print(key)
        plrInfo:DeleteVehicle(key)
        return nil
    end)
end

return Vehicle