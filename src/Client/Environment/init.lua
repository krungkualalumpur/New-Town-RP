--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Nature = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"):WaitForChild("Nature"))
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
        Nature.init(maid)
    end
}