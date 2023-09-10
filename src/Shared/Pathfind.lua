--!nonstrict
--modules
local LineUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("LineUtil"))

function BFS(paths, startN, endN)
	local points = {}
	local queue = {startN}

	if not paths[startN] then
		return false
	end

	local currentPoint = startN

	while #queue > 0 do
		--remove previous point from queue
		table.remove(queue, table.find(queue, currentPoint))

		--add to queue
		for _,neighborPoint in pairs(paths[currentPoint].Connector) do
			if not table.find(queue, neighborPoint.N) and not table.find(points, neighborPoint.N) then
				print(currentPoint, neighborPoint.N)
				table.insert(queue, neighborPoint.N)
			end
		end

		--add into detected points
		table.insert(points, currentPoint)

		--if it reaches the end
		if currentPoint == endN then
			break
		end

		--moving onto the next point for the loop
		currentPoint = queue[1]

		task.wait()
	end

	return points
end


function PathfindAlgorithm(paths, startN, endN)
	local points = {}
	local queue = {}

	table.insert(queue, {N = startN, Came_From = nil})

	if not paths[startN] then
		return false
	end

	local function findNinPoints(n)
		for _,v in pairs(points) do
			if v.N == n then
				return v
			end
		end
	end

	local function findNinQueue(n)
		for _,v in pairs(queue) do
			if v.N == n then
				return v
			end
		end
	end

	local currentQueue = findNinQueue(startN)

	while #queue > 0 do

		--remove previous point from queue
		table.remove(queue, table.find(queue, currentQueue))

		--add to queue
		for _,neighborPoint in pairs(paths[currentQueue.N].Connector) do
			if not findNinQueue(neighborPoint.N) and not findNinPoints(neighborPoint.N) and not neighborPoint.Blocked then
				table.insert(queue, {N = neighborPoint.N, Came_From = currentQueue.N})
			end
		end

		--add into detected points
		table.insert(points, {N = currentQueue.N, Came_From = currentQueue.Came_From})

		--simple pathfinding by reversing the trajectory by knowing where it's from
		if currentQueue and currentQueue.N == endN then --if it reaches the end
			local route = {}
			--defining current point and came from 
			local currentPoint = currentQueue
			local cameFrom = currentQueue.Came_From
			table.insert(route, currentPoint)

			--looping to trace back until the came_from is nil
			while cameFrom ~= nil do
				currentPoint = findNinPoints(cameFrom)
				cameFrom = currentPoint.Came_From

				--recording the traceback into 'route' array
				table.insert(route, currentPoint)
			end

			--returning the route
			return route
		end		

		--moving onto the next point for the loop
		currentQueue = queue[1]	

		--task.wait()
	end

	return points
end

function Dijkstra(paths, startN, endN)
	local points = {}
	local queue = {}

	table.insert(queue, {N = startN, Came_From = nil, Cost_So_Far = 0})

	if not paths[startN] then
		return false
	end

	local function findNinPoints(n)
		for _,v in pairs(points) do
			if v.N == n then
				return v
			end
		end
	end

	local function findNinQueue(n)
		for _,v in pairs(queue) do
			if v.N == n then
				return v
			end
		end
	end
	
	local function findNinCameFrom(n)
		for _,v in pairs(points) do
			if v.Came_From == n then
				return v
			end
		end
	end
	
	local currentQueue = findNinQueue(startN)

	while #queue > 0 do	
		--task.wait()
		--print(currentQueue.N, " = current Q")
		--remove previous point from queue
		table.remove(queue, table.find(queue, currentQueue))

		--add to queue
		for _,neighborPoint in pairs(paths[currentQueue.N].Connector) do
			if (#queue < 10 and not (findNinQueue(neighborPoint.N) and findNinCameFrom(neighborPoint.N)) or not findNinQueue(neighborPoint.N)) and not findNinPoints(neighborPoint.N) and not neighborPoint.Blocked then
				--print("insert ".. neighborPoint.N)
				table.insert(queue, {N = neighborPoint.N, Came_From = currentQueue.N, Cost_So_Far = currentQueue.Cost_So_Far + neighborPoint.Cost})
			end
		end

		--add into detected points
		table.insert(points, {N = currentQueue.N, Came_From = currentQueue.Came_From, Cost = currentQueue.Cost_So_Far})

		--simple pathfinding by reversing the trajectory by knowing where it's from
		if currentQueue and currentQueue.N == endN then
			local route = {}
			--defining current point and came from 
			local currentPoint = currentQueue
			local cameFrom = currentQueue.Came_From
			table.insert(route, currentPoint)
			--looping to trace back until the came_from is nil
			while cameFrom ~= nil do
				currentPoint = findNinPoints(cameFrom)
				cameFrom = currentPoint.Came_From

				--recording the traceback into 'route' array
				table.insert(route, currentPoint)
			end

			--flipping to provide accurate dest sequence and checking if theres end dest...
			local adjustedRoute = {}

			local endNavailable = false

			for i,v in pairs(route) do
				adjustedRoute[#route - i + 1] = v 
				if v.N == endN then
					endNavailable = true
				end
			end

		--	print(adjustedRoute)
			--returning the route
			return endNavailable and adjustedRoute
		end

		--moving onto the next point for the loop
		--currentQueue = queue[1]	
		--print(queue)
		local lowestCost = math.huge
		for _,v in pairs(queue) do
		--	print(v.Cost_So_Far, "<", lowestCost,"?")
			if v.Cost_So_Far < lowestCost then
			--	print("True!")
				lowestCost = v.Cost_So_Far
				currentQueue = v
			else
			--	print("FAlse1")
			end
		end
		--task.wait()
	end
	
	
end

function DFS(tbl, startNode, detectDeadend, detectCircle, mainPoint) --tbl = adjacency list
	local function countTbl(anyTbl)
		local tblCount = 0
	
		for i,v in pairs(anyTbl) do
			tblCount += 1
		end
	
		return tblCount
	end

	if detectDeadend then
		local function removeDeadEnds()
			for i,v in pairs(tbl) do
				local neighbours = v.Neighbours
				if countTbl(neighbours) <= 1 --[[and not neighbours[startNode]] then
					task.wait()

					if i == startNode and countTbl(v.Neighbours) >= 1 then
						for index,_ in pairs(v.Neighbours) do
							startNode = index
							break
						end
					end

					--[[if tbl[i] ~= nil then
						local p = Instance.new("Part")
						p.Transparency = 0.9
						p.Name = "cCepecp"
						p.Size = Vector3.new(10,10,10)
						p.Color = Color3.fromRGB(255, 0, 0)
						p.Position = tbl[i].Position
						p.Anchored = true
						p.Parent = workspace
					end]]

					tbl[i] = nil

					for _,v in pairs(tbl) do
						v.Neighbours[i] = nil
					end

					removeDeadEnds()
					return 
				end
			end

		end

		removeDeadEnds()
	end

	--print(tbl)

	if countTbl(tbl) == 0 then
		return false
	end

	local terminate = false

	local dir

	do
		local firstNeighborPos
		
		if not tbl[startNode] then
			return false
		end

		for i,v in pairs(tbl[startNode].Neighbours) do
			firstNeighborPos = v
			break
		end

		if not firstNeighborPos then
			return false
		end
		dir = ((mainPoint - tbl[startNode].Position).Unit:Cross((firstNeighborPos - tbl[startNode].Position).Unit)).Y
		--[[if dir == -1 then
			dir = 0
		end]]
	end

	--setting index and avg dir
	for i,v in pairs(tbl) do
		v.Index = v.Index or i
	end

	--local n = #tbl
	local visited = {} --n = #tbl
	local ptsInOrder = {}

	local came_From
	local function _dFS(at)
		if terminate or visited[at] or tbl[at] == nil then
			return false
		end
		visited[at] = true

		table.insert(ptsInOrder, {Position = tbl[at].Position, Index = tbl[at].Index, cameFrom = came_From, Neighbours = tbl[at].Neighbours})
		local initialCame_From = came_From
		came_From = tbl[at]
		local neighbours = tbl[at].Neighbours

		--delete the deleted neighbors
		for i,v in pairs(neighbours) do
			if tbl[i] == nil then
				neighbours[i] = nil
			end
		end

		for i,v in pairs(neighbours) do

			--[[print('cheley')
			]]
			local neighborIndexChosen 

			if detectCircle then
				--if it branches to more than two neighbors, find out which one has the same direction to the one before..
				do
					local maxAngle = math.huge

					for i2,v2 in pairs(neighbours) do
						local plusOrMinus = math.sign(dir)
						local localDir = math.sign((((initialCame_From and tbl[initialCame_From.Index].Position or mainPoint) - tbl[at].Position).Unit:Cross((v2 - tbl[at].Position).Unit)).Y)
						local deg = math.deg(math.acos((((initialCame_From and tbl[initialCame_From.Index].Position or mainPoint) - tbl[at].Position).Unit:Dot((v2 - tbl[at].Position).Unit))))*(localDir == 0 and 1 or localDir)

						if ((plusOrMinus < 0 and localDir < 0 and math.abs(deg) <= maxAngle) or (plusOrMinus >= 0 and localDir >= 0 and math.abs(deg) <= maxAngle)) and (not visited[i2] or (countTbl(ptsInOrder) >= 3 and i2 == startNode)) then 
							--print("test!")
							maxAngle = math.abs(deg)
							neighborIndexChosen = i2

							--[[local p = Instance.new("Part")
							p.Transparency = 0
							p.Name = "cCepecp"
							p.Size = Vector3.new(3,5,3)
							p.Color = Color3.fromRGB(255, 240, 16)
							p.Position = v2
							p.Anchored = true
							p.Parent = workspace

							local p2 = Instance.new("Part")
							p2.Transparency = 0
							p2.Name = "cCepecp"
							p2.Size = Vector3.new(5,5,5)
							p2.Color = Color3.fromRGB(0, 0, 0)
							p2.Position = tbl[at].Position
							p2.Anchored = true
							p2.Parent = workspace

							local p3 = Instance.new("Part")
							p3.Transparency = 0
							p3.Name = "cCepecp"
							p3.Size = Vector3.new(3,5,3)
							p3.Color = Color3.fromRGB(247, 6, 6)
							p3.Position = initialCame_From and tbl[initialCame_From.Index].Position or mainPoint
							p3.Anchored = true
							p3.Parent = workspace
							wait()
							p:Destroy()
							p2:Destroy()
							p3:Destroy()]]


						end
						print("Dir:", dir, "Deg:", deg, "i2: ".. i2, "Neigindchos:", neighborIndexChosen, "at:", at)
					end

					if neighborIndexChosen == nil then
						local count = 0
						for i2,v2 in pairs(neighbours) do
							count += 1
							if not visited[i2] or i2 == startNode then
								neighborIndexChosen = i2
								break
							end
						end

						if count == 1 and not neighborIndexChosen then
							for i2,v2 in pairs(neighbours) do
								neighborIndexChosen = i2
							end
						end
					end
				end

			end


			--[[if detectCircle then --effects
				--[[print(neighborIndexChosen, "luakh")
				local p = Instance.new("Part")
				p.Transparency = 0.9
				p.Name = "cCepecp"
				p.Size = Vector3.new(10,10,10)
				p.Color = Color3.fromRGB(42, 74, 255)
				p.Position = tbl[at].Position
				p.Anchored = true
				p.Parent = workspace

				--[[task.wait()

				if neighborIndexChosen then
					local p2 = Instance.new("Part")
					p2.Transparency = 0.9
					p2.Name = "cCepecp"
					p2.Size = Vector3.new(10,10,10)
					p2.Color = Color3.fromRGB(92, 255, 17)
					p2.Position = tbl[neighborIndexChosen].Position
					p2.Anchored = true
					p2.Parent = workspace
					task.wait()
					p2:Destroy()
				end
				p:Destroy() 
			end]]

			if  detectCircle == nil or ((detectCircle and neighborIndexChosen and i == neighborIndexChosen)) then
				if countTbl(ptsInOrder) >= 3 and (neighborIndexChosen == startNode or at == startNode)then
					terminate = true
					--print("termineit?")
				end

				--print(i, " test?")
				_dFS(i)	

			end
		end
	end

	_dFS(startNode)

	return ptsInOrder
end

local module = {}

module.BFS = BFS
module.DFS = DFS



--path 

function addPoint(v3, connectors, parent, ptName)
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

function CreatePathSys(rawPts, roadPtsParent)
	--refresh road pts
	roadPtsParent:ClearAllChildren()

	--extract raw points into road pts 
	for _,lineFolder in pairs(rawPts:GetChildren()) do
		for _, pt in pairs(lineFolder:GetChildren()) do
			local nextPt = tonumber(pt.Name) and lineFolder:FindFirstChild(tostring(tonumber(pt.Name) + 1)) or nil
			local prevPt = tonumber(pt.Name) and lineFolder:FindFirstChild(tostring(tonumber(pt.Name) - 1)) or nil

			local p = addPoint(pt.Position, {prevPt and roadPtsParent:GetChildren()[#roadPtsParent:GetChildren()]} , roadPtsParent)
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
			
			--two points that form a line
			local currentPt = tonumber(pt.Name) and lineFolder:FindFirstChild(pt.Name)
			local nextPt = tonumber(pt.Name) and lineFolder:FindFirstChild(tostring(tonumber(pt.Name) + 1))

			local prevPt = tonumber(pt.Name) and lineFolder:FindFirstChild(tostring(tonumber(pt.Name) - 1))
			
			if currentPt and nextPt then
				totalLength += (currentPt.Position - nextPt.Position).Magnitude
				--iterate through other lines
				for _,lineFolder2 in pairs(rawPts:GetChildren()) do
					if lineFolder ~= lineFolder2 then
						for _,pt2 in pairs(lineFolder2:GetChildren()) do
							local currentPt2 = tonumber(pt2.Name) and lineFolder2:FindFirstChild(pt2.Name)
							local nextPt2 = tonumber(pt2.Name) and lineFolder2:FindFirstChild(tostring(tonumber(pt2.Name) + 1))

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
									for _,v in pairs(roadPtsParent:GetChildren()) do
										if v:GetAttribute("isIntersection") and (intersectV3 - v.Position).Magnitude < 5 then
											noPointsNear = false
											break
										end
									end

									if noPointsNear then
										local function findInRoadPt(instance)
											for _,v in pairs(roadPtsParent:GetChildren()) do
												if math.floor((v.Position - instance.Position).Magnitude) == 0 then
													return v
												end
											end
										end

										local p = addPoint(intersectV3, {findInRoadPt(currentPt), findInRoadPt(nextPt), findInRoadPt(currentPt2), findInRoadPt(nextPt2)} , roadPtsParent)
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
		for _,v in pairs(lineFolder:GetChildren()) do
			local avgDist = totalLength/#lineFolder:GetChildren()
			local n = tonumber(v.Name)
			if n and (n ~= 1 or n ~= #lineFolder:GetChildren()) and (n*2)%(totalLength/#lineFolder:GetChildren()) < 2 then
				v.Size += Vector3.new(0, 0.01,0.5)
				v.TopSurface = Enum.SurfaceType.Smooth
				v.BottomSurface = Enum.SurfaceType.Smooth
				v.Transparency = 0
			end
		end
	end
end

module.CreatePathSys = CreatePathSys
--

return setmetatable(module, {
	__call = function(k, tbl, startN, endN)
		--while wait() do
		if typeof(tbl) == "Instance" then
			for i,v in pairs(tbl:GetChildren()) do
				if tonumber(v.Name) == nil then
					warn("Name your points in number first!")
					return false
				end
			end
			local pathModel = tbl
			tbl = {}


			for _,part in pairs(pathModel:GetChildren()) do
				if tonumber(part.Name) and part:IsA("BasePart") then
					tbl[tonumber(part.Name)] = {N = tonumber(part.Name), Connector = {}, Blocked = part:GetAttribute("Blocked")}
					for i,v in pairs(part:GetChildren()) do
						if v:IsA("ObjectValue") then
							table.insert(tbl[tonumber(part.Name)].Connector, {N = tonumber(v.Value.Name), Cost = v:GetAttribute("Cost") or (v.Value.Position - part.Position).Magnitude, Blocked = v.Value:GetAttribute("Blocked")})
						end
					end
				end
			end
		end
		
--		print(tbl, "NUMBER?!")
		local path = Dijkstra(tbl, startN, endN)
		return path
	end,
})
