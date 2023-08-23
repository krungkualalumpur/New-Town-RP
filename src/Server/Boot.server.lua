--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environments = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"))
local EnvironmentSound = require(ServerScriptService:WaitForChild("Server"):WaitForChild("EnvironmentSound"))

local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local CharacterManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("CharacterManager"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
--types
--constants
--references
local maid = Maid.new()
--variables
--script
Environments.init(maid)
EnvironmentSound.init(maid)

PlayerManager.init(maid)
CharacterManager.init(maid)

BackpackUtil.init(maid)
CustomizationUtil.init(maid)
InteractableUtil.init(maid)
ToolActions.init(maid)

NotificationUtil.init(maid)
print("Hello world, du bist heissen?! PENAT LAAAA de stronkest")

