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

type Direction = "Ascending" | "Descending"

type CallQueueData = {
	Direction : Direction,
	Floor : string | number
}

export type Elevator = {
	__index : Elevator,
	_Maid : Maid,
	_queue : {[number] : string | number},
	_callDownQueue : {[number] : string | number},
	_callUpQueue : {[number] : string | number},
	Model : Model,
	CurrentFloor : string,
	Status : Direction, 

	new : (elevatorModel : Model) -> Elevator,
	UpdateCurrentFloor : (Elevator) -> (),
	InsertFloorQueue : (Elevator, floorDest : BasePart, CallDirection : Direction ?) -> (),
	UpdateUI : (Elevator) -> (),
	ResetElevator : (Elevator) -> (),
	Destroy : (Elevator) -> (),
	init : (maid : Maid) -> ()
}
--constants
local FLOOR_TOP_KEY = "FloorTop"
local FLOOR_BOTTOM_KEY = "FloorBottom"

local SELECTED_COLOR = Color3.new(0.764706, 0.933333, 0.007843)
local DEFAULT_COLOR = Color3.fromRGB(128, 127, 130)

--references
--variables
--local functions
function weld(part0 : BasePart, part1 : BasePart)
	local weldConst = Instance.new("Weld") :: Weld
	weldConst.Part0 = part0
	weldConst.Part1 = part1
	weldConst.C0 =  part0.CFrame:Inverse()
	weldConst.C1 = part1.CFrame:Inverse()
	weldConst.Parent = part0
	return weldConst
end

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
	return (elevPart.Position.Y - floorDestPart.Position.Y) -- ((elevPart.Position - floorDestPart.Position)).Unit:Dot(floorDestPart.CFrame.UpVector)--prismaticConstraint.Velocity	
end

local function openCageDoor(elevModel : Model, openTime : number, floorName : string ?)
	local elevCageModel = elevModel:FindFirstChild("Elevator") :: Model
	local elevPart = elevCageModel.PrimaryPart :: BasePart
	local buttons = elevCageModel:FindFirstChild("Buttons")
	local doors = elevCageModel:FindFirstChild("Doors")
	local elevatorGates = elevModel:FindFirstChild("ElevatorGates")

	local tweenTime = 2

	if elevModel:GetAttribute("isOpening") then return end

	local function onDoorOpen(doorPart : BasePart)
		local cfVal = Instance.new("CFrameValue")
		cfVal.Name = "CfVal"
		cfVal.Value = doorPart.CFrame
		cfVal.Parent = doorPart
		
--							v.Transparency = 1
		doorPart.CanCollide = false
		local tween = game:GetService("TweenService"):Create(doorPart, TweenInfo.new(tweenTime), {CFrame = cfVal.Value - doorPart.CFrame.RightVector*doorPart.Size.X*(if doorPart.Name == "R" then 2 else 1)}) 

		--disables the weld momentarily
		local weld = doorPart:FindFirstChild("Weld") :: Weld
		if weld then
			doorPart.Anchored = true
			weld.Enabled = false
		end

		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
	end

	local function onDoorClose(doorPart : BasePart)
		local cfVal = doorPart:FindFirstChild("CfVal") :: CFrameValue
		if cfVal then
			doorPart.CanCollide = true
			local tween = game:GetService("TweenService"):Create(doorPart, TweenInfo.new(tweenTime), {CFrame = cfVal.Value}) 
			tween:Play()
			tween.Completed:Wait()
			tween:Destroy()
			cfVal:Destroy()

				--reenables the weld 	
			local weld = doorPart:FindFirstChild("Weld") :: Weld
			if weld then
				weld.Enabled = true
				doorPart.Anchored = false
			end
			
		end 
	end

	if doors then
		elevModel:SetAttribute("isOpening", true)
		for _,v in pairs(doors:GetChildren()) do
			if v:IsA("BasePart") then
				task.spawn(function()
					onDoorOpen(v)
				end)
				--sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://9114154039"
				sound.Parent = v
				sound:Play()
				task.spawn(function()
					sound.Ended:Wait()
					sound:Destroy()
				end)
			end
		end

		if floorName and elevatorGates then
			for _, elevatorGate in ipairs(elevatorGates:GetChildren()) do
				local gatedoors = elevatorGate:FindFirstChild("Doors")
				if elevatorGate.Name == floorName and gatedoors then
					for _,v in pairs(gatedoors:GetChildren()) do
						if v:IsA("BasePart") then
							task.spawn(function()
								onDoorOpen(v)
							end)
						end
					end
				end
			end
		end

		task.wait(openTime)

		for _,v in pairs(doors:GetChildren()) do
			if v:IsA("BasePart")  then
				task.spawn(function()
					onDoorClose(v)
				end)

				--sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://9114154039"
				sound.Parent = v
				sound:Play()
				task.spawn(function()
					sound.Ended:Wait()
					sound:Destroy()
				end)
			end
		end
		if floorName and elevatorGates then
			for _, elevatorGate in ipairs(elevatorGates:GetChildren()) do
				local gatedoors = elevatorGate:FindFirstChild("Doors")
				if elevatorGate.Name == floorName and gatedoors then
					for _,v in pairs(gatedoors:GetChildren()) do
						if v:IsA("BasePart") then
							task.spawn(function()
								onDoorClose(v)
							end)
						end
					end
				end
			end
		end
		task.wait(tweenTime)
		elevModel:SetAttribute("isOpening", nil)
	end
end


--class
local Elevator = {} :: Elevator
Elevator.__index = Elevator

function Elevator.new(elevatorModel : Model)
    local self : Elevator = setmetatable({}, Elevator) :: any 
	self._Maid = Maid.new()
	self._queue = {}
	self._callUpQueue = {}
	self._callDownQueue = {}
    self.CurrentFloor = ""
	self.Status = "Ascending"
    self.Model = self._Maid:GiveTask(elevatorModel)

	self._Maid.BackupModel = self.Model:Clone()

	local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
	local buttons = elevCageModel:FindFirstChild("Buttons")
	local buttonAddons = elevCageModel:FindFirstChild("ButtonAddons")
	local gates = self.Model:FindFirstChild("ElevatorGates")

    local prismaticConstraint = elevPart:FindFirstChild("PrismaticConstraint") :: PrismaticConstraint
    
	assert(elevCageModel.PrimaryPart)
	--welding
    for _,v in pairs(elevCageModel:GetDescendants()) do
        if v:IsA("BasePart") then
			weld(v, elevPart)
        end
    end

	--marking highest and lowest floor
	local max = -math.huge
	local min = math.huge
	
	local highestFloor
	local lowestFloor
	--print(floors)
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
				if v:IsA("Model") and v.PrimaryPart then
					local textPart = v:FindFirstChild("TextPart") :: BasePart ?


					local clickDetector = Instance.new("ClickDetector")
					clickDetector.MaxActivationDistance = 32
					clickDetector.Parent = v
					
					self._Maid:GiveTask(clickDetector.MouseClick:Connect(function()
						local floorDest = floors:FindFirstChild(v.Name) :: BasePart ?
						if floorDest then
							self:InsertFloorQueue(floorDest)
						end
					end))

					if textPart then
						local text = textPart:WaitForChild("SurfaceGui"):WaitForChild("TextLabel") :: TextLabel
						text.Text = v.Name
					end
				end
			end

			if buttonAddons then
				local openButton = buttonAddons:FindFirstChild("Open")
				local closeButton= buttonAddons:FindFirstChild("Close")
	
				if openButton then
					local openClickDetector = Instance.new("ClickDetector")
					openClickDetector.MaxActivationDistance = 32
					openClickDetector.Parent = openButton
	
					self._Maid:GiveTask(openClickDetector.MouseClick:Connect(function()
						local currentFloor = floors:FindFirstChild(self.CurrentFloor) :: BasePart ?
						if  currentFloor and (currentFloor.Position - elevCageModel.PrimaryPart.Position).Magnitude <= 1 then
							self:InsertFloorQueue(currentFloor, self.Status)
						end

						--light effect
						local light = openButton:WaitForChild("Light") :: BasePart
						light.Color = SELECTED_COLOR
						task.wait(0.25)
						light.Color = DEFAULT_COLOR
					end))
				end
				if closeButton then
					local closeClickDetector = Instance.new("ClickDetector")
					closeClickDetector.MaxActivationDistance = 32
					closeClickDetector.Parent = closeButton
	
					self._Maid:GiveTask(closeClickDetector.MouseClick:Connect(function()
						--light effect
						local light = closeButton:WaitForChild("Light") :: BasePart
						light.Color = SELECTED_COLOR
						task.wait(0.25)
						light.Color = DEFAULT_COLOR
	
					end))
				end
			end
		end

		
	end

	if gates and floors then
		for _,gateModel in pairs(gates:GetChildren()) do
			local callButtons = gateModel:WaitForChild("CallButtons") :: Model
			local GateDoors = gateModel:WaitForChild("Doors") :: Model

			
			local upButton = callButtons:FindFirstChild("Up")
			local downButton = callButtons:FindFirstChild("Down")

			if upButton then
				local upClickDetector = Instance.new("ClickDetector")
				upClickDetector.MaxActivationDistance = 32
				upClickDetector.Parent = upButton
				
				self._Maid:GiveTask(upClickDetector.MouseClick:Connect(function()
					--print("Mba")
					local floor = floors:FindFirstChild(gateModel.Name) :: BasePart ?
					--[[if floor then
						floor:SetAttribute("attribute")
					end]]
					if floor then
						if not table.find(self._callUpQueue, floor.Name) then
							--table.insert(self._callUpQueue, floor.Name) 
							self:InsertFloorQueue(floor, "Ascending")
						end
					end
				end))

				local textLabel = upButton:WaitForChild("TextPart"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel") :: TextLabel
				textLabel.Text = "↑"
			end

			if downButton then
				local downClickDetector = Instance.new("ClickDetector")
				downClickDetector.MaxActivationDistance = 32
				downClickDetector.Parent = downButton

				self._Maid:GiveTask(downClickDetector.MouseClick:Connect(function()
					--print("Mba")
					local floor = floors:FindFirstChild(gateModel.Name) :: BasePart ?
					--[[if floor then
						floor:SetAttribute("attribute")
					end]]
					if floor then
						if not table.find(self._callDownQueue, floor.Name) then
							--table.insert(self._callDownQueue, floor.Name) 
							self:InsertFloorQueue(floor, "Descending")
						end
					end
				end))

				local textLabel = downButton:WaitForChild("TextPart"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel") :: TextLabel
				textLabel.Text = "↓"
			end

			
		end
		
	end

	if highestFloor and lowestFloor then
		highestFloor:SetAttribute(FLOOR_TOP_KEY, true)
		lowestFloor:SetAttribute(FLOOR_BOTTOM_KEY, true)
	end

	self:UpdateCurrentFloor()
	self:UpdateUI()

    return self
end

function Elevator:InsertFloorQueue(floorDest, buttonCall : Direction ?)	


	local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
	local buttons = elevCageModel:FindFirstChild("Buttons")
	local doors = elevCageModel:FindFirstChild("Doors")
	local elevatorGates = self.Model:FindFirstChild("ElevatorGates")
	local playerDetector = elevCageModel:WaitForChild("PlayerDetector") :: BasePart

	assert(floors and floorDest:IsDescendantOf(floors))
	assert(floors)
	assert(buttons)
	assert(elevCageModel.PrimaryPart)
	assert(elevatorGates)

    local prismaticConstraint = elevPart:FindFirstChild("PrismaticConstraint") :: PrismaticConstraint
	
	local function getPosNumRelativeToVel(elevRelativePosNum : number)
		return elevRelativePosNum*prismaticConstraint.Velocity
	end
	

	if prismaticConstraint then

		--setting up queues
		if buttonCall == nil then
			if not table.find(self._queue, floorDest.Name) then
				table.insert(self._queue, floorDest.Name)

				--rearrange queues (obselete)
				--[[if self.Status == "Ascending" then 
					table.sort(self._queue, function(a : any, b : any) --ascending order
						return a < b
					end)
				elseif self.Status == "Descending" then 
					table.sort(self._queue, function(a : any, b : any) --descending order
						return a > b
					end)
				end	]]
				--print(self._queue)
			end
		elseif buttonCall == "Ascending" then
			if not table.find(self._callUpQueue, floorDest.Name) then
				table.insert(self._callUpQueue,  floorDest.Name)
			end
		elseif buttonCall == "Descending" then
			if not table.find(self._callDownQueue, floorDest.Name) then
				table.insert(self._callDownQueue,  floorDest.Name)
			end
		end

		do
			local buttonFloor = buttons:FindFirstChild(floorDest.Name) :: Model ?
			local buttonlight = if buttonFloor then buttonFloor:FindFirstChild("Light") :: BasePart else nil
			if buttonFloor and buttonlight and buttonCall == nil then buttonlight.Color = SELECTED_COLOR end

			if buttonCall == "Ascending" then
				local elevatorGate = elevatorGates:FindFirstChild(floorDest.Name)
				if elevatorGate then
					local callbuttons = elevatorGate:WaitForChild("CallButtons")
					local up = callbuttons:FindFirstChild("Up")
					if up then 
						local light = up:WaitForChild("Light") :: BasePart
						light.Color = SELECTED_COLOR
					end
				end
			elseif buttonCall == "Descending" then
				local elevatorGate = elevatorGates:FindFirstChild(floorDest.Name)
				if elevatorGate then
					local callbuttons = elevatorGate:WaitForChild("CallButtons")
					local down = callbuttons:FindFirstChild("Down")
					if down then 
						local light = down:WaitForChild("Light") :: BasePart
						light.Color = SELECTED_COLOR
					end
				end
			end
		end

		--detecting if there's any queue left based on the direction/status
		
		local queuePresentForCurrentStatus = false
		local function queueCheck(queue : {})
			for k,v in pairs(queue) do
				local floorPart = floors:FindFirstChild(tostring(v))
				if floorPart and floorPart:IsA("BasePart") then
					local direction = math.sign(getElevatorRelativePositionInNumber(elevPart, floorPart, false))
					if (self.Status == "Descending" and math.sign(direction) >= 0) or (self.Status == "Ascending" and math.sign(direction) <= 0) then
						queuePresentForCurrentStatus = true
					end
				end
			end
		end
		queueCheck(self._queue)
		queueCheck(self._callDownQueue)
		queueCheck(self._callUpQueue)
		--switch direction/status
		if not queuePresentForCurrentStatus then
			if self.Status == "Descending" then self.Status = "Ascending" elseif self.Status == "Ascending" then self.Status = "Descending" end
		end

		--condition filters
		if self._Maid.ElevatorMovement then return end
		if self.Model:GetAttribute("isOpening") then return end

		--		
		--local elevRelativePosNum = getElevatorRelativePositionInNumber(elevPart, floorDest)
		prismaticConstraint.Velocity = 8*(if self.Status == "Descending" then 1 else -1)
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

		local timeoutMaxTolerance, currentRate = 6, 0 --seconds of error tolerance
		local intInterval = tick() -- for checking

		self._Maid.ElevatorMovement = RunService.Stepped:Connect(function()			
			self:UpdateCurrentFloor()
			self:UpdateUI()

			local nearestFloorPart = floors:FindFirstChild(self.CurrentFloor) :: BasePart?

			--print(floorList[self.CurrentFloor], floorList, self.CurrentFloor, nearestFloorPart and getElevatorRelativePositionInNumber(elevPart, nearestFloorPart, false))
			--print(elevPart.Position, nearestFloorPart and nearestFloorPart.Position)
			if nearestFloorPart and (table.find(self._queue, nearestFloorPart.Name) or table.find(self._callDownQueue, nearestFloorPart.Name) or table.find(self._callUpQueue, nearestFloorPart.Name)) then
				intDir = intDir or math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false))
				--print('eeeh?', intDir, math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)))
				if intDir ~= math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)) then
					--print('eeeh?', intDir, math.sign(getElevatorRelativePositionInNumber(elevPart, nearestFloorPart :: BasePart, false)))
					arrivedFloorPart = nearestFloorPart
				end
				--arrived = true
			end

			--checking if elev is stuck
			if (tick() - intInterval) >= 1 then
				intInterval = tick()
				if (not elevCageModel.PrimaryPart) or (math.floor(elevCageModel.PrimaryPart.AssemblyLinearVelocity.Magnitude) == 0) then  --if got flung out
					currentRate += 1
				else
					currentRate = 0
				end
				print(currentRate, " : current tolerance rate")
				if currentRate >= timeoutMaxTolerance then
					self:ResetElevator()
					--print('TUIT TUIT RESPAWN THOIMMEE TUIT TUIT!')
					return
				end
			end

			--print(floorList[self.CurrentFloor], floorList)
			if arrivedFloorPart then	
				--arrivedFloorPart.Transparency = 0.25
				--print("hey?")
				self._Maid.ElevatorMovement = nil

				--temporarily and quickly adding elevator weld for player to not make em fall off
				local temporaryWelds = {}
				for _,v in pairs(playerDetector:GetTouchingParts()) do
					if v.Parent and v.Parent:FindFirstChild("Humanoid") then
						table.insert(temporaryWelds, weld(v, elevCageModel.PrimaryPart))
					end
				end

				prismaticConstraint.Velocity = 0	
				elevCageModel:PivotTo(CFrame.new(elevCageModel.PrimaryPart.Position.X, arrivedFloorPart.Position.Y, elevCageModel.PrimaryPart.Position.Z)*(elevCageModel.PrimaryPart.CFrame - elevCageModel.PrimaryPart.CFrame.Position))
				elevCageModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
				
				--removing the elevator weld for the players
				for _,v in pairs(temporaryWelds) do
					v:Destroy()
				end

				--removing table in the queues
				if table.find(self._queue, arrivedFloorPart.Name) then
					table.remove(self._queue, table.find(self._queue, arrivedFloorPart.Name))
				end
				if table.find(self._callUpQueue, arrivedFloorPart.Name) then
					table.remove(self._callUpQueue, table.find(self._callUpQueue, arrivedFloorPart.Name))
				end
				if table.find(self._callDownQueue, arrivedFloorPart.Name) then
					table.remove(self._callDownQueue, table.find(self._callDownQueue, arrivedFloorPart.Name))
				end

				--print("open door")
				--button
				do
					local buttonFloor = buttons:FindFirstChild(arrivedFloorPart.Name) :: Model ?
					local buttonlight = if buttonFloor then buttonFloor:FindFirstChild("Light") :: BasePart else nil
					if buttonFloor and buttonlight and buttonCall == nil then buttonlight.Color = DEFAULT_COLOR end

					if buttonCall ~= nil then
						if self.Status == "Ascending" then
							local elevatorGate = elevatorGates:FindFirstChild(arrivedFloorPart.Name)
							if elevatorGate then
								local callbuttons = elevatorGate:WaitForChild("CallButtons")
								local up = callbuttons:FindFirstChild("Up")
								if up then 
									local light = up:WaitForChild("Light") :: BasePart
									light.Color = DEFAULT_COLOR
								end
							end
						elseif self.Status == "Descending" then
							local elevatorGate = elevatorGates:FindFirstChild(arrivedFloorPart.Name)
							if elevatorGate then
								local callbuttons = elevatorGate:WaitForChild("CallButtons")
								local down = callbuttons:FindFirstChild("Down")
								if down then 
									local light = down:WaitForChild("Light") :: BasePart
									light.Color = DEFAULT_COLOR
								end
							end
						end
					end
			
				end
				
				openCageDoor(self.Model, 4, self.CurrentFloor)
				--print('close door')
				--arrivedFloorPart.Transparency = 1

				--print(self._queue, "NEW LEEEW!")
				task.wait()
				self:UpdateUI()
				local nextFloor = if self._queue[1] then floors:FindFirstChild(tostring(self._queue[1])) :: BasePart else nil
				local nextCalledUpFloor = if self._callUpQueue[1] then floors:FindFirstChild(tostring(self._callUpQueue[1])) :: BasePart else nil
				local nextCalledDownFloor = if self._callDownQueue[1] then floors:FindFirstChild(tostring(self._callDownQueue[1])) :: BasePart else nil

				if nextFloor then
					self:InsertFloorQueue(nextFloor)
				elseif nextCalledUpFloor then
					self:InsertFloorQueue(nextCalledUpFloor, "Ascending")
				elseif nextCalledDownFloor then
					self:InsertFloorQueue(nextCalledDownFloor, "Descending")
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

function Elevator:UpdateCurrentFloor()
	local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
	local buttons = elevCageModel:FindFirstChild("Buttons")
	local doors = elevCageModel:FindFirstChild("Doors")

	assert(floors)

	local floorList = {}
	for _,v in pairs(floors:GetChildren()) do
		local elevRelativeFloorPosNum = getElevatorRelativePositionInNumber(elevPart, v :: BasePart, false)
		floorList[v.Name] = math.abs(elevRelativeFloorPosNum) --elevRelativeFloorPosNum 
	end

	self.CurrentFloor = getMinValueInKey(floorList)
	return 
end

function Elevator:UpdateUI()
    local elevCageModel = self.Model:FindFirstChild("Elevator") :: Model
    local elevPart = elevCageModel.PrimaryPart :: BasePart
    local floors = self.Model:FindFirstChild("Floors")
    local prismaticConstraint = elevPart:FindFirstChild("PrismaticConstraint") :: PrismaticConstraint
	local elevatorGates = self.Model:FindFirstChild("ElevatorGates")

	local floorIndicationPart = elevCageModel:WaitForChild("Indications"):WaitForChild("FloorLabel") 
	local floorNameText = floorIndicationPart:WaitForChild("SurfaceGui"):WaitForChild("FloorName") :: TextLabel

	local floordisplay = (if prismaticConstraint.Velocity == 0 then "" elseif self.Status == "Ascending" then '⬆️' else '⬇️') .. self.CurrentFloor
	
	if floorNameText.Text ~= floordisplay and math.floor(prismaticConstraint.Velocity) ~= 0 then
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6148388066"
		sound.Parent = floorIndicationPart
		sound:Play()
		task.spawn(function()
			sound.Ended:Wait()
			sound:Destroy()
		end)
	end

	local floorNameText2 = floorIndicationPart:WaitForChild("SurfaceGui"):WaitForChild("FloorName") :: TextLabel
	floorNameText2.Text = floordisplay 
 
	if elevatorGates then
		for _,elevGate in pairs(elevatorGates:GetChildren()) do
			local elevatorFloor = elevGate:FindFirstChild("ElevatorFloor")
			if elevatorFloor then
				local floorName = elevatorFloor:WaitForChild("SurfaceGui"):WaitForChild("FloorName") :: TextLabel
				floorName.Text = floordisplay
			end
		end
	end
end

function Elevator:ResetElevator()
	local elevModel = if self._Maid.BackupModel then self._Maid.BackupModel:Clone() else nil
	local parent = self.Model.Parent

	if elevModel then
		self:Destroy()
 
		elevModel.Parent = parent
		Elevator.new(elevModel)
	end	
end

function Elevator:Destroy()
	self._Maid:Destroy()
	
	local t : any = self 
	for k,v in pairs(t) do
		t[k] = nil
	end

	setmetatable(self, nil)
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
