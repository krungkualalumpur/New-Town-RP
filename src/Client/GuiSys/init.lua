--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local InteractSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("InteractSys"))
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
local MainUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"))
local SideOptions = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("SideOptions"))
local NotificationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))

local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = ItemOptionsUI.OptInfo

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

export type VehicleData = ItemUtil.ItemInfo & {
    IsSpawned : string,
    Key : number ?
}

type GuiSys = {
    __index : GuiSys,
    _Maid : Maid,
    MainUI : GuiObject,
    NotificationUI : GuiObject,

    NotificationStatus : ValueState<string ?>,

    new : () -> GuiSys,
    Notify : (GuiSys, text : string) -> nil,
    Destroy : (GuiSys) -> nil,
    init : (maid : Maid) -> ()
}
--constants
local MAX_DISTANCE = 18

local LIST_TYPE_ATTRIBUTE = 'ListType'
--remotes
local ON_OPTIONS_OPENED = "OnOptionsOpened"
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local ADD_BACKPACK = "AddBackpack" 

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"

local SPAWN_VEHICLE = "SpawnVehicle"
local ADD_VEHICLE = "AddVehicle"
local DELETE_VEHICLE = "DeleteVehicle"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"
--variables
local Player = Players.LocalPlayer
--references
--local functions
local function getListButtonInfo(
    signal : Signal,
    buttonName : string
)
    return 
        {
            Signal = signal,
            ButtonName = buttonName
        }
    
end
--class
local currentGuiSys : GuiSys

local guiSys : GuiSys = {} :: any
guiSys.__index = guiSys

function guiSys.new()
    local maid = Maid.new()
    
    local target = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local notificationUItarget = _new("ScreenGui")({
        Name = "NotificationScreenGui",
        Parent = Player:WaitForChild("PlayerGui"),
        DisplayOrder = 10
    })

    local interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType> = _Value(Enum.KeyCode.E) :: any
    
    local self : GuiSys = setmetatable({}, guiSys) :: any
    self._Maid = maid
    self.NotificationStatus = _Value(nil :: string ?)

    local backpack = _Value(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))

    local backpackOnEquip = maid:GiveTask(Signal.new())
    local backpackOnDelete = maid:GiveTask(Signal.new())
    
    local nameCustomizationOnClick = maid:GiveTask(Signal.new()) 

    local onCharacterReset = maid:GiveTask(Signal.new())

    local MainUIStatus : ValueState<MainUI.UIStatus> = _Value(nil) :: any

    self.MainUI = MainUI(
        maid,
        backpack,
        
        MainUIStatus,

        backpackOnEquip,
        backpackOnDelete,

        nameCustomizationOnClick,
        
        onCharacterReset,

        target
    )

    maid:GiveTask(nameCustomizationOnClick:Connect(function(descType, text)
        CustomizationUtil.setDesc(Player, descType, text)
    end))

    maid:GiveTask(backpackOnEquip:Connect(function(toolKey : number, toolName : string ?)
        NetworkUtil.invokeServer(
            EQUIP_BACKPACK,
            toolKey,
            toolName
        )
    end))
    maid:GiveTask(backpackOnDelete:Connect(function(toolKey : number, toolName : string)
        NetworkUtil.invokeServer(
            DELETE_BACKPACK,
            toolKey,
            toolName
        )
    end))


    self.NotificationUI = NotificationUI(
        maid,
        self.NotificationStatus
    )


    do
        local charMaid = maid:GiveTask(Maid.new()) 

        local onSprintClick = maid:GiveTask(Signal.new())
        local sprintState = _Value(false)
        local function onCharAdded(char : Model)
            charMaid:DoCleaning()
            charMaid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
                if char:GetAttribute("IsSprinting") == true then
                    sprintState:Set(true)
                else
                    sprintState:Set(false)
                end
            end))
        end
        local sideOptionsUI = SideOptions(
            maid, 
            onSprintClick,

            sprintState
        )
        sideOptionsUI.Parent = target
        
        onCharAdded(Player.Character or Player.CharacterAdded:Wait())

        maid:GiveTask(onSprintClick:Connect(function()
            local char = Player.Character
            if char then
                char:SetAttribute("IsSprinting", not char:GetAttribute("IsSprinting"))
            end
        end))

        maid:GiveTask(Player.CharacterAdded:Connect(onCharAdded))
    end
    self.MainUI.Parent = target
    self.NotificationUI.Parent = notificationUItarget

    currentGuiSys = self

    local proxPrompt = _new("ProximityPrompt")({
        RequiresLineOfSight = false
    }) :: ProximityPrompt
    InteractSys.init(maid, proxPrompt, interactKeyCode)

    maid:GiveTask(NetworkUtil.onClientEvent(UPDATE_PLAYER_BACKPACK, function(newbackpackval : {BackpackUtil.ToolData<boolean>})
        backpack:Set(newbackpackval)
    end))

    local currentOptInfo : ValueState<OptInfo ?> = _Value(nil) :: any   
    local onItemGet = maid:GiveTask(Signal.new())

    local isExitButtonVisible = _Value(true)

    NetworkUtil.onClientInvoke(ON_OPTIONS_OPENED, function(
        listName : string,
        inst : Instance
    )
        local _maid = Maid.new()
        local _fuse = ColdFusion.fuse(_maid)
        local _new = _fuse.new
        local _import = _fuse.import
        local _bind = _fuse.bind
        local _clone = _fuse.clone
    
        local _Computed = _fuse.Computed
        local _Value = _fuse.Value
        
        local cam = workspace.CurrentCamera

        local position = _Value(UDim2.new())
        local isVisible = _Value(true)

        local list = _Value({}) 
        
        local buttonlistsInfo = {}

        if inst:GetAttribute(LIST_TYPE_ATTRIBUTE) == "Vehicle" then
            local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            if not plrIsVIP then 
                MarketplaceService:PromptGamePassPurchase(Player, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                _maid:Destroy()
                return nil 
            end
            
            list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            
            local onVehicleSpawn = maid:GiveTask(Signal.new())
            local onVehicleDelete = maid:GiveTask(Signal.new())

            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleSpawn, "Spawn"))
            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleDelete, "Delete"))

            maid:GiveTask(onVehicleSpawn:Connect(function(key, val : string)
                local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                local spawnerZones = spawnerZonesPointer.Value

                NetworkUtil.invokeServer(
                    SPAWN_VEHICLE, 
                    key,
                    val,
                    spawnerZones
                )
            end))

            maid:GiveTask(onVehicleDelete:Connect(function(key, val)
                NetworkUtil.invokeServer(
                    DELETE_VEHICLE,
                    key
                )

                list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            end))
        end

        local listUI =  ListUI(
            _maid, 
            listName, 
            list,
            position,
            isVisible,
            buttonlistsInfo
        ) :: GuiObject

        ExitButton.new(
            listUI, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        listUI.Parent = target

        _maid:GiveTask(RunService.Stepped:Connect(function()
            local worldPos 
            local pos, isOnRange
            if inst:IsA("Model") then
                local cf, _ = inst:GetBoundingBox()
                pos, isOnRange = cam:WorldToScreenPoint(cf.Position)
                worldPos = cf.Position
            elseif inst:IsA("BasePart") then
                pos, isOnRange = cam:WorldToScreenPoint(inst.Position)
                worldPos = inst.Position
            end
            if pos and (isOnRange ~= nil) then
                position:Set(UDim2.fromOffset(pos.X, pos.Y))
                isVisible:Set(isOnRange)

                if Player.Character and worldPos and ((worldPos - Player.Character.PrimaryPart.Position).Magnitude >= MAX_DISTANCE) then
                    maid.ItemOptionsUI = nil
                end
            end
        end))

        return nil
    end)

    NetworkUtil.onClientInvoke(ON_ITEM_OPTIONS_OPENED, function(
        listName : string,
        ToolsList : {[number] : OptInfo},
        interactedItem : Instance
    )
        local _maid = Maid.new()
        currentOptInfo:Set(nil)
        
        local itemOptionsUI: GuiObject = ItemOptionsUI(
            _maid,
            listName, 
            ToolsList,

            currentOptInfo,

            onItemGet,

            interactedItem
        ) :: GuiObject
        ExitButton.new(
            itemOptionsUI:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        itemOptionsUI.Parent = target

        --managing player list
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        maid.OnItemOptionsUIDestroy = itemOptionsUI.Destroying:Connect(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            maid.OnItemOptionsUIDestroy = nil
        end)

        return nil
    end)

    maid:GiveTask(onItemGet:Connect(function(inst : Instance)
        local optInfo : ItemOptionsUI.OptInfo ? = currentOptInfo:Get()
        local char = Player.Character or Player.CharacterAdded:Wait()
        
        if optInfo then
            if optInfo.Type == "Tool" then
                NetworkUtil.invokeServer(
                    ADD_BACKPACK,
                    optInfo.Name
                )
            elseif optInfo.Type == "Vehicle" then
                NetworkUtil.invokeServer(
                    ADD_VEHICLE,
                    optInfo.Name
                )
                --local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                --local spawnerZones = spawnerZonesPointer.Value
                
                --NetworkUtil.invokeServer(
                --    SPAWN_VEHICLE,
                --    optInfo.Name,
                --    spawnerZones
                --)
            end
        end
        currentOptInfo:Set(nil)
    end))

    maid:GiveTask(onCharacterReset:Connect(function()
        NetworkUtil.fireServer(ON_CHARACTER_APPEARANCE_RESET)
    end))

    --setting default backpack to untrue it 
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    return self 
end

function guiSys:Notify(text : string)
    print("Test1")
    self.NotificationStatus:Set(nil)
    print(self.NotificationStatus:Get())
    task.wait(0.1)
    self.NotificationStatus:Set(text)
    print(self.NotificationStatus:Get())
    return
end

function guiSys:Destroy()
    self._Maid:Destroy()

    local t : GuiSys = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end
    
    setmetatable(self, nil)
    return
end

function guiSys.init(maid : Maid)
    local newGuiSys = maid:GiveTask(guiSys.new())

    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)