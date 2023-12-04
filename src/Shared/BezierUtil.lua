--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local CustomEnum = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
--modules
--types
--constants
--variables
--references
--local functions
--class
local BezierUtil = {}

function BezierUtil.getBezierPoint(
    pointsArray : {[number] : CFrame}, 
    lerpAlpha : number, 
    interval : number
) : CFrame

	pointsArray = pointsArray or {}

	local lerpPoint = {}

	for n : number,cf : CFrame in pairs(pointsArray) do
		local point1 = pointsArray[n]
		local point2 = pointsArray[n + 1]

		if point1 and point2 then
			table.insert(lerpPoint, CFrame.lookAt(point1:Lerp(point2, lerpAlpha).Position, point1:Lerp(point2, lerpAlpha + interval).Position))

		end
	end

	if #lerpPoint > 0 then
		local curvePoint = BezierUtil.getBezierPoint(lerpPoint, lerpAlpha, interval)
		if curvePoint then
			return curvePoint
		end
	end

	if #pointsArray == 1 then
		return pointsArray[1]
	end

    error("Cannot get the bezier point")
end

function BezierUtil.bezierify(points : {[number] : CFrame}, quality : CustomEnum.BezierQuality) : {[number] : CFrame}
	local ptsTbl = {}

    local interval = if quality == CustomEnum.BezierQuality.High then 0.05 elseif quality == CustomEnum.BezierQuality.Medium then 0.2 else 0.35
	for i = 0, 1, interval do
		--task.spawn(function()
		local p = BezierUtil.getBezierPoint(points, i, interval)
		table.insert(ptsTbl, p)
		--end)
	end
	return ptsTbl
end

return BezierUtil