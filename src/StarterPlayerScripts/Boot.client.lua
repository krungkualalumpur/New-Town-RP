--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
local GuiSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"))
--types
--constants
--variables
--references
local maid = Maid.new()
--local functions
--class
InputHandler.new(true)
GuiSys.init(maid)
