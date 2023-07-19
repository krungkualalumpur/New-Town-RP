--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Artificial = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"))
local Nature = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Nature"))

local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
--types
--constants
local ON_INTERACT = "On_Interact"
 
--references
--variables
--class
return {
    init = function(maid)
        Artificial.init(maid)
        Nature.init(maid)

        maid:GiveTask(NetworkUtil.onServerEvent(ON_INTERACT, function(plr : Player, inst : Instance)
            if inst:IsA("Model") then
                InteractableUtil.Interact(inst)
            end
        end))
    end
}