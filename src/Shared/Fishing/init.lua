--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Fishes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Fishing"):WaitForChild("Fishes"))
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local functions
--class
return {
    Fishes = Fishes,

    FishesDataToRarityArray = function()
        local rarityArray = {}
        for _,v in pairs(Fishes) do
            rarityArray[v] = v.Common
        end
        return rarityArray
    end,

    init = function (maid : Maid)
        
    end
}
