--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
export type JobData = {
    Name : string,
    ImageId : number
}
--constants
--remotes
local ON_JOB_CHANGE = "OnJobChange"
--variables
local jobsList : {[number] : JobData} = {
    [1] = {
        Name = "Police Officer",
        ImageId = 13585622472
    },
    [2] = {
        Name = "Doctor",
        ImageId = 6872170564
    },
    [3] = {
        Name = "Fisherman",
        ImageId = 14376301448
    },
    [4] = {
        Name = "Barber",
        ImageId = 12329088417 
    },
    [5] = {
        Name = "Cashier",
        ImageId = 1037634856
    },
    [6] = {
        Name = "Teacher",
        ImageId = 15487178426
    },
    [7] = {
        Name = "Portworker",
        ImageId = 3040311268
    },
    [8] = {
        Name = "Chef",
        ImageId = 15554154385
    },
    [9] = {
        Name = "Firefighter",
        ImageId = 13238607889
    },
    [10] = {
        Name = "Security",
        ImageId = 6336179166
    },
}
--references
local JobTriggers = workspace:WaitForChild("Assets"):WaitForChild("JobTriggers")
--local functions
--class
local Jobs = {}

function Jobs.getJobs()
    return table.clone(jobsList)
end

function Jobs.getJobByName(name : string) : (JobData, number)
    for k,v in pairs(jobsList) do
        if v.Name == name then
            return v, k
        end
    end
    error("Unable to find the job")
end

function Jobs.getJobTriggerByName(name : string)
    for _,jobTriggerPart : BasePart in pairs(CollectionService:GetTagged("Job")) do
        for _,jobData in pairs(jobsList) do
            if jobData.Name == jobTriggerPart:GetAttribute("JobName") then
                return jobTriggerPart
            end
        end
    end
    error("Can't find the trigger")
end

function Jobs.setJob(plr : Player, name : string ?)
    local job : JobData ?
    for _,v in pairs(jobsList) do
        if v.Name == name then
            job = v
            break
        end
    end

    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local displayNameGUI = head:WaitForChild("DisplayNameGUI")
    local displayFrame = displayNameGUI:WaitForChild("Frame")
    local iconImage = displayFrame:WaitForChild("Icon") :: ImageLabel

    iconImage.ImageTransparency = 1

    if job then
       -- print('1')
        if job.Name ~= Jobs.getJob(plr) then
        --    print('2')
            NetworkUtil.fireClient(ON_JOB_CHANGE, plr, job)
        end

        plr:SetAttribute("Job", job.Name)

        iconImage.ImageTransparency = 0
        iconImage.Image = string.format("rbxassetid://%d", job.ImageId)  
    else 
       -- print('3')
        plr:SetAttribute("Job", nil)
    end

    return
end

function Jobs.getJob(plr : Player) : string ?
    return plr:GetAttribute("Job")
end

return Jobs