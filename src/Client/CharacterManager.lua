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
local function sprint(maid : Maid)   
    local _maid = maid:GiveTask(Maid.new())

    local function camSprinting()
        local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        if math.round(humanoid.MoveDirection.Magnitude) == 0 then
            local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = FIELD_OF_VIEW,
                }
            )
            tween:Play()
        else
            local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = 85,
                }
            )
            tween:Play()
        end
    end

    InputHandler:Map("Sprint", "Keyboard", {Enum.KeyCode.LeftShift}, "Hold"
    ,function()

        local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED*3

        camSprinting()

        _maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            camSprinting()
        end))
    end

    ,function()

        local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED

        local tween = _maid:GiveTask(TweenService:Create(
            currentCamera, 
            TweenInfo.new(0.5), 
            {
                FieldOfView = FIELD_OF_VIEW,
            } 
        ))
        tween:Play()

        _maid:DoCleaning()
    end)
    return
end



--class
local CharacterManager = {}

function CharacterManager.init(maid: Maid)
    sprint(maid) 
end

return CharacterManager