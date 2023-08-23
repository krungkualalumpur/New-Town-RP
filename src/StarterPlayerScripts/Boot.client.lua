--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environment = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"))
local EnvironmentSound = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("EnvironmentSound"))

local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
local GuiSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"))
local OptimizationSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("OptimizationSys"))
local CharacterManager = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("CharacterManager"))

local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
--types
--constants
--variables
--references
local maid = Maid.new()
--local functions
--class
maid:GiveTask(InputHandler.new(true))

Environment.init(maid)
EnvironmentSound.init(maid)

GuiSys.init(maid)
OptimizationSys.init(maid)
CharacterManager.init(maid)

NotificationUtil.init(maid)
