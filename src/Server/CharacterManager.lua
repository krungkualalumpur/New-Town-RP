--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local WALK_SPEED = 6
--variables
--references
--local functions
--class
local CharacterManager = {}

function CharacterManager.init(maid : Maid)
    maid:GiveTask(Players.PlayerAdded:Connect(function(plr : Player)
        local _maid = Maid.new()
        _maid:GiveTask(plr.CharacterAdded:Connect(function(char : Model)
            local humanoid = char:WaitForChild("Humanoid") :: Humanoid
            if humanoid then
                humanoid.WalkSpeed = WALK_SPEED
            end
        end))
 
        _maid:GiveTask(plr.Destroying:Connect(function()
            _maid:Destroy()
        end))
    end))
end

return CharacterManager