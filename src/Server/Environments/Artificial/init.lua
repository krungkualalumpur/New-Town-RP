--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
--modules
local Elevator = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Elevator"))
local Seat = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Seat"))
local Minigame = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Minigame"))
--types
--constants
--references
--variables
--class
return {
    init = function(maid)
        Elevator.init(maid)
        Seat.init(maid)
        Minigame.init(maid)
    end
}