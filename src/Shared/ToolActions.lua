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

local TOOL_IS_WRITING_KEY = "IsWriting"
--remotes
local ON_TOOL_ACTIVATED = "OnToolActivated"
local ON_CAMERA_SHAKE = "OnCameraShake"
--variables
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = workspace:WaitForChild("Assets"):GetChildren()
--references
--local functions
local function playSound(soundId : number, onLoop : boolean, parent : Instance ?, volume : number?)
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    if volume then sound.Volume = volume end
    sound.Parent = parent or (if RunService:IsClient() then Players.LocalPlayer else nil)
    sound.RollOffMaxDistance = 35
    sound.Looped = onLoop
    if sound.Parent then
        sound:Play()
    end
    task.spawn(function()
        sound.Ended:Wait()
        sound:Destroy()
    end)
    return sound
end
--class
local ActionLists = {
    {
        ToolClass = "Consumption",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)            
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
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            AnimationUtil.playAnim(player, 6831327167, false)
        end
    },

    {
        ToolClass = "Fishing Rod",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            --print("rodding")
            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Instance

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            NetworkUtil.fireClient(ON_TOOL_ACTIVATED, player, toolData.Class, player, toolData)
        end
    },

    {
        ToolClass = "BathBucket",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            AnimationUtil.playAnim(player, 15370187795, false)

            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Instance

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            local bucketModel = toolInst:WaitForChild("Bucket")
            local bucketPart = bucketModel:WaitForChild("Bucket")
            local water = bucketPart:WaitForChild("Water") :: ParticleEmitter
            water.Enabled = true
            playSound(9120504377, false, bucketPart, 0.25)
            task.wait(0.6)
            water.Enabled = false
          
        end
    },

    {
        ToolClass = "SoundPlayer",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Tool

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            if toolInst then
                local model = toolInst:FindFirstChild(toolInst.Name) :: Model ?
                print(model, model and model.PrimaryPart)
                if model and model.PrimaryPart then
                    playSound(model:GetAttribute("Sound") or 9117124777, false, model.PrimaryPart)
                end
            end
        end
    },

    {
        ToolClass = "Weapon",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
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
                print(flare)
                if flare then
                    local muzzleFlash = flare:FindFirstChild("MuzzleFlash") :: BillboardGui ?
                    --print(muzzleFlash)
                    if muzzleFlash then
                        muzzleFlash.Enabled = true

                        local gunMesh = gunModel:FindFirstChild("GunMesh") :: MeshPart ?
                      --  print(gunMesh)
                        if gunMesh then
                            local rayCast = workspace:Raycast(gunMesh.Position, -gunMesh.CFrame.LookVector*50, raycastParams)
                          --  print(rayCast)
                            if rayCast then
                                task.spawn(function()
                                    task.wait((rayCast.Distance/3.571)/120 + 0.1)
                                    local part = Instance.new("Part")
                                    part.Anchored = true
                                    part.Position = rayCast.Position
                                    part.Transparency = 1
                                    part.Parent = workspace
                                
                                    local smoke = Instance.new("Smoke")
                                    smoke.RiseVelocity = 0.5
                                    smoke.Size = 0.1
                                    smoke.Opacity = 0.75
                                    smoke.Color = rayCast.Instance.Color
                                    smoke.Parent = part

                                    local rand = math.random(1,3)
                                    local sound = Instance.new("Sound") 
                                    sound.Volume = 0.1
                                    sound.SoundId = if rand == 1 then "rbxassetid://4427236368" elseif rand ==2 then "rbxassetid://4427231299" else "rbxassetid://4427234167"
                                    sound.RollOffMaxDistance = 50
                                    sound.Parent = part
                                    sound:Play()

                                    task.wait(0.5)
                                    smoke.Enabled = false
                                    task.wait(6)
                                    part:Destroy()
                                end)
                            end
                        end

                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            -- print(humanoid, " test1")
                            NetworkUtil.fireClient(ON_CAMERA_SHAKE, player)
                        end

                        task.wait(0.1)
                        muzzleFlash.Enabled = false
                    end
                    playSound(143286342, false, flare, 0.1)
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
    },

    {
        ToolClass = "Pencil",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Tool

            print("testPencil", IsReleased)
            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            if toolInst then
                if not IsReleased then
                    toolInst:SetAttribute(TOOL_IS_WRITING_KEY, true)
                elseif IsReleased == true then
                    toolInst:SetAttribute(TOOL_IS_WRITING_KEY, nil)
                end
                --[[if toolInst:GetAttribute(TOOL_IS_WRITING_KEY) == nil then
                    toolInst:SetAttribute(TOOL_IS_WRITING_KEY, true)
                elseif toolInst:GetAttribute(TOOL_IS_WRITING_KEY) == true then
                    toolInst:SetAttribute(TOOL_IS_WRITING_KEY, nil)
                end]]
            end
        end
    },

    {
        ToolClass = "Emitter",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            local emitterSoundName = "EmitterSound"
            
            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Tool

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            if toolInst then
                for _,v in pairs(toolInst:GetDescendants()) do
                    if v:IsA("ParticleEmitter") then
                        if not IsReleased then
                            v.Enabled = true
                        elseif IsReleased == true then
                            v.Enabled = false
                        end
                    end
                end
                local toolModel = toolInst:FindFirstChild(toolInst.Name) :: Model ?
                if toolModel and toolModel:IsA("Model") then
                    if not IsReleased then
                        local sound = playSound(toolModel:GetAttribute("Sound") or 9114437231, true, toolInst:FindFirstChild(toolInst.Name))
                        sound.Name =  emitterSoundName
                        sound.Parent = toolModel.PrimaryPart
                    elseif IsReleased == true then
                        for _,v in pairs(toolInst:GetDescendants()) do
                            if v:IsA("Sound") and v.Name == emitterSoundName then
                                v:Destroy()
                            end
                        end
                    end
                end
            end
        end
    },
    {
        ToolClass = "TextDisplay",
        Activated = function(player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, IsReleased : boolean ?)
            local character = player.Character or player.CharacterAdded:Wait()
            local toolInst : Tool

            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and v.Name == toolData.Name then
                    toolInst = v
                    break
                end
            end

            if toolInst then
                local toolModel = toolInst:FindFirstChild(toolInst.Name) :: Model ?
                if toolModel then
                    
                end
            end
        end
    },
    {
        ToolClass = "Miscs",
        Activated = function()
            
        end
    }

}
--references
--local functions
--class
local ToolActions = {}

function ToolActions.onToolActivated(toolClass : string, player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, isReleased : boolean ?)
    if RunService:IsServer() then
        local actionInfo = ToolActions.getActionInfo(toolClass)
        actionInfo.Activated(player, toolData, plrInfo, isReleased)
        if toolData.OnRelease and ((isReleased == nil) or (isReleased == false)) then
            NetworkUtil.fireClient(ON_TOOL_ACTIVATED, player, toolClass, player, toolData, nil, false)
        --elseif toolData.OnRelease and (isReleased == true) then
            --NetworkUtil.fireClient(ON_TOOL_ACTIVATED, player, toolClass, player, toolData, nil, true)
        end
    else
        if (toolData.OnRelease == true) then
            print("Onrelease property true")
            if isReleased == nil then
                NetworkUtil.fireServer(ON_TOOL_ACTIVATED, toolClass, player, toolData, nil, false)
            end
            if (isReleased == nil) or (isReleased == false) then
                local conn
                conn = game:GetService("UserInputService").InputEnded:Connect(function(input : InputObject, gpe : boolean)
                    print(input.UserInputType, input.UserInputType == Enum.UserInputType.MouseButton1)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        --print("Libit")
                        NetworkUtil.fireServer(ON_TOOL_ACTIVATED, toolClass, player, toolData, nil, true)
                        conn:Disconnect()
                    end
                end)
            end
        elseif (toolData.OnRelease == false) then
            NetworkUtil.fireServer(ON_TOOL_ACTIVATED, toolClass, player, toolData, plrInfo)
        end
    end
    return
end

function ToolActions.getActionInfo(toolClass : string)
    for _,v in pairs(ActionLists) do
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