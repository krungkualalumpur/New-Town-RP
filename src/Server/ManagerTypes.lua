--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
--types
type Signal = Signal.Signal
type Maid = Maid.Maid
type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type ABType = "A" | "B"

export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}

export type CharacterData = CustomizationUtil.CharacterData

export type PlayerData = {
    RoleplayBios : {
        Name : string,
        Bio : string
    },
    Backpack : {[number] : string},
    Vehicles : {[number] : string},
    Character : CustomizationUtil.CharacterData,
    CharacterSaves : {
        [number] : CustomizationUtil.CharacterData
    },
    ChatCount : number
}

export type PlayerManager = {
    __index : PlayerManager,
    _Maid : Maid,

    Player : Player,
    RoleplayBios : {
        Name : string,
        Bio : string
    },
    Backpack : {[number] : ToolData<boolean>},
    Vehicles : {[number] : VehicleData},
    CharacterSaves : {
        [number] : CustomizationUtil.CharacterData
    },
    ChatCount : number,
    
    isLoaded : boolean,

    onLoadingComplete : Signal,

    ABValue : ABType,

    new : (player : Player, maid : Maid ?) -> PlayerManager,
    
    InsertToBackpack : (PlayerManager, tool : Instance) -> boolean,
    DeleteBackpack : (PlayerManager, toolKey : number) -> (),

    GetBackpack : (PlayerManager, hasDisplayType : boolean, hasEquipInfo : boolean) -> {[number] : BackpackUtil.ToolData<boolean ?>},
    SetBackpackEquip : (PlayerManager, isEquip : boolean, toolKey : number) -> (),

    AddVehicle : (PlayerManager, vehicleName : string, isDestroyLocked : boolean) -> boolean,
    SpawnVehicle : (PlayerManager, key : number, isEquip : boolean, vehicleName : string ?, vehicleZones : Instance ?) -> (),
    DeleteVehicle : (PlayerManager, key : number) -> (),

    SetChatCount : (PlayerManager, count : number) -> (),

    SaveCharacterSlot : (PlayerManager, characterData : CharacterData ?) -> {[number] : CharacterData},
    LoadCharacterSlot : (PlayerManager, k : number) -> {[number] : CharacterData},
    DeleteCharacterSlot : (PlayerManager, k : number) -> {[number] : CharacterData},

    GetItemsCart : (PlayerManager, selectedItems : {[number] : BackpackUtil.ToolData<boolean>}, cf : CFrame) -> (),
    RemoveExistingItemsCart : (PlayerManager) -> (),

    ThrowItem : (PlayerManager, ToolData<nil>) -> nil,

    Destroy : (PlayerManager) -> (),

    GetData : (PlayerManager) -> PlayerData,
    SetData : (PlayerManager, PlayerData, isCharacterYield : boolean) -> boolean,

    get : (plr : Player) -> PlayerManager,
    init : (maid : Maid) -> ()
}
--constants
--variables
--references
--local functions
--class

return {}