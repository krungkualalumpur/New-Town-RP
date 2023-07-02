--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
--modules
local Elevator = require(ServerScriptService:WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Elevator"))
--types
--constants
--references
--variables
--class
return {
    init = function(maid)
        Elevator.init(maid)
    end
}