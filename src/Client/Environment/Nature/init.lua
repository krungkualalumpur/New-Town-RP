--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Bird = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"):WaitForChild("Nature"):WaitForChild("Bird"))
local Cricket = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"):WaitForChild("Nature"):WaitForChild("Cricket"))
--types
type Maid = Maid.Maid
--constants
--remotes
--variables
--references
--local functions 
--class
return {
    init = function(maid : Maid)
        Bird.init(maid)
        Cricket.init(maid)
    end
}