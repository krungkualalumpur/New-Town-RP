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
local fps = 0
--references
local Player = Players.LocalPlayer
--local functions
--scripts
local PlayerManager = {}

function PlayerManager.init(maid : Maid)
    local intervalTime = 30

    maid:GiveTask(RunService.RenderStepped:Connect(function()
        fps += 1
        task.wait(1)
        fps -= 1
    end))

    local t = tick() + (intervalTime - 1)
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        if tick() - t > intervalTime then
            t = tick()
            NetworkUtil.fireServer(USER_INTERVAL_UPDATE, fps)
            --print(Midas:GetDataSets(), " datasets!")
        end
    end))
end

function PlayerManager.getFPS()
    return fps
end

return PlayerManager