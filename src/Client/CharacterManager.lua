--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
--types
type Maid = Maid.Maid
--constants
local WALK_SPEED = 6
local FIELD_OF_VIEW = 70
--variables
--references
local Player = Players.LocalPlayer
--local functions
local function sprint(direction : "Forward"|"Back"|"Left"|"Right")
    local directionKeyCode = if direction == "Forward" then Enum.KeyCode.W elseif direction == "Back" then Enum.KeyCode.S elseif direction == "Left" then Enum.KeyCode.A elseif direction == "Right" then Enum.KeyCode.D else nil
    assert(directionKeyCode, "bad direction")
   
    InputHandler:Map("Sprint" .. direction, "Keyboard", {Enum.KeyCode.LeftShift, directionKeyCode}, "Hold"
    ,function()

        local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED*3

        local tween = TweenService:Create(
            currentCamera, 
            TweenInfo.new(0.5), 
            {
                FieldOfView = 85,
            }
        )
        tween:Play()
    end

    ,function()

        local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED

        local tween = TweenService:Create(
            currentCamera, 
            TweenInfo.new(0.5), 
            {
                FieldOfView = FIELD_OF_VIEW,
            }
        )
        tween:Play()
    end)
    return
end
--class
local CharacterManager = {}

function CharacterManager.init(maid: Maid)
    sprint( "Forward")
    sprint("Back")
    sprint("Left")
    sprint("Right")

end

return CharacterManager