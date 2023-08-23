--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
--types
type Maid = Maid.Maid
--constants
local ZONE_TAG = "RenderZone"
--variables
--references
local Player = Players.LocalPlayer
--local functions
local function getInsideZone(plr : Player, zonePart : Instance)
    local pointer = zonePart:FindFirstChild("Pointer") :: ObjectValue
    local interiorInstance = pointer.Value
    local interiorParentPointer = pointer:FindFirstChild("ParentPointer") :: ObjectValue
    local interiorParent = if interiorParentPointer then interiorParentPointer.Value else nil
    if interiorInstance and interiorParent then
        interiorInstance.Parent = interiorParent
    end
    return 
end
local function getOutsideZone(plr : Player, zonePart : Instance)
    local pointer = zonePart:FindFirstChild("Pointer") :: ObjectValue
    local interiorInstance = pointer.Value
    if interiorInstance then
        interiorInstance.Parent = nil
    end
end
--class
local optimizationSys = {}

function optimizationSys.init(maid : Maid)
    local filter = {}

    --interior pointers set up
    for _, interior : Model | BasePart in pairs(CollectionService:GetTagged("Interior")) do
        local cf, size
        if interior:IsA("Model") then
            cf, size = interior:GetBoundingBox()
        elseif interior:IsA("BasePart") then
            cf, size = interior.CFrame, interior.Size
        end
        local zonePart = Instance.new("Part")
        zonePart.CanCollide = false
        zonePart.CFrame, zonePart.Size = cf, size
        zonePart.Anchored = true
        zonePart.Transparency = 1
        zonePart.Parent = workspace:FindFirstChild("Zones")

        local pointer = Instance.new("ObjectValue")
        pointer.Name = "Pointer"
        pointer.Value = interior
        pointer.Parent = zonePart

        CollectionService:AddTag(zonePart, ZONE_TAG)
    end

    --creating pointer for its parents
    for _,zonePart in pairs(CollectionService:GetTagged(ZONE_TAG)) do
        local pointer = zonePart:FindFirstChild("Pointer") :: ObjectValue
        assert(pointer, "No pointer/ObjectVal detected")

        local interiorInstance = pointer.Value

        if interiorInstance then
            local parentPointer = Instance.new("ObjectValue")
            parentPointer.Name = "ParentPointer"
            parentPointer.Value = interiorInstance.Parent
            parentPointer.Parent = pointer 
        end
       -- getOutsideZone(game.Players.LocalPlayer, zonePart)
    end

    for _,zonePart in pairs(CollectionService:GetTagged(ZONE_TAG)) do
        local character = Player.Character or Player.CharacterAdded:Wait()
        if Zone.ItemIsInside(zonePart, character.PrimaryPart) then
            getInsideZone(Player, zonePart)
        else
            getOutsideZone(Player, zonePart)
        end
    end
   
    local zone = Zone.new(CollectionService:GetTagged(ZONE_TAG), maid, filter)
    zone.playerEntered:Connect(function(plr : Player, zonePart : BasePart)
        if plr == game.Players.LocalPlayer then
            getInsideZone(plr, zonePart)
        end
        return 
    end)

    zone.playerExited:Connect(function(plr : Player, zonePart)
        if plr == game.Players.LocalPlayer then
            getOutsideZone(plr, zonePart)
        end
        return
    end)

    table.insert(filter, Player.Character)

    maid:GiveTask(Player.CharacterAdded:Connect(function(char)
        table.clear(filter)
        table.insert(filter, char)
    end))
end

return optimizationSys