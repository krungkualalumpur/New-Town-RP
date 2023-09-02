--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
type Signal = Signal.Signal
type Maid = Maid.Maid
type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type ABType = "A" | "B"

export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number
}

export type PlayerData = {
    Backpack : {[number] : string},
    Vehicles : {[number] : string},
    Character : {
        Accessories : {[number] : number},
        Shirt : number,
        Pants : number,
        Face : number,
        Bundle : number,

        hasDefaultAccessories : boolean
    }
}

export type PlayerManager = {
    __index : PlayerManager,
    _Maid : Maid,

    Player : Player,
    Backpack : {[number] : ToolData<boolean>},
    Vehicles : {[number] : VehicleData},
    isLoaded : boolean,

    onLoadingComplete : Signal,

    ABValue : ABType,

    new : (player : Player, maid : Maid ?) -> PlayerManager,
    
    InsertToBackpack : (PlayerManager, tool : Instance) -> boolean,
    DeleteBackpack : (PlayerManager, toolKey : number) -> (),

    GetBackpack : (PlayerManager, hasDisplayType : boolean, hasEquipInfo : boolean) -> {[number] : BackpackUtil.ToolData<boolean ?>},
    SetBackpackEquip : (PlayerManager, isEquip : boolean, toolKey : number) -> (),

    AddVehicle : (PlayerManager, vehicleName : string) -> boolean,
    SpawnVehicle : (PlayerManager, key : number, isEquip : boolean, vehicleName : string ?, vehicleZones : Instance ?) -> (),
    DeleteVehicle : (PlayerManager, key : number) -> (),

    Destroy : (PlayerManager) -> (),

    GetData : (PlayerManager) -> PlayerData,
    SetData : (PlayerManager, PlayerData) -> boolean,

    get : (plr : Player) -> PlayerManager,
    init : (maid : Maid) -> ()
}
--constants
--variables
--references
--local functions
--class

return {}