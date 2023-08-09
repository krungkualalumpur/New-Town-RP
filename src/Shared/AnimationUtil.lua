--!strict
--services
--packages
--modules
--types
--constants
--variables
--references
--local functions
--class
local AnimUtil = {}
function AnimUtil.playAnim(plr : Player, animId : number | string)
    if type(animId) == "string" then
        animId = string.match(animId, "%d+") or "0"
    end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid
                
    local animator = humanoid:WaitForChild("Animator") :: Animator
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(animId)

    local animTrack : AnimationTrack = animator:LoadAnimation(animation)

    animTrack:Play()
    
    task.spawn(function()
        animTrack.Ended:Wait()
        animation:Destroy()
    end)
    
end
return AnimUtil