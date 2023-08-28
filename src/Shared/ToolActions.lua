--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))
--types
type Maid = Maid.Maid
--constants
local SOUND_NAME = "SFX"
--remotes
local ON_TOOL_ACTIVATED = "OnToolActivated"
--variables
--references
--local functions
local function playSound(soundId : number, onLoop : boolean, parent : Instance ? )
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Parent = parent or (if RunService:IsClient() then Players.LocalPlayer else nil)
    sound.RollOffMaxDistance = 35
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
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>)            
            local character = player.Character or player.CharacterAdded:Wait()
            local foodInst : Instance

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    foodInst = v
                    break
                end
            end

            assert(foodInst, "Unable to find the equipped tool!")

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
            AnimationUtil.playAnim(player, animId, false)
                
            --play sound
            if character then
                local hrp = character.PrimaryPart
                playSound(soundId, false, hrp)
            end
        end
    },
    {
        ToolClass = "Reading",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>)
            AnimationUtil.playAnim(player, 6831327167, false)
        end
    },

    {
        ToolClass = "Miscs",
        Activated = function()
            
        end
    },

    {
        ToolClass = "Gun",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>)
            local character = player.Character or player.CharacterAdded:Wait()
            local gunTool : Tool

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    gunTool = v
                    break
                end
            end

            local gunModel = gunTool:FindFirstChild("Gun")
            local flare = if gunModel then gunModel:FindFirstChild("Flare") else nil

            if flare then
                local muzzleFlash = flare:FindFirstChild("MuzzleFlash") :: BillboardGui ?
                if muzzleFlash then
                    muzzleFlash.Enabled = true
                    task.wait(0.1)
                    muzzleFlash.Enabled = false
                end
                playSound(143286342, false, flare)
            end

            print("Duar bruh ", toolData)
        end
    }
}
--references
--local functions
--class
local ToolActions = {}

function ToolActions.onToolActivated(toolClass : string, player : Player, toolData : BackpackUtil.ToolData<nil>)
    if RunService:IsServer() then
        local actionInfo = ToolActions.getActionInfo(toolClass)
        actionInfo.Activated( player, toolData)
    else
        NetworkUtil.fireServer(ON_TOOL_ACTIVATED, toolClass, player, toolData)
    end
    return
end

function ToolActions.getActionInfo(toolClass : string)
    for _,v in pairs(ActionLists) do
        print(v.ToolClass, toolClass)
        if v.ToolClass == toolClass then
            return v 
        end
    end
    error("Tool info not found!")
end

function ToolActions.init(maid) 
    if RunService:IsServer() then
        NetworkUtil.onServerEvent(ON_TOOL_ACTIVATED, function(plr : Player, toolClass : string, foodInst : Instance, toolData : BackpackUtil.ToolData<nil>)
            print(toolClass, " eeh")
            ToolActions.onToolActivated(toolClass, plr, toolData)
        end)
    end
end

return ToolActions