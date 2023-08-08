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
    local function onPlayerAdded(plr : Player)
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
    end

    for _, plr : Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))
end

return CharacterManager