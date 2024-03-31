--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
--remotes
local ON_TRAIN_INIT = "OnTrainInit"
local ON_VELOCITY_CHANGE = "OnVelocityChange"
local INVOKE_TRAIN_ANNOUNCEMENT = "InvokeTrainAnnouncement"
--variables
--references
--local functions
--class

local Trains = {}

function Trains.init(maid : Maid)
    local function checkPositionSideRelativeToTrain(train : Model, part : BasePart) -- checking if door is heading to left or right
        local dot = train.PrimaryPart.CFrame.RightVector:Dot((part.Position - train.PrimaryPart.Position).Unit)
        return dot > 0
    end
    
    NetworkUtil.onClientEvent(ON_VELOCITY_CHANGE, function(train : Model, status : "Start" | "Slowdown" | "Stop")
        if status == "Start" then
            local sound = train.Part.DieselSound
            if sound.PlaybackSpeed < 1*0.5 then
                local tween = TweenService:Create(sound, TweenInfo.new(0.6), {PlaybackSpeed = 1, Volume = 0.9})
                tween:Play()
                tween:Destroy()
                task.wait(1)
            end

            --[[local screech = workspace.Train.Part.Screech
            screech.PlaybackSpeed = 0.3*0.95
            local tween2 = TweenService:Create(screech, TweenInfo.new(4), {PlaybackSpeed = 0.3, Volume = 1})
            tween2:Play()
            tween2:Destroy()
            ]]
            local sound2 = train.Part.DieselSound2 --bass
            --sound2.PlaybackSpeed = 0.3*0.1
            
            
            --task.wait(1)
            
            local sound3 = train.Part.DieselSound3
            --sound3.PlaybackSpeed = 1.2*0.2
            local tween3 = TweenService:Create(sound3, TweenInfo.new(8), {PlaybackSpeed = 0.4*1, Volume = 0.12})
            tween3:Play()
            tween3:Destroy()
            
            task.wait(1)
            local tween2 = TweenService:Create(sound2, TweenInfo.new(7), {PlaybackSpeed = 2*1, Volume = 0.05}) --bass
            tween2:Play()
            tween2:Destroy()
            
            local tween = TweenService:Create(sound, TweenInfo.new(4), { Volume = 0})
            tween:Play()
            tween:Destroy()
        elseif status == "Slowdown" then
            print("slow down ma boi client")
            local sound = train.Part.DieselSound
                
            if sound.PlaybackSpeed < 1*0.3 then
                local tween = TweenService:Create(train.Part.DieselSound, TweenInfo.new(1.2), {PlaybackSpeed = 1, Volume = 2})
                tween:Play()
                tween:Destroy()
                task.wait()
            end
    
            --[[local screech = workspace.Train.Part.Screech
            screech.PlaybackSpeed = 0.3*0.95
            local tween2 = TweenService:Create(screech, TweenInfo.new(4), {PlaybackSpeed = 0.3, Volume = 1})
            tween2:Play()
            tween2:Destroy()
            ]]
            local sound2 = train.Part.DieselSound2
            local tween2 = TweenService:Create(sound2, TweenInfo.new(5), {PlaybackSpeed = 2*0.8, Volume = 0.04})
            tween2:Play()
            tween2:Destroy()
    
            task.wait(0.15)
            local tween = TweenService:Create(train.Part.DieselSound, TweenInfo.new(5), {Volume = 0.4}) 
            tween:Play()
            tween:Destroy()
    
            local sound3 = train.Part.DieselSound3 
            local tween3 = TweenService:Create(sound3, TweenInfo.new(4.5), {PlaybackSpeed = 0.4*0.75, Volume = 0.09})
            tween3:Play()
            tween3:Destroy()
    
            task.wait(0.15)
            local tween2 = TweenService:Create(sound2, TweenInfo.new(5), {Volume = 0.03}) --bass
            tween2:Play()
            tween2:Destroy()
            
            local tween = TweenService:Create(train.Part.DieselSound, TweenInfo.new(3), {PlaybackSpeed = 1, Volume = 0})
            tween:Play()
            tween:Destroy()
        elseif status == "Stop" then

            local tween = TweenService:Create(train.Part.DieselSound, TweenInfo.new(2), {PlaybackSpeed = 1*0.1, Volume = 0.1})
            tween:Play()
            tween:Destroy()
            task.wait(1)
            local sound2 = train.Part.DieselSound2-- bass
            local tween2 = TweenService:Create(sound2, TweenInfo.new(5), {PlaybackSpeed = 2*0.4, Volume = 0.02}) --BASS
            tween2:Play()
            tween2:Destroy()
            task.wait(1)
            local sound3 = train.Part.DieselSound3 
            local tween3 = TweenService:Create(sound3, TweenInfo.new(5), {PlaybackSpeed = 0.4*0.45, Volume = 0.02})
            tween3:Play()
            tween3:Destroy()
        end
    end)
    NetworkUtil.onClientEvent(INVOKE_TRAIN_ANNOUNCEMENT, function(train : Model, announcementType : "Station" | "DoorAnnouncement" | "Announcement", ...)
        if announcementType == "Station" then
            for _,v in pairs(train.Body.Body.Interior.LEDs:GetChildren()) do
                local station : BasePart, finalStation : BasePart, loopState = ...
                local sg = v:FindFirstChildWhichIsA("SurfaceGui") 
                if sg then
                    local isOnLeftSide = checkPositionSideRelativeToTrain(train, v)
                    
                    sg.DestinationDisplay.StationFrame.Visible = true
                    sg.DestinationDisplay.DoorFrame.Visible = false
    
                    sg.DestinationDisplay.FinalDestinationName.Text = 'to' .. finalStation:GetAttribute("StationCode") .. ' <b> ' .. finalStation.Name .. '</b>'
                    sg.DestinationDisplay.StationFrame.StationName.Text = '<font size="30"> ' .. station:GetAttribute("StationCode") .. ' </font> <b>' .. station.Name ..'</b>'
                    
                    sg.DestinationDisplay.StationFrame.Direction1.Text = if loopState == 1 and isOnLeftSide then "<" elseif loopState == 1 and not isOnLeftSide then ">" elseif loopState == -1 and isOnLeftSide then ">" elseif loopState == -1 and not isOnLeftSide then "<" else ""
                    sg.DestinationDisplay.StationFrame.Direction2.Text = if loopState == 1 and isOnLeftSide then "<" elseif loopState == 1 and not isOnLeftSide then ">" elseif loopState == -1 and isOnLeftSide then ">" elseif loopState == -1 and not isOnLeftSide then "<" else ""                    
                end
            end
        elseif announcementType == "DoorAnnouncement" then
            for _,v in pairs(train.Body.Body.Interior.LEDs:GetChildren()) do
                local isDesired = checkPositionSideRelativeToTrain(train, v)
                local doorStatus : "Open" | "Close", isFlip : boolean = ...
    
                isDesired = if isFlip then not isDesired else isDesired 
                
                local sg = v:FindFirstChildWhichIsA("SurfaceGui") 
                if sg then
                    sg.DestinationDisplay.StationFrame.Visible = false
                    sg.DestinationDisplay.DoorFrame.Visible = true
                    
                    sg.DestinationDisplay.DoorFrame.LArrow.Text = if doorStatus == "Open" then "<" else ">"
                    sg.DestinationDisplay.DoorFrame.RArrow.Text = if doorStatus == "Open" then ">" else "<"
                    sg.DestinationDisplay.DoorFrame.StationName.Text = ("Doors " ..  if doorStatus == "Open" then "opening " else "closing ") .. (if isDesired then "on this side" else "on another side")
                    
                    
                    task.spawn(function()
                        local lArrow =  sg.DestinationDisplay.DoorFrame.LArrow
                        local rArrow =  sg.DestinationDisplay.DoorFrame.RArrow

                        for i = 1, 5 do
                            lArrow.Size = UDim2.new(0.1,0,1,0)
                            rArrow.Size = UDim2.new(0.1,0,1,0)
                            lArrow.TextTransparency = 0
                            rArrow.TextTransparency = 0
                            local tween = TweenService:Create(lArrow, TweenInfo.new(1.2), {Size = UDim2.new(if doorStatus == "Open" then 0.3 else 0,0,1,0), TextTransparency = 1})
                            local tween2 = TweenService:Create(rArrow, TweenInfo.new(1.2), {Size = UDim2.new(if doorStatus == "Open" then 0.3 else 0,0,1,0), TextTransparency = 1})
                            tween:Play()
                            tween2:Play()
                            tween:Destroy()
                            tween2:Destroy()
                            task.wait(1.2)
                        end
                        task.wait()
                        sg.DestinationDisplay.StationFrame.Visible = true
                        sg.DestinationDisplay.DoorFrame.Visible = false
                    end)
                end
                
                
            end
        end
    end)

    NetworkUtil.onClientEvent(ON_TRAIN_INIT, function(train : Model)
        local _maid = Maid.new()
        for _,v in pairs(train.Body.Body.Interior.LEDs:GetChildren()) do
            local sg = v:FindFirstChildWhichIsA("SurfaceGui") 
            if sg then
                local dir1TextFrame = sg.DestinationDisplay.StationFrame.Direction1
                local dir2TextFrame  =  sg.DestinationDisplay.StationFrame.Direction2

                local db = false

                local AnimLoop 
                local function updateStationArrowDisplay()
                   -- local intText1 = dir1TextFrame.Text
                    if AnimLoop then
                        AnimLoop:Disconnect()
                    end
                    AnimLoop = RunService.Stepped:Connect(function()
                        if not db then
                            db = true
                            dir1TextFrame.TextTransparency = 0
                            dir2TextFrame.TextTransparency = 0
                            local tween = TweenService:Create(dir1TextFrame, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {TextTransparency = 1})
                            local tween2 = TweenService:Create(dir2TextFrame, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {TextTransparency = 1})

                            tween:Play()
                            tween2:Play()
                            tween:Destroy()
                            tween2:Destroy()
                            task.wait(2.4) 
                            db = false
                        end
                    end)
                end

                updateStationArrowDisplay()

                _maid:GiveTask(dir2TextFrame:GetPropertyChangedSignal("Text"):Connect(function()
                    updateStationArrowDisplay()
                end))

            end
        end

        _maid:GiveTask(train.Destroying:Connect(function()
            _maid:Destroy()
        end))
    end)
end

return Trains