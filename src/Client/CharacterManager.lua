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
local function camSprinting(on : boolean)
    local currentCamera = workspace.CurrentCamera

    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid

    if on then
        if math.round(humanoid.MoveDirection.Magnitude) == 0 then
            local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = FIELD_OF_VIEW,
                }
            )
            tween:Play()
            tween:Destroy()
        else
            local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = 85,
                }
            )
            tween:Play()
            tween:Destroy()
        end
    else
        humanoid.WalkSpeed = WALK_SPEED

        local tween = TweenService:Create(
            currentCamera, 
            TweenInfo.new(0.5), 
            {
                FieldOfView = FIELD_OF_VIEW,
            } 
        )
        tween:Play()
        tween:Destroy()
    end
end

local function sprint()   
    --local _maid = maid:GiveTask(Maid.new())

    InputHandler:Map("Sprint", "Keyboard", {Enum.KeyCode.LeftShift}, "Hold"
    ,function()
        local character: Model = Player.Character or Player.CharacterAdded:Wait()
        character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
        --[[local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED*3

        camSprinting()

        _maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            camSprinting()
        end))]]
    end

    ,function()
        local character: Model = Player.Character or Player.CharacterAdded:Wait()
        character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
        --[[local currentCamera = workspace.CurrentCamera

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

        _maid:DoCleaning()]]
    end)
    return
end

local function onCharacterAdded(char : Model)
    local _maid = Maid.new()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid

    _maid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
        if char:GetAttribute("IsSprinting") then
            humanoid.WalkSpeed = WALK_SPEED*3
    
            camSprinting(true)
    
        else
            camSprinting(false)
        end
    end))

    _maid:GiveTask(char.Destroying:Connect(function()
        _maid:Destroy()
    end))

    
    _maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if char:GetAttribute("IsSprinting") then
            camSprinting(true)
        end
    end))

    sprint()
end

--class
local CharacterManager = {}

function CharacterManager.init(maid: Maid)
    local char = Player.Character or Player.CharacterAdded:Wait()
    onCharacterAdded(char)
    

    maid:GiveTask(Player.CharacterAdded:Connect(onCharacterAdded))
end

return CharacterManager