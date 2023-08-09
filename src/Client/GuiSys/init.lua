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

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

type GuiSys = {
    __index : GuiSys,
    MainUI : GuiObject,
    InteractUI : GuiObject,

    new : (maid : Maid) -> GuiSys,
    init : (maid : Maid) -> ()
}
--constants
--remotes
local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"
--variables
local Player = Players.LocalPlayer
--references
--local functions
--class
local currentGuiSys : GuiSys

local guiSys : GuiSys = {} :: any
guiSys.__index = guiSys

function guiSys.new(maid : Maid)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType> = _Value(Enum.KeyCode.E) :: any
    
    local self : GuiSys = setmetatable({}, guiSys) :: any

    local backpack = _Value(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))

    local backpackOnEquip = maid:GiveTask(Signal.new())
    local backpackOnDelete = maid:GiveTask(Signal.new())

    self.MainUI = MainUI(
        maid,
        backpack,
        
        backpackOnEquip,
        backpackOnDelete
    )

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

    self.MainUI.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    self.InteractUI.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    currentGuiSys = self

    InteractSys.init(maid, self.InteractUI :: Frame, interactKeyCode)


    maid:GiveTask(NetworkUtil.onClientEvent(UPDATE_PLAYER_BACKPACK, function(newbackpackval : {BackpackUtil.ToolData<boolean>})
        backpack:Set(newbackpackval)
    end))

    --setting default backpack to untrue it 
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    return self 
end

function guiSys.init(maid : Maid)
    local newGuiSys = guiSys.new(maid)
    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)