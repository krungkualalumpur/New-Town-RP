--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environment = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"))
local EnvironmentSound = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("EnvironmentSound"))

local GuiSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"))
local OptimizationSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("OptimizationSys"))
local PlayerManager = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PlayerManager"))
local CharacterManager = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("CharacterManager"))
local ToolManager = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ToolManager"))
local AnimationManager = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("AnimationManager"))

local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))

local MapDensityChecker = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MapDensityChecker"))

--types
--constants
--variables
--references
local maid = Maid.new()
--local functions
--class
Environment.init(maid)
EnvironmentSound.init(maid)

OptimizationSys.init(maid)
GuiSys.init(maid)
PlayerManager.init(maid)
CharacterManager.init(maid)
ToolManager.init(maid)
AnimationManager.init(maid)
print("ga nongonl")

NotificationUtil.init(maid)

MapDensityChecker.init(maid)
