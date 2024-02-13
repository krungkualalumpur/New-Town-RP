--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local NPC_TAG = "NPC"

local CAR_CLASS_KEY = "Vehicle"

local CUSTOM_THROTTLE_KEY = "CustomThrottle"
local CUSTOM_STEER_KEY = "CustomSteer"
--remotes
--variables
--references
--local functions
local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end

local function init(maid : Maid, vehicleModel : Model)
	
    local vehiclePart = vehicleModel.PrimaryPart
    assert(vehiclePart, "Vehicle has no primary part!")

    local speedLimit = vehicleModel:GetAttribute("Speed") or 20

	local wheels = vehicleModel:FindFirstChild("Wheels") :: Model
    assert(wheels)

	maid:GiveTask(vehicleModel:GetAttributeChangedSignal(CUSTOM_THROTTLE_KEY):Connect(function()
		if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then 
			
			print("Comfort zone test")
			local throttle = vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
			local wheels = vehicleModel:FindFirstChild("Wheels") :: Model
			if throttle and wheels then
				for _,v in pairs(wheels:GetDescendants()) do
					if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
						--v.MotorMaxTorque = 1--999999999999
						v.AngularVelocity = throttle*convertionKpHtoVelocity((speedLimit)*(if math.sign(throttle) == 1 then 1 else 0.5))
						local accDir = vehiclePart.CFrame:VectorToObjectSpace(vehiclePart.AssemblyLinearVelocity).Z
						--task.spawn(function() task.wait(1); v.MotorMaxTorque = 1--[[550000000]]; end)
						if throttle ~= 0 then
							v.MotorMaxTorque = 1--999999999999
							v.MotorMaxAcceleration = if math.sign(accDir*throttle) == 1 then 60 else 25
							if math.sign(accDir*throttle) == 1 then
								v.AngularVelocity = 0
							end
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

	--[[vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function()
		if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
			vehicleSeat.AssemblyAngularVelocity += Vector3.new(0,1,0)*-vehicleSeat.Steer
		elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
			local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat ?
			local wheels = vehicleModel:FindFirstChild("Wheels") :: Model ?

			if seat and wheels then
				for _,v in pairs(wheels:GetDescendants()) do
					if v:IsA("HingeConstraint")  and v.ActuatorType == Enum.ActuatorType.Servo then    
						local velocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude

						local targetAngle 
						local angularSpeed
						if velocity < convertionKpHtoVelocity(10) then

							targetAngle = 60*seat.Steer
							angularSpeed = 1
						elseif velocity < convertionKpHtoVelocity(20) then
							targetAngle = 55*seat.Steer
							angularSpeed = 1*2
						elseif velocity >= convertionKpHtoVelocity(20) and velocity < convertionKpHtoVelocity(40) then
							targetAngle = 42*seat.Steer
							angularSpeed = 2*2
						elseif velocity >= convertionKpHtoVelocity(40) and velocity < convertionKpHtoVelocity(60) then
							targetAngle = 30*seat.Steer
							angularSpeed = 3*2
						elseif velocity >= convertionKpHtoVelocity(60) and velocity < convertionKpHtoVelocity(80) then
							targetAngle = 25*seat.Steer
							angularSpeed = 3*2
						elseif velocity >= convertionKpHtoVelocity(80) then
							targetAngle = 10*seat.Steer
							angularSpeed = 3*2
						end

						--v.TargetAngle = targetAngle
						--v.AngularSpeed = angularSpeed
						local tweenTime = 1
						if math.round(targetAngle) == 0 then angularSpeed = 25; tweenTime = 0.05 end 
						local tween  = TweenService:Create(v, TweenInfo.new(tweenTime), {TargetAngle = targetAngle, AngularSpeed = angularSpeed})
						tween:Play()
					end
				end
			end

		end
	end)]]
	
	local attachment0 = Instance.new("Attachment")
	local VectorForce = Instance.new("VectorForce")  

	attachment0.Parent = vehicleModel.PrimaryPart
	VectorForce.Parent = vehicleModel.PrimaryPart

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
                local _angularSpeed = angularSpeed or 40

                v.TargetAngle = targetAngle
                v.AngularSpeed = _angularSpeed

            end
        end
    end

    local function reachToDest(v3 :Vector3, onObstacleDetected : ((parts : {Instance}) -> ()) ?)
        local obstacleDetectionRange = 25
        
        local overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Include
        overlapParams.FilterDescendantsInstances = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles"):GetChildren()
        
        setCarMovement(1, 0)

        --local conn 
            
        --conn = RunService.Stepped:Connect(function()
        while (vehiclePart.Position - v3).Magnitude > 15 do
            task.wait()
            --creating bounding box for collusion detection
            local cf, size = vehicleModel:GetBoundingBox()
            cf = cf - Vector3.new(0,0,obstacleDetectionRange*0.5)*vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
            size += Vector3.new(0,0,obstacleDetectionRange)
            
            local partsDetected = workspace:GetPartBoundsInBox(cf, size, overlapParams)
            
            local cross = vehiclePart.CFrame.LookVector:Cross((v3 - vehiclePart.Position).Unit)
            local dot = vehiclePart.CFrame.LookVector:Dot((v3 - vehiclePart.Position).Unit)

            
            if #partsDetected > 0 then
                if onObstacleDetected then	
                    onObstacleDetected(partsDetected)
                    continue
                end
            end
            setCarMovement(1*math.sign(dot), (-cross.Y)*30*math.sign(dot), 40)
        end
            --if (vehicleSeat.Position - v3).Magnitude < 25 then
                --conn:Disconnect()
                
            --end
        --end)
        
        
        vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0)
        print("Done!")
        return
    end

	print("Dest : dest1")
    --[[reachToDest(workspace.Dest1.Position, function()
        print("Obstakerru")
        setCarMovement(0, 0)
        task.wait()
    end)

	print("Dest : dest2")
    reachToDest(workspace.Dest2.Position, function()
        task.wait()
        setCarMovement(0, 0)
        print("Obstakerru")

    end)

	print("Dest : dest3")
    reachToDest(workspace.Dest3.Position, function()
        task.wait()
        setCarMovement(0, 0)
        print("Obstakerru")

    end)

	print("Dest : dest4")
    reachToDest(workspace.Dest4.Position)
	print("Dest : dest5")
    reachToDest(workspace.Dest5.Position)
	print("Dest : dest6")
	reachToDest(workspace.Dest6.Position)]]
end

--script
local NPC = {}

function NPC.init(maid : Maid)
    for _, vehicleModel in pairs(CollectionService:GetTagged(NPC_TAG)) do
        init(maid, vehicleModel)
    end
end
    --automation
return NPC

