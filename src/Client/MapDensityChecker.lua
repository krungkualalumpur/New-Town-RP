--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
local Player = Players.LocalPlayer
--local functions
--class
local MapDensityChecker = {}
function MapDensityChecker.init(maid : Maid)
    if RunService:IsStudio() then
        local isDensityVisualEnabledValue = workspace:WaitForChild("IsDensityVisualEnabled") :: BoolValue
        if isDensityVisualEnabledValue.Value == true then
            local checkerMaid = Maid.new()
            local t = tick()
            maid:GiveTask(RunService.Heartbeat:Connect(function()
                if tick() - t > 10 then
                    t = tick()
                    
                    checkerMaid:DoCleaning()
            
                    local oriPos = workspace:WaitForChild("SpawnLocations"):WaitForChild("Spawn2").Position
                    local overlapParams = OverlapParams.new()

                    local folder = checkerMaid:GiveTask(Instance.new("Folder"))
                    folder.Name = "AssetsDensityTest"
                    folder.Parent = workspace

                    local gap = 50
                    for x = -25000/gap, 25000/gap, gap do
                        for z = -25000/gap, 25000/gap, gap do
                            local p = Instance.new("Part")
                            p.Anchored = true
                            p.Position = Vector3.new(x, if Player.Character and Player.Character.PrimaryPart then Player.Character.PrimaryPart.Position.Y else 0, z) + oriPos
                            p.CanCollide = false
                            p.Size = Vector3.new(gap, 1000, gap)
                            p.Parent = folder

                            local parts = workspace:GetPartsInPart(p, overlapParams)
                            local height = if Player.Character and Player.Character.PrimaryPart then Player.Character.PrimaryPart.Position.Y else 10              
                            p.Color = Color3.fromHSV(0, math.clamp(#parts/1000, 0, 1), 1)
                            p.Transparency = 0.5    p.Locked = true     p.Size = Vector3.new(gap, height, gap)
                            p.Position = Vector3.new(p.Position.X, (0) + height*0.5 ,p.Position.Z)
                        end
                    end
                end
            end))
        end   
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = Player:WaitForChild("PlayerGui")

        local qualityDegradation = 25
        local screenRes = (screenGui.AbsoluteSize)
        local detectionRange = 1000

        local defaultDrawCallCount = 15

        local function roundQualityDeg(screenSizeAxisNum : number)
            return screenSizeAxisNum/math.ceil(screenSizeAxisNum/qualityDegradation)
        end

        print(roundQualityDeg(screenRes.X))

        local drawCallWeight = {
            Default = 1,
            Part = 1,
            MeshPart = 1,
            UnionOperation = 1,
            TransparentPart = 1,
            Texture = 1,
            Decal = 1,
            GuiBase = 3,
            ParticleEmitter = 2,
            Beam = 2,
            Mesh = 1
        }

        local triWeight = {
            Texture = 2,
            Decal = 2,
            SurfaceGui = 4,
            Block = 12,
            Wedge = 10,
            Cylinder = 96,
            Ball = 432,
            CornerWedge = 10,
            Mesh = 80,
            SpecialMesh = 800,
        }

        local function getWeightOrder(weightTbl) : {[number] : {Name : string, Value : number}}
            local newTbl = {}
            
            local newK = 0
            for k,v in pairs(weightTbl) do
                newK += 1
                newTbl[newK] = {
                    Name = k,
                    Value = v
                }
            end
            
            table.sort(newTbl, function(a, b)
                return a.Value < b.Value
            end)
            
            return newTbl
        end

        local function getWeightInstanceDataByName(tbl : {[number] : {Name : string, Value : number}},  name : string)
            for k,v in pairs(tbl) do
                if v.Name == name then		
                    return v, k
                end
            end
            
        end

        local triWeightOrder = getWeightOrder(triWeight)
        local drawCallWeightOrder = getWeightOrder(drawCallWeight)

        local function getDrawCallType(inst : Instance)
            if inst:IsA("Part") then
                if inst.Transparency > 0 then
                    return "TransparentPart"
                end
                return "Part"
            elseif inst:IsA("MeshPart") then
                return "MeshPart"
                
            elseif inst:IsA("SpecialMesh") or inst:IsA("BlockMesh") or inst:IsA("CharacterMesh") then
                return "Mesh"
            elseif inst:IsA("UnionOperation") then
                return "UnionOperation"
                
            elseif inst:IsA("GuiBase") then
                return "GuiBase"
            elseif inst:IsA("ParticleEmitter") then
                return "ParticleEmitter"
            elseif inst:IsA("Beam") then
                return "Beam"
            elseif inst:IsA("Texture") then
                return "Texture"
            elseif inst:IsA("Decal") then
                return "Decal"
            end
        end

        local function getTriType(inst : Instance) 
            if inst:IsA("Texture") then
                return "Texture"
            elseif inst:IsA("Decal") then
                return "Decal"
            elseif inst:IsA("SurfaceGui") then
                return "SurfaceGui"
            elseif inst:IsA("Part") then
                return inst.Shape.Name
            end
            return nil
        end


        local function partCountHeatMap()
            
            screenGui:ClearAllChildren()
            local maxParts = 0
        --[[for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                totalParts += 1
            end
        end]]
            --calculate max parts
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local ray =	workspace.CurrentCamera:ViewportPointToRay(x*roundQualityDeg(screenRes.X), y*roundQualityDeg(screenRes.Y))
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))
                    if #parts > maxParts then
                        maxParts = #parts
                    end
                --[[local p = Instance.new("Part")
                p.CFrame = CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction)
                --p.Position = ray.Origin + ray.Direction*50
                p.CanCollide = false
                p.Size = Vector3.new(2,2,detectionRange)
                p.Anchored = true
                p.Parent = workspace]]


                end
            end

            --simulate
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local frame = Instance.new("Frame") :: Frame
                    frame.AnchorPoint = Vector2.new(0.5,0.5)
                    frame.BackgroundTransparency = 0.5
                    frame.Position = UDim2.fromOffset((x*roundQualityDeg(screenRes.X)), (y*roundQualityDeg(screenRes.Y)))
                    frame.Size = UDim2.fromOffset(roundQualityDeg(screenRes.X), roundQualityDeg(screenRes.Y))
                    frame.Parent = screenGui


                    local ray =	workspace.CurrentCamera:ViewportPointToRay(x*roundQualityDeg(screenRes.X), y*roundQualityDeg(screenRes.Y))
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))
                    frame.BackgroundColor3 = Color3.new(#parts/maxParts,0,0)
                --[[local p = Instance.new("Part")
                p.CFrame = CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction)
                --p.Position = ray.Origin + ray.Direction*50
                p.CanCollide = false
                p.Size = Vector3.new(2,2,detectionRange)
                p.Anchored = true
                p.Parent = workspace]]

                if qualityDegradation < 100 then task.wait() end

                end
            end
        end


        local function drawCallHeatMap()
            local totalCollectedDrawCall = {}
            
            screenGui:ClearAllChildren()

            local maxDrawCall = 0
            
            --calculate max parts
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local ray =	workspace.CurrentCamera:ViewportPointToRay(x*roundQualityDeg(screenRes.X), y*roundQualityDeg(screenRes.Y))
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))
                    local drawcallCount = 0
                    local collectedName = {}

                    for _,v in pairs(parts) do
                        local drawcallType = getDrawCallType(v)
                        if drawcallType then
                            if not table.find(collectedName, drawcallType) then
                                local recordName = drawcallType .. if v:IsA("MeshPart") and v.MeshId then tostring(v.MeshId) elseif v:IsA("UnionOperation") then tostring(math.round(v.Size.Magnitude*100)/100) else ""
                                table.insert(collectedName, recordName)
                                local data = getWeightInstanceDataByName(drawCallWeightOrder, drawcallType)
                                drawcallCount += data.Value
                                
                                if not table.find(totalCollectedDrawCall, recordName) then
                                    table.insert(totalCollectedDrawCall, recordName)
                                end
                                
                            end
                            for _,descendant in pairs(v:GetDescendants()) do
                                if not descendant:IsA("BasePart") then
                                    local descendantDrawCallType = getDrawCallType(descendant)

                                    local data = getWeightInstanceDataByName(drawCallWeightOrder, descendantDrawCallType)
                                    if data then
                                        drawcallCount += data.Value
                                        
                                        local recordName = descendantDrawCallType .. if descendant:IsA("MeshPart") and descendant.MeshId then tostring(descendant.MeshId) elseif descendant:IsA("UnionOperation") then tostring(math.round(descendant.Size.Magnitude*100)/100) else ""
                                        if not table.find(totalCollectedDrawCall, recordName) then
                                            table.insert(totalCollectedDrawCall, recordName)
                                        end
                                    end
                                end
                            end
                            
                        end
                    end

                    if drawcallCount > maxDrawCall then
                        maxDrawCall = drawcallCount 
                    end

                end
            end

            --simulate
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local frame = Instance.new("Frame") :: Frame
                    frame.AnchorPoint = Vector2.new(0.5,0.5)
                    frame.BackgroundTransparency = 0.5
                    frame.Position = UDim2.fromOffset((x*roundQualityDeg(screenRes.X)), (y*roundQualityDeg(screenRes.Y)))
                    frame.Size = UDim2.fromOffset(roundQualityDeg(screenRes.X), roundQualityDeg(screenRes.Y))
                    frame.Parent = screenGui

                    local ray =	workspace.CurrentCamera:ViewportPointToRay(frame.Position.X.Offset, frame.Position.Y.Offset)
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))			
                    local drawcallCount = 0
                    local collectedName = {}

                    for _,v in pairs(parts) do
                        local drawcallType = getDrawCallType(v)
                        if drawcallType then
                            if not table.find(collectedName, drawcallType) or drawcallType == "MeshPart" then
                                table.insert(collectedName, drawcallType)
                                local data = getWeightInstanceDataByName(drawCallWeightOrder, drawcallType)
                                drawcallCount += data.Value
                            end
                            for _,descendant in pairs(v:GetDescendants()) do
                                if not descendant:IsA("BasePart") then
                                    local descendantDrawCallType = getDrawCallType(descendant)
                                    local data = getWeightInstanceDataByName(drawCallWeightOrder, descendantDrawCallType)
                                    if data then
                                        drawcallCount += data.Value
                                    end
                                end
                            end
                            
                        end
                    end
                    frame.BackgroundColor3 = Color3.new(drawcallCount/maxDrawCall,0,0)
                    if qualityDegradation < 100 then task.wait() end
                end
            end
            
            print(#totalCollectedDrawCall + defaultDrawCallCount, " : estimated draw call in frame")
        end

        local function triHeatMap()
            screenGui:ClearAllChildren()
            
            local maxTris = 0

            --calculate max parts
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local ray =	workspace.CurrentCamera:ViewportPointToRay(x*roundQualityDeg(screenRes.X), y*roundQualityDeg(screenRes.Y))
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))
                    local trisCount = 0
                    
                    for _,v in pairs(parts) do
                        local triType = getTriType(v)
                        if triType then
                            local data = getWeightInstanceDataByName(triWeightOrder, triType)
                            trisCount += data.Value
                        end
                    end
                    
                    if trisCount > maxTris then
                        maxTris = trisCount 
                    end

                end
            end

            --simulate
            for x = 0, screenRes.X/roundQualityDeg(screenRes.X) do
                for y = 0, screenRes.Y/roundQualityDeg(screenRes.Y) do
                    local frame = Instance.new("Frame") :: Frame
                    frame.AnchorPoint = Vector2.new(0.5,0.5)
                    frame.BackgroundTransparency = 0.5
                    frame.Position = UDim2.fromOffset((x*roundQualityDeg(screenRes.X)), (y*roundQualityDeg(screenRes.Y)))
                    frame.Size = UDim2.fromOffset(roundQualityDeg(screenRes.X), roundQualityDeg(screenRes.Y))
                    frame.Parent = screenGui

                    local ray =	workspace.CurrentCamera:ViewportPointToRay(x*roundQualityDeg(screenRes.X), y*roundQualityDeg(screenRes.Y))
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction*100)

                    local parts = workspace:GetPartBoundsInBox(CFrame.new(ray.Origin + ray.Direction*detectionRange*0.5, ray.Origin + ray.Direction), Vector3.new(qualityDegradation/30,qualityDegradation/30,detectionRange))			
                    local trisCount = 0

                    for _,v in pairs(parts) do
                        local triType = getTriType(v)
                        if triType then
                            local data = getWeightInstanceDataByName(triWeightOrder, triType)
                            trisCount += data.Value
                        end
                    end
                    frame.BackgroundColor3 = Color3.new(trisCount/maxTris,0,0)
                    if qualityDegradation < 100 then task.wait() end
                end
            end
        end
        --partCountHeatMap()
        --[[while task.wait(5) do	
            --triHeatMap()
            drawCallHeatMap()
        end]]

    end 
    return 
end

return MapDensityChecker