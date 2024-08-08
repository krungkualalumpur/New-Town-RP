--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local VehicleUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("VehicleUI"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("BackpackUI"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
--types
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

type ToolData = BackpackUtil.ToolData<boolean>
export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}
--constants
--variables
--references
--local functions
local function newVehicleData(
    itemType : ItemUtil.ItemType,
    class : string,
    isSpawned : boolean,
    name : string,
    ownerId : number,
    destroyLocked : boolean
) : VehicleData
    
    return {
        Type = itemType,
        Class = class,
        IsSpawned = isSpawned,
        Name = name,
        OwnerId = ownerId,
        Key = game.HttpService:GenerateGUID(false),
        DestroyLocked = destroyLocked
    }
end
--class
return function(target : CoreGui)
    local maid = Maid.new()
    local _fuse = ColdFusion.fuse(maid)
    local _Value = _fuse.Value

    local vehicleList = {
        _Value(newVehicleData(
            "Vehicle",
            "Motorcycle",
            true,
            "Motorcycle",
            12121211,
            true
        )),
        _Value(newVehicleData(
            "Vehicle",
            "Motorcycle",
            false,
            "Motorcycle",
            12121211,
            true
        )),
        _Value(newVehicleData(
            "Vehicle",
            "Motorcycle",
            false,
            "Motorcycle",
            12121211,
            true
        )),
        _Value(newVehicleData(
            "Vehicle",
            "Motorcycle",
            false,
            "Motorcycle",
            12121211,
            true
        )),
    }

    local onVehicleSpawn = maid:GiveTask(Signal.new())
    local onVehicleDelete = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())
    local out = VehicleUI(
        maid,
        vehicleList :: any,
        onVehicleSpawn,
        onVehicleDelete,
        onBack,
        
        false
    )
    out.Parent = target
    return function()
        maid:Destroy()
    end
end