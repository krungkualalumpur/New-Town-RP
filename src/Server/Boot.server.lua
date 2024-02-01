--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
--packages
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environments = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"))
local EnvironmentSound = require(ServerScriptService:WaitForChild("Server"):WaitForChild("EnvironmentSound"))

local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local CharacterManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("CharacterManager"))
local ToolManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ToolManager"))
local Roleplay = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Roleplay"))
local MarketplaceManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MarketplaceManager"))
local DateSys = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DateSys"))
local OptimizationSys = require(ServerScriptService:WaitForChild("Server"):WaitForChild("OptimizationSys"))
local Analytics = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Analytics"))

local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))

local TelevisionChannel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TelevisionChannel"))
--types
--constants
--references
--variables
--local function
--script
local maid = Maid.new()

InteractableUtil.init(maid) -- change init to interactable manager soon! (Wip!! but dont forget!!)

Analytics.init(maid)

DateSys.init(maid)

Environments.init(maid)
EnvironmentSound.init(maid)


NotificationUtil.init(maid)
TelevisionChannel.init(maid)
MarketplaceUtil.init(maid)

PlayerManager.init(maid)
CharacterManager.init(maid)
ToolManager.init(maid)

Roleplay.init(maid)
task.spawn(function() MarketplaceManager.init(maid) end)
OptimizationSys.init(maid)
--analytics setup
--Midas.init(TITLE_ID, DEV_SECRET_KEY)


--Midas.init(maid)
--Midas.ProjectId = "F303E"

