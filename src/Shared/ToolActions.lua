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
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = workspace:WaitForChild("Assets"):GetChildren()
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
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any)            
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
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any)
            AnimationUtil.playAnim(player, 6831327167, false)
        end
    },

    {
        ToolClass = "Miscs",
        Activated = function()
            
        end
    },

    {
        ToolClass = "Weapon",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any)
            local character = player.Character or player.CharacterAdded:Wait()
            local weaponTool : Tool

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    weaponTool = v
                    break
                end
            end

            if weaponTool:FindFirstChild("Gun") then            
                local gunModel = weaponTool:FindFirstChild("Gun")
                local flare = if gunModel then gunModel:FindFirstChild("Flare") else nil

                if flare then
                    local muzzleFlash = flare:FindFirstChild("MuzzleFlash") :: BillboardGui ?
                    if muzzleFlash then
                        muzzleFlash.Enabled = true

                        local gunMesh = gunModel:FindFirstChild("GunMesh") :: MeshPart ?
                        if gunMesh then
                            local rayCast = workspace:Raycast(gunMesh.Position, -gunMesh.CFrame.LookVector*50, raycastParams)
                            if rayCast then
                                print(rayCast.Instance.Name)
                                local part = Instance.new("Part")
                                part.Anchored = true
                                part.Position = rayCast.Position
                                part.Transparency = 1
                                part.Parent = workspace
                             
                                local smoke = Instance.new("Smoke")
                                smoke.RiseVelocity = 0.5
                                smoke.Size = 0.1
                                smoke.Opacity = 1 
                                smoke.Color = rayCast.Instance.Color
                                smoke.Parent = part
                                
                                task.spawn(function()
                                    task.wait(0.5)
                                    smoke.Enabled = false
                                    task.wait(6)
                                    part:Destroy()
                                end)
                            end
                        end
                        task.wait(0.1)
                        muzzleFlash.Enabled = false
                    end
                    playSound(143286342, false, flare)
                end
            elseif weaponTool:FindFirstChild("Dynamite") then
                local dynamiteModel = weaponTool:FindFirstChild("Dynamite")
                if dynamiteModel then
                    local clonedDynamite = dynamiteModel:Clone() :: Model
                    clonedDynamite.Parent = workspace

                    task.spawn(function()
                        for k,v in pairs(plrInfo.Backpack) do
                            if v.IsEquipped then
                                plrInfo:DeleteBackpack(k)
                                break
                            end
                        end

                        task.wait(5)
                        if clonedDynamite.PrimaryPart then clonedDynamite.PrimaryPart.Transparency = 1 end

                        local cf, _ = clonedDynamite:GetBoundingBox()
                        local exp = Instance.new("Explosion") :: Explosion
                        exp.BlastRadius = 15
                        exp.BlastPressure = 0
                        exp.Position = (if clonedDynamite.PrimaryPart then clonedDynamite.PrimaryPart.Position else cf.Position)
                        
                        local explosionConn = exp.Hit:Connect(function(part : BasePart, dist : number)
                            part:SetAttribute("IsExplosionHit", true)
                            task.wait(1)
                            part:SetAttribute("IsExplosionHit", nil)
                        end)

                        exp.Parent = workspace

                        local sound = Instance.new("Sound") :: Sound
                        sound.RollOffMaxDistance = 45
                        sound.SoundId = "rbxassetid://5801257793" 
                        sound.Parent = clonedDynamite.PrimaryPart 
                        sound:Play()
                        sound.Ended:Wait()
                        clonedDynamite:Destroy()

                        explosionConn:Disconnect()

                    end)
                end
                weaponTool:Destroy()
            end
        end
    }
}
--references
--local functions
--class
local ToolActions = {}

function ToolActions.onToolActivated(toolClass : string, player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any)
    if RunService:IsServer() then
        local actionInfo = ToolActions.getActionInfo(toolClass)
        actionInfo.Activated(player, toolData, plrInfo)
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

--function ToolActions.init(maid) 
   -- if RunService:IsServer() then
     --   NetworkUtil.onServerEvent(ON_TOOL_ACTIVATED, function(plr : Player, toolClass : string, foodInst : Instance, toolData : BackpackUtil.ToolData<nil>)
     --       print(toolClass, " eeh")
     --       ToolActions.onToolActivated(toolClass, plr, toolData)
     --   end)
    --end
--end

return ToolActions