--!strict
--services
--packages
--modules
--types
type PointData = {
	PointId : number,
	["Neighbours"] : {
		[number] : PointData
	},
	Obstacled : boolean,
	Cost : number,
	Came_From : PointData ?
}
--constants
--remotes
--variables
--references
--local functions
local function reverseTbl(t : {any})
	for i = 1, math.floor(#t/2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
end

local function newPointData(
	PointId : number,
	Cost : number,
	Obstacled : boolean,
	Came_From : PointData ?,
	Neighbours : {
		[number] : PointData
	} ?
) : PointData
	return {
		PointId = PointId,
		Cost = Cost,
		Came_From = Came_From,
		Obstacled = Obstacled,
		Neighbours = Neighbours or {}
	}
end

local function BFS(points : {PointData}, startPoint : PointData)	
	local explored : {PointData} = {}
	local queue : {PointData} = {}
	
	table.insert(queue, startPoint)
	
	do
		--local previousPoint : PointData ?
		local currentPointIndex = 1
		while #queue > 0 do
			local currentPoint = queue[currentPointIndex]

			for _,neighborPoint in pairs(currentPoint.Neighbours) do
				if (not table.find(explored, neighborPoint)) and (not table.find(queue, neighborPoint)) and (neighborPoint.Obstacled == false) then
					table.insert(queue, neighborPoint)
				end
			end
			
			table.remove(queue, currentPointIndex)
			--if not table.find(explored, currentPoint) then
			table.insert(explored, currentPoint)	
			--end
			
			--[[currentPoint.Came_From = previousPoint
			
			previousPoint = currentPoint]]
			
			
			task.wait()
		end
	end
	
	return explored
end

local function simple_Pathfind_algorithm(points : {PointData}, startPoint : PointData, endPoint : PointData) : {[PointData] : PointData ?}
	local cameFrom : {[PointData] : PointData ?} = {}
	local queue : {PointData} = {}
	
	table.insert(queue, startPoint)
	cameFrom[startPoint] = nil
	do
		local currentPointIndex = 1
		while #queue > 0 do
			local currentPoint = queue[currentPointIndex]
			

			for _,neighborPoint in pairs(currentPoint.Neighbours) do
				if (not cameFrom[neighborPoint]) and (not table.find(queue, neighborPoint)) and (neighborPoint.Obstacled == false) then
					table.insert(queue, neighborPoint)
					cameFrom[neighborPoint] = currentPoint
				end
			end

			table.remove(queue, currentPointIndex)
			
			-- early exit
			if currentPoint == endPoint then
				break
			end

			task.wait()
		end
	end

	return cameFrom
end

local function djikstra_pathfind(points : {PointData}, startPoint : PointData, endPoint : PointData) : {[PointData] : PointData ?} 
	local cameFrom : {[PointData] : PointData ?} = {}
	local cost_so_far : {[PointData] : number} = {}
	local priorityQueue : {
		[number] : {
			PointData :	PointData,
			Priority : number
		},
	} = {}
	
	local function insertToPriorityQueue(pointData : PointData, priority : number)
		table.insert(priorityQueue, {
			PointData = pointData,
			Priority = priority
		})
		return
	end
	
	insertToPriorityQueue(startPoint, startPoint.Cost)
	--table.insert(priorityQueue, startPoint)
	cameFrom[startPoint] = nil
	cost_so_far[startPoint] = 0
	do
		local currentPointIndex = 1
		while #priorityQueue > 0 do
		
			local currentPoint = priorityQueue[currentPointIndex].PointData

			for _,neighborPoint in pairs(currentPoint.Neighbours) do
				local new_cost = cost_so_far[currentPoint] + neighborPoint.Cost			

				if ((not cost_so_far[neighborPoint]) or (new_cost < cost_so_far[neighborPoint])) and (neighborPoint.Obstacled == false) then
					cost_so_far[neighborPoint] = new_cost
					--table.insert(priorityQueue, neighborPoint)
					insertToPriorityQueue(neighborPoint, new_cost)
					cameFrom[neighborPoint] = currentPoint
				end
			end

			table.remove(priorityQueue, currentPointIndex)

			-- early exit
			if currentPoint == endPoint then
				break
			end

			--task.wait()
		end
	end
	return cameFrom 
end

local function processPathfindOutput(output : {[PointData] : PointData ?}, startN : number, endN : number): {[number] : PointData}
	local pointsData = {}
	for k,v in pairs(output) do
		if k and k.PointId == endN then
			local currentK : PointData ? = k
			while currentK ~= nil do
				task.wait()
				table.insert(pointsData, currentK)
				currentK = output[currentK]
				if currentK.PointId == startN then
					table.insert(pointsData, currentK)
					currentK = nil
				end
			end
			break
		end 
		task.wait()
	end
	
	reverseTbl(pointsData)
	return pointsData
end
--class
local Pathfind = {}

function Pathfind.breadthFirstSearch(points : {PointData}, startPoint : PointData)
	return BFS(points, startPoint)
end
function Pathfind.djikstraPathfinding(points : {PointData}, startPoint : PointData, endPoint : PointData)
	local output = djikstra_pathfind(points, startPoint, endPoint)
	return processPathfindOutput(output, startPoint.PointId, endPoint.PointId)
end
--
return