--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
--modules
--types
--constants
local SOUND_NAME = "SFX"
--variables
--references
--local functions
local function playSound(soundId : number, onLoop : boolean, parent : Instance ? )
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Parent = parent or (if RunService:IsClient() then Players.LocalPlayer else nil)
    sound.Looped = onLoop
    if sound.Parent then
        sound:Play()
    end
    sound.Ended:Wait()
    sound:Destroy()
end
--class
local ActionLists = {
    {
        ToolClass = "Consumption",
        Activated = function(foodInst : Instance, humanoid : Humanoid)
            local hrp = if humanoid.Parent and humanoid.Parent:IsA("Model") then humanoid.Parent.PrimaryPart else nil
            
            local animator = humanoid:WaitForChild("Animator") :: Animator
            
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://5569663688"

            local animTrack : AnimationTrack = animator:LoadAnimation(animation)

            animTrack:Play()
            
            task.spawn(function()
                animTrack.Ended:Wait()
                animation:Destroy()
            end)

            --play sound
            playSound(4511723890, false, hrp)
            print("eating" , foodInst.Name)
        end
    },
    {
        ToolClass = "Object",
        Activated = function()
            
        end
    }
}
--references
--local functions
--class
local ToolActions = {}

function ToolActions.getActionInfo(toolClass : string)
    for _,v in pairs(ActionLists) do
        if v.ToolClass == toolClass then
            return v 
        end
    end
    error("Tool info not found!")
end

return ToolActions