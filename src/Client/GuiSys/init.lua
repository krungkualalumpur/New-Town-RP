--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
--modules
local InteractSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("InteractSys"))
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
--types
type Maid = Maid.Maid
type GuiSys = {
    __index : GuiSys,
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
    local interactKeyCode = Enum.KeyCode.E
    
    local self : GuiSys = setmetatable({}, guiSys) :: any
    self.InteractUI = InteractUI(maid, interactKeyCode)

    self.InteractUI.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    currentGuiSys = self
    return self 
end

function guiSys.init(maid : Maid)
    local newGuiSys = guiSys.new(maid)

    InteractSys.init(maid, newGuiSys.InteractUI :: Frame)

    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)