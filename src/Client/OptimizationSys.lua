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
local LOD_UPDATE_INTERVAL = 0.5

local ZONE_TAG = "RenderZone"
local LOD_TAG = "LODItem"
local ADAPTIVE_LOD_TAG = "AdaptiveLODItem"
local LOD_OCCLUSION_TAG = "LODOcclusion"
--variables
--references
local Player = Players.LocalPlayer

local occlusionFolder = workspace:WaitForChild("Assets"):WaitForChild("OcclusionFolder")
local occlusionBoundingParts = workspace:WaitForChild("Assets"):WaitForChild("OcclusionFolder"):WaitForChild("OcclusionBoundingParts")

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

    local function onLODTagAdded(LODinst : Instance)
        local parentPointerValue = Instance.new("ObjectValue") 
        parentPointerValue.Name = "ParentPointer"
        parentPointerValue.Value = LODinst.Parent  
        parentPointerValue.Parent = LODinst
        table.insert(lodItems, LODinst)
    end

    local function onAdaptiveLODTagAdded(adaptiveLODInst : Instance)
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
        distanceRenderPart.Parent = workspace

        local parentPointerValue = Instance.new("ObjectValue")
        parentPointerValue.Name = "ParentPointer"
        parentPointerValue.Value = adaptiveLODInst.Parent  
        parentPointerValue.Parent = adaptiveLODInst

        local distanceRenderPointerValue = Instance.new("ObjectValue")
        distanceRenderPointerValue.Name = "DistanceRenderPartPointer"
        distanceRenderPointerValue.Value = distanceRenderPart
        distanceRenderPointerValue.Parent = adaptiveLODInst

        table.insert(adaptiveLODItems, adaptiveLODInst)

        do
            local prevRenderPart = distanceRenderPart
            maid:GiveTask(distanceRenderPointerValue.Changed:Connect(function()
                
                if (distanceRenderPointerValue.Value == nil) then
                    if prevRenderPart then
                        prevRenderPart:Destroy()
                    end
                else
                    prevRenderPart = distanceRenderPointerValue.Value
                end
            end))
        end
    end

    for _,LODinst in pairs(CollectionService:GetTagged(LOD_TAG)) do
        onLODTagAdded(LODinst)
    end

    maid:GiveTask(CollectionService:GetInstanceAddedSignal(LOD_TAG):Connect(function(LODinst : Instance)
        if not table.find(lodItems, LODinst) then
            --print(LODinst, " added")
            onLODTagAdded(LODinst)
        end
    end))

    --[[maid:GiveTask(CollectionService:GetInstanceRemovedSignal(LOD_TAG):Connect(function(LODinst : Instance)
        print("removed ", LODinst.Name)
        local i = table.find(lodItems, LODinst)
        if i then table.remove(lodItems, i) end
    end))]]

    for _, adaptiveLODInst in pairs(CollectionService:GetTagged(ADAPTIVE_LOD_TAG)) do
        onAdaptiveLODTagAdded(adaptiveLODInst)
    end

    --do this later, lod_tag first tho
    --[[maid:GiveTask(CollectionService:GetInstanceAddedSignal(ADAPTIVE_LOD_TAG):Connect(function(adaptiveLODinst : Instance)
        if not table.find(adaptiveLODItems, adaptiveLODinst) then
            onAdaptiveLODTagAdded(adaptiveLODinst)
        end
    end))]]

    --[[maid:GiveTask(CollectionService:GetInstanceRemovedSignal(ADAPTIVE_LOD_TAG):Connect(function(LODinst : Instance)
        local i = table.find(adaptiveLODItems, LODinst)
        if i then table.remove(adaptiveLODItems, i) end
    end))]]

    
    local t1 = tick()
    local t2 = tick()
    maid:GiveTask(RunService.Heartbeat:Connect(function()
        if tick() - t1 > LOD_UPDATE_INTERVAL then 
            t1 = tick()
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
                    local s, e = pcall(function() 
                        local currentDist = (cf.Position - camera.CFrame.Position).Magnitude - (math.max(size.X, size.Y, size.Z)*0.5)
                        currentDist = math.clamp(currentDist, 0, math.huge)

                        if currentDist >= ((LODinst:GetAttribute("RadiusAmplifier") or 1)*LOAD_OF_DISTANCE) then
                            LODinst.Parent = nil
                        else
                            LODinst.Parent = pointer.Value
                        end
                    end)
                    if not s and e then
                        local i = table.find(lodItems, LODinst)
                        if i then
                            table.remove(lodItems, i)
                        end
                        warn(e)
                    end
                end
            end
        end
    end))

    maid:GiveTask(RunService.Heartbeat:Connect(function()
        if tick() - t2 > LOD_UPDATE_INTERVAL then 
            t2 = tick()
            
            local camera = workspace.CurrentCamera :: Camera
            for _,adaptiveLODinst in pairs(adaptiveLODItems) do
                local parentPointer = adaptiveLODinst:FindFirstChild("ParentPointer") :: ObjectValue
                local distanceRenderPartPointer = adaptiveLODinst:FindFirstChild("DistanceRenderPartPointer") :: ObjectValue

                assert(distanceRenderPartPointer, ("No distance render POINTER detected for a part named %s!"):format(adaptiveLODinst.Name))
                if distanceRenderPartPointer.Value then
                    --assert(distanceRenderPartPointer.Value, ("No distance render part detected for a part named %s!"):format(adaptiveLODinst.Name))
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
                elseif not distanceRenderPartPointer:GetAttribute("IsProcessing") then
                    local cf, size
                    if adaptiveLODinst:IsA("Model") then
                        cf, size = adaptiveLODinst:GetBoundingBox()
                    elseif adaptiveLODinst:IsA("BasePart") then
                        cf, size = adaptiveLODinst.CFrame, adaptiveLODinst.Size
                    else
                        warn(adaptiveLODinst.Name, " is not a model nor a basepart for LOD!")
                    end
                    if cf and size then
                        distanceRenderPartPointer:SetAttribute("IsProcessing", true)
                        local distanceRenderPart = Instance.new("Part") 
                        distanceRenderPart.Material = if adaptiveLODinst:IsA("BasePart") then adaptiveLODinst.Material elseif adaptiveLODinst:IsA("Model") then (if adaptiveLODinst.PrimaryPart then adaptiveLODinst.PrimaryPart.Material else distanceRenderPart.Material) else distanceRenderPart.Material 
                        distanceRenderPart.Name = adaptiveLODinst.Name
                        distanceRenderPart.CFrame, distanceRenderPart.Size = cf, size
                        distanceRenderPart.Transparency = if adaptiveLODinst:IsA("BasePart") then adaptiveLODinst.Transparency elseif adaptiveLODinst:IsA("Model") then (if adaptiveLODinst.PrimaryPart then adaptiveLODinst.PrimaryPart.Transparency else distanceRenderPart.Transparency) else distanceRenderPart.Transparency 
                        distanceRenderPart.Reflectance = if adaptiveLODinst:IsA("BasePart") then adaptiveLODinst.Reflectance elseif adaptiveLODinst:IsA("Model") then (if adaptiveLODinst.PrimaryPart then adaptiveLODinst.PrimaryPart.Reflectance else distanceRenderPart.Reflectance) else distanceRenderPart.Reflectance 
                        distanceRenderPart.Anchored = true
                        distanceRenderPart.TopSurface = Enum.SurfaceType.Smooth
                        distanceRenderPart.BottomSurface = Enum.SurfaceType.Smooth
                        distanceRenderPart.CanCollide = false
                        distanceRenderPart.Color = if adaptiveLODinst:IsA("BasePart") then adaptiveLODinst.Color elseif adaptiveLODinst:IsA("Model") then (if adaptiveLODinst.PrimaryPart then adaptiveLODinst.PrimaryPart.Color else distanceRenderPart.Color) else distanceRenderPart.Color 
                        
                        --distanceRenderPart.Parent = parentPointer.Value

                        if camera then --setting the distance render part parent
                            local currentDist = (cf.Position - camera.CFrame.Position).Magnitude - (math.max(size.X, size.Y, size.Z)*0.5)
                            currentDist = math.clamp(currentDist, 0, math.huge)
    
                            if currentDist >= ((adaptiveLODinst:GetAttribute("RadiusAmplifier") or 1)*LOAD_OF_DISTANCE) then
                                adaptiveLODinst.Parent = nil
                                distanceRenderPartPointer.Value = distanceRenderPart
                                distanceRenderPartPointer.Value.Parent = parentPointer.Value
                            else
                                distanceRenderPartPointer.Value = distanceRenderPart
                                distanceRenderPartPointer.Value.Parent = nil
                                adaptiveLODinst.Parent = parentPointer.Value
                               
                            end
                        end

                       
                        
                        distanceRenderPartPointer:SetAttribute("IsProcessing", nil)
                    end
                end
            end

        end
    end))

    ----------------
    local occlusions = occlusionBoundingParts:GetChildren()
    local instsOnHide = {}
    local function occlusionHandle(inst : Instance, hide : boolean) 
        if hide then
            for _,occlusionInst : Instance in pairs(occlusions) do
                if (inst == occlusionInst or inst:IsDescendantOf(occlusionInst)) and not table.find(instsOnHide, occlusionInst) then
                    table.insert(instsOnHide, occlusionInst)
                    --print(occlusionInst, " add")
                end
            end
        else
            for _,occlusionInst : Instance in pairs(occlusions) do
                local instIndex = table.find(instsOnHide, occlusionInst)
                if (inst == occlusionInst or inst:IsDescendantOf(occlusionInst)) and instIndex then
                    table.remove(instsOnHide, instIndex)
                    --print(occlusionInst, " rmeove")
                end
            end
        end
    end

    --init occlusions
    local occlusionRaycastParams = RaycastParams.new()
    occlusionRaycastParams.FilterDescendantsInstances = occlusions
    occlusionRaycastParams.FilterType = Enum.RaycastFilterType.Include

    local db = true
    maid:GiveTask(RunService.Heartbeat:Connect(function()
        local camera = workspace.CurrentCamera 
        if camera and db then
            db = false
            occlusions = occlusionBoundingParts:GetChildren()
            occlusionRaycastParams.FilterDescendantsInstances = occlusions

            local char = Player.Character
            if char and char.PrimaryPart then
                local parts = workspace:GetPartsInPart(char.PrimaryPart)
                for _,v in pairs(parts) do
                    local index = table.find(occlusions, v)
                    if index then
                        table.remove(occlusions, index)
                    end
                end
            end

            local povCf = camera.CFrame

            local range = 250
            local fov = camera.DiagonalFieldOfView
          
            local degreeInterval = 5
            local occlusionDepth = 7
            
            for _,v in pairs(occlusions) do
                local detailModelPointer = v:FindFirstChild("DetailModelPointer") :: ObjectValue ?
                if detailModelPointer and detailModelPointer.Value then
                    occlusionHandle(v, true) 
                    --detailModelPointer.Value.Parent = nil
                end
            end 
            
            for depth = 1, occlusionDepth do
                local radAmp = (depth/occlusionDepth)
                local radius = math.tan(math.rad(fov*(radAmp))/2)*range
            
                for i = 1, 360, (360*degreeInterval/(360*radius/(occlusionDepth*range*0.5))) do
                    local pos = (povCf.LookVector*range) + povCf:PointToWorldSpace(Vector3.new(math.cos(math.rad(i)), math.sin(math.rad(i)),  0)*radius)
                    
                    local ray = workspace:Raycast(
                        povCf.Position, 
                        pos - povCf.Position,
                        occlusionRaycastParams
                    )
                    
                    if ray then
                        local v = ray.Instance
                        local detailModelPointer = v:FindFirstChild("DetailModelPointer") :: ObjectValue ?
                        if detailModelPointer and detailModelPointer.Value then
                            --detailModelPointer.Value.Parent = occlusionFolder
                            occlusionHandle(v, false) 
                        end
                    end
                    
                    --[[local p = Instance.new("Part")
                    p.Size = Vector3.new(10,10,10)
                    p.Position = pos
                    p.Anchored = true
                    p.Parent = workspace
                    
                    task.spawn(function()
                        task.wait(0.5)
                        p:Destroy()
                    end)]]
                
                end
                
            end

            for _,v in pairs(occlusions) do
                local detailModelPointer = v:FindFirstChild("DetailModelPointer") :: ObjectValue ?
                if detailModelPointer and detailModelPointer.Value then
                    if table.find(instsOnHide, v) then
                        detailModelPointer.Value.Parent = nil
                    else
                        detailModelPointer.Value.Parent = occlusionFolder
                    end
                end
            end
            task.wait(0.15)
            db = true
        end

       
    end))
end

return optimizationSys