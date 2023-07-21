--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Environments = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"))
local RoleplaySys = require(ServerScriptService:WaitForChild("Server"):WaitForChild("RoleplaySys"))
--types
--constants
--references
local maid = Maid.new()
--variables
--script
Environments.init(maid)
RoleplaySys.init(maid)
print("Hello world, du bist heissen?! PENAT LAAAA de stronkest")

