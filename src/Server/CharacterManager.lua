--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
--types
type Maid = Maid.Maid
--constants
local WALK_SPEED = 10

--remotes
local CATALOG_FOLDER_NAME = "CatalogFolder"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"

local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"
local GET_AVATAR_FROM_CHARACTER_DATA = "GetAvatarFromCharacterData"

local ON_CHARACTER_INFO_SET_FROM_CHARACTER_DATA = "OnCharacterInfoSetFromCharacterData"

local ON_ANIMATION_PLAY = "OnAnimationPlay"
local ON_ANIMATION_STOP = "OnAnimationStop"

local ON_AVATAR_ANIMATION_SET = "OnAvatarAnimationSet"
local ON_AVATAR_RAW_ANIMATION_SET = "OnAvatarRawAnimationSet"
--variables
--references
--local functions
local function playAnimation(char : Model, id : number)   
    
    if RunService:IsServer() then
        local plr = Players:GetPlayerFromCharacter(char)
        assert(plr)
        NetworkUtil.fireClient(ON_AVATAR_ANIMATION_SET, plr, char, id)
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
        maid:GiveTask(char.AncestryChanged:Connect(function()
            if char.Parent == nil then
                stopAnimation()
            end
        end))
        maid:GiveTask(charHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if charHumanoid.MoveDirection.Magnitude ~= 0 and not charHumanoid.Sit then
                stopAnimation()
            end
        end))
        
    end
end

local function getCatalogFolder()
    local catalogFolder = ReplicatedStorage:FindFirstChild(CATALOG_FOLDER_NAME) :: Folder or Instance.new("Folder")
    catalogFolder.Name = CATALOG_FOLDER_NAME
    catalogFolder.Parent = ReplicatedStorage
    return catalogFolder
end

local function paralyzeCharacter(char : Model)
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("Motor6D") then
            local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
            a0.CFrame = v.C0
            a1.CFrame = v.C1
            a0.Parent = v.Part0
            a1.Parent = v.Part1

            local ballSocketConstraint = Instance.new("BallSocketConstraint")
            ballSocketConstraint.Attachment0 = a0
            ballSocketConstraint.Attachment1 = a1
            ballSocketConstraint.Parent = v.Parent

            v:Destroy()
        end
    end

    if char.PrimaryPart then
        char.PrimaryPart.CanCollide = false
    end

    local head = char:FindFirstChild("Head") :: BasePart
    if head then
        head.CanCollide = true
    end

    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = false
        end
    end

    return
end

local function characterAdded(char : Model)
    local playerCollisionGroupKey = "Player"
   
    local charMaid = Maid.new()
    
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid
    if humanoid then
        if not humanoid:IsDescendantOf(game) then
            humanoid.AncestryChanged:Wait()
        end
        humanoid.WalkSpeed = WALK_SPEED
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.BreakJointsOnDeath = false
        charMaid:GiveTask(humanoid.Died:Connect(function()
            charMaid:Destroy()
            paralyzeCharacter(char)
        end))
    end

    charMaid:GiveTask(char.ChildAdded:Connect(function(child : Instance)
        if child:IsA("Tool") then
            local rawTool = BackpackUtil.getToolFromName(child.Name)
            assert(rawTool)
            local toolData = BackpackUtil.getData(rawTool, false)
            print(toolData)
            if toolData.Class == "Meat" then
                local _maid = Maid.new()

                local meatModel = child:FindFirstChild(child.Name) :: Model
                local meatPripart = meatModel.PrimaryPart :: MeshPart
                if meatPripart then
                    _maid:GiveTask(meatPripart.Touched:Connect(function(hit)
                        if hit:FindFirstChildWhichIsA("Fire") then 
                            meatPripart.TextureID = "rbxassetid://" .. tostring(661123557)
                        end
                    end))
                end

                _maid:GiveTask(child.AncestryChanged:Connect(function()
                    if child.Parent == nil then
                        _maid:Destroy()
                    end
                end))
            end
        end
    end))

    charMaid:GiveTask(char.AncestryChanged:Connect(function()
        if char.Parent == nil then
            charMaid:Destroy()
        end
    end))

    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CollisionGroup = playerCollisionGroupKey
        end
    end
end

local function onPlayerAdded(plr : Player)
    local char = plr.Character or plr.CharacterAdded:Wait()
    characterAdded(char)
    
    local _maid = Maid.new()
    _maid:GiveTask(plr.CharacterAdded:Connect(characterAdded))

    _maid:GiveTask(plr.AncestryChanged:Connect(function()
        if plr.Parent == nil then
            _maid:Destroy()
        end
    end))

   

    --testing char only
    --[[local testacc
    for _,v in pairs(CustomizationList) do
        if v.Class == "Accessory" then
            testacc = v
        end
    end
    
    CustomizationUtil.Customize(plr, testacc.TemplateId)]]
end

--class
local CharacterManager = {}

function CharacterManager.init(maid : Maid)
    local playerCollisionGroupKey = "Player"
    local trainWheelCollisionGroupKey = "TrainWheel"
    local trainWheelSwitchCollisionGroupKey = "TrainWheel_Switch"

    PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupKey, playerCollisionGroupKey, false)
    PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupKey, trainWheelCollisionGroupKey, false)
    PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupKey, trainWheelSwitchCollisionGroupKey, false)

    for _, plr : Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))


    NetworkUtil.onServerInvoke(ON_CHARACTER_APPEARANCE_RESET, function( plr : Player)
        local character = plr.Character or plr.CharacterAdded:Wait()

        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local hum_desc = game.Players:GetHumanoidDescriptionFromUserId(plr.UserId)

        if hum_desc then
            humanoid:ApplyDescription(Instance.new("HumanoidDescription") :: HumanoidDescription)
            --humanoid:RemoveAccessories()
            task.wait()
            humanoid:ApplyDescription(hum_desc)
        end

        CustomizationUtil.setDesc(plr, "PlayerName", plr.Name)
        CustomizationUtil.setDesc(plr, "PlayerBio", "")
        return nil
    end)

    NetworkUtil.onServerInvoke(GET_CATALOG_FROM_CATALOG_INFO, function(plr : Player, catalogId : number)
        local catalogFolder = getCatalogFolder()
        local asset = catalogFolder:FindFirstChild(tostring(catalogId)) or game:GetService("InsertService"):LoadAsset(catalogId)
        asset.Name = tostring(catalogId)
        asset.Parent = catalogFolder
        task.spawn(function()
            task.wait(5)
            asset:Destroy()
        end)
        return asset
    end)

    
    NetworkUtil.onServerInvoke(GET_AVATAR_FROM_CHARACTER_DATA, function(plr : Player, characterData : CustomizationUtil.CharacterData)
        local character = CustomizationUtil.getAvatarPreviewByCharacterData(characterData)

        task.spawn(function()
            task.wait(5)
            character:Destroy()
        end)

        return character
    end)

    NetworkUtil.onServerInvoke(ON_CHARACTER_INFO_SET_FROM_CHARACTER_DATA, function(plr : Player, characterData)
        CustomizationUtil.SetInfoFromCharacter(plr.Character or plr.CharacterAdded:Wait(), characterData)
        return nil
    end)

    NetworkUtil.getRemoteEvent(ON_AVATAR_ANIMATION_SET)
    NetworkUtil.getRemoteEvent(ON_AVATAR_RAW_ANIMATION_SET)

    NetworkUtil.getRemoteEvent(ON_ANIMATION_PLAY)
    NetworkUtil.getRemoteEvent(ON_ANIMATION_STOP)
end

return CharacterManager