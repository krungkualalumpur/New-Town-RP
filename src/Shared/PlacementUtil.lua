--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--modules
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))


--module
local PlacementUtil = {}

--local functions
function PlacementUtil.SnapCFrame(selectedBasePart : BasePart, v3 : Vector3, grid : number, raycastResult : RaycastResult ?) : Vector3 ?
    assert(selectedBasePart, "Part not found!")
    assert(grid, "Grid required")

    if raycastResult and raycastResult.Instance:IsA("BasePart") then
        --function to return axis enum from a given v3
        local function axisFromV3(v3: Vector3) : Enum.Axis ?
            local v3Tbl = {
                {Axis = Enum.Axis.X; Value = math.abs(v3.X)};
                {Axis = Enum.Axis.Y; Value = math.abs(v3.Y)};
                {Axis = Enum.Axis.Z; Value = math.abs(v3.Z)}
            }
            --sort the table to sort from the largest value
            table.sort(v3Tbl, function(a : {Axis:Enum.Axis, Value:number} ,b : {Axis:Enum.Axis, Value:number}) return (a.Value > b.Value) end)

            for k,v in pairs(v3Tbl) do return v3Tbl[1].Axis end
            return nil
        end

        local faceNorm = raycastResult.Normal

        local faceV3 : Vector3, rDot : number = nil, -math.huge
        for i, face : Enum.NormalId in pairs(Enum.NormalId:GetEnumItems()) do
            local faceVector = Vector3.fromNormalId(face) :: Vector3 
            local td = selectedBasePart.CFrame:VectorToWorldSpace(faceVector):Dot(faceNorm)
            if td > rDot then
                rDot = td
                faceV3 = faceVector
            end
        end

        local faceObj = faceV3 :: Vector3

        local directionalFaceNorm = raycastResult.Instance.CFrame:VectorToObjectSpace(faceNorm) :: Vector3
        --local absoluteDirectionalFaceNorm = Vector3.new(math.abs(directionalFaceNorm.X), math.abs(directionalFaceNorm.Y), math.abs(directionalFaceNorm.Z))
        --round up v3 first
        --knowing which axis is it in
        local currentAxis : Enum.Axis? = axisFromV3(directionalFaceNorm)
        assert(currentAxis, "Error in reading axis")

        local function returnV3RoundedComp(axis: Enum.Axis, v3: Vector3)
            local v3Tbl = {X = v3.X, Y = v3.Y, Z = v3.Z}
            return currentAxis ~= axis and NumberUtil.roundNum(v3Tbl[axis.Name], grid) or v3Tbl[axis.Name]
        end
        local relativeV3 : Vector3 = raycastResult.Instance.CFrame:PointToObjectSpace(v3)

        --adjusting based on the touched normal axis
        relativeV3 = Vector3.new(
            returnV3RoundedComp(Enum.Axis.X, relativeV3),
            returnV3RoundedComp(Enum.Axis.Y, relativeV3),
            returnV3RoundedComp(Enum.Axis.Z, relativeV3)
        ) :: Vector3

        relativeV3 = relativeV3 + directionalFaceNorm * ((selectedBasePart.Size * 0.5) * faceObj).Magnitude 

        local snappedV3 = raycastResult.Instance.CFrame:PointToWorldSpace(relativeV3)

        --adjusting if its touching to wall
        --[[if
            raycastResult.Instance
            and raycastResult.Instance:IsA("BasePart")
            and (clientSystemRegistry[game.Players.LocalPlayer].ConstructTable.Model.PrimaryPart ~= raycastResult.Instance)
            and clientSystemRegistry[game.Players.LocalPlayer].clipToTouchedPart
            and clientSystemRegistry[game.Players.LocalPlayer].Model
            and clientSystemRegistry[game.Players.LocalPlayer].Model.PrimaryPart
        then
            snapCf = CFrame.new(v3)
                * (raycastResult.Instance.CFrame - raycastResult.Instance.CFrame.Position)
                * (clientSystemRegistry[game.Players.LocalPlayer].Rotation or CFrame.new(0, 0, 0)) --PROBLEM AGAIN!! :((
        end]]
    
        return  snappedV3
    else
        return Vector3.new(math.round(v3.X/grid)*grid, math.round(v3.Y/grid)*grid, math.round(v3.Z/grid)*grid)
    end
end

function PlacementUtil.scaleModel(model : Model, size : Vector3, oriSize : Vector3, sizeOffset : Vector3 ?, normal : Enum.NormalId ?)
    assert(model and model.PrimaryPart)
    local v3Normal = normal and Vector3.fromNormalId(normal) or Vector3.new(1,1,1)
    
    model.PrimaryPart.Size = sizeOffset and (oriSize + sizeOffset) or size
    if sizeOffset then
        --model:PivotTo(self._Maid.PreviewModel.PrimaryPart.CFrame + (self._Maid.PreviewModel.PrimaryPart.CFrame:VectorToWorldSpace(sizeOffset*0.5*v3Normal)))
    end
    return nil
end

function PlacementUtil.changeExpandablePartsDimension(model : Model, originalModel : Model, size : Vector3)
    assert(originalModel and originalModel.PrimaryPart, "Original model not found!")
    assert(originalModel ~= model, "Cannot edit the original model!")
    
    local sizeOffset : Vector3 = size - originalModel.PrimaryPart.Size

    assert(model.PrimaryPart)
    local expandableParts = model:FindFirstChild("ExpandableParts") :: Model 
    if not expandableParts then return end 

    for _,part : BasePart in pairs(expandableParts:GetDescendants() :: any) do
        if part:IsA("BasePart") and model.PrimaryPart ~= part then

            local v3Relative : Vector3 = model.PrimaryPart.CFrame:PointToObjectSpace(part.Position) 
            local closestNormal, minDist = nil, math.huge

            for _,normal : Enum.NormalId in pairs(Enum.NormalId:GetEnumItems()) do
                local normalv3 : Vector3 = model.PrimaryPart.CFrame:VectorToWorldSpace(Vector3.fromNormalId(normal))
                local dist : number = (normalv3 - v3Relative.Unit).Magnitude
                if dist < minDist then
                    closestNormal = normal
                    minDist = dist
                end
            end

            assert(closestNormal)

            local closestAxis, minDist2  = nil, math.huge
            for _,axis : Enum.Axis in pairs(Enum.Axis:GetEnumItems()) do
                for i = -1, 1, 2 do
                    local dist2 : number = (Vector3.fromNormalId(closestNormal) - (Vector3.fromAxis(axis)*i)).Magnitude
                    if dist2 < minDist2 then
                        closestAxis = axis
                        minDist2 = dist2
                    end
                end
            end

            --calculating offset based on size and stuff
            if not part:GetAttribute("Offset") then
                part:SetAttribute("Offset", model.PrimaryPart.CFrame:PointToObjectSpace(part.Position).Magnitude)
            end
            local offset : number = (sizeOffset*Vector3.fromAxis(closestAxis)*0.5).Magnitude + part:GetAttribute("Offset")
            print(closestAxis, sizeOffset)
            --end
            part.Position = model.PrimaryPart.Position + model.PrimaryPart.CFrame:VectorToWorldSpace(Vector3.fromNormalId(closestNormal)*offset)
        end
    end
end


return PlacementUtil
