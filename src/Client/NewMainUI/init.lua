--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

--constants
local PADDING_SIZE =  UDim.new(0, 5)

local BACKGROUND_COLOR = Color3.fromRGB(50,50,50)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)

local DELAY_TIME = 5
--variables
--references
--local functions
local function getSound(soundId : number, target : Instance ?)
    local maid = Maid.new()

    local sound = maid:GiveTask(Instance.new("Sound"))
    sound.SoundId = "rbxassetid://"..tostring(soundId)
    sound.Parent = target
    sound:Play()
    maid:GiveTask(sound.Ended:Connect(function()
        maid:Destroy()
    end))
    return
end

