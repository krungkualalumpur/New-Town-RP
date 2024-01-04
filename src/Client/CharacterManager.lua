--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
--local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
--local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
local VehicleControl = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("VehicleControl"))
--types
type Maid = Maid.Maid

export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}
--constants
local WALK_SPEED = 10
local FIELD_OF_VIEW = 70
local CAM_SHAKE_TIME = 0.16
local KEY_VALUE_NAME = "KeyValue"
--remotes
local ON_CAMERA_SHAKE = "OnCameraShake"
local ON_ANIMATION_SET = "OnAnimationSet"
local ON_RAW_ANIMATION_SET = "OnRawAnimationSet"
local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"
local ON_VEHICLE_CONTROL_EVENT = "OnVehicleControlEvent"
--variables
--references
local Player = Players.LocalPlayer
local SpawnedVehiclesParent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
function PlaySound(id, parent, volumeOptional: number ?, maxDist : number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = maxDist or 150
    s.Looped = false
    s.Parent = parent
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end


local function playAnimationByRawId(char : Model, id : number)
    local maid = Maid.new()
    local charHumanoid = char:WaitForChild("Humanoid") :: Humanoid
    local animator = charHumanoid:WaitForChild("Animator") :: Animator

    local animation = maid:GiveTask(Instance.new("Animation"))
    animation.AnimationId = "rbxassetid://" .. tostring(id)
    local animationTrack = maid:GiveTask(animator:LoadAnimation(animation))
    --animationTrack.Looped = false
    animationTrack:Play()
    --animationTrack.Ended:Wait()
    local function stopAnimation()
        animationTrack:Stop()
        maid:Destroy()
    end
    maid:GiveTask(char.Destroying:Connect(stopAnimation))
    maid:GiveTask(charHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if charHumanoid.MoveDirection.Magnitude ~= 0 and not charHumanoid.Sit then
            stopAnimation()
        end
    end))
end

local function playAnimation(char : Model, id : number)   
    
    if RunService:IsServer() then
        local plr = Players:GetPlayerFromCharacter(char)
        assert(plr)
        NetworkUtil.fireClient(ON_ANIMATION_SET, plr, char, id)
    else  
        local maid = Maid.new()
        local charHumanoid = char:WaitForChild("Humanoid") :: Humanoid
        local animator = charHumanoid:WaitForChild("Animator") :: Animator
    
        local catalogAsset = maid:GiveTask(NetworkUtil.invokeServer(GET_CATALOG_FROM_CATALOG_INFO, id):Clone())
        local animation = catalogAsset:GetChildren()[1]
        local animationTrack = maid:GiveTask(animator:LoadAnimation(animation))
        --animationTrack.Looped = false
        animationTrack:Play()
        --animationTrack.Ended:Wait()
        local function stopAnimation()
            animationTrack:Stop()
            maid:Destroy()
        end
        maid:GiveTask(char.Destroying:Connect(stopAnimation))
        maid:GiveTask(charHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if charHumanoid.MoveDirection.Magnitude ~= 0 and not charHumanoid.Sit then
                stopAnimation()
            end
        end))

    end
end

local function camSprinting(on : boolean)
    local currentCamera = workspace.CurrentCamera

    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid

    if on then
        if math.round(humanoid.MoveDirection.Magnitude) == 0 then
            --[[local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = FIELD_OF_VIEW,
                }
            )
            tween:Play()
            tween:Destroy()]]
        else
            --[[local tween = TweenService:Create(
                currentCamera, 
                TweenInfo.new(0.5), 
                {
                    FieldOfView = 85,
                }
            )
            tween:Play()
            tween:Destroy()]]
        end
    else
        humanoid.WalkSpeed = WALK_SPEED

        --[[local tween = TweenService:Create(
            currentCamera, 
            TweenInfo.new(0.5), 
            {
                FieldOfView = FIELD_OF_VIEW,
            } 
        )
        tween:Play()
        tween:Destroy()]]
    end
end

local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild(KEY_VALUE_NAME) :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class"),
        IsSpawned = model:IsDescendantOf(SpawnedVehiclesParent),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId"),
        DestroyLocked = model:GetAttribute("DestroyLocked")
    }
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
local function getRandomAB() 
    local rand = math.random(0, 1)
    return if rand == 0 then "A" else "B" 
end

local function onCharacterAdded(char : Model)
    local _maid = Maid.new()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid

    Player.CameraMaxZoomDistance = 8

    _maid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
        if char:GetAttribute("IsSprinting") then
            humanoid.WalkSpeed = WALK_SPEED*2.3
    
            camSprinting(true)
    
        else
            camSprinting(false)
        end
    end))

    local vehicleControlMaid = _maid:GiveTask(Maid.new())
    _maid:GiveTask(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart
        if seat and seat:IsDescendantOf(workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")) then
            local vehicleModel = seat.Parent
            assert(vehicleModel)
            local vehicleData = getVehicleData(vehicleModel)
            if vehicleModel:GetAttribute("Class") ~= "Vehicle" then
                return
            end
            if vehicleModel:GetAttribute("isLocked") --[[and vehicleData.OwnerId ~= Player.UserId]] then
                return
            end

            Player.CameraMaxZoomDistance = 18

            local hornSignal = vehicleControlMaid:GiveTask(Signal.new())
            local headlightSignal = vehicleControlMaid:GiveTask(Signal.new())
            local leftSignal = vehicleControlMaid:GiveTask(Signal.new())
            local rightSignal = vehicleControlMaid:GiveTask(Signal.new())

            local vehicleControl = VehicleControl(
                vehicleControlMaid,
                
                hornSignal,
                headlightSignal,
                leftSignal,
                rightSignal
            )

            vehicleControl.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

            vehicleControlMaid:GiveTask(hornSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Horn")
            end))

            vehicleControlMaid:GiveTask(headlightSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "Headlight")
            end))
            
            vehicleControlMaid:GiveTask(leftSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "LeftSignal")
            end))
            
            vehicleControlMaid:GiveTask(rightSignal:Connect(function()
                NetworkUtil.fireServer(ON_VEHICLE_CONTROL_EVENT, vehicleModel, "RightSignal")
            end))
        else
            Player.CameraMaxZoomDistance = 8
            vehicleControlMaid:DoCleaning()
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
    local abValue = "A" --getRandomAB()

    if abValue == "A" then
        char:SetAttribute("IsSprinting", true)
    elseif abValue == "B" then
        char:SetAttribute("IsSprinting", false)
    end 

    --MidasStateTree.Others.ABValue(Player, function()
    --    return string.byte(abValue)
    --end)
    --[[if game:GetService("UserInputService").KeyboardEnabled then
        char:SetAttribute("IsSprinting", false)
    else
        char:SetAttribute("IsSprinting", true)
    end]]
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

    maid:GiveTask(NetworkUtil.onClientEvent(ON_ANIMATION_SET, function(char : Model, id : number)
        playAnimation(char, id)
    end))

    maid:GiveTask(NetworkUtil.onClientEvent(ON_RAW_ANIMATION_SET, function(char : Model, id : number)
        playAnimationByRawId(char, id)
    end))
end

return CharacterManager