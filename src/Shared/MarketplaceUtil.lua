--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local VIP_PLR_COLLISION_KEY = "VIPPlayerCollision"
--variables
--references
--local functions
function vipPlayer(char : Model)
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CollisionGroup = VIP_PLR_COLLISION_KEY
        end
    end
end
--class
local gamePassList = {
    [1] = {
        Name = "VIP Feature",
        Id = 241440364,
        OnPurchased = function(player : Player, gamepassId : number, wasPurchased : boolean)
            if wasPurchased and player.Character then
                vipPlayer(player.Character)
            end
        end
    }
}

local developerProductList = {}

local marketplaceUtil = {}

function marketplaceUtil.getGamePassIdByName(name : string)
    for _,info in pairs(gamePassList) do
        if info.Name == name then
            return info.Id
        end
    end
    error("Unable to find the id by the given name")
end


function marketplaceUtil.getGamePassInfoById(id : number)
    for _,info in pairs(gamePassList) do
        if info.Id == id then
            return info
        end
    end
    error("Unable to find info by the given id")
end

function marketplaceUtil.getDeveloperProductIdByName(name : string)
    for _,info in pairs(developerProductList) do
        if info.Name == name then
            return info.Id
        end
    end
    error("Unable to find the id by the given name")
end


function marketplaceUtil.getDeveloperProductInfoById(id : number)
    for _,info in pairs(developerProductList) do
        if info.Id == id then
            return info
        end
    end
    error("Unable to find the info by the given id")
end

function marketplaceUtil.init(maid : Maid)
    if RunService:IsServer() then
        for _,v in pairs(gamePassList) do
            MarketplaceService.PromptGamePassPurchaseFinished:Connect(v.OnPurchased)
        end
        for _,v in pairs(developerProductList) do
            MarketplaceService.PromptProductPurchaseFinished:Connect(v.OnPurchased)
        end
    end
end


return marketplaceUtil