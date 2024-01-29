--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
--types
type Maid = Maid.Maid
--constants
local USER_INTERVAL_UPDATE = "UserIntervalUpdate"
--remotes
--variables
local fps 
--references
local Player = Players.LocalPlayer
--local functions
--scripts
local PlayerManager = {}

function PlayerManager.init(maid : Maid)
    local intervalTime = 30

    local accumulativeSteps = 0

    local fpsesInLastSecond = {}

    maid:GiveTask(RunService.Heartbeat:Connect(function(step : number)
        --[[fps += 1
        task.wait(1)
        fps -= 1]]

        
        if accumulativeSteps > 1 then
            accumulativeSteps = 0
            table.clear(fpsesInLastSecond)
        end

        accumulativeSteps += step

        local current_fps = math.round((1/step))
        table.insert(fpsesInLastSecond, current_fps)
        
        local avg_fps 
        local n = 0

        local totalPrev = 0
        for k,v in pairs(fpsesInLastSecond) do
            n += 1
            avg_fps = (totalPrev + v)/n
            totalPrev += v
        end
        if avg_fps then
            fps = math.clamp(math.round(avg_fps), 0, 60)
        end
    end))

    local t = tick() - (intervalTime - 2)
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        if tick() - t > intervalTime then 
            t = tick()
            if fps then
                NetworkUtil.fireServer(USER_INTERVAL_UPDATE, fps)
                if RunService:IsStudio() then
                    print(fps .. ": fps detected")
                end
            end
        end
    end))
end

function PlayerManager.getFPS()
    return fps
end

return PlayerManager