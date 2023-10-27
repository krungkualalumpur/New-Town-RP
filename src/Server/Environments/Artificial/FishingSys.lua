--!strict
--services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local functions
--class
local FishingSys = {}

function FishingSys.init(maid : Maid)
    local intTick = tick()
    for _, zone in pairs(CollectionService:GetTagged("FishingZone")) do
        if zone:IsA("BasePart") then
            
        end
    end
end

return FishingSys