--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))
--types
type Maid = Maid.Maid
--constants
local ON_GAME_LOADING_COMPLETE = "OnGameLoadingComplete"
--variables
--references
local Player = Players.LocalPlayer
--local functions
--class
local target = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local loadingMaid = Maid.new()

local loadingFrame = LoadingFrame(loadingMaid, "Loading the game")
loadingFrame.Parent = target

    --yields the main UI
Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("MainUI")

    --then finishes loading
loadingMaid:Destroy()
NetworkUtil.fireServer(ON_GAME_LOADING_COMPLETE)

--local character = Player.Character or Player.CharacterAdded:Wait()
--local humanoid = character:WaitForChild("Humanoid")
