--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local SIZE_RANGE = 35

local LOD_TAG = "LODItem"
local ADAPTIVE_LOD_TAG = "AdaptiveLODItem"
local LOD_OCCLUSION_TAG = "LODOcclusion"
--variables

--references
local Assets = workspace:WaitForChild("Assets")
--local functions
local function mergeBlockZAxis(tbl : {[number] : BasePart}, tblParent : {[number] : {[number] : BasePart}}, tblBlockMerged, sizeRange : number ?)
    local occlusionBoundingParts = workspace:WaitForChild("Assets"):WaitForChild("OcclusionFolder"):WaitForChild("OcclusionBoundingParts")

    local _sizeRange = sizeRange or SIZE_RANGE
    local cf : CFrame ?, _size : Vector3 

	local n = 0
	local pos = Vector3.new()

	_size = Vector3.new()
	
	
	for k,v in pairs(tbl) do

		local nextPart = tbl[k + 1]

		local dist
		if nextPart then
			dist = math.round((nextPart.Position - v.Position).Magnitude)
		end

		cf = v.CFrame
		pos += v.Position
		_size = Vector3.new(v.Size.X, v.Size.Y, _size.Z + v.Size.Z)
		n += 1			

		tbl[k] = nil

		v:Destroy()

		if dist and (dist ~= _sizeRange) then
			--print(tbl, tblBlockMerged)
			mergeBlockZAxis(tbl, tblParent, tblBlockMerged)
			--task.wait(0.5)
			break	
		end
	end
	

	pos = pos/n

	cf = if cf then CFrame.new(pos)*(cf - cf.Position) else nil
	
	if cf then 
		local p = Instance.new("Part") :: BasePart
		p.Anchored = true
		p.CFrame = cf
		p.Size = _size
        p.CanCollide = false
		p.Transparency = 1
		p.Parent = occlusionBoundingParts 
		
		table.insert(tblBlockMerged, p)
		--print(tblBlockMerged)
	end
	
	table.insert(tblParent, tblBlockMerged)

	table.remove(tblParent, table.find(tblParent, tbl))
end

local function mergeBlockYAxis(
	tbl : {[number] : {[number] : BasePart}}, 
	tblParent : {[number] : { [number] : BasePart} | {[number] : { [number] : BasePart}}}, 
	tblBlockMerged,
    sizeRange : number ?
)
    
    local occlusionBoundingParts = workspace:WaitForChild("Assets"):WaitForChild("OcclusionFolder"):WaitForChild("OcclusionBoundingParts")

    local _sizeRange = sizeRange or SIZE_RANGE

	local _blocksMerged = {}
	
	for k,v in pairs(tbl) do
		local nextPartTbl = tbl[k + 1]

		if nextPartTbl then
			for _, nextP in pairs(nextPartTbl) do
				for _,p in pairs(v) do
					local dist = math.round((nextP.Position - p.Position).Magnitude)
					if dist == _sizeRange then
						local existingBlocksArray = {}
						for _,blocksArray in pairs(_blocksMerged) do
							if table.find(blocksArray, nextP) or table.find(blocksArray, p) then
								existingBlocksArray = blocksArray
								
								break
							end 
						end
						
						if table.find(_blocksMerged, existingBlocksArray) then
							if not table.find(existingBlocksArray, p) then
								table.insert(existingBlocksArray, p)
							end
							if not table.find(existingBlocksArray, nextP) then
								table.insert(existingBlocksArray, nextP)
							end
						else
							table.insert(existingBlocksArray, p)
							table.insert(existingBlocksArray, nextP)
							
							table.insert(_blocksMerged, existingBlocksArray)
						end
					end

				end
			end
		end
	end
	
	for _,blocksArray in pairs(_blocksMerged) do
		local cf, _size 

		local n = 0
		local pos = Vector3.new()

		_size = Vector3.new()
		
		for _,p in pairs(blocksArray) do
			cf = p.CFrame
			pos += p.Position
			_size = Vector3.new(p.Size.X, _size.Y + p.Size.Y, p.Size.Z)
			n += 1	
			
			p:Destroy()
			
			for _,blockOrderArray in pairs(tbl) do
				local partI = table.find(blockOrderArray, p)
				if partI then
					table.remove(blockOrderArray, partI)
				end
			end
		end
		
		pos = pos/n

		cf = CFrame.new(pos)*(cf - cf.Position)
		
		local p = Instance.new("Part") :: BasePart
		p.Anchored = true
		p.CFrame = cf
		p.Size = _size
		p.Transparency = 1
        p.CanCollide = false
		p.Parent = occlusionBoundingParts 
		
		table.insert(tblBlockMerged, p)
	end
	
	table.insert(tblParent, tblBlockMerged)

	table.remove(tblParent, table.find(tblParent, tbl))
	
	--inserting the left overs/unmerged parts
	for _,v in pairs(tbl) do
		for _,p in pairs(v) do
			table.insert(tblBlockMerged, p)
		end
	end
end

local function mergeBlocks(tbl : {[number] : {[number] : BasePart}}, sizeRange : number?)
    local occlusionBoundingParts = workspace:WaitForChild("Assets"):WaitForChild("OcclusionFolder"):WaitForChild("OcclusionBoundingParts")
  
    local _sizeRange = sizeRange or SIZE_RANGE

    local totalBlocksMerged = {}
	local _blocksMerged = {}

	for k,v in pairs(tbl) do
		--print(k, v)
		local nextPartTbl = tbl[k + 1]

		if nextPartTbl then
			for _, nextP in pairs(nextPartTbl) do
				
				for _,p in pairs(v) do
					local dist = math.round((nextP.Position - p.Position).Magnitude)
					local dot = math.round(p.CFrame.LookVector:Dot((nextP.Position - p.Position).Unit)*100)/100 
					local size = math.round((p.Size - nextP.Size).Magnitude*100)/100

                    if dist == _sizeRange and dot == 0 and size == 0 then --filtering distance, parallelness, and size
						local existingBlocksArray = {}
						for _,blocksArray in pairs(_blocksMerged) do
							if table.find(blocksArray, nextP) or table.find(blocksArray, p) then
								existingBlocksArray = blocksArray

								break
							end 
						end

						if table.find(_blocksMerged, existingBlocksArray) then
							if not table.find(existingBlocksArray, p) then
								table.insert(existingBlocksArray, p)
							end
							if not table.find(existingBlocksArray, nextP) then
								table.insert(existingBlocksArray, nextP)
							end
						else
							table.insert(existingBlocksArray, p)
							table.insert(existingBlocksArray, nextP)

							table.insert(_blocksMerged, existingBlocksArray)
						end
					end
				end
				
			end
		end
	end	
	
	for _,blocksArray in pairs(_blocksMerged) do
		local cf, _size 

		local n = 0
		local pos = Vector3.new()

		_size = Vector3.new()

		for _,p in pairs(blocksArray) do
			cf = p.CFrame
			pos += p.Position
			_size = Vector3.new(_size.X + p.Size.X,  p.Size.Y, p.Size.Z)
			n += 1	

			p:Destroy()
			
			for _,blockOrderArray in pairs(tbl) do
				local partI = table.find(blockOrderArray, p)
				if partI then
					table.remove(blockOrderArray, partI)
				end
			end

		end

		pos = pos/n

		cf = CFrame.new(pos)*(cf - cf.Position)

		local p = Instance.new("Part") :: BasePart
		p.Anchored = true
		p.CFrame = cf
		p.Size = _size
		p.Transparency = 1
        p.CanCollide = false
		p.Parent = occlusionBoundingParts 

		table.insert(totalBlocksMerged, p)		
	end

	--inserting the left overs/unmerged parts
	
	table.insert(tbl, totalBlocksMerged)
	
	local function tblKeyDeletion(ifConditionFn : (val : any) -> boolean)
		for k,v in pairs(tbl) do
			if ifConditionFn(v) then
				table.remove(tbl, k)
				tblKeyDeletion(ifConditionFn)
				break
			end
		end
	end
	tblKeyDeletion(function(val)
		if #val == 0 then
			return true
		end
		return false
	end)
end


--class
local OptimizationSys = {}

function OptimizationSys.init(maid : Maid)
    local occlusionFolder = Instance.new("Folder")
    occlusionFolder.Name = "OcclusionFolder"
    occlusionFolder.Parent = Assets

    local occlusionBoundingParts = Instance.new("Folder")
    occlusionBoundingParts.Name = "OcclusionBoundingParts"
    occlusionBoundingParts.Parent = occlusionFolder

    for _,model in pairs(CollectionService:GetTagged(LOD_OCCLUSION_TAG)) do
        local _sizeRange = model:GetAttribute("OcclusionBoxSize") or SIZE_RANGE 
        local cf, size = model:GetBoundingBox()
        size *= 3
    
        local overlapParams = OverlapParams.new()
        overlapParams.FilterDescendantsInstances = {model:GetChildren()}
        overlapParams.FilterType = Enum.RaycastFilterType.Include
    
        local tbl = {}
    
        for x = 0, size.X, _sizeRange do
            local xTbl = {}
            table.insert(tbl, xTbl)
            for y = 0, size.Y, _sizeRange do
                local yTbl = {}
                table.insert(xTbl, yTbl)
                for z = 0, size.Z, _sizeRange do
                    local p = Instance.new("Part") :: BasePart
                    p.CFrame = (cf:ToWorldSpace(CFrame.new(x, y, z) - size*0.5)) 
                    p.Size = Vector3.new(math.clamp(size.X, 0, _sizeRange), math.clamp(size.Y, 0, _sizeRange), math.clamp(size.Z, 0, _sizeRange))
                    p.Transparency = 1
                    p.CanCollide = false
        
                    p.Anchored = true
                    p.Parent = occlusionBoundingParts
                    if #workspace:GetPartsInPart(p, overlapParams) == 0 then
                        p:Destroy()
                    else
                        table.insert(yTbl, p)
                    end
                end
                
                --merging block
                local yTblMerged = {}
                
                
                mergeBlockZAxis(yTbl, xTbl, yTblMerged, _sizeRange)
                
                --
                --table.insert(xTbl, yTblMerged)
            end
            
            ---
            local xTblMerged = {}
            mergeBlockYAxis(xTbl, tbl, xTblMerged, _sizeRange)
            task.wait() 

        end
        
        mergeBlocks(tbl :: any, _sizeRange)
        
        local detailModels = Instance.new("Model")
        detailModels.Name = "DetailModels"
        detailModels.Parent = occlusionFolder
        
        for _,partsArray in pairs(tbl) do
            --local parts = workspace:GetPartsInPart()
            for _, occlusionPart : BasePart in pairs(partsArray :: any) do
                local parts = workspace:GetPartsInPart(occlusionPart, overlapParams)
                
                local detailModel = Instance.new("Model")
                detailModel.Name = "DetailModel"
                detailModel.Parent = detailModels

                local detailModelPointer = Instance.new("ObjectValue")
                detailModelPointer.Name = "DetailModelPointer"
                detailModelPointer.Value = detailModel
                detailModelPointer.Parent = occlusionPart

                for _,part in pairs(parts) do
                    part.Parent = detailModel
                end
            end
        end
    end

    print("Opt init done")
end


return OptimizationSys