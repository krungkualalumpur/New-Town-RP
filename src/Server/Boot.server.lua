--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environments = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"))
local EnvironmentSound = require(ServerScriptService:WaitForChild("Server"):WaitForChild("EnvironmentSound"))

local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local CharacterManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("CharacterManager"))
local MarketplaceManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MarketplaceManager"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))

local TelevisionChannel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TelevisionChannel"))
--types
--constants
local TITLE_ID = "F303E"
local DEV_SECRET_KEY = "8MWPBTO9AOFZUUZUJT4EEDRGWU54D874KN33B51653U68K1SKZ"
--references
local maid = Maid.new()
--variables
--script
Environments.init(maid)
EnvironmentSound.init(maid)

PlayerManager.init(maid)
CharacterManager.init(maid)
MarketplaceManager.init(maid)

BackpackUtil.init(maid)
CustomizationUtil.init(maid)
InteractableUtil.init(maid)
ToolActions.init(maid)

NotificationUtil.init(maid)
TelevisionChannel.init(maid)
MarketplaceUtil.init(maid)

Midas.init(TITLE_ID, DEV_SECRET_KEY)

