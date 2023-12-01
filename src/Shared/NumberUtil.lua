--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Local Functions

local function getMilisecondsFromSecond(sec : number, decimalPlaces : number ?)
	return (sec - math.floor(sec))*(10^(decimalPlaces or 2))
end
-- Class
local NumberUtil = {}

NumberUtil.roundNum = function(num: number, check: number)
	return (num + (check / 2)) - ((num + (check / 2)) % check)
end

local function getAxisValue(v3: Vector3, axis: Enum.Axis): number
	return if axis == Enum.Axis.X then v3.X elseif axis == Enum.Axis.Y then v3.Y else v3.Z
end

local function alterv3Comp(v3: Vector3, axis: Enum.Axis, axisToIgnore: { [number]: Enum.Axis }, snapNum: number)
	local val = getAxisValue(v3, axis)
	return if not table.find(axisToIgnore, axis) then (val - (val % snapNum)) else val
end

function NumberUtil.snapVector3(obj: BasePart, v3: Vector3, snapNum: number, axisToIgnore: { [number]: Enum.Axis }?)
	axisToIgnore = axisToIgnore or {}
	assert(axisToIgnore ~= nil)
	local relativePos: Vector3 = obj.CFrame:PointToObjectSpace(v3)

	local snappedPos = Vector3.new(
		alterv3Comp(relativePos, Enum.Axis.X, axisToIgnore, snapNum),
		alterv3Comp(relativePos, Enum.Axis.Y, axisToIgnore, snapNum),
		alterv3Comp(relativePos, Enum.Axis.Z, axisToIgnore, snapNum)
	)
	return obj.CFrame:PointToWorldSpace(snappedPos)
end

function NumberUtil.Abbreviate(number : number)
	local abbreviations = {
		[0] = "",
		[1] = "k",
		[2] = "M",
		[3] = "G",
		[4] = "T",
		[5] = "P",
		[6] = "E",
		[7] = "Z",
		[8] = "Y",
		[9] = "R",
		[10] = "Q"
	}
	local index = math.floor(math.log(number, 10)/3)
	local abbrevSymbol = abbreviations[index] or "?"
	
	return string.format("%.2f", number/(10^(index*3))) .. abbrevSymbol
end

function NumberUtil.NotateDecimals(number : number, isMonetization : boolean)
	local decimalPoint = ","
	local fractionPoint = "."

	local numStr = ""
	local gmatchIndex = 0

	local roundedNum = math.round(number)

	for i in string.gmatch(string.reverse(tostring(roundedNum)), "%d") do
		gmatchIndex += 1
		numStr = numStr .. i .. if gmatchIndex%3 == 0 and gmatchIndex ~= #tostring(roundedNum) then decimalPoint else ""
	end
	numStr = string.reverse(numStr)

	return numStr .. if isMonetization then (fractionPoint .. string.format("%02d", math.round((number - math.floor(number))*100))) else ""
end

function NumberUtil.MonetizeNumber(number : number)
	return string.format("%s$%s", if math.sign(number) >= 0 then "" else "-", NumberUtil.NotateDecimals(math.abs(number), true))
end

function NumberUtil.NumberToClock(num : number, displaySecond : boolean, secondDecimalPlace : number ?)
	local miliseconds = getMilisecondsFromSecond(num, secondDecimalPlace)
	return string.format("%.1d:%.2d" .. (if displaySecond then ":%.2d" else "") .. (if displaySecond and secondDecimalPlace then (".%." .. tostring(secondDecimalPlace) .. "d") else ""), math.floor(num/(60*60)), math.floor((num/60)%60), if displaySecond then num%60 else nil, (if displaySecond and secondDecimalPlace then getMilisecondsFromSecond(num, secondDecimalPlace) else nil)) 
end

return NumberUtil
