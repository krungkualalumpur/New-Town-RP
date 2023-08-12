--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))
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
        Activated = function(foodInst : Instance, player : Player, toolData : BackpackUtil.ToolData<nil>)            
            local animId = 0
            local soundId = 0

            print(toolData.Class) 
            if toolData.Class == "Food" then
                animId = 5569663688
                soundId = 4511723890
            elseif toolData.Class == "Drink" then
                animId = 5569673797
                soundId = 1820372394
            end
            AnimationUtil.playAnim(player, animId)
                
            --play sound
            local character = player.Character
            if character then
                local hrp = character.PrimaryPart
                playSound(soundId, false, hrp)
                print("eating" , foodInst.Name)
            end
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
        print(v.ToolClass, toolClass)
        if v.ToolClass == toolClass then
            return v 
        end
    end
    error("Tool info not found!")
end

return ToolActions