--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
--modules
local Artificial = require(ServerScriptService:WaitForChild("Environments"):WaitForChild("Artificial"))
local Nature = require(ServerScriptService:WaitForChild("Environments"):WaitForChild("Nature"))
--types
--constants
--references
--variables
--class
return {
    init = function(maid)
        Artificial.init(maid)
        Nature.init(maid)
    end
}