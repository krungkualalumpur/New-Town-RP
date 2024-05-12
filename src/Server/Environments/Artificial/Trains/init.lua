--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
--remotes
local ON_VELOCITY_CHANGE = "OnVelocityChange"
local INVOKE_TRAIN_ANNOUNCEMENT = "InvokeTrainAnnouncement"
local ON_TRAIN_INIT = "OnTrainInit"
--variables
--references
--local functions
--class


local function playSound(soundId : number, target : Instance ?, volume : number ?, maxDistance : number ?)
	local sound = Instance.new("Sound") 
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Volume = volume or 0.5 
	sound.Parent = target
	sound.RollOffMaxDistance = maxDistance or 50
	sound:Play()
	
	task.spawn(function()
		sound.Ended:Wait()
		sound:Destroy()
	end)
	return sound
end

local Trains = {}

function Trains.init(maid : Maid)
    for _,train in pairs(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Trains"):GetChildren()) do
        local trainOriginalCFrame = train.PrimaryPart.CFrame
        
        local firstTickErrorDetect : number ?

        local function trainStuckCheck()
            if train.PrimaryPart == nil then
                return true
            end
          
            if (math.floor(train.PrimaryPart.AssemblyLinearVelocity.Magnitude) == 0) or (math.abs(train.PrimaryPart.Orientation.X) > 8) or (math.abs(train.PrimaryPart.Orientation.Z) > 8) then
                    --if tick() - errorCheck >= 1 then
                firstTickErrorDetect = firstTickErrorDetect or tick()
                    --end
                --print("seconds before reset: ", tick() - firstTickErrorDetect)
            else 
                firstTickErrorDetect = nil
            end
            if firstTickErrorDetect and (tick() - firstTickErrorDetect >= 4) then
                firstTickErrorDetect = nil
                return true
            end
            return false
        end

        local function setVelocity(velocity : number)
        --	print("Velocity set: ", velocity, debug.traceback())
            train:SetAttribute("CustomVelocity", velocity)
            
            for _,v in pairs(train.Machines.Wheels:GetDescendants()) do
                if v:IsA("HingeConstraint") then
                    v.AngularVelocity = velocity
                end
            end
            for _,v in pairs(train.Machines.Mechanics.Wheels:GetDescendants()) do
                if v:IsA("HingeConstraint") then
                    v.AngularVelocity = velocity
                end
            end
            --train.Machines.MachinePripart.VectorForce.Force = Vector3.new(2500*math.sign(velocity),0,0)
            
            
        end
        
        
        local function setLoopState(n : number)
            train:SetAttribute("LoopState", n)
        end
        local function getLoopState(specTrain : Model ?) 
            return (specTrain or train):GetAttribute("LoopState")
        end

        local function start(intVel : number ?)
            local vel = intVel or 36

            NetworkUtil.fireAllClients(ON_VELOCITY_CHANGE, train, "Start")            
            task.wait(1)
            setVelocity(vel)
        end
        
        local function slowDown(intVel : number ?)
            local vel = (intVel or 36)*0.45
            NetworkUtil.fireAllClients(ON_VELOCITY_CHANGE, train, "Slowdown")
            setVelocity(vel)
        end
        
        local function stop(loopState : number, cf : CFrame ?)
            local sound = train.Part.DieselSound
            
            NetworkUtil.fireAllClients(ON_VELOCITY_CHANGE, train, "Stop")
            if cf then
                local s, e = pcall(function()
                    repeat local dot = cf.LookVector:Dot((cf.Position - train.PrimaryPart.Position).Unit)
                        task.wait()
                        local distDir = (train.PrimaryPart.Position - cf.Position).Magnitude*math.sign(dot)
                        --if math.round(distDir) > 0 then
                        local vel = math.clamp(distDir, -3, 3)
                        setVelocity(vel)
                        --print(vel, " :velocity approach")

                        if trainStuckCheck() then
                            error(`Train is detected stuck during stop at dist {distDir} studs`)
                        end
                    until (math.round(distDir))*loopState <= 1
                    --else
                    setVelocity(0)
                    repeat task.wait() until math.round(train.PrimaryPart.AssemblyLinearVelocity.Magnitude) == 0
                    task.wait(2)
                    --end 
                end)
                if e then
                    error(e)
                end
                --[[local conn
                conn = RunService.Stepped:Connect(function()
                    local dot = cf.LookVector:Dot((cf.Position - train.PrimaryPart.Position).Unit)
                    print(dot)
                    local distDir = (train.PrimaryPart.Position - cf.Position).Magnitude*math.sign(dot)
                    if math.round(distDir) > 0 then
                        local vel = math.min(distDir, 1)
                        setVelocity(vel)
                    else
                        setVelocity(0)
                        conn:Disconnect()
                    end 
                    print(distDir)
                    
                end)]]
            else
                setVelocity(0)
                task.wait(1.5)
            end
        end
        
        local function checkPositionSideRelativeToTrain(part : BasePart) -- checking if door is heading to left or right
            local dot = train.PrimaryPart.CFrame.RightVector:Dot((part.Position - train.PrimaryPart.Position).Unit)
            return dot > 0
        end
        
        local function init()
            setVelocity(0)
        
            
            local sound = train.Part.DieselSound
            sound:Play()
            sound.Volume = 0
            local sound2 = train.Part.Screech
            sound2.Volume = 0
            sound2:Play()
            local sound2 = train.Part.DieselSound2
            sound2.Volume = 0.015
            sound2.PlaybackSpeed = 2*0.65
            sound2:Play()
        
            local sound3 = train.Part.DieselSound3
            sound3.Volume = 0.015
            sound3:Play()
            stop(1)
            local acSound = train.Part.AC
            acSound.Volume = 0.15
            acSound:Play()
            
            --doors
            for _,door in pairs(train.Body.Doors:GetChildren()) do
                local attachment = Instance.new("Attachment")
                attachment.Name = "DoorAttachment"
                attachment.Parent = door.PrimaryPart
                door.PrimaryPart:FindFirstChildWhichIsA("PrismaticConstraint").Enabled = false
            end

            NetworkUtil.fireAllClients(ON_TRAIN_INIT, train)
        end
        
        local function updateAnnouncementDisplay(announcementType : "Station" | "DoorAnnouncement" | "Announcement", ...)
            NetworkUtil.fireAllClients(INVOKE_TRAIN_ANNOUNCEMENT, train, announcementType, ...)
        end

        local function switchTrack(loopState, switchPointModel : Model)
            local startPart = switchPointModel:FindFirstChild("Start") :: BasePart
            local endPart = switchPointModel:FindFirstChild("End") :: BasePart

            assert(startPart and endPart)
            
            local trainWheelSwitchCollisionKey = "TrainWheel_Switch"
            local trainWheelDefaultCollisionKey = "TrainWheel"
            stop(loopState, startPart.CFrame)
            --allow the train to move approacing to the destination line (lineParts) by disabling collision on the lines (preferably by one of two ways OR both: (1. set custom collision or/and 2. wait until the other train stop/switch track)
            local mechanicWheels = train:WaitForChild("Machines"):WaitForChild("Mechanics"):WaitForChild("Wheels")
            for _,v in pairs(mechanicWheels:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CollisionGroup = trainWheelSwitchCollisionKey
                end
            end
            --head to switch point part using stop(switchPtV3)
            stop(loopState, endPart.CFrame)
            --enable the destination line collision again
            for _,v in pairs(mechanicWheels:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CollisionGroup = trainWheelDefaultCollisionKey
                end
            end
        end

     
        
        local function moveToStation(stationPart : BasePart, loopState : number)
            local stationWaitTime = 10
            train.PrimaryPart.Anchored = false
            
            local velocity = 20*loopState
            
            local triggerStopDistanceFromStation = 50
            local dist = (train.PrimaryPart.Position - stationPart.Position).Magnitude
            
            local function trainSpeedUpdate()
                if train:GetAttribute("IsSlowDown")  == true then
                    slowDown(velocity)
                else
                    start(velocity)
                end
            end
            
            --dettcting slow down zones
            local slowDownConn = train:GetAttributeChangedSignal("IsSlowDown"):Connect(trainSpeedUpdate)
            local zones = workspace:WaitForChild("Assets"):WaitForChild("Infrastructures"):WaitForChild("LRT"):WaitForChild("SlowdownZones")
            local overlapParams = OverlapParams.new()
            overlapParams.FilterType = Enum.RaycastFilterType.Include
            overlapParams.FilterDescendantsInstances = zones:GetChildren()
            
            --updating visual
            if loopState == 1 then
                train.Body.Lights.R.Color = Color3.fromRGB(200,50,50)
                train.Body.Lights.F.Color = Color3.fromRGB(255, 255, 255)
        
            elseif loopState == -1 then
                train.Body.Lights.F.Color = Color3.fromRGB(200,50,50)
                train.Body.Lights.R.Color = Color3.fromRGB(255, 255, 255)
        
                
            end
            
            --running to destination
            local s, e = pcall(function()
                trainSpeedUpdate()

                --announce
                task.spawn(function() -- make this in klooooiien leitha on okeh?
                    local stationNameSoundId = if stationPart:GetAttribute("Order") == 1 then 16878542580 elseif stationPart:GetAttribute("Order") == 2 then 16878536551 elseif stationPart:GetAttribute("Order") == 3 then 16878525832 else 0
                    
                    task.wait(1)
                    local s = playSound(143147223, train.PrimaryPart, 0.35, 30)
                    s.Destroying:Wait()
                    local s2 = playSound(16878504815, train.PrimaryPart, 0.35, 30)
                    s2.Destroying:Wait()
                    local s3 =  playSound(stationNameSoundId, train.PrimaryPart, 0.35, 30)
                    s3.Destroying:Wait()
                    local randAnn = math.random(0,math.random(0,1))
                    if randAnn == 1 then
                        local s4 =  playSound(16878550604, train.PrimaryPart, 0.35, 30)
                        
                    end

                end)

                local emergencyStop = false
                    
                local function setEmergencyStop(trainModel : Model, bool : boolean)
                    emergencyStop = bool
                    trainModel:SetAttribute("IsEmergencyStop", bool)
                end
                local function getEmergencyStop(trainModel : Model)
                    trainModel:GetAttribute("IsEmergencyStop")
                end

                local function getOtherTrainRelativeDirectionRelativeToTrain(train : Model, otherTrain : Model)
                    assert(otherTrain.PrimaryPart and train.PrimaryPart)

                    return train.PrimaryPart.CFrame.LookVector:Dot((otherTrain.PrimaryPart.Position - train.PrimaryPart.Position).Unit)*getLoopState(train)
                end
               
                repeat  task.wait()
                    setEmergencyStop(train, false)

                    local slowDownPt = workspace:GetPartsInPart(train.PrimaryPart, overlapParams)

                    local dist =  (train.PrimaryPart.Position - stationPart.Position).Magnitude--*math.sign(dot)*loopState

                    for _,otherTrain in pairs(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Trains"):GetChildren()) do
                        if otherTrain ~= train then
                            local _dist = if otherTrain.PrimaryPart then (otherTrain.PrimaryPart.Position - train.PrimaryPart.Position).Magnitude else math.huge

                            --if train.Parent:GetChildren()[1] == train then
                            -- --   print(getOtherTrainRelativeDirectionRelativeToTrain(train, otherTrain), " direction breeh! ", train)
                            --end
                            if (getLoopState(otherTrain) == getLoopState()) and _dist <= 150 and (getOtherTrainRelativeDirectionRelativeToTrain(train, otherTrain) > 0) then
                                setEmergencyStop(train, true)

                                stop(getLoopState())
                                task.wait(6)
                                break
                            end
                        end
                    end

                    if not emergencyStop then
                    -- local dot = stationPart.CFrame.LookVector:Dot((stationPart.CFrame.Position - train.PrimaryPart.Position).Unit)
                        
                        if dist <= triggerStopDistanceFromStation*2 then
                            train:SetAttribute("IsSlowDown", true)
                        else
                            if #slowDownPt > 0 then
                                train:SetAttribute("IsSlowDown", true)
                            else
                                train:SetAttribute("IsSlowDown", nil)    
                            end
                        end
                    
                        if trainStuckCheck() then
                            error(`Train is detected stuck during approach to station {stationPart.Name} at dist {dist} studs`)
                        end 
                    end
                until dist <= triggerStopDistanceFromStation 
                slowDownConn:Disconnect()
                stop(loopState, stationPart.CFrame)
            end)
            if e then
                warn(`Refreshing train due to an error: {e}`)
                return false
            end
            
            local function refreshTrain()
                for _,v in pairs(train:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.AssemblyLinearVelocity = Vector3.new()
                        v.AssemblyAngularVelocity = Vector3.new()
                    end
                end
            end
            refreshTrain()
            train.PrimaryPart.Anchored = true
        
            ---DOOR OPENING----
            local isDoorOpenFlip = stationPart:GetAttribute("IsTrainDoorOpenFlip")
            
            local stationDoorsPointer = stationPart:FindFirstChild("StationDoorsPointer") :: ObjectValue
            local stationDoors = if stationDoorsPointer then stationDoorsPointer.Value else nil
            
            if stationDoors then
                for _,v in pairs(stationDoors:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if not v:GetAttribute("Transparency") then
                            v:SetAttribute("Transparency", v.Transparency)
                        end
                        v.Transparency = 1
                        v.CanCollide = false
                    end
                end
            end

            local copiedDoors : {CopiedDoor : Model, OriginalDoor : Model} = {} :: any
            for _,door in pairs(train.Body.Doors:GetChildren()) do
                local doorOnDesignatedSide = checkPositionSideRelativeToTrain(door.PrimaryPart)
                if isDoorOpenFlip then
                    doorOnDesignatedSide = not doorOnDesignatedSide
                end 
                
                if doorOnDesignatedSide then
                    local doorCf = door.PrimaryPart.CFrame
                    
                    local intCf = train.PrimaryPart.CFrame:Inverse()*doorCf
                    door:SetAttribute("CFrameRelativeToTrain", door:GetAttribute("CFrameRelativeToTrain") or intCf)
                    
                    --make a door copy 
                    local copiedDoorData = {CopiedDoor = door:Clone(), OriginalDoor = door}
                    table.insert(copiedDoors, copiedDoorData)
                    copiedDoorData.CopiedDoor.Parent = train
                    
                    for _,doorPart in pairs(door:GetDescendants()) do
                        if doorPart:IsA("BasePart") then
                            doorPart:SetAttribute("Transparency", doorPart:GetAttribute("Transparency") or doorPart.Transparency)				
                            doorPart.Transparency = 1
                        end
                    end
                    copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChildWhichIsA("PrismaticConstraint").Enabled = true
        
                    local intPos = copiedDoorData.CopiedDoor.PrimaryPart.Position
                    local alignPosition = copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChild("AlignPosition") :: AlignPosition or Instance.new("AlignPosition") 
                    alignPosition.MaxVelocity = 1
                    alignPosition.MaxForce = 100000
                    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
                    alignPosition.Attachment0 = copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChild("DoorAttachment")
                    alignPosition.Parent = copiedDoorData.CopiedDoor.PrimaryPart
                    local dir = if copiedDoorData.CopiedDoor.Name == "DoorL" then -1 else 1
                    alignPosition.Position = (doorCf.Position + doorCf.RightVector*dir*copiedDoorData.CopiedDoor.PrimaryPart.Size.X)
                    --print(alignPosition.Position, (doorCf.Position + doorCf.RightVector*dir*copiedDoor.PrimaryPart.Size.X))
                    
                    local doorToTrainWeld = copiedDoorData.CopiedDoor.PrimaryPart.DoorToTrainWeld
                    doorToTrainWeld:Destroy()
                    
                    playSound(4496280365, train.PrimaryPart, 0.05) -- door open sound
                    
                end
            end	
            
            updateAnnouncementDisplay("DoorAnnouncement", "Open", isDoorOpenFlip)
            local t = tick()
            local doorSignalConn0 = RunService.Stepped:Connect(function() -- door signal initiating
                if tick() - t > 0.2 then
                    t = tick()
                    for _,v in pairs(train.Body.Body.Interior.Alarms.DoorAlarm:GetChildren()) do
                        local partOnDesignatedSide = checkPositionSideRelativeToTrain(v)
                        if isDoorOpenFlip then
                            partOnDesignatedSide = not partOnDesignatedSide
                        end 
                        if partOnDesignatedSide then
                            v.Color = Color3.fromRGB(200,50,50)
                            v.Material = if v.Material == Enum.Material.Neon then Enum.Material.SmoothPlastic else Enum.Material.Neon
                        end
                    end
                end
            end)
            task.wait(1.2)
            for _,copiedDoorData in pairs(copiedDoors) do
                local doorCf = train.PrimaryPart.CFrame*copiedDoorData.CopiedDoor:GetAttribute("CFrameRelativeToTrain")	
                local dir = if copiedDoorData.CopiedDoor.Name == "DoorL" then -1 else 1
        
                copiedDoorData.CopiedDoor:PivotTo(doorCf + doorCf.RightVector*dir*copiedDoorData.CopiedDoor.PrimaryPart.Size.X)
            end
            doorSignalConn0:Disconnect()
            for _,v in pairs(train.Body.Body.Interior.Alarms.DoorAlarm:GetChildren()) do -- door signal stopping
                local partOnDesignatedSide = checkPositionSideRelativeToTrain(v)
                if isDoorOpenFlip then
                    partOnDesignatedSide = not partOnDesignatedSide
                end 
                if partOnDesignatedSide then
                    v.Color = Color3.fromRGB(165, 165, 165)
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
            ----------------
            task.wait(stationWaitTime)
            ----------------
            
            local sound = playSound(332341188, train.PrimaryPart, 0.08) -- alarm
            updateAnnouncementDisplay("DoorAnnouncement", "Close", isDoorOpenFlip)
        
            local t2 = tick()
            local doorSignalConn = RunService.Stepped:Connect(function() -- door signal initiating
                if tick() - t2 > 0.2 then
                    t2 = tick()
                    for _,v in pairs(train.Body.Body.Interior.Alarms.DoorAlarm:GetChildren()) do
                        local partOnDesignatedSide = checkPositionSideRelativeToTrain(v)
                        if isDoorOpenFlip then
                            partOnDesignatedSide = not partOnDesignatedSide
                        end 
                        if partOnDesignatedSide then
                            v.Color = Color3.fromRGB(200,50,50)
                            v.Material = if v.Material == Enum.Material.Neon then Enum.Material.SmoothPlastic else Enum.Material.Neon
                        end
                    end
                end
            end)
            
            task.spawn(function()
                local announcementSound = playSound(16878673790, train.PrimaryPart,0.3)
                announcementSound.Ended:Wait()
                playSound(16878676917, train.PrimaryPart, 0.3)
            end)
            task.wait(2)
            for _,copiedDoorData in pairs(copiedDoors) do
        
                local intCf = copiedDoorData.CopiedDoor:GetAttribute("CFrameRelativeToTrain")
                
                local alignPosition = copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChild("AlignPosition")
                if alignPosition then
                    
                    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
                    alignPosition.Parent = copiedDoorData.CopiedDoor.PrimaryPart
                    alignPosition.Position = (train.PrimaryPart.CFrame*intCf).Position
                end
                
                playSound(2547083186, train.PrimaryPart, 0.04) -- door close sound
            end	
            
            --station doors closing
            if stationDoors then
                for _,v in pairs(stationDoors:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = v:GetAttribute("Transparency") or 0
                        v.CanCollide = true
                    end
                end
            end
            task.wait(1.2)
            for _,copiedDoorData in pairs(copiedDoors) do
                local intCf = copiedDoorData.CopiedDoor:GetAttribute("CFrameRelativeToTrain")
                
                
                local alignPosition = copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChild("AlignPosition")
                if alignPosition then
                    alignPosition.Enabled = false
                    alignPosition:Destroy()
                end
                copiedDoorData.CopiedDoor.PrimaryPart:FindFirstChildWhichIsA("PrismaticConstraint").Enabled = false
                copiedDoorData.CopiedDoor:PivotTo(train.PrimaryPart.CFrame*intCf)
                --[[local newDoorToTrainWeld = Instance.new("WeldConstraint")
                newDoorToTrainWeld.Name = doorToTrainWeld.Name
                newDoorToTrainWeld.Part0 = doorToTrainWeld.Part0
                newDoorToTrainWeld.Part1 = doorToTrainWeld.Part1
                newDoorToTrainWeld.Parent = doorToTrainWeld.Parent
                doorToTrainWeld:Destroy()]]
                --doorToTrainWeld.Enabled = true
                for _,doorPart in pairs(copiedDoorData.OriginalDoor:GetDescendants()) do
                    if doorPart:IsA("BasePart") then
                        doorPart.Transparency = doorPart:GetAttribute("Transparency")
                    end
                end
                copiedDoorData.CopiedDoor:Destroy()
            end
            task.wait(3)
            sound:Destroy()
            
            local t = tick()
            doorSignalConn:Disconnect() 
            for _,v in pairs(train.Body.Body.Interior.Alarms.DoorAlarm:GetChildren()) do -- door signal stopping
                local partOnDesignatedSide = checkPositionSideRelativeToTrain(v)
                if isDoorOpenFlip then
                    partOnDesignatedSide = not partOnDesignatedSide
                end 
                if partOnDesignatedSide then
                    v.Color = Color3.fromRGB(165, 165, 165)
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
                
            task.wait(3)
            train.PrimaryPart.Anchored = false
            refreshTrain()

            return true
        end
        
        init()
        task.wait(3)
        
        local intLoopState = train:GetAttribute("InitialLoopState") or 1

      
        
        setLoopState(intLoopState)
        
        local function checkIfOtherTrainIsInDifferentLoop()
            local isDifferentLoop: boolean ?
            for _,otherTrain in pairs(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Trains"):GetChildren()) do
                if otherTrain ~= train then
                    if getLoopState(otherTrain) == getLoopState() then --temporary / doesnt apply if there's >2 #n of trains
                        isDifferentLoop = false
                        break
                    else
                        isDifferentLoop = true
                    end
                end
            end

         
            return isDifferentLoop
        end

        local function operateTrain()
            local trainMaid = Maid.new()

            local function resetTrain()
                trainMaid:Destroy()
                train:Destroy()
                
                repeat task.wait(1); --[[print(checkIfOtherTrainIsInDifferentLoop())]] until (checkIfOtherTrainIsInDifferentLoop() == true) or (checkIfOtherTrainIsInDifferentLoop() == nil)

                local new_train = ServerStorage:WaitForChild("Assets"):WaitForChild("Train"):Clone()
                new_train:PivotTo(trainOriginalCFrame)
                new_train.Parent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Trains")
    
                train = new_train

                init()
                setLoopState(intLoopState)
                operateTrain()
            end

            local db = false
            trainMaid:GiveTask(RunService.Stepped:Connect(function()
                if db == false then
                    db = true
                    local s, e = pcall(function()
                        local stationPartsRaw = if getLoopState() == 1 then workspace.Assets.Infrastructures.LRT.Stops.Lane2 else workspace.Assets.Infrastructures.LRT.Stops.Lane1

                        local stationParts = {}
                        for _,v in pairs(stationPartsRaw:GetChildren()) do
                            if v:IsA("BasePart") and v:GetAttribute("Order") then
                                stationParts[v:GetAttribute("Order")] = v
                            end
                        end
                        
                        if getLoopState() == -1 then
                            for i = 1, #stationParts do
                                local destinationStationPart = stationParts[i]
                                local finalStationPart = stationParts[#stationParts]

                                updateAnnouncementDisplay("Station", destinationStationPart, finalStationPart, getLoopState())
                                local success = moveToStation(destinationStationPart, getLoopState())
                                if success == false then
                                    resetTrain()
                                    return success
                                end
                            end
                        else
                            for i = #stationParts, 1, -1 do
                                local destinationStationPart = stationParts[i]
                                local finalStationPart = stationParts[1]

                                updateAnnouncementDisplay("Station", destinationStationPart, finalStationPart, getLoopState())
                                local success = moveToStation(destinationStationPart, getLoopState())
                                if success == false then
                                    resetTrain()  
                                    return success

                                end
                            end
                        end
                        
                        --wait until other train is in the same loop, then switch tracks
                        train:SetAttribute("IsSwitchingLoop", true)
                        repeat task.wait(1);  
                            local isOtherSwitching = false
                            for _,otherTrain in pairs(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Trains"):GetChildren()) do
                                if train ~= otherTrain and otherTrain:GetAttribute("IsSwitchingLoop") then  --temporary
                                    isOtherSwitching = true
                                end
                            end
                        until (checkIfOtherTrainIsInDifferentLoop() == false) or (checkIfOtherTrainIsInDifferentLoop() == nil) or (isOtherSwitching == true)

                        --switch tracks
                        local s, e = pcall(function()
                            if getLoopState() == 1 then
                                switchTrack(getLoopState(), workspace.Assets.Infrastructures.LRT.LineSwitchPoints.SwitchPoint1)
                            else
                                switchTrack(getLoopState(), workspace.Assets.Infrastructures.LRT.LineSwitchPoints.SwitchPoint2)
                            end
                        end)
                        
                        if not s and e then
                            warn(e)
                            resetTrain()
                            return s, e
                        end
                        setLoopState(if getLoopState() == 1 then -1 else 1)
                        train:SetAttribute("IsSwitchingLoop", nil)

                        return true
                    end)
                    
                    if not s and e then
                        warn(`Train error during this operation: {e}`)
                        resetTrain()   
                        return s
                    end
                    db = false
                end
                return true
            end))
        end
        operateTrain()
    end

    NetworkUtil.getRemoteEvent(ON_TRAIN_INIT)
    NetworkUtil.getRemoteEvent(ON_VELOCITY_CHANGE)
    NetworkUtil.getRemoteEvent(INVOKE_TRAIN_ANNOUNCEMENT)
end

return Trains
