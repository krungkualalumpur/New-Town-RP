--!strict
--services
--packages
--modules
--types
--constants
--variables
--references
--local functions
local function getPointsConnectorInfo(p1: Vector3, p2: Vector3, lineLength: number)
    local length = (p1 - p2).Magnitude

	local info = { CFrame = CFrame.new() :: CFrame, PointPositions = {}, OffsetInfo = { Position = Vector3.new() :: Vector3, Size = Vector3.new() :: Vector3 } }
	local cf = CFrame.lookAt(p1, p2) * CFrame.fromEulerAnglesYXZ(0, math.rad(90), 0)
	--local size          =  Vector3.new(length,0.25, 0.25)

	cf += (cf.RightVector * length / 2)
	info.CFrame = cf - cf.Position

	local offset = length
	local modelLength = lineLength --+ (modelSize.Z/2)

	for i = modelLength, length, modelLength do
		table.insert(info.PointPositions, p1:Lerp(p2, i / length) - cf.RightVector * modelLength * 0.5)

		offset = math.abs(length - modelLength) % modelLength
	end

	if offset > 0.5 then
		info.OffsetInfo.Size = Vector3.new(offset, 0.1, 0.25)
		info.OffsetInfo.Position = (p2 - cf.RightVector * (info.OffsetInfo.Size.X * 0.5))
	end

	return info
end

--module
local LineUtil = {}

function LineUtil.getLineFromTwoPoints(p1: Vector3, p2: Vector3, model: Model | BasePart) : Instance ?
    --if the "model" is a basepart
	if model:IsA("BasePart") then
		local newModel = Instance.new("Model")
		model.Parent = newModel
		newModel.PrimaryPart = model
		model = newModel
		newModel:SetAttribute("ConvertedToModel", true)
	end
	assert(model:IsA("Model"), "Error converting basepart to model")
	assert(model.PrimaryPart, "Primary part not detected!")

	--having linefolder to make something to return to
	local lineFolder = Instance.new("Model")
	--local info = ptConnector:Connect(p1, p2, model.PrimaryPart.Size.X)
    local info = getPointsConnectorInfo(p1, p2,  model.PrimaryPart.Size.X)
	
    if #info.PointPositions > 100 then
		warn("System overload!")
		return nil
	end

	--spawning wall segments along in between points
	for _, v3 in pairs(info.PointPositions) do
		local lineSegment = model:Clone()
		lineSegment:PivotTo(CFrame.new(v3) * info.CFrame)
		lineSegment.Parent = lineFolder
	end

	--spawning any offsets inbetween incomplete fills
	if info.OffsetInfo and info.OffsetInfo.Size and info.OffsetInfo.Position then
		info.OffsetInfo.Size = Vector3.new(info.OffsetInfo.Size.X, model.PrimaryPart.Size.Y, model.PrimaryPart.Size.Z)

		local p = if model.PrimaryPart then model.PrimaryPart:Clone() :: BasePart else Instance.new("Part") :: BasePart
		p.Transparency = 0
		p.Name = "WallPart_Offset"
		p.Anchored = true
		p.Size = info.OffsetInfo.Size
		p.CFrame = CFrame.new(info.OffsetInfo.Position) * info.CFrame
		p.Parent = lineFolder
	end

	--reverting model back to basepart
	if model:GetAttribute("ConvertedToModel") then
		model.PrimaryPart.Parent = model.Parent
		model:Destroy()
	end

	return lineFolder
end

function LineUtil.getTwoLinesIntersectPoint(l1p1 : Vector3, l1p2 : Vector3, l2p1 :Vector3, l2p2 :Vector3) : Vector3 ?
	local maxGradient = 10^3
	local m1 = math.clamp((l1p2.Z - l1p1.Z)/(l1p2.X - l1p1.X), -maxGradient, maxGradient)
	local m2 = math.clamp((l2p2.Z - l2p1.Z)/(l2p2.X - l2p1.X), -maxGradient, maxGradient)

	if m2 - m1 == 0 then
		return nil
	end

	local offset1 = l1p1.Z - (m1*l1p1.X)
	local offset2 = l2p1.Z - (m2*l2p1.X)

	local intersectingX = (offset2 - offset1)/(m1 - m2)
	local intersectingY = m1*intersectingX + offset1

	--take avg height
	local averageHeight = (l1p1.Y + l1p2.Y + l2p1.Y + l2p2.Y)/4

	return Vector3.new(intersectingX, averageHeight, intersectingY)
end

function LineUtil.getPerpendicularPointToALine(mainP :Vector3, P1 :Vector3, floatingP : Vector3)
	local dotProduct = (mainP - P1).Unit:Dot((mainP - floatingP).Unit)
	--local rad = math.acos(dotProduct)

	local hypo  = (mainP - floatingP).Magnitude

	local adjacent = dotProduct*hypo

	local alpha = adjacent/(mainP - P1).Magnitude

	local intersectPos = mainP:Lerp(P1, alpha)

	return intersectPos, alpha >= -0.2 and alpha <= 1.2 and alpha
end

function LineUtil.CreatePathStuff(rawPts : Instance, roadPtsParent : Instance)
	local function addPoint(v3, connectors :{ [number]: BasePart } ?, parent, ptName : string ?)
		local p = Instance.new("Part")
		p.Anchored = true
		p.Name = ptName or tostring(#parent:GetChildren())
		p.Color = Color3.new(1,0,0)
		p.Position = v3
		p.Size = Vector3.new(10,10,10)
		p.Parent = parent
		for _,v : Instance in pairs(connectors or {}) do
			local objVal = Instance.new("ObjectValue")
			objVal.Value = v
			objVal.Parent = p
	
			local objVal2 = Instance.new("ObjectValue")
			objVal2.Value = p
			objVal2.Parent = v
		end
		return p
	end
	
	--[[function IntersectLines(l1p1 : Vector3, l1p2 : Vector3, l2p1 :Vector3, l2p2 :Vector3)
		local maxGradient = 10^3
		local m1 = math.clamp((l1p2.Z - l1p1.Z)/(l1p2.X - l1p1.X), -maxGradient, maxGradient)
		local m2 = math.clamp((l2p2.Z - l2p1.Z)/(l2p2.X - l2p1.X), -maxGradient, maxGradient)
	
		if m2 - m1 == 0 then
			return false
		end
	
		local offset1 = l1p1.Z - (m1*l1p1.X)
		local offset2 = l2p1.Z - (m2*l2p1.X)
	
		local intersectingX = (offset2 - offset1)/(m1 - m2)
		local intersectingY = m1*intersectingX + offset1
	
		--take avg height
		local averageHeight = (l1p1.Y + l1p2.Y + l2p1.Y + l2p2.Y)/4
	
		return Vector3.new(intersectingX, averageHeight, intersectingY)
	end
	
	function IntersectPerpendicularPoint(mainP :Vector3, P1 :Vector3, floatingP : Vector3)
		local dotProduct = (mainP - P1).Unit:Dot((mainP - floatingP).Unit)
		local rad = math.acos(dotProduct)
	
		local hypo  = (mainP - floatingP).Magnitude
	
		local adjacent = dotProduct*hypo
	
		local alpha = adjacent/(mainP - P1).Magnitude
	
		local intersectPos = mainP:Lerp(P1, alpha)
	
		return intersectPos, alpha >= -0.2 and alpha <= 1.2 and alpha
	end]]
	
	--refresh road pts
	roadPtsParent:ClearAllChildren()

	--extract raw points into road pts 
	for _,lineFolder in pairs(rawPts:GetChildren()) do
		for _, pt : BasePart in pairs(lineFolder:GetChildren() :: any) do
			local ptNum = tonumber(pt.Name)

			local nextPt = if ptNum then lineFolder:FindFirstChild(tostring(ptNum + 1)) else nil
			local prevPt = if ptNum then lineFolder:FindFirstChild(tostring(ptNum - 1)) else nil
			
			local connectors = {} 
			if prevPt then
				connectors = table.insert(connectors, roadPtsParent:GetChildren()[#roadPtsParent:GetChildren()] :: BasePart)
			end

			local p = addPoint(pt.Position, connectors , roadPtsParent)
			p.CanCollide = false
			p.Anchored = true
			p.Transparency = 1
		end
	end
	

	---finding intersection lines---

	--iterating through each lines
	for _,lineFolder in pairs(rawPts:GetChildren()) do
		
		local totalLength = 0
		
		for _, pt in pairs(lineFolder:GetChildren()) do
			local ptIndex = tonumber(pt.Name)
			local nextPtName = ptIndex and tostring(ptIndex + 1)
			local prevPtName = ptIndex and tostring(ptIndex - 1)
			--two points that form a line
			local currentPt = lineFolder:FindFirstChild(pt.Name) :: BasePart ?
			local nextPt = if nextPtName then lineFolder:FindFirstChild(nextPtName) :: BasePart ? else nil
			local prevPt = if prevPtName then lineFolder:FindFirstChild(prevPtName) :: BasePart ? else nil
			
			if currentPt and nextPt then
				totalLength += (currentPt.Position - nextPt.Position).Magnitude
				--iterate through other lines
				for _,lineFolder2 in pairs(rawPts:GetChildren()) do
					if lineFolder ~= lineFolder2 then
						for _,pt2 in pairs(lineFolder2:GetChildren()) do
							local pt2Index = tonumber(pt2.Name)
							local nextPt2Name = pt2Index and tostring(pt2Index + 1)

							local currentPt2 = lineFolder2:FindFirstChild(pt2.Name) :: BasePart ?
							local nextPt2 = if nextPt2Name then lineFolder2:FindFirstChild(nextPt2Name) :: BasePart ? else nil

							if currentPt2 and nextPt2 then
								--filters

								--
								local intersectV3 = LineUtil.getTwoLinesIntersectPoint(currentPt.Position, nextPt.Position, currentPt2.Position, nextPt2.Position)


								if intersectV3 then
									local _, alpha1 = LineUtil.getPerpendicularPointToALine(currentPt.Position, nextPt.Position, intersectV3)
									local _, alpha2 = LineUtil.getPerpendicularPointToALine(currentPt2.Position, nextPt2.Position, intersectV3)
									if not alpha1 or not alpha2 then
										intersectV3 = nil
									end
								end

								if intersectV3 then

								--[[currentPt.Color = Color3.fromRGB(255, 255, math.random(0, 100))
								currentPt.Size = Vector3.new(20,20,20)
								nextPt.Color = currentPt.Color 
								nextPt.Size = Vector3.new(20,20,20)
								currentPt.Transparency = 0.5
								nextPt.Transparency = 0.5
								
								currentPt2.Color = Color3.fromRGB(255, 255, math.random(0, 100))
								currentPt2.Size = Vector3.new(20,20,20)
								nextPt2.Color = currentPt2.Color 
								nextPt2.Size = Vector3.new(20,20,20)
								currentPt2.Transparency = 0.5
								nextPt2.Transparency = 0.5]]

									local noPointsNear = true
									for _,v : BasePart in pairs(roadPtsParent:GetChildren() :: any) do
										if v:GetAttribute("isIntersection") and (intersectV3 - v.Position).Magnitude < 5 then
											noPointsNear = false
											break
										end
									end

									if noPointsNear then
										local function findInRoadPt(instance): BasePart ?
											for _,v : BasePart in pairs(roadPtsParent:GetChildren() :: any) do
												if math.floor((v.Position - instance.Position).Magnitude) == 0 then
													return v
												end
											end
											return nil
										end

										local a, b, c, d = findInRoadPt(currentPt), findInRoadPt(nextPt), findInRoadPt(currentPt2), findInRoadPt(nextPt2)
										local connectors = {}
										if a then table.insert(connectors, a) end
										if b then table.insert(connectors, b) end
										if c then table.insert(connectors, c) end
										if d then table.insert(connectors, d) end

										
										local p = addPoint(intersectV3, connectors, roadPtsParent)
										p:SetAttribute("isIntersection", true)
										p.Color = Color3.fromRGB(100,109,190)
										p.Anchored = true
										p.CanCollide = false 
										p.Transparency = 1
									end

								end

							end
						end
					end
				end
			end
		end
		for _,v : BasePart in pairs(lineFolder:GetChildren() :: any) do
			--local avgDist = totalLength/#lineFolder:GetChildren()
			local n = tonumber(v.Name)
			if n and (n ~= 1 or n ~= #lineFolder:GetChildren()) and (n*2)%(totalLength/#lineFolder:GetChildren()) < 2 then
				v.Size += Vector3.new(0, 0.01,0.5)
				v.TopSurface = Enum.SurfaceType.Smooth
				v.BottomSurface = Enum.SurfaceType.Smooth
				v.Transparency = 0
			end
		end
		
	end
	return 
end

return LineUtil