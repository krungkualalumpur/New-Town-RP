--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
--constants
--remotes
local ON_AVATAR_ANIMATION_SET = "OnAvatarAnimationSet"
local ON_AVATAR_RAW_ANIMATION_SET = "OnAvatarRawAnimationSet"
local ON_RAW_ANIMATION_SET = "OnRawAnimationSet"
local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"
--variables
--references
--local functions
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
--class
local AnimUtil = {}
function AnimUtil.playAnim(plr : Player, animId : number | string, onLoop : boolean)
    if type(animId) == "string" then
        animId = string.match(animId, "%d+") or "0"
    end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid
    local animator = humanoid:WaitForChild("Animator") :: Animator

    if RunService:IsServer() then
        NetworkUtil.fireClient(ON_RAW_ANIMATION_SET, plr, char, animId)
    else
        playAnimationByRawId(char, animId :: number)
    end
end
return AnimUtil