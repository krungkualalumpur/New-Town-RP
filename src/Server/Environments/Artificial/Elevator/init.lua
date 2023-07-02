--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid

export type Elevator = {
	__index : Elevator,
	_Maid : Maid,
	_queue : {[number] : string | number},
	Model : Model,
	CurrentFloor : string,
	Status : "Ascending" | "Descending", 

	new : (elevatorModel : Model) -> Elevator,
	MoveElevator : (Elevator, floorDest : BasePart) -> (),
	UpdateUI : (Elevator) -> (),
	init : (maid : Maid) -> ()
}
--constants
--references
--variables
--local functions
function getMaxValueInKey(tbl : {number})
	local maxVal = -math.huge
	local key
	for k,v in pairs(tbl) do
		if maxVal < v then
			maxVal = v
			key = k
		end
	end
	return key
end

function getMinValueInKey(tbl : {[any] : number})
	local minVal = math.huge
	local key
	for k,v in pairs(tbl) do
		if minVal > v then
			minVal = v
			key = k
		end
	end
	return key
end

function getElevatorRelativePositionInNumber(elevPart : BasePart, floorDestPart : BasePart, flip : boolean) : number
	return ((elevPart.Position - floorDestPart.Position)*(if flip then -1 else 1)).Unit:Dot((if flip then -1 else 1)*floorDestPart.CFrame.UpVector)--prismaticConstraint.Velocity	
end


--class
local Elevator = {} :: Elevator
Elevator.__index = Elevator

function Elevator.new(elevatorModel : Model)
    local self : Elevator = setmetatable({}, Elevator) :: any 
    self._queue = {}
    self.CurrentFloor = ""
	self.Status = "Ascending"
    self.Model = elevatorModel
	self._Maid = Maid.new()

    --welding
	local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
	local buttons = elevCageModel:FindFirstChild("Buttons")

    local prismaticConstraint = elevPart:FindFirstChild("PrismaticConstraint") :: PrismaticConstraint

    for _,v in pairs(elevCageModel:GetDescendants()) do
        if v:IsA("BasePart") then
            local weldConst = Instance.new("Weld")
            weldConst.Part0 = v
            weldConst.Part1 = elevPart
            weldConst.C0 =  v.CFrame:Inverse()
            weldConst.C1 = elevPart.CFrame:Inverse()
            weldConst.Parent = v
        end
    end

	--marking highest and lowest floor
	local max = -math.huge
	local min = math.huge
	
	local highestFloor
	local lowestFloor
	if floors then
		for _,floorPart in pairs(floors:GetChildren()) do
			if floorPart:IsA("BasePart") then
				if max < floorPart.Position.Y then
					max = floorPart.Position.Y
					highestFloor = floorPart
				end

				if min > floorPart.Position.Y then
					min = floorPart.Position.Y
					lowestFloor = floorPart
				end
			end
		end

		--init buttons
		if buttons  then 

			for _,v in pairs(buttons:GetChildren()) do
				if v:IsA("Model") then
					local clickDetector = Instance.new("ClickDetector")
					clickDetector.MaxActivationDistance = 32
					clickDetector.Parent = v.PrimaryPart
					
					self._Maid:GiveTask(clickDetector.MouseClick:Connect(function()
						local floorDest = floors:FindFirstChild(v.Name) :: BasePart ?
						if floorDest then
							self:MoveElevator(floorDest)
						end
					end))
				end
			end

		end
	end



	if highestFloor and lowestFloor then
		highestFloor:SetAttribute("FloorTop", true)
		lowestFloor:SetAttribute("FloorBottom", true)
	end

    return self
end

function Elevator:MoveElevator(floorDest)	


	local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
	local buttons = elevCageModel:FindFirstChild("Buttons")
	local doors = elevCageModel:FindFirstChild("Doors")

	assert(floors and floorDest:IsDescendantOf(floors))
	assert(floors)
	assert(buttons)

    local prismaticConstraint = elevPart:FindFirstChild("PrismaticConstraint") :: PrismaticConstraint
	
	local function getPosNumRelativeToVel(elevRelativePosNum : number)
		return elevRelativePosNum*prismaticConstraint.Velocity
	end
	

	if prismaticConstraint then

		--setting up queues
		if not table.find(self._queue, floorDest.Name) then
			table.insert(self._queue, floorDest.Name)

			--rearrange queues
			if self.Status == "Ascending" then 
				table.sort(self._queue, function(a : any, b : any) --ascending order
					return a < b
				end)
			elseif self.Status == "Descending" then 
				table.sort(self._queue, function(a : any, b : any) --descending order
					return a > b
				end)
			end	
			print(self._queue)
		end

		do
			local buttonFloor = buttons:FindFirstChild(floorDest.Name) :: Model ?
			if buttonFloor and buttonFloor.PrimaryPart then buttonFloor.PrimaryPart.Material = Enum.Material.Neon end
		end

		--detecting if there's any queue left based on the direction/status
		local queuePresentForCurrentStatus = false
		for k,v in pairs(self._queue) do
			local floorPart = floors:FindFirstChild(tostring(v))
			if floorPart and floorPart:IsA("BasePart") then
				local direction = math.sign(getElevatorRelativePositionInNumber(elevPart, floorPart, false))
				if (self.Status == "Descending" and math.sign(direction) >= 0) or (self.Status == "Ascending" and math.sign(direction) <= 0) then
					queuePresentForCurrentStatus = true
				end
			end
		end

		--switch direction/status
		if not queuePresentForCurrentStatus then
			if self.Status == "Descending" then self.Status = "Ascending" elseif self.Status == "Ascending" then self.Status = "Descending" end
		end

		--condition filters
		if self._Maid.ElevatorMovement then return end
		if self.Model:GetAttribute("isOpening") then return end

		--		
		--local elevRelativePosNum = getElevatorRelativePositionInNumber(elevPart, floorDest)
		prismaticConstraint.Velocity = 10*(if self.Status == "Descending" then 1 else -1)
		--print(getElevatorRelativePositionInNumber(floorDest))
		--local posNumRelativeToVelocity =   getPosNumRelativeToVel(elevRelativePosNum)

		--[[local customFloor
		if self.Status == "Descending" and nearestFloorPart and table.find(self._queue, nearestFloorPart.Name) then
			local floorPartsList = {}
			for _,v in pairs(floors:GetChildren()) do
				if v:IsA("BasePart") then
					local elevRelativeFloorPosNum = getElevatorRelativePositionInNumber(v, nearestFloorPart :: BasePart)
					if math.sign(elevRelativeFloorPosNum) <= 0 then
						floorPartsList[v] = math.abs(elevRelativeFloorPosNum)
					end
				end
			end
			customFloor = getMinValueInKey(floorPartsList)
		end]]

		local arrivedFloorPart
		local intDir
		self._Maid.ElevatorMovement = RunService.Stepped:Connect(function()
			local floorList = {}
			for _,v in pairs(floors:GetChildren()) do
				local elevRelativeFloorPosNum = getElevatorRelativePositionInNumber(elevPart, v :: BasePart, false)
				floorList[v.Name] = math.abs(elevRelativeFloorPosNum) --elevRelativeFloorPosNum 
			end
		
			self.CurrentFloor = getMinValueInKey(floorList)
			self:UpdateUI()

			local nearestFloorPart = floors:FindFirstChild(self.CurrentFloor) :: BasePart?

			--print(floorList[self.CurrentFloor], floorList, self.CurrentFloor, nearestFloorPart and getElevatorRelativePositionInNumber(elevPart, nearestFloorPart))
			if nearestFloorPart and table.find(self._queue, nearestFloorPart.Name) then
				intDir = intDir or math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false))
				--print('eeeh?', intDir, math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)))
				if intDir ~= math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)) then
					--print('eeeh?', intDir, math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)))
					arrivedFloorPart = nearestFloorPart
				end
				--arrived = true
			end
			--print(floorList[self.CurrentFloor], floorList)
			if arrivedFloorPart then	
				print("hey?")
				self._Maid.ElevatorMovement = nil

				prismaticConstraint.Velocity = 0	
				table.remove(self._queue, table.find(self._queue, arrivedFloorPart.Name))

				print("open door")
				--button
				do
					local buttonFloor = buttons:FindFirstChild(arrivedFloorPart.Name) :: Model ?
					if buttonFloor and buttonFloor.PrimaryPart then buttonFloor.PrimaryPart.Material = Enum.Material.Metal end
				end
				
				if doors then
					self.Model:SetAttribute("isOpening", true)
					for _,v in pairs(doors:GetChildren()) do
						if v:IsA("BasePart") then
							v.Transparency = 1
							v.CanCollide = false
						end
					end
					task.wait(5)
					self.Model:SetAttribute("isOpening", nil)
					for _,v in pairs(doors:GetChildren()) do
						if v:IsA("BasePart") then
							v.Transparency = 0
							v.CanCollide = true
						end
					end
				end
				print('close door')
				

				print(self._queue, "NEW LEEEW!")
				task.wait()
				local nextFloor = if self._queue[1] then floors:FindFirstChild(tostring(self._queue[1])) :: BasePart else nil
				if nextFloor then
					self:MoveElevator(nextFloor)
				end
				--[[if table.find(self._queue, floorDest.Name) then
					print(self._queue, "STOP")
					table.remove(self._queue, table.find(self._queue, floorDest.Name))
					print(self._queue, "NEW LEEEW!")
					task.wait()
					local nextFloor = if self._queue[1] then floors:FindFirstChild(tostring(self._queue[1])) :: BasePart else nil
					if nextFloor then
						self:MoveElevator(nextFloor)
					end
				end]]
			end
			--math.sign(getElevatorRelativePositionInNumber(elevPart, floors:FindFirstChild(self.CurrentFloor) :: any))
		end)
			--local dynamicFloorDest = if self._queue[1] then floors:FindFirstChild(tostring(self._queue[1])) :: BasePart else nil

			--[[elevRelativePosNum = getElevatorRelativePositionInNumber(elevPart, floorDest)
			posNumRelativeToVelocity = getPosNumRelativeToVel(elevRelativePosNum)
			
			--ui
			local floorList = {}
			for _,v in pairs(floors:GetChildren()) do
				local elevRelativeFloorPosNum = getElevatorRelativePositionInNumber(elevPart, v :: BasePart)
				floorList[v.Name] = math.abs(elevRelativeFloorPosNum)
			end
			
			self:UpdateUI()

			if posNumRelativeToVelocity <= 0 then
				self._Maid.ElevatorMovement = nil
						
				prismaticConstraint.Velocity = 0	

				if table.find(self._queue, floorDest.Name) then
					print(self._queue, "STOP")
					table.remove(self._queue, table.find(self._queue, floorDest.Name))
					print(self._queue, "NEW LEEEW!")
					task.wait()
					local nextFloor = if self._queue[1] then floors:FindFirstChild(tostring(self._queue[1])) :: BasePart else nil
					if nextFloor then
						self:MoveElevator(nextFloor)
					end
				end
			end]]
	
		
	end
end

function Elevator:UpdateUI()
    local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")

	local floorIndicationPart = elevCageModel:FindFirstChild("Indications"):FindFirstChild("FloorLabel") 
	
	floorIndicationPart:FindFirstChild("SurfaceGui"):FindFirstChild("FloorName").Text = self.CurrentFloor
end

function Elevator.init(maid)
	for _,elevModel in pairs(CollectionService:GetTagged("Elevator")) do
		local elevator = Elevator.new(elevModel)
		--elevator:MoveElevator(elevModel:FindFirstChild("Floors"):FindFirstChild("3"))

		--elevator:MoveElevator(elevModel:FindFirstChild("Floors"):FindFirstChild("4"))
		--task.wait(1)
		--elevator:MoveElevator(elevModel:FindFirstChild("Floors"):FindFirstChild("2"))

	end
end

return Elevator
