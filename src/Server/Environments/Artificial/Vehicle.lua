--!strict
--services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService('TweenService')
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local PlayerManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerManager"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))

--local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
--local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
--types
type Maid = Maid.Maid
type VehicleData = ManagerTypes.VehicleData
--constants
local VEHICLE_TAG = "Vehicle"

local ENV_BOAT_CLASS_KEY = "EnvironmentBoat"
local CAR_CLASS_KEY = "Vehicle"
local BOAT_CLASS_KEY = "Boat"

local CUSTOM_THROTTLE_KEY = "CustomThrottle"
local CUSTOM_STEER_KEY = "CustomSteer"

--remotes
local SPAWN_VEHICLE = "SpawnVehicle"
local KEY_VALUE_NAME = "KeyValue"

local ON_VEHICLE_CONTROL_EVENT = "OnVehicleControlEvent"
local ON_VEHICLE_CHANGE_COLOR = "OnVehicleChangeColor"

local ON_TOOL_ANIM_PLAY = "OnAnimPlau"
--variables
--references
local CarSpawns = workspace:WaitForChild("Miscs"):WaitForChild("CarSpawns")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function playSound(soundId : number, target : Instance, isLoop : boolean, maxHeardDistance : number ?)
    local _maid = Maid.new()

    local sound = _maid:GiveTask(Instance.new("Sound"))
    sound.Looped = isLoop
    sound.RollOffMaxDistance = maxHeardDistance or 50
    sound.Parent = target
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound:Play()

    _maid:GiveTask(sound.Ended:Connect(function()
        _maid:Destroy()
    end))
    _maid:GiveTask(sound.AncestryChanged:Connect(function()
        if sound.Parent == nil then
            _maid:Destroy()
        end
    end))

    return sound
end

local function setupSpawnedCar(vehicleModel : Model)
    local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat")
    local body = vehicleModel:FindFirstChild("Body")
    if vehicleModel.PrimaryPart and body then
        local vehicleBodyParts = body:GetDescendants()
        for _,v in pairs(vehicleBodyParts) do
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
    if vehicleSeat then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = vehicleSeat
        weld.Part1 = vehicleModel.PrimaryPart
        weld.Parent = vehicleModel.PrimaryPart
    end
end

local function convertionKpHtoVelocity(KpH : number)
	return (KpH)*1000*3.571/3600
end

local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild(KEY_VALUE_NAME) :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class"),
        IsSpawned = model:IsDescendantOf(SpawnedCarsFolder),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId"),
        DestroyLocked = model:GetAttribute("DestroyLocked")
    }
end

local function getVehicleFromPlayer(plr : Player) : Model ?
    for _,vehicleModel in pairs(SpawnedCarsFolder:GetChildren()) do
        local vehicleData = getVehicleData(vehicleModel)
        if vehicleData.OwnerId == plr.UserId then
            return vehicleModel
        end
    end
    return nil
end

--class
local Vehicle = {}

function Vehicle.init(maid : Maid)
   
    local isHeadlightAttribute= "IsHeadlightAttribute"
    local isLeftSignalingAttribute = "IsLeftSignaling"
    local isRightSignalingAttribute = "IsRightSignaling"
    local isHazardSignalingAttribute = "IsHazardSignaling"
    local isSireningAttribute = "IsSirening"


    local function vehicleSetup(vehicleModel : Instance)
        local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
        local speedLimit = vehicleModel:GetAttribute("Speed") or 45
        
        vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0)
        vehicleModel:SetAttribute(CUSTOM_STEER_KEY, 0)

        if vehicleModel:IsA("Model") and vehicleSeat and vehicleSeat:IsA("VehicleSeat") and vehicleModel.PrimaryPart then
            if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then setupSpawnedCar(vehicleModel) end
            
            local _maid = Maid.new()

            local hasChassis = if vehicleModel:FindFirstChild("Chassis") then true else false 
            if hasChassis == false then 
                local attachment0 = Instance.new("Attachment")
                local VectorForce = Instance.new("VectorForce")  
                VectorForce.Name = "GeneratedVectorForce" 

                attachment0.Parent = vehicleModel.PrimaryPart
                VectorForce.Parent = vehicleModel.PrimaryPart
                
                VectorForce.Attachment0 = attachment0
                VectorForce.Force = Vector3.new(0,0,0)
            end

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(CUSTOM_THROTTLE_KEY):Connect(function()
                local customThrottleNum = vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY) :: number
                assert(customThrottleNum, "no throttle number")

                if vehicleModel:GetAttribute("Class") == ENV_BOAT_CLASS_KEY then
                    local hum = vehicleSeat.Occupant
                    if hum then
                      
                        local char = hum.Parent
                        local plr = if char then Players:GetPlayerFromCharacter(char) :: Player else nil 

                      
                        if char and plr and (customThrottleNum ~= 0) then
                            local db = false
                            _maid.BoatOnRow = RunService.Stepped:Connect(function()
                                if not db then
                                    db = true

                                    if vehicleSeat.AssemblyLinearVelocity.Magnitude <= 10 then
                                        local throttleV3 = vehicleSeat.CFrame.LookVector*customThrottleNum
                                        vehicleSeat.AssemblyLinearVelocity += throttleV3*20 
                                    end
                                    
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
                                        task.wait(0.85)
                                        handle:Destroy()
                                    end
                                    db = false
                                end
                            end)
                        elseif char and plr and (customThrottleNum == 0) then
                            _maid.BoatOnRow = nil
                        else
                            _maid.BoatOnRow = nil
                        end
                        -- animation:Destroy()
                    end
                  
                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then 
                    local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model

                    if seat and wheels then
                       --[[ for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
                                v.AngularVelocity = customThrottleNum*convertionKpHtoVelocity((speedLimit)*(if math.sign(customThrottleNum) == 1 then 1 else 0.5))
                                local accDir = vehicleModel.PrimaryPart.CFrame:VectorToObjectSpace(vehicleModel.PrimaryPart.AssemblyLinearVelocity).Z
                                if customThrottleNum ~= 0 then
                                    v.MotorMaxTorque = 5--999999999999
                                    v.MotorMaxAcceleration = if math.sign(accDir*customThrottleNum) == 1 then 60 else 25
                                    if math.sign(accDir*customThrottleNum) == 1 then
                                        v.AngularVelocity = 0
                                    end
                                else
                                    v.MotorMaxTorque = 999999999999
                                    v.MotorMaxAcceleration = 5
                                    v.AngularVelocity = 0
                                end
                            end
                        end]]

                        --brake signal
                        local lights = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                        local brakeLight = lights:FindFirstChild("R") :: Instance ?
                        if brakeLight then
                            local function updateLight(part : BasePart) 
                                if customThrottleNum == -1 then
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
                       
                        --VectorForce.Force = Vector3.new(0,0,-customThrottleNum*8000)
                    end
                
                elseif vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    print("powahh!")
                    
                end
            end))

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(CUSTOM_STEER_KEY):Connect(function()
                local customSteer = vehicleModel:GetAttribute(CUSTOM_STEER_KEY) :: number
                assert(customSteer, "no steer number")
                if vehicleModel:GetAttribute("Class") == ENV_BOAT_CLASS_KEY then
                    local db = false

                    _maid.BoatOnTurn = RunService.Stepped:Connect(function()
                        if db == false then
                            db = true
                            vehicleSeat.AssemblyAngularVelocity += Vector3.new(0,0.25,0)*-customSteer
                            task.wait(0.5)
                            db = false
                        end
                    end)
                elseif vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    --[[local seat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat ?
                    local wheels = vehicleModel:FindFirstChild("Wheels") :: Model ?

                    if seat and wheels then
                        for _,v in pairs(wheels:GetDescendants()) do
                            if v:IsA("HingeConstraint")  and v.ActuatorType == Enum.ActuatorType.Servo then    
                                local velocity = vehicleModel.PrimaryPart.AssemblyLinearVelocity.Magnitude

                                local targetAngle 
                                local angularSpeed
                                if velocity < convertionKpHtoVelocity(10) then
                                    
                                    targetAngle = 60*customSteer
                                    angularSpeed = 1
                                elseif velocity < convertionKpHtoVelocity(20) then
                                    targetAngle = 55*customSteer
                                    angularSpeed = 1*2
                                elseif velocity >= convertionKpHtoVelocity(20) and velocity < convertionKpHtoVelocity(40) then
                                    targetAngle = 42*customSteer
                                    angularSpeed = 2*2
                                elseif velocity >= convertionKpHtoVelocity(40) and velocity < convertionKpHtoVelocity(60) then
                                    targetAngle = 30*customSteer
                                    angularSpeed = 3*2
                                elseif velocity >= convertionKpHtoVelocity(60) and velocity < convertionKpHtoVelocity(80) then
                                    targetAngle = 25*customSteer
                                    angularSpeed = 3*2
                                elseif velocity >= convertionKpHtoVelocity(80) then
                                    targetAngle = 10*customSteer
                                    angularSpeed = 3*2
                                end

                        
                                local tweenTime = 1
                                if math.round(targetAngle) == 0 then angularSpeed = 25; tweenTime = 0.05 end 
                                local tween  = TweenService:Create(v, TweenInfo.new(tweenTime), {TargetAngle = targetAngle, AngularSpeed = angularSpeed})
                                tween:Play()
                            end
                        end
                    end]]
                elseif vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY then
                    --[[if customSteer ~= 0 then
                        _maid.OnRotate = RunService.Stepped:Connect(function()
                            local customThrottle = customSteer*vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY)
                            vehicleSeat.AssemblyAngularVelocity += Vector3.new(0,0.03,0)*(-customSteer*(if customThrottle ~= 0 then customSteer*customThrottle else 1))
                        end)     
                    else
                       _maid.OnRotate = nil 
                    end]]
                end
            end))

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
                --if vehicleModel:GetAttribute(CUSTOM_THROTTLE_KEY) == 0 then
                    vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, vehicleSeat.Throttle)
                --end
            end))

            _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Steer"):Connect(function() 
                --if vehicleModel:GetAttribute(CUSTOM_STEER_KEY) == 0 then
                    vehicleModel:SetAttribute(CUSTOM_STEER_KEY, vehicleSeat.Steer)
               -- end
            end))


            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isHeadlightAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local F = lightsModel:FindFirstChild("F") :: Instance ?

                    if F then
                        local function updateLight(part : BasePart) 
                            part.Material = if vehicleModel:GetAttribute(isHeadlightAttribute) then Enum.Material.Neon else Enum.Material.SmoothPlastic
                            local light = part:FindFirstChildWhichIsA("Light")
                            if light then
                                light.Enabled = vehicleModel:GetAttribute(isHeadlightAttribute) or false
                            end
                        end
                        if F:IsA("BasePart") then
                            updateLight(F)
                        elseif F:IsA("Model") then
                            for _,v in pairs(F:GetChildren()) do
                                if v:IsA("BasePart") then
                                    updateLight(v)
                                end
                            end
                        end
                    end
                end
            end))

            local function lightSignalFn(I: {BasePart | Model}, isStop : boolean, hasBuffer : boolean)
                if isStop then
                    local mat = Enum.Material.SmoothPlastic
                    for _,v in pairs(I) do
                        if v:IsA("Model") then
                            for _,l in pairs(v:GetDescendants()) do
                                if l:IsA("BasePart") then
                                    l.Material = mat
                                end
                            end
                        elseif v:IsA("BasePart") then
                            v.Material = mat
                        end
                    end
                else
                    local firstInst = I[1]
                    local firstMat 

                    if firstInst:IsA("BasePart") then
                        firstMat = firstInst.Material
                    elseif firstInst:IsA("Model") then
                        for _,v in pairs(firstInst:GetDescendants()) do
                            if v:IsA("BasePart") then
                                firstMat = v.Material
                                break
                            end
                        end
                    end
 
                    for _,v in pairs(I) do
                        local targetMat = if firstMat == Enum.Material.Neon then Enum.Material.SmoothPlastic else Enum.Material.Neon
                        if v:IsA("BasePart") then
                            v.Material = targetMat
                            if hasBuffer then task.wait(0.1) end
                        elseif v:IsA("Model") then
                            for _,l in pairs(v:GetChildren()) do
                                if l:IsA("BasePart") then
                                    l.Material = targetMat
                                    if hasBuffer then task.wait(0.1) end
                                end
                            end

                        end
                        
                         
                    end
                end
                
                
            end

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isLeftSignalingAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local FLI = lightsModel:FindFirstChild("FLI") :: (BasePart | Model) ?
                    local RLI = lightsModel:FindFirstChild("RLI") :: (BasePart | Model) ?

                    if FLI and RLI then
                        if vehicleModel:GetAttribute(isLeftSignalingAttribute) == true then
                            vehicleModel:SetAttribute(isHazardSignalingAttribute, nil)
                            vehicleModel:SetAttribute(isRightSignalingAttribute, nil)
                            task.wait()
                            local t = tick()
                            _maid.LightSignal = RunService.Stepped:Connect(function()
                                if tick() - t >= 0.35 then
                                    t = tick()

                                    lightSignalFn({FLI, RLI}, false, false)
                                    --[[if FLI.Material == Enum.Material.Neon then
                                        FLI.Material = Enum.Material.SmoothPlastic
                                        RLI.Material = Enum.Material.SmoothPlastic
                                    else
                                        FLI.Material = Enum.Material.Neon
                                        RLI.Material = Enum.Material.Neon
                                    end]]
                                    
                                end
                            
                            end)

                        else
                            lightSignalFn({FLI, RLI}, true, false)
                            _maid.LightSignal = nil
                        end
                    end

                end
            end))
            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isRightSignalingAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local FRI = lightsModel:FindFirstChild("FRI") :: (BasePart | Model) ?
                    local RRI = lightsModel:FindFirstChild("RRI") :: (BasePart | Model) ?
                    
                    if FRI and RRI then
                        if vehicleModel:GetAttribute(isRightSignalingAttribute) == true then
                            vehicleModel:SetAttribute(isHazardSignalingAttribute, nil)
                            vehicleModel:SetAttribute(isLeftSignalingAttribute, nil)
                            task.wait()
                            local t = tick()
                            _maid.LightSignal = RunService.Stepped:Connect(function()
                                if tick() - t >= 0.35 then
                                    t = tick()

                                    lightSignalFn({FRI, RRI}, false, false)
                                    --[[if FRI.Material == Enum.Material.Neon then
                                        FRI.Material = Enum.Material.SmoothPlastic
                                        RRI.Material = Enum.Material.SmoothPlastic
                                    else
                                        FRI.Material = Enum.Material.Neon
                                        RRI.Material = Enum.Material.Neon
                                    end]]
                                end
                            
                            end)

                        else
                            lightSignalFn({FRI, RRI}, true, false)
                            _maid.LightSignal = nil
                        end
                    end
                end
            end))

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isHazardSignalingAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local lightsModel = vehicleModel:WaitForChild("Body"):WaitForChild("Lights")
                    local FRI = lightsModel:FindFirstChild("FRI") :: BasePart ?
                    local RRI = lightsModel:FindFirstChild("RRI") :: BasePart ?
                    local FLI = lightsModel:FindFirstChild("FLI") :: BasePart ?
                    local RLI = lightsModel:FindFirstChild("RLI") :: BasePart ?

                    if FRI and RRI and FLI and RLI then
                        if vehicleModel:GetAttribute(isHazardSignalingAttribute) == true then
                            vehicleModel:SetAttribute(isLeftSignalingAttribute, nil)
                            vehicleModel:SetAttribute(isRightSignalingAttribute, nil)
                            task.wait()
                            local t = tick()
                            _maid.LightSignal = RunService.Stepped:Connect(function()
                                if tick() - t >= 0.35 then
                                    t = tick()

                                    lightSignalFn({FRI, RRI, FLI, RLI}, false, false)
                                end
                            
                            end)
                        else
                            lightSignalFn({FRI, RRI, FLI, RLI}, true, false)
                            _maid.LightSignal = nil
                        end
                    end
                end
            end))

            _maid:GiveTask(vehicleModel:GetAttributeChangedSignal(isSireningAttribute):Connect(function()
                if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                    local vehicleBody = vehicleModel:FindFirstChild("Body")
                    if vehicleBody then
                        local body = vehicleBody:WaitForChild("Body")
                        local sirene = body:FindFirstChild("Sirene")

                        local sireneLamps = {}
                        for _,v in pairs(sirene:GetChildren()) do
                            if v:IsA("BasePart") then
                                table.insert(sireneLamps, v)
                            end
                        end

                        if sirene then
                            if vehicleModel:GetAttribute(isSireningAttribute) == true then
                                local t = tick()
                                local db = false
                                _maid.Sirene = RunService.Stepped:Connect(function()
                                    if tick() - t >= 0.5 and not db then
                                        db =  true
                                        t = tick()

                                        lightSignalFn(sireneLamps, false, true)
                                        db = false
                                    end
                                end)

                                _maid.SireneSound = playSound(5074502989, vehicleModel.PrimaryPart, true)
                                
                            else
                                _maid.Sirene = nil
                                _maid.SireneSound = nil
                                lightSignalFn(sireneLamps, true, false)
                            end

                        end
                    end
                end
            end))

            if vehicleModel:IsDescendantOf(workspace) then
                if vehicleModel:GetAttribute("Class") == ENV_BOAT_CLASS_KEY then
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
                    PhysicsService:CollisionGroupSetCollidable("Player", borderCollisionKey, false)

                elseif (vehicleModel:GetAttribute("Class") == BOAT_CLASS_KEY) or (vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY) then
                    --local occupantMaid = _maid:GiveTask(Maid.new())
                    print(hasChassis, vehicleModel:FindFirstChild("Chassis"))
                    if hasChassis then 
                        local chassisModel = vehicleModel:FindFirstChild("Chassis") :: Model
                        assert(chassisModel)
                        local wheels = chassisModel:FindFirstChild("Wheels") :: Model
                        assert(wheels)
                        local chassis = chassisModel:FindFirstChild("Chassis") :: BasePart
                        assert(chassis)

                        local height = vehicleModel:GetAttribute("Height") 
                        local suspension = vehicleModel:GetAttribute("Suspension") 
                        local bounce = vehicleModel:GetAttribute("Bounce") 
                        local turnSpeed = vehicleModel:GetAttribute("TurnSpeed") 
                        local maxSpeed = vehicleModel:GetAttribute("Speed") 



                        local throttlespeed = 0


                        --local movement = Vector2.new()


                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {vehicleModel}

                        local function updateWheel(wheelModel : Model)
                            local wheelPart = wheelModel:FindFirstChild("WheelPart") :: BasePart
                            local thruster = wheelModel:FindFirstChild("Thruster") :: BasePart

                            local realThrusterHeight = math.huge
                            assert(wheelPart and thruster)

                            local raycastResult = workspace:Raycast(thruster.Position, thruster.CFrame.UpVector*Vector3.new(0, -height*1.2, 0), raycastParams)
                            if raycastResult and raycastResult.Instance.CanCollide then
                                realThrusterHeight = thruster.CFrame:PointToObjectSpace(raycastResult.Position).Y
                                --local pos, normal = raycast.Position, raycast.Normal
                                --local chassisWeld = thruster:FindFirstChild("ChassisWeld") :: Weld
                            end
                            local wheelWeld = thruster:FindFirstChild("WheelWeld") :: Weld
                            local wheelDisplayWeld = wheelPart:FindFirstChild("WheelDisplayWeld") :: Weld
                            wheelWeld.C0 = CFrame.new(wheelWeld.C0.Position):Lerp(CFrame.new(0, -math.min(math.abs(realThrusterHeight), height) + wheelPart.Size.Y*0.5, 0), 0.1)--*CFrame.Angles(math.pi/2, 0, 0)
                            wheelWeld.C1 = CFrame.Angles(0, math.pi, 0)

                            local speed = chassis.CFrame:VectorToObjectSpace(chassis.AssemblyLinearVelocity)

                            local wheelIsInFront = (chassis.CFrame:Inverse()*thruster.CFrame).Position.Z < 0
                            local wheelIsInRight = (chassis.CFrame:Inverse()*thruster.CFrame).Position.X > 0

                            local direction = -math.sign(speed.Z)
                            if wheelIsInFront then
                                local turnVel = (chassis.CFrame:VectorToObjectSpace(chassis.AssemblyAngularVelocity).Y*40)*direction
                                wheelWeld.C0 = wheelWeld.C0*CFrame.Angles(0, math.rad(turnVel), 0)
                            end
                            wheelDisplayWeld.C0 = wheelDisplayWeld.C0*CFrame.Angles(math.rad(if wheelIsInRight then speed.Z else -speed.Z), 0, 0)
                            return
                        end


                        for _,wheelModel : Model in pairs(wheels:GetChildren() :: any) do 
                            local wheelPart = wheelModel:FindFirstChild("WheelPart") :: BasePart
                            local thruster = wheelModel:FindFirstChild("Thruster") :: BasePart
                            local wheelDisplay = wheelModel:FindFirstChild("WheelDisplay") :: BasePart

                            assert(wheelPart and thruster)

                            local chassisWeld = Instance.new("Weld")
                            chassisWeld.Name = "ChassisWeld"
                            chassisWeld.Part0 = thruster
                            chassisWeld.Part1 = chassis
                            chassisWeld.C0 = thruster.CFrame:ToObjectSpace(chassis.CFrame) 
                            chassisWeld.C1 = CFrame.new()
                            chassisWeld.Parent = thruster

                            local wheelWeld = Instance.new("Weld")
                            wheelWeld.Name = "WheelWeld"
                            wheelWeld.Part0 = thruster
                            wheelWeld.Part1 = wheelPart
                            wheelWeld.C0 = CFrame.new() 
                            wheelWeld.C1 = CFrame.new()
                            wheelWeld.Parent = thruster
                            
                            local wheelDisplayWeld = Instance.new("Weld")
                            wheelDisplayWeld.Name = "WheelDisplayWeld"
                            wheelDisplayWeld.Part0 = wheelPart
                            wheelDisplayWeld.Part1 = wheelDisplay
                            wheelDisplayWeld.C0 = CFrame.new(0,0,0)*CFrame.Angles(0, math.pi, 0) 
                            wheelDisplayWeld.C1 = CFrame.new()
                            wheelDisplayWeld.Parent = wheelPart

                            task.spawn(function()
                                while task.wait() do 
                                    updateWheel(wheelModel)
                                end
                            end)
                        end

                        local linearVelocity = Instance.new("LinearVelocity")
                        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
                        linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                        linearVelocity.MaxAxesForce = Vector3.new(0, 0, 0)
                        linearVelocity.Parent = chassis
                        do
                            local attachment = Instance.new("Attachment")
                            attachment.Parent = chassis
                            linearVelocity.Attachment0 = attachment
                        end
                        local angularVelocity = Instance.new("AngularVelocity")
                        angularVelocity.AngularVelocity = Vector3.new()
                        angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        angularVelocity.MaxTorque = 0
                        angularVelocity.Parent = chassis
                        do
                            local attachment = angularVelocity.Attachment0 or Instance.new("Attachment")
                            attachment.Parent = chassis
                            angularVelocity.Attachment0 = attachment
                        end
                        linearVelocity.Enabled = false
                        angularVelocity.Enabled = false

                        local alignPosition = Instance.new("AlignPosition")
                        alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                        alignPosition.MaxAxesForce = Vector3.new()
                        alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
                        alignPosition.ReactionForceEnabled = true
                        alignPosition.Parent = chassis
                        do
                            local attachment = Instance.new("Attachment")
                            attachment.Parent = chassis
                            alignPosition.Attachment0 = attachment
                        end

                        local alignOrientation = Instance.new("AlignOrientation") 
                        alignOrientation.ReactionTorqueEnabled = true
                        alignOrientation.Enabled = false
                        alignOrientation.MaxTorque = 0

                        alignOrientation.AlignType = Enum.AlignType.Perpendicular
                        alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        alignOrientation.Parent = chassis
                        do
                            local attachment = Instance.new("Attachment")
                            attachment.Parent = chassis
                            alignOrientation.Attachment0 = attachment
                        end

                        local function setCarOwnership(player : Player?)
                            if player ~= nil then 
                                vehicleSeat:SetNetworkOwner(player)

                                alignOrientation.Enabled = false
                                alignPosition.Enabled = false

                                linearVelocity.Enabled = true
                                angularVelocity.Enabled = true
                                
                                
                                -- if not player.PlayerGui:FindFirstChild("LocalScript") then 
                                --     local ls = script.LocalScript:Clone()
                                --     ls.Disabled = false
                                --     ls.Parent = player.PlayerGui
                                -- end
                            else
                                print(vehicleSeat)
                                task.wait()
                                vehicleSeat:SetNetworkOwnershipAuto()

                                linearVelocity.Enabled = false
                                angularVelocity.Enabled = false

                                alignPosition.Enabled = true
                                alignOrientation.Enabled = true
                                
                                --TEMPORARY!!
                                -- for _, plr in pairs(game.Players:GetPlayers()) do
                                --     if plr:WaitForChild("PlayerGui"):FindFirstChild("LocalScript") then 
                                --         plr:WaitForChild("PlayerGui"):FindFirstChild("LocalScript"):Destroy()
                                --     end
                                -- end
                            end
                        end

                        _maid:GiveTask(vehicleSeat.Changed:Connect(function(property)
                            local hum = vehicleSeat.Occupant
                            local player = if hum then game:GetService("Players"):GetPlayerFromCharacter(hum.Parent) else nil
                            
                            if property == "Occupant" then
                                if player then
                                    setCarOwnership(player)
                                else
                                    setCarOwnership()
                                end
                            end
                        end))

                        setCarOwnership()
                        _maid:GiveTask(RunService.Stepped:Connect(function()
                            local raycastResult = workspace:Raycast(chassis.Position, chassis.CFrame.UpVector*Vector3.new(0, -height*1.2, 0), raycastParams)
                            if raycastResult then 
                                local position, normal = raycastResult.Position, raycastResult.Normal
                                local chassisHeight = math.abs(chassis.CFrame:PointToObjectSpace(raycastResult.Position).Y) --(position - chassis.Position).Magnitude

                                if vehicleSeat.Occupant == nil then			
                                            
                                    local mass = 0

                                    for i, v in pairs(vehicleModel:GetChildren()) do
                                        if v:IsA("BasePart") then
                                            mass = mass + (v:GetMass() * 196.2)
                                            if v:IsA("Seat") then
                                                local humanoid = v.Occupant
                                                local char = if humanoid then humanoid.Parent else nil 
                                                if char then
                                                     for _,v in pairs(char:GetDescendants()) do
                                                        if v:IsA("BasePart") and not v.Massless then mass += v:GetMass()*196.2 end 
                                                     end
                                                end
                                            end
                                        end
                                    end
                    
                                    chassis.AssemblyLinearVelocity = chassis.AssemblyLinearVelocity:Lerp(Vector3.new(0, chassis.AssemblyLinearVelocity.Y, 0), 0.1)
                                    
                                    local rotCf = (CFrame.new(position, position + normal)*CFrame.Angles(-math.pi/2, 0, 0))
                                    local x, y, z = rotCf:ToOrientation()

                                    if vehicleSeat.Throttle ~= 0 then
                                        throttlespeed = math.min(throttlespeed + vehicleSeat.Throttle, 75)
                                    else
                                        throttlespeed = math.max(throttlespeed - 5, 0)
                                    end
                                    --chassis.LinearVelocity.VectorVelocity = Vector3.new(0,0,-throttlespeed)

                                    alignPosition.MaxAxesForce = Vector3.new(mass/4,math.huge,mass/4)

                                    alignPosition.Position = position + normal*((height*0.57))
 

                                    alignOrientation.CFrame = CFrame.Angles(math.rad(x), math.rad(chassis.Orientation.Y - vehicleSeat.Steer*20*math.sign(vehicleSeat.Throttle)), math.rad(z))
                                    alignOrientation.MaxTorque = math.huge

                                end
                            
                                --alignOrientation.CFrame = CFrame.Angles(math.rad(x), math.rad(chassis.Orientation.Y - vehicleSeat.Steer*20*math.sign(vehicleSeat.Throttle)), math.rad(z))
                                --alignOrientation.MaxTorque = math.huge
                            else
                                alignPosition.MaxAxesForce = Vector3.new()
                                alignOrientation.MaxTorque = 0

                            end
                        end))

                    else 
                        
                    
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
    
                       
                    end  
                    local occupantMaid = _maid:GiveTask(Maid.new())

                    _maid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                        occupantMaid:DoCleaning()

                        --detecting lock
                        local humanoid = vehicleSeat.Occupant
                        local plr = if humanoid and humanoid.Parent then Players:GetPlayerFromCharacter(humanoid.Parent) else nil
                        local vehicleData = getVehicleData(vehicleModel)
                        if humanoid and vehicleModel:GetAttribute("isLocked") and plr.UserId ~= vehicleData.OwnerId then                            
                            local seatWeld = vehicleSeat:FindFirstChild("SeatWeld")
                            local char = humanoid.Parent
                            humanoid.Sit = false
                            if seatWeld then
                                game:GetService("Debris"):AddItem(seatWeld,0)
                            end
                            if char then
                                char:PivotTo(char.PrimaryPart.CFrame - char.PrimaryPart.CFrame.LookVector*5) --FIX DIS!
                            end 
                            return
                        end
                        
                        if vehicleSeat.Occupant then
                            vehicleSeat:SetNetworkOwner(plr)
                            playSound(912961304, vehicleModel.PrimaryPart, false)
                        
                            local delayTime = 1
                            local t = tick()
                            local sound = occupantMaid:GiveTask(playSound(vehicleModel:GetAttribute("EngineSound") or 532147820, vehicleModel.PrimaryPart, true, 35))
                            sound.Volume = 0
                            occupantMaid:GiveTask(RunService.Stepped:Connect(function()
                                if tick() - t > delayTime then     
                                    sound.Volume = 1  
                                    local pripart = vehicleModel.PrimaryPart :: BasePart ?
                                    if pripart then         
                                        sound.PlaybackSpeed = 1 + math.sqrt(pripart.AssemblyLinearVelocity.Magnitude)/4     
                                    end
                                end
                            end))
                        else
                            vehicleSeat:SetNetworkOwnershipAuto()
                            vehicleSeat.AssemblyLinearVelocity = Vector3.new()
                        end
                    end)) 
                end
            end
            _maid:GiveTask(vehicleModel.AncestryChanged:Connect(function()
                if vehicleModel.Parent == nil then
                    _maid:Destroy()
                end
            end))

            if vehicleModel:GetAttribute("Class") == CAR_CLASS_KEY then
                local function updatePlate()
                    local plates = vehicleModel:WaitForChild("Body"):WaitForChild("Body"):FindFirstChild("Plates")

                    if plates then
                        local function getRandomNum()
                            return string.char(math.random(49, 57))
                        end
                        local function getRandomAlphabet()
                            return string.char(math.random(65, 65+25))
                        end
    
                        local randomPlateNum = `{getRandomAlphabet()} {getRandomNum()}{getRandomNum()}{getRandomNum()}{getRandomNum()} {getRandomAlphabet()}{getRandomAlphabet()}`
                       
                        for _,v in pairs(plates:GetChildren()) do
                            local sg = v:FindFirstChildWhichIsA("SurfaceGui")
                            local tl = if sg then sg:FindFirstChildWhichIsA("TextLabel") else nil
                            if tl then
                                tl.Text = if vehicleModel:GetAttribute("OwnerId") then Players:GetNameFromUserIdAsync(vehicleModel:GetAttribute("OwnerId") or 0) else randomPlateNum
                            end
                        end
                    end
                end

                if vehicleModel:IsDescendantOf(workspace) then
                    updatePlate()
                    _maid:GiveTask(vehicleModel:GetAttributeChangedSignal("OwnerId"):Connect(function()
                        updatePlate()
                    end))
                end
            end
        end
    end
    
    --local carSpawnZone = Zone.new(CarSpawns:GetChildren(), maid)

    for _,vehicleModel in pairs(CollectionService:GetTagged(VEHICLE_TAG)) do
        vehicleSetup(vehicleModel)
    end

    CollectionService:GetInstanceAddedSignal(VEHICLE_TAG):Connect(function(inst)
        vehicleSetup(inst)
    end)


    NetworkUtil.onServerInvoke(SPAWN_VEHICLE, function(plr : Player, key : number ?, vehicleName : string?, partZones : Instance ?)
        local plrInfo = PlayerManager.get(plr)
       -- print(carSpawnZone.ItemIsInside(v, plr.Character.PrimaryPart), " is insoide or nahhh", v)
        local existingVehicleData 
        local defKey  
        if key then 
            existingVehicleData = plrInfo.Vehicles[key]
            defKey = key
        else
            for k,v in pairs(plrInfo.Vehicles) do
                if v.IsSpawned then
                    defKey, existingVehicleData = k, v
                    break
                end
            end
        end
        assert(defKey and existingVehicleData, "Unable to find the vehicle data!")

        if existingVehicleData and (existingVehicleData.IsSpawned == false) then
            plrInfo:SpawnVehicle(defKey, true, vehicleName, partZones)
        elseif existingVehicleData and (existingVehicleData.IsSpawned == true) then
            plrInfo:SpawnVehicle(defKey, false)
            NotificationUtil.Notify(plr, "You despawned " .. tostring(plrInfo.Vehicles[defKey].Name))
        end

        --MidasEventTree.Gameplay.EquipVehicle.Value(plr)

        return plrInfo.Vehicles
    end)

    maid:GiveTask(NetworkUtil.onServerEvent(ON_VEHICLE_CONTROL_EVENT, function(plr : Player, vehicleModel : Model, eventName : string, ...)
        if eventName == "Horn" then
            assert(vehicleModel.PrimaryPart)

            local vehicleBody = vehicleModel:FindFirstChild("Body")
            if vehicleBody then
                local body = vehicleBody:WaitForChild("Body")
                local sirene = if body then body:FindFirstChild("Sirene") else nil

                if sirene then
                    vehicleModel:SetAttribute(isSireningAttribute, if vehicleModel:GetAttribute(isSireningAttribute) == true then nil else true)
                    return
                end
            end

            if vehicleModel.PrimaryPart:FindFirstChild("HornSound") then
                return  
            end
            local sound = playSound(vehicleModel:GetAttribute("HornSound") or 200530606, vehicleModel.PrimaryPart, false, 70)
            sound.Name = "HornSound"
        elseif eventName == "Headlight" then
            vehicleModel:SetAttribute(isHeadlightAttribute, if vehicleModel:GetAttribute(isHeadlightAttribute) == true then nil else true)
        elseif eventName == "LeftSignal" then
            vehicleModel:SetAttribute(isLeftSignalingAttribute, if vehicleModel:GetAttribute(isLeftSignalingAttribute) == true then nil else true)
        elseif eventName == "RightSignal" then
            --PlaySound(200530606, seat, 1, 85)
            vehicleModel:SetAttribute(isRightSignalingAttribute, if vehicleModel:GetAttribute(isRightSignalingAttribute) == true then nil else true)
        elseif eventName == "HazardSignal" then
            vehicleModel:SetAttribute(isHazardSignalingAttribute, if vehicleModel:GetAttribute(isHazardSignalingAttribute) == true then nil else true)
        elseif eventName == "Move" then
            local vehicleSeat = vehicleModel:FindFirstChild("VehicleSeat") :: VehicleSeat

            local direction = table.pack(...)[1]

            if direction == "Forward" then
                vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 1)
            elseif direction == "Backward" then
                vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, -1)
            elseif direction == "Left" then
                vehicleModel:SetAttribute(CUSTOM_STEER_KEY, -1)
            elseif direction == "Right" then
                vehicleModel:SetAttribute(CUSTOM_STEER_KEY, 1)
            elseif direction == "Straight" then
                vehicleModel:SetAttribute(CUSTOM_STEER_KEY, 0)
            elseif direction == "Brake" then
                vehicleModel:SetAttribute(CUSTOM_THROTTLE_KEY, 0)
            end
        elseif eventName == "WaterSpraySignal" then
            --continue this tommorow pls
            local waterEmitter = vehicleModel:WaitForChild("Body"):WaitForChild("Body"):FindFirstChild("WaterEmitter")
            if waterEmitter then
                local particleEmitter = waterEmitter:FindFirstChildWhichIsA("ParticleEmitter")
                if particleEmitter then
                    particleEmitter.Enabled = not particleEmitter.Enabled

                    if particleEmitter.Enabled then
                        playSound(5057582133, waterEmitter, true, 50)
                    else
                        local sound = waterEmitter:FindFirstChildWhichIsA("Sound")
                        if sound then sound:Destroy() end
                    end
                end
            end
        end
        return
    end))

    NetworkUtil.onServerInvoke(ON_VEHICLE_CHANGE_COLOR, function(plr : Player, color : Color3)
        local vehicleModel = getVehicleFromPlayer(plr)
        assert(vehicleModel)
        local vehicleData = getVehicleData(vehicleModel)
        if vehicleData.Class ~= CAR_CLASS_KEY then
            return nil
        end
        local bodyModel = vehicleModel:FindFirstChild("Body")
        local internalBody = if bodyModel then bodyModel:FindFirstChild("Body") else nil
        local paints = if internalBody then internalBody:FindFirstChild("Paints") else nil

        if paints then
            for _,v in pairs(paints:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = color
                end
            end
        end
    
        return nil
    end)

end

return Vehicle