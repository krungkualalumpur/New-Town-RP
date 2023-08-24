--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local GamePassService = game:GetService("GamePassService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local VIPZone = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MarketplaceManager"):WaitForChild("VIPZone"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
--types
type Maid = Maid.Maid
--constants
local VIP_PLR_COLLISION_KEY = "VIPPlayerCollision"
--variables
--references
--local functions
--class
local GamepassManager = {}

function GamepassManager.newPlayer(maid : Maid, plr : Player)
    local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
    if plrIsVIP then
        if plr.Character then MarketplaceUtil.getGamePassInfoById(MarketplaceUtil.getGamePassIdByName("VIP Feature")).OnPurchased(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"), plrIsVIP) end
        maid:GiveTask(plr.CharacterAdded:Connect(function()
            MarketplaceUtil.getGamePassInfoById(MarketplaceUtil.getGamePassIdByName("VIP Feature")).OnPurchased(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"), plrIsVIP)
        end))
    end
end

function GamepassManager.init(maid : Maid)
    
    VIPZone.init(maid)
    return
end

return GamepassManager