--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
local BOAT_CLASS_KEY = "Boat"

--remotes
local SPAWN_VEHICLE = "SpawnVehicle"
--variables
--references
--local functions
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
    for _,vehicleModel in pairs(CollectionService:GetTagged("Vehicle")) do
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

    --create border with ship
    local defaultCollisionKey = "Default"
    local shipCollisionKey = "Ship"
    local borderCollisionKey = "Border2"

    PhysicsService:RegisterCollisionGroup(borderCollisionKey)
    PhysicsService:CollisionGroupSetCollidable(borderCollisionKey, shipCollisionKey, true)
    PhysicsService:CollisionGroupSetCollidable(defaultCollisionKey, borderCollisionKey, false)

    NetworkUtil.onServerInvoke(SPAWN_VEHICLE, function(plr : Player, vehicleInfo)
        print(vehicleInfo, " mueng")
        return nil
    end)
end

return Vehicle