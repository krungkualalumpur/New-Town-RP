--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
--packages
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))
--types
type Maid = Maid.Maid
--constants
--remotes
local ON_JOB_CHANGE = "OnJobChange"
--references
--variables
--local function
local function onPlayerAdded(plr : Player)
    local plrMaid = Maid.new()

    plrMaid:GiveTask(plr.CharacterAdded:Connect(function()
        local currentPlrJob = Jobs.getJob(plr)
        Jobs.setJob(plr, currentPlrJob)
    end))

    plrMaid:GiveTask(plr.AncestryChanged:Connect(function()
        if plr.Parent == nil then
            plrMaid:Destroy()
        end
    end))
end
--script
local JobManager = {}

function JobManager.init(maid : Maid)
    for _, jobTriggerPart : BasePart in pairs(CollectionService:GetTagged("Job")) do
        local proxPrompt = Instance.new("ProximityPrompt")
        proxPrompt.ObjectText = jobTriggerPart:GetAttribute("JobName")
        proxPrompt.ActionText = "Change job"
        maid:GiveTask(proxPrompt.Triggered:Connect(function(plr : Player)
            Jobs.setJob(plr, jobTriggerPart:GetAttribute("JobName"))
        end))
        proxPrompt.Parent = jobTriggerPart
    end

    for _, plr : Player in pairs(Players:GetPlayers()) do
        task.spawn(function() onPlayerAdded(plr) end)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))

    NetworkUtil.getRemoteEvent(ON_JOB_CHANGE)
end

return JobManager