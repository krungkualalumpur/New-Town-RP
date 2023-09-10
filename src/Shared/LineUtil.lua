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


return LineUtil