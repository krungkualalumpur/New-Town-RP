--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
local SUN_RISE = 5
local SUN_SET = 18
--variables
--references
local Trees = workspace:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Trees")
--local functions
--class
local Cricket = {}

function Cricket.init(maid : Maid)
    local boolVal = Instance.new("BoolValue")
    boolVal.Name = "isCricketActive"
    
    maid:GiveTask(RunService.Stepped:Connect(function()
        if Lighting.ClockTime >= SUN_SET or Lighting.ClockTime < SUN_RISE then
            boolVal.Value = true
        else
            boolVal.Value = false
        end
    end))
    
    local function initCricketSound()
        if boolVal.Value == true then
            for _,v in pairs(Trees:GetChildren()) do
                for _, part in pairs(v:GetChildren()) do
                    if part:IsA("BasePart") then
                        local sound = Instance.new("Sound")
                        sound.Name = "CricketSound"
                        sound.SoundId = "rbxassetid://7274926294"
                        sound.Looped = true
                        sound.Volume = 0
                        sound.RollOffMaxDistance = 55
                        sound.Parent = part       
                        sound:Play()       
                        
                        local tween = game:GetService("TweenService"):Create(sound, TweenInfo.new(0.5), {Volume = 2.5})
                        tween:Play()
                        tween:Destroy()
                        break
                    end
                end
            end
        else
            for _,v in pairs(Trees:GetChildren()) do
                for _, sound in pairs(v:GetDescendants()) do
                    if sound:IsA("Sound") and sound.Name == "CricketSound" then
                        local tween = game:GetService("TweenService"):Create(sound, TweenInfo.new(0.5), {Volume = 0})
                        tween:Play()
                        task.spawn(function()
                            tween.Completed:Wait()
                            tween:Destroy()
                            sound:Destroy()
                        end)
                    end
                end
            end
        end
    end

    initCricketSound()
    maid:GiveTask(boolVal.Changed:Connect(function()
        initCricketSound()
    end))
end

return Cricket