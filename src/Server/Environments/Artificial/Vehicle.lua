--!strict
--services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService('TweenService')
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))

--local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
--local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
--types
type Maid = Maid.Maid
--constants
local VEHICLE_TAG = "Vehicle"

local BOAT_CLASS_KEY = "Boat"
local CAR_CLASS_KEY = "Vehicle"

--remotes
local SPAWN_VEHICLE = "SpawnVehicle"

local ON_VEHICLE_CONTROL_EVENT = "OnVehicleControlEvent"
--variables
--references
local CarSpawns = workspace:WaitForChild("Miscs"):WaitForChild("CarSpawns")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function playSound(soundId : number, target : Instance, isLoop : boolean, maxHeardDistance : number ?)
    local _maid = Maid.new()

    local sound = _maid:GiveTask(Instance.new("Sound"))
    sound.Looped = isLoop
    sound.RollOffMaxDistance = maxHeardDistance or 20
    sound.Parent = target
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound:Play()

    _maid:GiveTask(sound.Ended:Connect(function()
        _maid:Destroy()
    end))
    _maid:GiveTask(sound.Destroying:Connect(function()
        _maid:Destroy()
    end))

    return sound
end

local function setupSpawnedCar(vehicleModel : Model)
    local body = vehicleModel:FindFirstChild("Body")
    if vehicleModel.PrimaryPart and body then
        for _,v in pairs(body:GetDescendants()) do
            if v:IsA("BasePart") then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = v
                weld.Part1 = vehicleModel.PrimaryPart
                weld.Parent = vehicleModel.PrimaryPart
                v.CanCollide = false
            elseif v:IsA("WeldConstraint") then
                v:Destroy()
            end
        end
    end
end

local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end
--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
   
    local isHeadlightAttribute= "IsHeadlightAttribute"
    local isLeftSignalingAttribute = "IsLeftSignaling"
    local isRightSignalingAttribute = "IsRightSignaling"


    local function vehicleSetup(vehicleModel : Instance)
        local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
        local speedLimit = vehicleModel:GetAttribute("Speed") or 45
        
        if vehicleModel:IsA("Model") and vehicleSeat and vehicleSeat:IsA("VehicleSeat") and vehicleModel.PrimaryPart then
            setupSpawnedCar(vehicleModel)
            
            local _maid = Maid.new()

            --[[if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                    local hum = vehicleSeat.Occupant
                    local char = if hum then hum.Parent else nil
                   
                    return
                end))
            end]]
            local attachment0 = Instance.new("Attachment")
            local VectorForce = Instance.new("VectorForce")  

            attachment0.Parent = vehicleModel.PrimaryPart
            VectorForce.Parent = vehicleModel.PrimaryPart
            
            VectorForce.Attachment0 = attachment0
            VectorForce.Force = Vector3.new(0,0,0)

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
                if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    local hum = vehicleSeat.Occupant
                    if hum then
                        if vehicleSeat.AssemblyLinearVelocity.Magnitude <= 10 then
                            local throttleV3 = vehicleSeat.CFrame.LookVector*vehicleSeat.Throttle
                            vehicleSeat.AssemblyLinearVelocity += throttleV3*15 
                        end
                        
                        local char = hum.Parent
                        local plr = if char then game:GetService("Players"):GetPlayerFromCharacter(char) :: Player else nil 
                        if char and plr and (vehicleSeat.Throttle ~= 0) then
                            local rowAnim = 15341401436
                            local isPlayingTheAnim = false

                            local humanoid = char:WaitForChild("Humanoid") :: Humanoid
                            for _,v : AnimationTrack in pairs(humanoid:GetPlayingAnimationTracks()) do
                                local animId =  tonumber(v.Animation.AnimationId:match("%d+"))
                                if animId == rowAnim then
                                    isPlayingTheAnim = true
                                    break
                                end
                            end

                            if not isPlayingTheAnim then
                                AnimationUtil.playAnim(plr, rowAnim, false)

                                local rowPart = vehicleModel:FindFirstChild("RowTool") :: BasePart ?
                                assert(rowPart, "Row row row your boat, but where's the rowing tool?")
                                local leftHand = char:FindFirstChild("LeftHand") :: BasePart
                                assert(leftHand, "Cannot find the left hand!")
            
                                local handle = _maid:GiveTask(rowPart:Clone())
                                handle.Name = "Handle"
                                handle.CFrame = leftHand.CFrame + leftHand.CFrame.LookVector*(leftHand.Size.Z*0.5)
                                handle.Parent = leftHand
                                --local tool = Instance.new("Tool")
                                local weld = Instance.new("WeldConstraint") :: WeldConstraint
                                weld.Name = "WeldConstraint"
                                weld.Part0 = handle
                                weld.Part1 = leftHand
                                weld.Parent = handle
                                --tool.Parent = char    
                                playSound(5930519356, rowPart, false)  
                                task.wait(3)
                                handle:Destroy()
                            end
                        end
                        -- animation:Destroy()
                    end
                  
                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then 
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model

                    if seat and wheels then
                        for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
                                --v.MotorMaxTorque = 1--999999999999
                                v.AngularVelocity = seat.Throttle*convertionKpHtoVelocity((speedLimit)*(if math.sign(seat.Throttle) == 1 then 1 else 0.5))
                                local accDir = vehicleModel.PrimaryPart.CFrame:VectorToObjectSpace(vehicleModel.PrimaryPart.AssemblyLinearVelocity).Z
                                --task.spawn(function() task.wait(1); v.MotorMaxTorque = 1--[[550000000]]; end)
                                if seat.Throttle ~= 0 then
                                    v.MotorMaxTorque = 1--999999999999
                                    v.MotorMaxAcceleration = if math.sign(accDir*seat.Throttle) == 1 then 60 else 25
                                    if math.sign(accDir*seat.Throttle) == 1 then
                                        v.AngularVelocity = 0
                                    end
                                else
                                    v.MotorMaxTorque = 999999999999
                                    v.MotorMaxAcceleration = 0
                                    v.AngularVelocity = 0
                                end
                            end
                        end

                        --brake signal
                        local lights = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                        local brakeLight = lights:FindFirstChild("R") :: BasePart ?
                        if brakeLight then
                            if seat.Throttle == -1 then
                                brakeLight.Material = Enum.Material.Neon
                            else
                                brakeLight.Material = Enum.Material.SmoothPlastic
                            end
                        end
                       
                        --VectorForce.Force = Vector3.new(0,0,-seat.Throttle*8000)
                    end
                end
            end))

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function()
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
            end))

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isHeadlightAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local F = lightsModel:FindFirstChild("F") :: BasePart ?

                    if F then
                        F.Material = if vehicleModel:GetAttribute(isHeadlightAttribute) then Enum.Material.Neon else Enum.Material.SmoothPlastic
                        local light = F:FindFirstChildWhichIsA("Light")
                        if light then
                            light.Enabled = vehicleModel:GetAttribute(isHeadlightAttribute) or false
                        end
                    end
                end
            end))
            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isLeftSignalingAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local FLI = lightsModel:FindFirstChild("FLI") :: BasePart ?
                    local RLI = lightsModel:FindFirstChild("RLI") :: BasePart ?

                    if FLI and RLI then
                        if vehicleModel:GetAttribute(isLeftSignalingAttribute) == true then
                            vehicleModel:SetAttribute(isRightSignalingAttribute, nil)
                            task.wait()
                            local t = tick()
                            _maid.LightSignal = RunService.Stepped:Connect(function()
                                if tick() - t >= 0.35 then
                                    t = tick()

                                    if FLI.Material == Enum.Material.Neon then
                                        FLI.Material = Enum.Material.SmoothPlastic
                                        RLI.Material = Enum.Material.SmoothPlastic
                                    else
                                        FLI.Material = Enum.Material.Neon
                                        RLI.Material = Enum.Material.Neon
                                    end
                                end
                            
                            end)

                        else
                            FLI.Material = Enum.Material.SmoothPlastic
                            RLI.Material = Enum.Material.SmoothPlastic
                            _maid.LightSignal = nil
                        end
                    end

                end
            end))
            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isRightSignalingAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local FRI = lightsModel:FindFirstChild("FRI") :: BasePart ?
                    local RRI = lightsModel:FindFirstChild("RRI") :: BasePart ?

                    if FRI and RRI then
                        if vehicleModel:GetAttribute(isRightSignalingAttribute) == true then
                            vehicleModel:SetAttribute(isLeftSignalingAttribute, nil)
                            task.wait()
                            local t = tick()
                            _maid.LightSignal = RunService.Stepped:Connect(function()
                                if tick() - t >= 0.35 then
                                    t = tick()

                                    if FRI.Material == Enum.Material.Neon then
                                        FRI.Material = Enum.Material.SmoothPlastic
                                        RRI.Material = Enum.Material.SmoothPlastic
                                    else
                                        FRI.Material = Enum.Material.Neon
                                        RRI.Material = Enum.Material.Neon
                                    end
                                end
                            
                            end)

                        else
                            FRI.Material = Enum.Material.SmoothPlastic
                            RRI.Material = Enum.Material.SmoothPlastic
                            _maid.LightSignal = nil
                        end
                    end
                end
            end))


            if vehicleModel:IsDescendantOf(workspace) then
                if vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    --ship physics check
                    local spawnPositionValue = vehicleModel:FindFirstChild("SpawnPosition") :: CFrameValue
                    if spawnPositionValue then
                        _maid:GiveTask(RunService.Stepped:Connect(function()
                            if (math.abs(vehicleModel.PrimaryPart.Orientation.Z) >= 90) then
                                --vehicleModel:PivotTo(CFrame.new(vehicleModel.PrimaryPart.Position)*CFrame.Angles(vehicleModel.PrimaryPart.Orientation.X, vehicleModel.PrimaryPart.Orientation.Y, 0))
                                vehicleModel:PivotTo(spawnPositionValue.Value)
                            end
                        end))   
                    end   
                    
                    --create border with ship
                    local defaultCollisionKey = "Default"
                    local vipPlayerCollisionKey = "VIPPlayerCollision"
                    local shipCollisionKey = "Ship"
                    local borderCollisionKey = "Border2"

                    PhysicsService:RegisterCollisionGroup(borderCollisionKey)
                    PhysicsService:CollisionGroupSetCollidable(borderCollisionKey, shipCollisionKey, true)
                    PhysicsService:CollisionGroupSetCollidable(defaultCollisionKey, borderCollisionKey, false)
                    PhysicsService:CollisionGroupSetCollidable(vipPlayerCollisionKey, borderCollisionKey, false)

                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local occupantMaid = _maid:GiveTask(Maid.new())
                    
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat ?
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model ?

                    if seat and wheels then
                        for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
                                v.MotorMaxTorque = 999999999999
                                v.MotorMaxAcceleration = 0
                                v.AngularVelocity = 0                            
                            end
                        end
                    end

                    _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                        occupantMaid:DoCleaning()
                        
                        if vehicleSeat.Occupant then
                            playSound(912961304, vehicleModel.PrimaryPart, false)
                        
                            task.spawn(function()
                                task.wait(1)
                                local sound = occupantMaid:GiveTask(playSound(vehicleModel:GetAttribute("EngineSound") or 532147820, vehicleModel.PrimaryPart, true, 35))
                                occupantMaid:GiveTask(RunService.Stepped:Connect(function()
                                    if not vehicleModel.PrimaryPart then
                                        _maid:Destroy()
                                    end
                                    sound.PlaybackSpeed = 1 + math.sqrt(vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude)/4
                                end))
                            end)
                        else
                            vehicleSeat.AssemblyLinearVelocity = Vector3.new()
                        end
                    end)) 

                    local vectorMaxForce = vehicleModel:GetAttribute("Power") or 20000
                    _maid:GiveTask(RunService.Stepped:Connect(function()
                        local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat

                        local direction = math.sign(seat.CFrame.LookVector:Dot(seat.AssemblyLinearVelocity.Unit))
                        local currentVelocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude
                        VectorForce.Force = Vector3.new(0,0,-seat.Throttle*(math.clamp(vectorMaxForce - ((vectorMaxForce)*(((currentVelocity)/ speedLimit))), 0, vectorMaxForce)))
                        if seat.Throttle ~= 0 and direction ~= seat.Throttle then
                            VectorForce.Force = Vector3.new(0,0, direction*vectorMaxForce)
                            --print(direction*vectorMaxForce)
                        end
                    end))
                end
            end
            _maid:GiveTask(vehicleModel.Destroying:Connect(function()
                print(vehicleModel, " destroyed")
                _maid:Destroy()
            end))
        end
    end
    
    --local carSpawnZone = Zone.new(CarSpawns:GetChildren(), maid)

    for _,vehicleModel in pairs(CollectionService:GetTagged(VEHICLE_TAG)) do
        vehicleSetup(vehicleModel)
    end

    CollectionService:GetInstanceAddedSignal(VEHICLE_TAG):Connect(function(inst)
        vehicleSetup(inst)
    end)


    NetworkUtil.onServerInvoke(SPAWN_VEHICLE, function(plr : Player, key : number, vehicleName : string, partZones : Instance ?)
        local plrInfo = PlayerManager.get(plr)
       -- print(carSpawnZone.ItemIsInside(v, plr.Character.PrimaryPart), " is insoide or nahhh", v)
        local existingVehicleData = plrInfo.Vehicles[key]
        if existingVehicleData and (existingVehicleData.IsSpawned == false) then
            plrInfo:SpawnVehicle(key, true, vehicleName, partZones)
        elseif existingVehicleData and (existingVehicleData.IsSpawned == true) then
            plrInfo:SpawnVehicle(key, false)
            NotificationUtil.Notify(plr, "You despawned " .. tostring(plrInfo.Vehicles[key].Name))
        end

        --MidasEventTree.Gameplay.EquipVehicle.Value(plr)

        return plrInfo.Vehicles
    end)

    maid:GiveTask(NetworkUtil.onServerEvent(ON_VEHICLE_CONTROL_EVENT, function(plr : Player, vehicleModel : Model, eventName : string)
       print(eventName)
        if eventName == "Horn" then
            assert(vehicleModel.PrimaryPart)
            if vehicleModel.PrimaryPart:FindFirstChild("HornSound") then
                return  
            end
            local sound = playSound(vehicleModel:GetAttribute("HornSound") or 200530606, vehicleModel.PrimaryPart, false, 50)
            sound.Name = "HornSound"
        elseif eventName == "Headlight" then
            vehicleModel:SetAttribute(isHeadlightAttribute, if vehicleModel:GetAttribute(isHeadlightAttribute) == true then nil else true)
        elseif eventName == "LeftSignal" then
            vehicleModel:SetAttribute(isLeftSignalingAttribute, if vehicleModel:GetAttribute(isLeftSignalingAttribute) == true then nil else true)
            --[[
            local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
            local FLI = lightsModel:FindFirstChild("FLI") :: BasePart ?
            local RLI = lightsModel:FindFirstChild("RLI") :: BasePart ?

            if FLI and RLI then
                FLI.Material = Enum.Material.Neon
                RLI.Material = Enum.Material.Neon
            end
            ]]
        elseif eventName == "RightSignal" then
            --PlaySound(200530606, seat, 1, 85)
            vehicleModel:SetAttribute(isRightSignalingAttribute, if vehicleModel:GetAttribute(isRightSignalingAttribute) == true then nil else true)
            --[[
            local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
            local FRI = lightsModel:FindFirstChild("FRI") :: BasePart ?
            local RRI = lightsModel:FindFirstChild("RRI") :: BasePart ?

            if FRI and RRI then
                FRI.Material = Enum.Material.Neon
                RRI.Material = Enum.Material.Neon
            end
            ]]
        end
        return
    end))
end

return Vehicle