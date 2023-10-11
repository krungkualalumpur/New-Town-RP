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
local ON_ANIMATION_SET = "OnAnimationSet"
local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"
--variables
--references
--local functions
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
            if charHumanoid.MoveDirection.Magnitude ~= 0 then
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

    --[[local humanoid = char:WaitForChild("Humanoid") :: Humanoid
                
    local animator = humanoid:WaitForChild("Animator") :: Animator
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(animId)

    local animTrack : AnimationTrack = animator:LoadAnimation(animation)
    animTrack.Looped = onLoop

    animTrack:Play()
    
    task.spawn(function()
        animTrack.Ended:Wait()
        animation:Destroy()
    end)]]
    local maid = Maid.new()
    local animation = maid:GiveTask(Instance.new("Animation"))
    animation.AnimationId = "rbxassetid://" .. tostring(animId)
    local animationTrack = maid:GiveTask(animator:LoadAnimation(animation))
    --animationTrack.Looped = false
    animationTrack:Play()
    --animationTrack.Ended:Wait()
    local function stopAnimation()
        animationTrack:Stop()
        maid:Destroy()
    end
    maid:GiveTask(char.Destroying:Connect(stopAnimation))
    maid:GiveTask(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if humanoid.MoveDirection.Magnitude ~= 0 then
            stopAnimation()
        end
    end))
end
return AnimUtil