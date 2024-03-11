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
--remotes
local ON_VEHICLE_CONTROL_EVENT = "OnVehicleControlEvent"
--variables
local KEY_VALUE_NAME = "KeyValue"
--references
local Player = Players.LocalPlayer
local SpawnedVehiclesParent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
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

local function onCharacterAdded(char : Model)
    local _maid = Maid.new()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid

    local vehicleControlMaid = _maid:GiveTask(Maid.new())
    _maid:GiveTask(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart
        if seat and seat:IsDescendantOf(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")) then
            local vehicleModel = seat.Parent
            assert(vehicleModel)
            local vehicleData = getVehicleData(vehicleModel)
            Player.CameraMaxZoomDistance = 24
            if vehicleModel:GetAttribute("Class") ~= "Vehicle" then
                return
            end
            if vehicleModel:GetAttribute("isLocked") --[[and vehicleData.OwnerId ~= Player.UserId]] then
                return
            end


            local hornSignal = vehicleControlMaid:GiveTask(Signal.new())
            local headlightSignal = vehicleControlMaid:GiveTask(Signal.new())
            local leftSignal = vehicleControlMaid:GiveTask(Signal.new())
            local rightSignal = vehicleControlMaid:GiveTask(Signal.new())
            local hazardSignal = vehicleControlMaid:GiveTask(Signal.new())

            local onMove  = vehicleControlMaid:GiveTask(Signal.new())

            local vehicleControl = VehicleControl(
                vehicleControlMaid,
                
                hornSignal,
                headlightSignal,
                leftSignal,
                rightSignal,

                hazardSignal,

                onMove
            )

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

            vehicleControlMaid:GiveTask(onMove:Connect(function(directionStr : string)
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Move", directionStr)
            end))
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