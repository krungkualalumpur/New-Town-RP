--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local NotificationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))


local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = ItemOptionsUI.OptInfo

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

type GuiSys = {
    __index : GuiSys,
    _Maid : Maid,
    MainUI : GuiObject,
    InteractUI : GuiObject,
    NotificationUI : GuiObject,

    NotificationStatus : ValueState<string ?>,

    new : () -> GuiSys,
    Notify : (GuiSys, text : string) -> nil,
    Destroy : (GuiSys) -> nil,
    init : (maid : Maid) -> ()
}
--constants
--remotes
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local ADD_BACKPACK = "AddBackpack" 

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"
--variables
local Player = Players.LocalPlayer
--references
--local functions
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

    self.InteractUI = InteractUI(maid, interactKeyCode)

    self.NotificationUI = NotificationUI(
        maid,
        self.NotificationStatus
    )

    self.MainUI.Parent = target
    self.InteractUI.Parent = target
    self.NotificationUI.Parent = notificationUItarget
    print(self.NotificationUI, self.NotificationUI.Parent, " kok ora ene yo")

    currentGuiSys = self

    InteractSys.init(maid, self.InteractUI :: Frame, interactKeyCode)

    maid:GiveTask(NetworkUtil.onClientEvent(UPDATE_PLAYER_BACKPACK, function(newbackpackval : {BackpackUtil.ToolData<boolean>})
        backpack:Set(newbackpackval)
    end))

   local currentOptInfo : ValueState<OptInfo ?> = _Value(nil) :: any   
    local onItemGet = maid:GiveTask(Signal.new())

    local isExitButtonVisible = _Value(true)
    NetworkUtil.onClientInvoke(ON_ITEM_OPTIONS_OPENED, function(
        listName : string,
        ToolsList : {[number] : OptInfo}
    )
        currentOptInfo:Set(nil)
        
        local itemOptionsUI: GuiObject = ItemOptionsUI(
            maid,
            listName, 
            ToolsList,

            currentOptInfo,

            onItemGet
        ) :: GuiObject
        ExitButton.new(
            itemOptionsUI, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = itemOptionsUI
        itemOptionsUI.Parent = target

        return nil
    end)
   
    maid:GiveTask(onItemGet:Connect(function()
        print("kiatisuk ", currentOptInfo:Get()) 
        local optInfo : ItemOptionsUI.OptInfo ? = currentOptInfo:Get()
        local char = Player.Character or Player.CharacterAdded:Wait()
        
        if optInfo then
            NetworkUtil.invokeServer(
                ADD_BACKPACK,
                optInfo.Name
            )
            print("equip it")
        end
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