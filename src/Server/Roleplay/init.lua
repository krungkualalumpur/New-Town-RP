--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local JobManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Roleplay"):WaitForChild("JobManager")) 
--types
type Maid = Maid.Maid
--constants
--references
--variables
--script
local Roleplay = {
    JobManager = JobManager,

    init = function(maid : Maid)
        JobManager.init(maid)
    end
}

return Roleplay