--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))

local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))

local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))

local TelevisionChannel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TelevisionChannel"))

--types
type Maid = Maid.Maid

export type InteractableData = {
    Class : string,
    IsSwitch : boolean ?
}
--constants
local SOUND_NAME = "SFX"

local INTERACT_TRIGGERED_ATTRIBUTE_KEY = "Triggered"

--remotes
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local ON_INTERACT = "On_Interact"
local ON_TOOL_INTERACT = "On_Tool_Interact"

local ON_OPTIONS_OPENED = "OnOptionsOpened"
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local ON_NOTIFICATION = "OnNotification"
--references
--variables
--local functions
local function playSound(soundId : number, onLoop : boolean, parent : Instance ?, volume : number ?, maxDistance : number ?)
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.RollOffMaxDistance = maxDistance or 30
    sound.Volume = volume or 1
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Parent = parent or (if RunService:IsClient() then Players.LocalPlayer else nil)
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

local function adjustModel(model : Model, fn : (part : BasePart) -> (), soundId : number ?, onLoop : boolean ?)
    local soundPart = model.PrimaryPart
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            fn(v)

            if not soundPart then
                soundPart = v
            end

            --removing any sounds 
            local sfx = v:FindFirstChild(SOUND_NAME) 
            if sfx then
                sfx:Destroy()
            end
        end
       
    end

    if soundId then 
        playSound(soundId, if onLoop ~= nil then onLoop else false, soundPart)
    end
end
--class
local Interactable = {}

function Interactable.newData(class : string, isSwitch : boolean ?) : InteractableData
    return {
        Class = class, 
        IsSwitch = isSwitch
    }
end

function Interactable.getData(model : Model) : InteractableData
    return {
        Class = model:GetAttribute("Class"),
        IsSwitch = model:GetAttribute("IsSwitch")
    }
end

function Interactable.setData(model : Model, data : InteractableData)
    model:SetAttribute("Class", data.Class)
    model:SetAttribute("IsSwitch", data.IsSwitch)

    return nil 
end

function Interactable.Interact(model : Model, player : Player, plrInfo : any)
    --if model.PrimaryPart then
    local ownerId = model:GetAttribute("OwnerId")
    if ownerId ~= nil and player.UserId ~= ownerId then
        return
    end

    if CollectionService:HasTag(model, "Door") or CollectionService:HasTag(model, "Window") then
        Interactable.InteractOpening(model,true, player)
    end 

    
    if CollectionService:HasTag(model, "Tool") then
        if RunService:IsClient() then
            Interactable.onClientToolInteract(model)
        else
            if plrInfo then
                Interactable.InteractToolGiver(plrInfo, model, player)
            end
        end
    end

    local interactableData = Interactable.getData(model)
    if (interactableData.Class) and (interactableData.IsSwitch ~= nil) then
        Interactable.InteractSwitch(model, player)
    elseif (interactableData.Class) and interactableData.IsSwitch == nil then
        Interactable.InteractNonSwitch(model, player, plrInfo)
    end

        
        --just for fun :P
        --local exp = Instance.new("Explosion")
        --exp.BlastRadius = 35
        --exp.BlastPressure = 1000
        --exp.ExplosionType = Enum.ExplosionType.Craters
        --exp.Position = model.PrimaryPart.Position
        --exp.Parent = workspace
       
   -- end
end

function Interactable.InteractToolGiver(plrInfo : any,  model : Model, player : Player)
    if RunService:IsServer() then
        if not model:GetAttribute("DescendantsAreTools") then
          
            --local newTool = createTool(model)
            local newTool = BackpackUtil.getToolFromName(model.Name)
            -----
            if newTool then
                local success = plrInfo:InsertToBackpack(newTool)
                if success then
                    NetworkUtil.fireClient(ON_NOTIFICATION, player, model.Name .. " added to your backpack!")
                end
            end
            ----- 
        else
            for _,v in pairs(model:GetChildren()) do
                if v:GetAttribute("IsTool") then
                    local newTool = BackpackUtil.getToolFromName(v.Name)
                   -- createTool(newModel).Parent = player:WaitForChild("Backpack")
                     ----- 
                    assert(newTool) 
                    local success = plrInfo:InsertToBackpack(newTool)
                    if success then
                        NetworkUtil.fireClient(ON_NOTIFICATION, player, v.Name .. " added to your backpack!")
                    end
                    ----- 
                end
            end
        end
        NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plrInfo.Player,  plrInfo:GetBackpack(true, true))

        if model:GetAttribute("DeleteAfterInteract") == true then
            model:Destroy()
        end
    --else
        --NetworkUtil.fireServer(ON_TOOL_INTERACT, model)
    end
    
    return
end

function Interactable.onClientToolInteract(model : Model)
    NetworkUtil.fireServer(ON_TOOL_INTERACT, model)
end

function Interactable.InteractSwitch(model : Model, player : Player, plrInfo : any)
    local IsWaterAttributeKey = "IsWater"
    local IsParticleAttributeKey = "IsParticle"

    local data = Interactable.getData(model)
    assert(data.IsSwitch ~= nil, "IsSwitch attribute non-existant!")
    
    data.IsSwitch = not data.IsSwitch
    Interactable.setData(model, data)

    local function switchTransparency(part : BasePart, on : boolean)
        if on then
            if not part:GetAttribute("Transparency") then
                part:SetAttribute("Transparency", part.Transparency)
                part.Transparency = 1
            end
        else
            if part:GetAttribute("Transparency") then
                part.Transparency = part:GetAttribute("Transparency")
                part:SetAttribute("Transparency", nil)
            end
        end
    end

    if data.Class == "Blind" then
        if data.IsSwitch then
            local curtainFabric = model:FindFirstChild("CurtainFabric") :: Model?
            if curtainFabric then 
                adjustModel(curtainFabric, function(part : BasePart)
                    switchTransparency(part, true)
                end, 3657933537)
            end
        else
            local curtainFabric = model:FindFirstChild("CurtainFabric") :: Model?
            if curtainFabric then 
                adjustModel(curtainFabric, function(part : BasePart)
                    switchTransparency(part, false)
                end, 3657935906)
            end
        end
    elseif data.Class == "Water" then
        if data.IsSwitch then
            adjustModel(model, function(part : BasePart)
                if part:GetAttribute(IsWaterAttributeKey) ~= nil then
                    part.Transparency = 0.5
                end
                if part:GetAttribute(IsParticleAttributeKey) ~= nil then
                    local particleEmitter = part:FindFirstChildWhichIsA("ParticleEmitter") :: ParticleEmitter ?
                    if particleEmitter then
                        particleEmitter.Enabled = true
                    end
                end
            end, model:GetAttribute("WaterSound") or 2218767018, true)
        else
            adjustModel(model, function(part : BasePart)
                if part:GetAttribute(IsWaterAttributeKey) ~= nil then
                    part.Transparency = 1
                end
                if part:GetAttribute(IsParticleAttributeKey) ~= nil then
                    local particleEmitter = part:FindFirstChild("ParticleEmitter") :: ParticleEmitter ?
                    if particleEmitter then
                        particleEmitter.Enabled = false
                    end
                end
            end)
        end
    elseif data.Class == "Circuit" then
        if data.IsSwitch then
            local SwitchPartName = "SwitchPart"
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local circuitModel = if model.Parent and model.Parent.Parent and model.Parent.Parent:GetAttribute("IsCircuitModel") then model.Parent.Parent else nil
            assert(circuitModel, "No circuit model detected!")
            local lampSwitchPart = model:FindFirstChild(SwitchPartName) :: BasePart?

            for _,childModel in pairs(circuitModel:GetChildren()) do
                if CollectionService:HasTag(childModel, "Lamp") then
                    for _, light in pairs(childModel:GetDescendants()) do
                        if light:IsA("Light") then
                            light.Enabled = true
                            local neonPart = light.Parent :: BasePart ?
                            if neonPart then
                                neonPart.Material = Enum.Material.Neon
                            end
                        end
                    end
                elseif CollectionService:HasTag(childModel, "Door") then
                    task.spawn(function() Interactable.InteractOpening(childModel :: Model, true, player) end)
                end
            end
            if lampSwitchPart then
                local cf = lampSwitchPart.CFrame
                lampSwitchPart.CFrame = (cf - cf.Position)*CFrame.Angles(-50,0,0) + cf.Position

                playSound(9125620381, false,  lampSwitchPart)
            end
        else
            local SwitchPartName = "SwitchPart"
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local circuitModel = if model.Parent and model.Parent.Parent and model.Parent.Parent:GetAttribute("IsCircuitModel") then model.Parent.Parent else nil
            assert(circuitModel, "No circuit model detected!")
            local lampSwitchPart = model:FindFirstChild(SwitchPartName) :: BasePart ?

            for _,childModel in pairs(circuitModel:GetChildren()) do
                if CollectionService:HasTag(childModel, "Lamp") then
                    for _, light in pairs(childModel:GetDescendants()) do
                        if light:IsA("Light") then
                            light.Enabled = false
                            local neonPart = light.Parent :: BasePart ?
                            if neonPart then
                                neonPart.Material = Enum.Material.SmoothPlastic
                            end
                        end
                    end
                elseif CollectionService:HasTag(childModel, "Door") then
                    task.spawn(function() Interactable.InteractOpening(childModel :: Model, false, player) end)
                end
            end
            if lampSwitchPart then
                local cf = lampSwitchPart.CFrame
                lampSwitchPart.CFrame = (cf - cf.Position)*CFrame.Angles(50,0,0) + cf.Position

                playSound(9125620381, false,  lampSwitchPart)
            end
        end
    elseif data.Class == "Television" then
        if data.IsSwitch then
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local screenPart = model:FindFirstChild("ScreenPart") :: BasePart

            local TVgui = Instance.new("SurfaceGui") :: SurfaceGui
            TVgui.Name = "TelevisionGui"
            TVgui.Face = Enum.NormalId.Right
            TVgui.Parent = screenPart

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = TVgui

            local textLabel = Instance.new("TextLabel")
            textLabel.BackgroundTransparency = 0
            textLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
            textLabel.Size = UDim2.fromScale(1, 1)
            textLabel.TextSize = 40
            textLabel.TextYAlignment = Enum.TextYAlignment.Center
            textLabel.RichText = true
            textLabel.TextWrapped = true
            textLabel.Parent = TVgui 

            local _maid = Maid.new()
            local _fuse =  ColdFusion.fuse(_maid)
            local _new = _fuse.new
            local _bind = _fuse.bind

            local _Computed = _fuse.Computed

            local currentTextState = TelevisionChannel.getCurrentTextStateByChannelId(1)
          
            textLabel.Text = tostring(TelevisionChannel.getTextByTextState(1, currentTextState.Value))
            _maid:GiveTask(currentTextState.Changed:Connect(function()
                local text = TelevisionChannel. getTextByTextState(1, currentTextState.Value)
                if textLabel.Parent then
                    local intTextState = currentTextState.Value
                    for i = 1, #text do
                        if currentTextState.Value == intTextState then
                            task.wait()
                            textLabel.Text = string.sub(text, 1, i)
                        end
                    end
                end
            end))

            _maid:GiveTask(TVgui.AncestryChanged:Connect(function()
                if TVgui.Parent == nil then
                    _maid:Destroy()
                end
            end))
        else
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local screenPart = model:FindFirstChild("ScreenPart") :: BasePart

            local TVgui = screenPart:FindFirstChild("TelevisionGui")

            if TVgui then
                TVgui:Destroy()
            end
        end
    elseif data.Class == "Stove" then
        if RunService:IsClient() then
            NetworkUtil.fireServer(ON_INTERACT, model)
            return
        end
        
        if data.IsSwitch then
            local _maid = Maid.new()

            for _,v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Igniter" then
                    local fire = v:FindFirstChild("Fire") :: Fire ?
                    if fire then
                        local function onExplode()
                            local sourcePart = Instance.new("Part")
                            sourcePart.Name = "FireSource"
                            sourcePart.Anchored = true
                            sourcePart.Position = v.Position
                            sourcePart.CanCollide = false
                            sourcePart.Transparency = 1
                            sourcePart.Parent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries")

                            local exp = Instance.new("Explosion")
                            exp.BlastRadius = 0
                            exp.BlastPressure = 0
                            exp.Position = v.Position
                            exp.Parent = sourcePart
                            local smoke = Instance.new"Smoke" 
                            smoke.RiseVelocity = 80
                            smoke.Size = 10
                            smoke.Color = Color3.new(0.231373, 0.231373, 0.231373)
                            smoke.Parent = sourcePart
                            local fire = Instance.new"Fire" 
                            fire.Size = 100
                            fire.Parent = sourcePart

                            playSound(5801257793, false, v, 3, 65)
                            if not v:IsDescendantOf(workspace:WaitForChild("Assets"):WaitForChild("Houses")) then
                                playSound(9125557781, true, sourcePart, 1.5, 65)
                            end
                            task.wait(50)
                            fire.Enabled = false
                            smoke.Enabled = false
                            
                            local updatedData = Interactable.getData(model)
                            if updatedData.IsSwitch then
                                Interactable.InteractSwitch(model, player)
                            end

                            task.wait(15)
                            exp:Destroy()
                            smoke:Destroy()
                            fire:Destroy() 
                            sourcePart:Destroy()
                        end
                        fire.Enabled = true
                        playSound(9061999173, true, v, 0.08)

                        _maid:GiveTask(fire:GetPropertyChangedSignal("Enabled"):Connect(function()
                            if fire.Enabled == false then
                                _maid:Destroy()
                            end
                        end))

                        local burnT = 0
                        local t = tick()
                        _maid:GiveTask(RunService.Stepped:Connect(function()
                            if tick() - t >= 1 then
                                t = tick()
                                burnT += 1
                                --print(burnT, " : final countdown dududuuuudu")
                                if burnT >= 60 then
                                    _maid:Destroy()
                                    onExplode()
                                end
                            end
                        end))
                    end
                end
            end
            
        else
            for _,v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Igniter" then
                    local fire = v:FindFirstChild("Fire") :: Fire ?
                    if fire then
                        fire.Enabled = false
                        for _,sound in pairs(v:GetChildren()) do
                            if sound:IsA("Sound") then
                                sound:Destroy()
                            end
                        end
                    end
                end
            end
        end
   
    end
end

function Interactable.InteractNonSwitch(model : Model, plr : Player, plrInfo : any)
    local data = Interactable.getData(model)
    if data.Class == "CharacterCustomization" then
        if RunService:IsClient() then       
            if model:GetAttribute("HasShirt") then   
                NetworkUtil.fireServer(ON_INTERACT, model)
            else
                --open the customization UI
                local uistatus = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("StatusUtil")).getStatusFromName("Ui")
                uistatus:Set("Customization")      
            end
            return
        end

        local function CustomeReplacement(character : Model, instClassName : "Shirt" | "Pants" , id : number)
            local foundInst = character:FindFirstChild(instClassName) :: Instance  -- Tries to find Shirt
            if not foundInst then -- if there is no shirt
                local newInst = Instance.new(instClassName) 
                newInst.Name = instClassName
                foundInst = newInst
            elseif foundInst then -- if there is a shirt
                foundInst:Destroy()
                local newInst = Instance.new(instClassName :: "Shirt" | "Pants")
                newInst.Name = instClassName
                foundInst = newInst 
            end
            if foundInst:IsA("Shirt") then
                foundInst.ShirtTemplate = "rbxassetid://" .. tostring(id)
            elseif foundInst:IsA("Pants") then
                foundInst.PantsTemplate = "rbxassetid://" .. tostring(id)
            end
            foundInst.Parent = character
        end

        local character = plr.Character
        if character and model:GetAttribute("HasShirt") then
            for _,v in pairs(model:GetDescendants()) do
                if v:IsA("Shirt") then -- shirt
                    local idNum = tonumber(string.match(v.ShirtTemplate, "%d+"))
                    if idNum then
                        CustomeReplacement(character, "Shirt", idNum)
                    end
                elseif v:IsA("Pants") then -- pants
                    local idNum = tonumber(string.match(v.PantsTemplate, "%d+"))
                    if idNum then
                        CustomeReplacement(character, "Pants", idNum)
                    end
                elseif v:GetAttribute("Accessory") then
                    CustomizationUtil.Customize(plr, v:GetAttribute("Accessory"), Enum.AvatarItemType.Asset)
                end
            end
         
        end
    elseif data.Class == "ItemOptionsUI" then
        if RunService:IsServer() then
            local function getItemInfo(
                name : string,
                desc : string
            )
            local itemType = ItemUtil.getItemTypeByName(name)
            return {
                Name = name,
                Desc = desc,  
                Type = itemType      
            } end

            --require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil")).getData(model :: Model, false)
            local itemlist = model:FindFirstChild("ItemList")

            if itemlist then
                local listName = itemlist:GetAttribute("ListName")
                local listTbl = {}
                for _,v in pairs(itemlist:GetChildren()) do
                    if v:IsA("StringValue") then
                        table.insert(listTbl, getItemInfo(v.Name, v.Value))
                    end
                end
                task.wait()
                NetworkUtil.invokeClient(ON_ITEM_OPTIONS_OPENED, plr, listName, listTbl, model)
            else
                NetworkUtil.invokeClient(ON_OPTIONS_OPENED, plr, model.Name, model)
            end
        else
            NetworkUtil.invokeServer(ON_ITEM_OPTIONS_OPENED, model)
        end
    elseif data.Class == "Claim" then
        local claimerPointer = model:FindFirstChild("ClaimerPointer") :: ObjectValue ?
        assert(claimerPointer)

        if RunService:IsClient() then
            NetworkUtil.fireServer(ON_INTERACT, model)
        else
            if claimerPointer.Value == plr then
                claimerPointer.Value = nil
            else
                claimerPointer.Value = plr
            end
        end
        
        --[[local house = if model.Parent then model.Parent.Parent else nil
        if house and house:IsA("Model") then
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
            else
                local Houses = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Houses"))
                Houses.claim(house, plr)
            end
           
        end]]
    elseif data.Class == "Farm" then
        if RunService:IsClient() then
            NetworkUtil.fireServer(ON_INTERACT, model)
            return
        end
        
        local plantPartName = "Plant"

        local plantPart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Nature"):WaitForChild("Grass") :: BasePart
        local farmState = (model:GetAttribute("State")) :: "Plant" | "Food" | "Processing"

        if farmState == "Processing" then
            return
        end

        local farmPripart = model.PrimaryPart
        assert(farmPripart)

        local cf, size = model:GetBoundingBox() 

        local plantModel : Model ? = (if model.Parent and not model.Parent:FindFirstChild(plantPartName) then Instance.new("Model") elseif model.Parent and model.Parent:FindFirstChild(plantPartName) then model.Parent:FindFirstChild(plantPartName) :: Model else nil)
        assert(plantModel) 
        plantModel.Name = plantPartName

        model:SetAttribute("State", "Processing")
        if farmState == "Plant" then 
            for i = 1, 5 do
                local plantPartCloned = plantPart:Clone()
                plantPartCloned.CFrame = cf + farmPripart.CFrame.RightVector*size.X*math.random(-50, 50)*0.01
                plantPartCloned.Size = Vector3.new()
                plantPartCloned.Parent = plantModel
            end
            plantModel.Parent = model.Parent
            farmPripart.Transparency = 1

            --plant grow anim
            for _,v in pairs(plantModel:GetChildren()) do
                if v:IsA("BasePart") then
                    local waitTime = 0.25
                    v.Size = Vector3.new()

                    local tween = TweenService:Create(v, TweenInfo.new(waitTime), {Size = plantPart.Size})
                    tween:Play()
                    playSound(6544398467, false, v)
                    task.wait(waitTime)
                    tween:Destroy()
                end
            end
        else
            if farmState == "Food" then 
                farmPripart.Transparency = 1
                if plrInfo then
                    local newTool = BackpackUtil.getToolFromName("Rice")
                    -----
                    if newTool then
                        local success = plrInfo:InsertToBackpack(newTool)
                        if success then
                            NetworkUtil.fireClient(ON_NOTIFICATION, plr, newTool.Name .. " added to your backpack!")
                        end
                    end
                end

                --plant destroys
                for _,v in pairs(plantModel:GetChildren()) do
                    if v:IsA("BasePart") then
                        local waitTime = 0.25
                        local intSize = v.Size
                        v.Size = Vector3.new()
    
                        local tween = TweenService:Create(v, TweenInfo.new(waitTime), {Size = Vector3.new()})
                        tween:Play()
                        playSound(6544398467, false, v)
                        task.wait(waitTime)
                        v:Destroy()
                        tween:Destroy()
                    end
                end
            elseif farmState == nil then
                farmPripart.Transparency = 0
            end

            plantModel:Destroy()
        end

        model:SetAttribute("State", if farmState == "Plant" then "Food" elseif farmState == "Food" then nil else "Plant")
    else  --default
        if RunService:IsClient() then
            NetworkUtil.fireServer(ON_INTERACT, model)
        else
            model:SetAttribute(INTERACT_TRIGGERED_ATTRIBUTE_KEY, plr.UserId)
            task.wait()
            model:SetAttribute(INTERACT_TRIGGERED_ATTRIBUTE_KEY, nil)
        end   
    end
end

function Interactable.InteractOpening(model : Model,on : boolean, player : Player ?)
    if RunService:IsServer() then


        local pivot = model:FindFirstChild("Pivot")
        local hingeConstraint = if pivot then pivot:FindFirstChild("HingeConstraint") :: HingeConstraint else nil

        local slides = model:FindFirstChild("Slides")

        if hingeConstraint  then --if it's a hinges opening
            local doorModel = model:FindFirstChild("Model")
            if --[[(hingeConstraint.TargetAngle == 0) and]] doorModel and (doorModel:GetAttribute("IsOpened") == nil) then
                doorModel:SetAttribute("IsOpened", true)
                for _,v in pairs(doorModel:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Anchored = false
                    end
                end
                hingeConstraint.ServoMaxTorque = math.huge
                hingeConstraint.TargetAngle = 90
                playSound(833871080, false, pivot)

            elseif doorModel and (doorModel:GetAttribute("IsOpened") == true) then

                playSound(7038967181, false, pivot)
                hingeConstraint.TargetAngle = 0

                task.wait(0.75)
                for _,v in pairs(doorModel:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                        v.Anchored = true
                    end
                end

                doorModel:SetAttribute("IsOpened", nil)
            end
        elseif slides then --if it's a slides opening
            local right = slides:FindFirstChild("Right") :: BasePart
            local left = slides:FindFirstChild("Left") :: BasePart

            if right and left then
                playSound(9114154039, false, right)
                if on then
                    if right:FindFirstChild("CFrameValue") or left:FindFirstChild("CFrameValue") then
                        return
                    end

                    local rightCfValue = Instance.new("CFrameValue")
                    rightCfValue.Name = "CFrameValue"
                    rightCfValue.Value = right.CFrame
                    rightCfValue.Parent = right

                    local leftCfValue = Instance.new("CFrameValue")
                    leftCfValue.Name = "CFrameValue"
                    leftCfValue.Value = left.CFrame
                    leftCfValue.Parent = left

                    local leftTween = game:GetService("TweenService"):Create(
                        left, 
                        TweenInfo.new(0.1), 
                        {
                            CFrame = left.CFrame + left.CFrame.RightVector*left.Size.X
                        }
                    )
                    local rightTween = game:GetService("TweenService"):Create(
                        right, 
                        TweenInfo.new(0.1), 
                        {
                            CFrame = right.CFrame - right.CFrame.RightVector*right.Size.X
                        }
                    )

                    leftTween:Play()
                    rightTween:Play()

              

                    task.spawn(function()
                        leftTween.Completed:Wait()
                        leftTween:Destroy()
                        rightTween:Destroy()
                    end)
                    
                else
                    local leftCfValue = left:FindFirstChild("CFrameValue") :: CFrameValue ?
                    local rightCfValue = right:FindFirstChild("CFrameValue") :: CFrameValue ?

                    if leftCfValue and rightCfValue then 
                        local leftTween = game:GetService("TweenService"):Create(
                            left, 
                            TweenInfo.new(0.1), 
                            {
                                CFrame = leftCfValue.Value
                            }
                        )
                        local rightTween = game:GetService("TweenService"):Create(
                            right, 
                            TweenInfo.new(0.1), 
                            {
                                CFrame = rightCfValue.Value
                            }
                        )
    
                        leftTween:Play()
                        rightTween:Play()
                              
                        leftCfValue:Destroy()
                        rightCfValue:Destroy()

                        task.spawn(function()
                            leftTween.Completed:Wait()
                            leftTween:Destroy()
                            rightTween:Destroy()
                        end)

                    end
                end

                --[[task.spawn(function()
                    task.wait(2)
                    
                    local leftCloseTween = game:GetService("TweenService"):Create(
                        left, 
                        TweenInfo.new(0.1), 
                        {
                            CFrame = leftCfValue.Value
                        }
                    )
                    local rightCloseTween = game:GetService("TweenService"):Create(
                        right, 
                        TweenInfo.new(0.1), 
                        {
                            CFrame = rightCfValue.Value
                        }
                    )
    
                    leftCloseTween:Play()
                    rightCloseTween:Play()
                    
                    leftCfValue:Destroy()
                    rightCfValue:Destroy()

                    leftTween:Destroy()
                    rightTween:Destroy()
                    leftCloseTween:Destroy()
                    rightCloseTween:Destroy()
                end)]]
            end
        end
    elseif RunService:IsClient() then
        NetworkUtil.fireServer(ON_INTERACT, model)
    end
end

function Interactable.getTriggeredAttributeKey()
    return INTERACT_TRIGGERED_ATTRIBUTE_KEY
end

function Interactable.init(maid : Maid)
    local slidingDoorsZone = {}

    for _,v in pairs(CollectionService:GetTagged("Door")) do
        local detectionZone = v:FindFirstChild("Detection")
        if detectionZone then
            table.insert(slidingDoorsZone, detectionZone)
        end

        --anchoring
        for _,doorPart in pairs(v:GetDescendants()) do
            if doorPart:IsA("BasePart") then
                doorPart.Anchored = true
            end
        end
    end

    local zone = maid:GiveTask(Zone.new(slidingDoorsZone))
    
    maid:GiveTask(zone.playerEntered:Connect(function(plr : Player, zonePart : BasePart)
       -- print(plr.Name, "Entered")
        local model = zonePart.Parent :: Model
        Interactable.InteractOpening(model, true, plr)
        return
    end))
    maid:GiveTask(zone.playerExited:Connect(function(plr : Player, zonePart : BasePart)
       -- print(plr.Name, " Exited")
        local hasOtherPeople = false
        
        local touchedParts = zonePart:GetTouchingParts() 
        for _,v in pairs(touchedParts) do
            if v.Parent and v.Parent:FindFirstChild("Humanoid") then
                hasOtherPeople = true
                break
            end
        end

        if not hasOtherPeople then
            local model = zonePart.Parent :: Model
            Interactable.InteractOpening(model, false, plr)
        end
        return
    end))
        
    local claims = {}
    for _,v in pairs(CollectionService:GetTagged("Interactable")) do
        local data = Interactable.getData(v)
        if data.Class == "Claim" then
            table.insert(claims, v)
        end
    end
    for _,v in pairs(CollectionService:GetTagged("ClickInteractable")) do
        local data = Interactable.getData(v)
        if data.Class == "Claim" then
            table.insert(claims, v)
        end
    end

    for _,v in pairs(claims) do
        local playerPointer = Instance.new("ObjectValue")
        playerPointer.Name = "ClaimerPointer"
        playerPointer.Parent = v
    end
 
    NetworkUtil.onServerInvoke(ON_OPTIONS_OPENED, function(plr : Player)
        return nil
    end)

    NetworkUtil.onServerInvoke(ON_ITEM_OPTIONS_OPENED, function(plr : Player, model : Model)
        Interactable.InteractNonSwitch(model, plr) 
        return nil 
    end)

       
    NetworkUtil.getRemoteFunction(ON_OPTIONS_OPENED)
    NetworkUtil.getRemoteFunction(ON_ITEM_OPTIONS_OPENED) 
end

return Interactable
