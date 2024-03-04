--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Pathfind = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Pathfind"))
--types
type Maid = Maid.Maid
type PointData = Pathfind.PointData
--constants
local NPC_TAG = "NPC"

local CAR_CLASS_KEY = "Vehicle"

local CUSTOM_THROTTLE_KEY = "CustomThrottle"
local CUSTOM_STEER_KEY = "CustomSteer"
--remotes
--variables
--references
local NPCModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Others"):WaitForChild("NPCs")
local NPCSpawns = workspace:WaitForChild("Assets"):WaitForChild("Spawns"):WaitForChild("NPCs")
--local functions
local function resetNPC(spawnPart : BasePart, initFn : (vehicleModel : Model, spawnPart : BasePart) -> ())
	
	local npcModelPointer = spawnPart:FindFirstChild("ModelPointer") :: ObjectValue ?
	if npcModelPointer and npcModelPointer.Value then
		local vehicleModel = npcModelPointer.Value:Clone() :: Model
		vehicleModel:PivotTo(spawnPart.CFrame)
		vehicleModel.Parent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("NPCs")
		CollectionService:AddTag(vehicleModel, NPC_TAG)

		initFn(vehicleModel, spawnPart)
	end

	return
end
local function newPointData(
	PointId : number,
	Cost : number,
	Obstacled : boolean,
	Neighbours : {
		[number] : PointData
	} ?,
	Came_From : PointData ?

) : PointData
	return {
		PointId = PointId,
		Cost = Cost,
		Came_From = Came_From,
		Obstacled = Obstacled,
		Neighbours = Neighbours or {}
	}
end

local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end

local function init(vehicleModel : Model, spawnPart : BasePart)
	assert(vehicleModel.PrimaryPart)
	local maid = Maid.new()
	maid:GiveTask(vehicleModel)

    local vehiclePart = vehicleModel.PrimaryPart
    assert(vehiclePart, "Vehicle has no primary part!")

    local speedLimit = vehicleModel:GetAttribute("Speed") or 20

	local wheels = vehicleModel:FindFirstChild("Wheels") :: Model
    assert(wheels)

	maid:GiveTask(vehicleModel:GetAttributeChangedSignal(CUSTOM_THROTTLE_KEY):Connect(function()
		if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then 
			
			local throttle = vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
			local wheels = vehicleModel:FindFirstChild("Wheels") :: Model
			if throttle and wheels then
				for _,v in pairs(wheels:GetDescendants()) do
					if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
						--v.MotorMaxTorque = 1--999999999999
						v.AngularVelocity = throttle*convertionKpHtoVelocity((speedLimit))
						local accDir = vehiclePart.CFrame:VectorToObjectSpace(vehiclePart.AssemblyLinearVelocity).Z
						--task.spawn(function() task.wait(1); v.MotorMaxTorque = 1--[[550000000]]; end)
						if throttle ~= 0 then
							v.MotorMaxTorque = vehicleModel:GetAttribute("WheelPower") or 15--999999999999
							v.MotorMaxAcceleration = 60 --if math.sign(accDir*throttle) == 1 then 60 else 25
							--[[if math.sign(accDir*throttle) == 1 then
								v.AngularVelocity = 0
							end]]
						else
							v.MotorMaxTorque = 999999999999
							v.MotorMaxAcceleration = 40
							v.AngularVelocity = 0
						end
					end
				end

				--brake signal
				local lights = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
				local brakeLight = lights:FindFirstChild("R") :: Instance ?
				if brakeLight then
					local function updateLight(part : BasePart) 
						if throttle == -1 then
							part.Material = Enum.Material.Neon
						else
							part.Material = Enum.Material.SmoothPlastic
						end
					end

					if brakeLight:IsA("BasePart") then
						updateLight(brakeLight)
					else
						for _,part in pairs(brakeLight:GetChildren()) do
							if part:IsA("BasePart") then updateLight(part) end
						end
					end

				end

				--VectorForce.Force = Vector3.new(0,0,-seat.Throttle*8000)
			end
		end
	end))

	local attachment0 = Instance.new("Attachment")
	local VectorForce = Instance.new("VectorForce")  

	attachment0.Parent = vehicleModel.PrimaryPart
	VectorForce.Parent = vehicleModel.PrimaryPart
	print(VectorForce, " aa")
	VectorForce.Attachment0 = attachment0
	VectorForce.Force = Vector3.new(0,0,0)
	
	local vectorMaxForce = vehicleModel:GetAttribute("Power") or 30000
	maid:GiveTask(RunService.Stepped:Connect(function()
		local throttle = vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY) 

		local direction = math.sign(vehiclePart.CFrame.LookVector:Dot(vehiclePart.AssemblyLinearVelocity.Unit))
		local currentVelocity = vehiclePart.AssemblyLinearVelocity.Magnitude
		
		VectorForce.Force = Vector3.new(0,0,-throttle*(math.clamp(vectorMaxForce - ((vectorMaxForce)*(((currentVelocity)/ speedLimit))), 0, vectorMaxForce)))
		if throttle ~= 0 and direction ~= throttle then
			VectorForce.Force = Vector3.new(0,0, direction*vectorMaxForce)
			--print(direction*vectorMaxForce)
		end
	end))
	
    vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0) 

  
    local function setCarMovement(throttle : number, targetAngle : number, angularSpeed : number?)
        vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, throttle)
        --print(vehicleModel:GetAttribute("CustomThrottle"), debug.traceback())
        for _,v in pairs(wheels:GetDescendants()) do
            if v:IsA("HingeConstraint")  and v.ActuatorType == Enum.ActuatorType.Servo then  
--              local velocity = vehiclePart.AssemblyLinearVelocity.Magnitude                
                local _angularSpeed = angularSpeed or 30

                v.TargetAngle = targetAngle
                v.AngularSpeed = _angularSpeed

            end
        end
    end

    local function reachToDest(v3 :Vector3, onObstacleDetected : ((parts : {BasePart}) -> ()) ?, onObstacleCleared : (() -> ()) ?)
		
	
		local destDetectionRange = 6
		local obstacleDetectionRange = 15
        
		local charactersModel = {}
		for _,plr in pairs(Players:GetPlayers()) do
			local char = plr.Character
			table.insert(charactersModel, char)
		end

        local overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Include
        overlapParams.FilterDescendantsInstances = {
			charactersModel
			--workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles"):GetChildren()
			--workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles"):GetChildren(),
			--workspace:WaitForChild("Assets"):WaitForChild("Buildings"):GetChildren(),

		--	workspace:WaitForChild("Assets"):WaitForChild("Infrastructures"):GetChildren()
		}
        
        setCarMovement(1, 0)

        --local conn 
            
        --conn = RunService.Stepped:Connect(function()
        while (vehiclePart.Position - v3).Magnitude > destDetectionRange do
            task.wait()
			assert(vehiclePart.Parent)
            --creating bounding box for collusion detection
            local cf, size = vehicleModel:GetBoundingBox()
            cf = cf + vehiclePart.CFrame.LookVector*obstacleDetectionRange*0.5*vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
            size += Vector3.new(0,0,obstacleDetectionRange)
            
            local partsDetected = workspace:GetPartBoundsInBox(cf, size, overlapParams)
            
            local cross = vehiclePart.CFrame.LookVector:Cross((v3 - vehiclePart.Position).Unit)
            local dot = vehiclePart.CFrame.LookVector:Dot((v3 - vehiclePart.Position).Unit)

			local canCollidePartsDetected = {}
			for _,v in pairs(partsDetected) do
				if v.CanCollide == true then
					table.insert(canCollidePartsDetected, v)
				end
			end
            
            if #canCollidePartsDetected > 0 then
                if onObstacleDetected then	
                    onObstacleDetected(canCollidePartsDetected)
                    continue
                end
			else
				if onObstacleCleared then
					onObstacleCleared()
				end
            end
            setCarMovement(1*math.sign(dot), (-cross.Y)*32*math.sign(dot))
        end
            --if (vehicleSeat.Position - v3).Magnitude < 25 then
                --conn:Disconnect()
                
            --end
        --end)
        
        
        vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0)
        print("Done!")
        return
    end

	local pathfindsFolder = workspace:WaitForChild("Assets"):WaitForChild("Paths"):WaitForChild("Pathfinds")
	
	local mallPatrol = pathfindsFolder:WaitForChild("MallPatrol")
	
	do --mall path pts
		local pts = {}
		for _,v in pairs(mallPatrol:GetChildren()) do
			local pointId = tonumber(v.Name)
			assert(pointId, "Incorrect point id")
			local neighbours = {}
			local pointData = newPointData(pointId, 0, false, neighbours)
			pts[pointId] = pointData
		end

		for _,v in pairs(pts) do
			local pointInst = mallPatrol:FindFirstChild(tostring(v.PointId))
			local neighbours = {}
			for _,beam : Instance in pairs(pointInst:GetChildren()) do
				if beam:IsA("Beam") then
					local battachment0 = beam.Attachment0
					local battachment1 = beam.Attachment1
					
					local neighbourPointId 
					if battachment0 and battachment0.Parent then
						if v.PointId ~= tonumber(battachment0.Parent.Name)  then
							neighbourPointId = tonumber(battachment0.Parent.Name) 
						end
					end
					if battachment1 and battachment1.Parent then
						if v.PointId ~= tonumber(battachment1.Parent.Name)  then
							neighbourPointId = tonumber(battachment1.Parent.Name) 
						end
					end

					if neighbourPointId then
						local neighbourPointData = pts[neighbourPointId]
						if neighbourPointData and not table.find(neighbours, neighbourPointData) then 
							table.insert(neighbours, neighbourPointData)
							if not table.find(neighbourPointData.Neighbours, v) then
								table.insert(neighbourPointData.Neighbours, v)
							end
						end
					end
				end
			end
			for _,detectedNeighbourPt in pairs(neighbours) do
				table.insert(v.Neighbours, detectedNeighbourPt)
			end
		end

		local t = tick()

		local stopT = 0
		local db = false
		maid:GiveTask(RunService.Stepped:Connect(function()
			--check if the npc is stuck or is outside
			if vehicleModel.PrimaryPart then
				if not vehicleModel:GetAttribute("HasObstacle") then
					if tick() - t > 1 then
						t = tick()

						if math.round(vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude) < 1 then
							stopT += 1
						else
							stopT = 0
						end

						if stopT >= 10 then
							maid:Destroy()
							resetNPC(spawnPart, init)
						end
					end
				end
			else
				maid:Destroy()
				resetNPC(spawnPart, init)
			end
			-----
			
			if not db then
				db = true
				local nearestPointPart 
				local farthestPointPart

				local minDist = math.huge
				local maxDist = 0
				for _,v : Part in pairs(mallPatrol:GetChildren()) do
					local dist = (v.Position - vehicleModel.PrimaryPart.Position).Magnitude
					if dist < minDist then
						minDist = dist
						nearestPointPart = v
					end
					if dist > maxDist then
						maxDist = dist
						farthestPointPart = v
					end
				end

				local nearestPointId = tonumber(nearestPointPart.Name)
				local farthestPointId = tonumber(farthestPointPart.Name)
				local nearestPoint = if nearestPointId then pts[nearestPointId] else nil
				local farthestPoint = if farthestPointId then pts[farthestPointId] else nil

				if nearestPoint and farthestPoint then
					local output = Pathfind.djikstraPathfinding(pts, nearestPoint, farthestPoint)
					--print(nearestPoint, farthestPoint, pts, output)
					for _,v in pairs(output) do
						local destPart = mallPatrol:FindFirstChild(tostring(v.PointId))
						print(destPart, " is now the destination!!!")
						reachToDest(destPart.Position, function(parts)
							vehicleModel:SetAttribute("HasObstacle", true)
							
							local minODist = math.huge
							local nearestObstacle
							for _,v in pairs(parts) do
								local dist = (v.Position - vehicleModel.PrimaryPart.Position).Magnitude
								if dist < minODist then
									minODist = dist
									nearestObstacle = v
								end
							end

							if nearestObstacle then
								--local cross = vehiclePart.CFrame.LookVector:Cross((destPart.Position - vehiclePart.Position).Unit)

								--setCarMovement(
									---math.sign(vehiclePart.CFrame.LookVector:Dot((nearestObstacle.Position - vehiclePart.Position).Unit)), 
									--vehicleModel.PrimaryPart.CFrame.LookVector:Dot((nearestObstacle.Position - vehicleModel.PrimaryPart.Position).Unit)*40*-math.sign(cross.Y)
								--)
								setCarMovement(0, 0)

								local plr = Players:GetPlayerFromCharacter(nearestObstacle.Parent)
								if plr then
									local vehicleBody = vehicleModel:WaitForChild("Body"):WaitForChild("Body")
									local infoDisplay = vehicleBody:FindFirstChild("InfoDisplay")

									local sg = if infoDisplay then infoDisplay:FindFirstChild("SurfaceGui") else nil
									if infoDisplay and sg then
										local frame = sg:FindFirstChild("Frame")
										if frame then
											local title = frame:FindFirstChild("Title") :: TextLabel ?
											local avatarImage = frame:FindFirstChild("AvatarImage") :: ImageLabel ?

											if title then
												title.Text = `WELCOME <font color = "rgb(20,100,20)"> {plr.Name:upper()} </font>`	
											end

											if avatarImage then
												local uiStroke = avatarImage:FindFirstChild("UIStroke") :: UIStroke ?
												avatarImage.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
												avatarImage.BackgroundColor3 = Color3.fromRGB(138, 204, 255)

												if uiStroke then
													uiStroke.Color = avatarImage.BackgroundColor3
												end
											end
										end
										task.wait(1)
									end
								end
							end
							task.wait()
						end, function()
							vehicleModel:SetAttribute("HasObstacle", nil)

							local vehicleBody = vehicleModel:WaitForChild("Body"):WaitForChild("Body")
							local infoDisplay = vehicleBody:FindFirstChild("InfoDisplay")

							local sg = if infoDisplay then infoDisplay:FindFirstChild("SurfaceGui") else nil
							if infoDisplay and sg then
								local frame = sg:FindFirstChild("Frame")
								if frame then
									local title = frame:FindFirstChild("Title") :: TextLabel ?
									local avatarImage = frame:FindFirstChild("AvatarImage") :: ImageLabel ?

									if title then
										title.Text = `STATUS: <font color = "rgb(255,0,0)">PATROLLING </font>`	
									end

									if avatarImage then
										local uiStroke = avatarImage:FindFirstChild("UIStroke") :: UIStroke ?

										avatarImage.Image = ""
										avatarImage.BackgroundColor3 = Color3.fromRGB(255,50,50)
										if uiStroke then
											uiStroke.Color = avatarImage.BackgroundColor3
										end
									end
								end
							end

						end)
					end
				end
				db = false
			end
		end))	
	end
end

--script
local NPC = {}

function NPC.init(maid : Maid)
	for _, spawnPart in pairs(NPCSpawns:GetChildren()) do
		assert(spawnPart:IsA("BasePart"))
		local npcModelPointer = spawnPart:FindFirstChild("ModelPointer") :: ObjectValue ?

		resetNPC(spawnPart, init)

		--[[if npcModelPointer and npcModelPointer.Value then
			init(npcModelPointer.Value :: Model, spawnPart)
		end]]
	end
	--[[for _, vehicleModel in pairs(CollectionService:GetTagged(NPC_TAG)) do
		if vehicleModel:IsDescendantOf(workspace) then
			init(vehicleModel)
		end
    end

	maid:GiveTask(CollectionService:GetInstanceAddedSignal(NPC_TAG):Connect(function(npc : Model)
		init(npc)
	end))]]
end
    --automation
return NPC

