--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local functions
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
    print(CollectionService:GetTagged("Vehicle"), " UCUP1!")
    for _,vehicleModel in pairs(CollectionService:GetTagged("Vehicle")) do
        local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
        if vehicleModel:IsA("Model") and vehicleSeat and vehicleSeat:IsA("VehicleSeat") and vehicleModel.PrimaryPart then
            local _maid = Maid.new()
            
            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
                vehicleSeat.AssemblyLinearVelocity += vehicleSeat.CFrame.LookVector*vehicleSeat.Throttle*4 
            end))
            
            _maid:GiveTask(vehicleModel.Destroying:Connect(function()
                _maid:Destroy()
            end))
            
        end
    end

    --create border with ship
    
end

return Vehicle