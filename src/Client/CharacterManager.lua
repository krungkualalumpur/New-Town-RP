--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
--types
type Maid = Maid.Maid
--constants
local WALK_SPEED = 6
local FIELD_OF_VIEW = 70
local CAM_SHAKE_TIME = 0.16
--remotes
local ON_CAMERA_SHAKE = "OnCameraShake"
local ON_ANIMATION_LOOP_SET = "OnAnimationLoopSet"
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

--local function sprintSetup()   
    --local _maid = maid:GiveTask(Maid.new())

    --InputHandler:Map("Sprint", "Keyboard", {Enum.KeyCode.LeftShift}, "Hold"
    --,function()
     --   local character: Model = Player.Character or Player.CharacterAdded:Wait()
     --   character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
        --[[local currentCamera = workspace.CurrentCamera

        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = WALK_SPEED*3

        camSprinting()

        _maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            camSprinting()
        end))]]
   -- end

    --,function()
    --    local character: Model = Player.Character or Player.CharacterAdded:Wait()
    --    character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
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
   -- end)

   -- return
--end

local function onCharacterAdded(char : Model)
    local _maid = Maid.new()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid

    _maid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
        if char:GetAttribute("IsSprinting") then
            humanoid.WalkSpeed = WALK_SPEED*2.3
    
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

    InputHandler:Map("Sprint", "Keyboard", {Enum.KeyCode.LeftShift}, "Hold"
    ,function()
        local character: Model = Player.Character or Player.CharacterAdded:Wait()
        character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
    end

    ,function()
        local character: Model = Player.Character or Player.CharacterAdded:Wait()
        character:SetAttribute("IsSprinting", not character:GetAttribute("IsSprinting"))
    end)


    --sprint setup 2
    if game:GetService("UserInputService").KeyboardEnabled then
        char:SetAttribute("IsSprinting", false)
    else
        char:SetAttribute("IsSprinting", true)
    end
end

local function setAnimationLoop(plr : Player, animationTrack : AnimationTrack, isLooped : boolean)
    if RunService:IsServer() then
        NetworkUtil.fireClient(ON_ANIMATION_LOOP_SET, plr, animationTrack, isLooped)
    else
        animationTrack.Looped = isLooped
    end
end

--class
local CharacterManager = {}

function CharacterManager.init(maid: Maid)
    local camera = workspace.CurrentCamera
    local char = Player.Character or Player.CharacterAdded:Wait()
    onCharacterAdded(char)
    
    maid:GiveTask(Player.CharacterAdded:Connect(onCharacterAdded))

    maid:GiveTask(NetworkUtil.onClientEvent(ON_CAMERA_SHAKE, function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid") :: Humanoid
        if humanoid then
            local function getRandHeight() 
                return math.random(1,10)/75
            end
            
            local tween = TweenService:Create(humanoid, TweenInfo.new(CAM_SHAKE_TIME), {CameraOffset = Vector3.new( getRandHeight(), getRandHeight(), getRandHeight())})
            tween:Play()
            tween:Destroy()
            task.wait(CAM_SHAKE_TIME) 
            local tween2 = TweenService:Create(humanoid, TweenInfo.new(CAM_SHAKE_TIME), {CameraOffset = Vector3.new(0,0,0)})
            tween2:Play()
            tween2:Destroy()
            task.wait()
        end
    end))

    maid:GiveTask(NetworkUtil.onClientEvent(ON_ANIMATION_LOOP_SET, function(animationTrack : AnimationTrack, isLooped : boolean)
        setAnimationLoop(Player, animationTrack, isLooped)
    end))
end

return CharacterManager