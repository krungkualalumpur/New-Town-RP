--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Weather = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Nature"):WaitForChild("Weather"))
--types
type Maid = Maid.Maid
--constants
--references
--variables
--class
return {
    init = function(maid : Maid)
        Weather.init(maid)
    end
}