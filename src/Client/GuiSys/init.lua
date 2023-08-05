--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local InteractSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("InteractSys"))
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
local MainUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"))
--types
type Maid = Maid.Maid

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
    self.MainUI = MainUI(maid)
    self.InteractUI = InteractUI(maid, interactKeyCode)

    self.MainUI.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    self.InteractUI.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    currentGuiSys = self

    InteractSys.init(maid, self.InteractUI :: Frame, interactKeyCode)


    return self 
end

function guiSys.init(maid : Maid)
    local newGuiSys = guiSys.new(maid)
    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)