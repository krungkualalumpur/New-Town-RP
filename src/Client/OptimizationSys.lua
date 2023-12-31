--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
--types
type Maid = Maid.Maid
--constants
local LOAD_OF_DISTANCE = 70

local ZONE_TAG = "RenderZone"
local LOD_TAG = "LODItem"
local ADAPTIVE_LOD_TAG = "AdaptiveLODItem"
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
        else
            warn(interior.Name, " is not a model nor a basepart for interior!")
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

    --load of distance
    local lodItems = {} 
    local adaptiveLODItems = {}

    for _,LODinst in pairs(CollectionService:GetTagged(LOD_TAG)) do
        local parentPointerValue = Instance.new("ObjectValue")
        parentPointerValue.Name = "ParentPointer"
        parentPointerValue.Value = LODinst.Parent  
        parentPointerValue.Parent = LODinst
        table.insert(lodItems, LODinst)
    end

    for _, adaptiveLODInst in pairs(CollectionService:GetTagged(ADAPTIVE_LOD_TAG)) do
        local cf, size
        if adaptiveLODInst:IsA("Model") then
            cf, size = adaptiveLODInst:GetBoundingBox()
        elseif adaptiveLODInst:IsA("BasePart") then
            cf, size = adaptiveLODInst.CFrame, adaptiveLODInst.Size
        else
            warn(adaptiveLODInst.Name, " is not a model nor a basepart for LOD!")
        end

        local distanceRenderPart = Instance.new("Part") 
        distanceRenderPart.Material = if adaptiveLODInst:IsA("BasePart") then adaptiveLODInst.Material elseif adaptiveLODInst:IsA("Model") then (if adaptiveLODInst.PrimaryPart then adaptiveLODInst.PrimaryPart.Material else distanceRenderPart.Material) else distanceRenderPart.Material 
        distanceRenderPart.Name = adaptiveLODInst.Name
        distanceRenderPart.CFrame, distanceRenderPart.Size = cf, size
        distanceRenderPart.Transparency = if adaptiveLODInst:IsA("BasePart") then adaptiveLODInst.Transparency elseif adaptiveLODInst:IsA("Model") then (if adaptiveLODInst.PrimaryPart then adaptiveLODInst.PrimaryPart.Transparency else distanceRenderPart.Transparency) else distanceRenderPart.Transparency 
        distanceRenderPart.Reflectance = if adaptiveLODInst:IsA("BasePart") then adaptiveLODInst.Reflectance elseif adaptiveLODInst:IsA("Model") then (if adaptiveLODInst.PrimaryPart then adaptiveLODInst.PrimaryPart.Reflectance else distanceRenderPart.Reflectance) else distanceRenderPart.Reflectance 
        distanceRenderPart.Anchored = true
        distanceRenderPart.TopSurface = Enum.SurfaceType.Smooth
        distanceRenderPart.BottomSurface = Enum.SurfaceType.Smooth
        distanceRenderPart.CanCollide = false
        distanceRenderPart.Color = if adaptiveLODInst:IsA("BasePart") then adaptiveLODInst.Color elseif adaptiveLODInst:IsA("Model") then (if adaptiveLODInst.PrimaryPart then adaptiveLODInst.PrimaryPart.Color else distanceRenderPart.Color) else distanceRenderPart.Color 
        distanceRenderPart.Parent = nil

        local parentPointerValue = Instance.new("ObjectValue")
        parentPointerValue.Name = "ParentPointer"
        parentPointerValue.Value = adaptiveLODInst.Parent  
        parentPointerValue.Parent = adaptiveLODInst

        local distanceRenderPointerValue = Instance.new("ObjectValue")
        distanceRenderPointerValue.Name = "DistanceRenderPartPointer"
        distanceRenderPointerValue.Value = distanceRenderPart
        distanceRenderPointerValue.Parent = adaptiveLODInst

        table.insert(adaptiveLODItems, adaptiveLODInst)
    end
    
    maid:GiveTask(RunService.Stepped:Connect(function()
        local camera = workspace.CurrentCamera :: Camera

        for _,LODinst in pairs(lodItems) do
            local pointer = LODinst:FindFirstChild("ParentPointer") :: ObjectValue
            local cf, size
            if LODinst:IsA("Model") then
                cf, size = LODinst:GetBoundingBox()
            elseif LODinst:IsA("BasePart") then
                cf, size = LODinst.CFrame, LODinst.Size
            else
                warn(LODinst.Name, " is not a model nor a basepart for LOD!")
            end
            if cf and size and camera then
                local currentDist = (cf.Position - camera.CFrame.Position).Magnitude - (math.max(size.X, size.Y, size.Z)*0.5)
                currentDist = math.clamp(currentDist, 0, math.huge)

                if currentDist >= ((LODinst:GetAttribute("RadiusAmplifier") or 1)*LOAD_OF_DISTANCE) then
                    LODinst.Parent = nil
                else
                    LODinst.Parent = pointer.Value
                end

            end
        end

        for _,adaptiveLODinst in pairs(adaptiveLODItems) do
            local parentPointer = adaptiveLODinst:FindFirstChild("ParentPointer") :: ObjectValue
            local distanceRenderPartPointer = adaptiveLODinst:FindFirstChild("DistanceRenderPartPointer") :: ObjectValue

            assert(distanceRenderPartPointer and distanceRenderPartPointer.Value, ("No distance render part detected for a part named %s!"):format(adaptiveLODinst.Name))
            local cf, size
            if adaptiveLODinst:IsA("Model") then
                cf, size = adaptiveLODinst:GetBoundingBox()
            elseif adaptiveLODinst:IsA("BasePart") then
                cf, size = adaptiveLODinst.CFrame, adaptiveLODinst.Size
            else
                warn(adaptiveLODinst.Name, " is not a model nor a basepart for LOD!")
            end
            if cf and size and camera then
                local currentDist = (cf.Position - camera.CFrame.Position).Magnitude - (math.max(size.X, size.Y, size.Z)*0.5)
                currentDist = math.clamp(currentDist, 0, math.huge)

                if currentDist >= ((adaptiveLODinst:GetAttribute("RadiusAmplifier") or 1)*LOAD_OF_DISTANCE) then
                    adaptiveLODinst.Parent = nil
                    distanceRenderPartPointer.Value.Parent = parentPointer.Value
                else
                    distanceRenderPartPointer.Value.Parent = nil
                    adaptiveLODinst.Parent = parentPointer.Value
                end
            end
        end
    end))
end

return optimizationSys