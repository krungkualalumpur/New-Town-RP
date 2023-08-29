--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
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
local function playSound(soundId : number, onLoop : boolean, parent : Instance ? )
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.RollOffMaxDistance = 30
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
        if CollectionService:HasTag(model, "Door") or CollectionService:HasTag(model, "Window") then
            Interactable.InteractOpening(model,true)
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
            Interactable.InteractSwitch(model)
        elseif (interactableData.Class) and interactableData.IsSwitch == nil then
            Interactable.InteractNonSwitch(model, player)
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
    --else
        --NetworkUtil.fireServer(ON_TOOL_INTERACT, model)
    end
    
    return
end

function Interactable.onClientToolInteract(model : Model)
    NetworkUtil.fireServer(ON_TOOL_INTERACT, model)
end

function Interactable.InteractSwitch(model : Model)
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

    if data.IsSwitch then
        if data.Class == "Blind" then
            adjustModel(model, function(part : BasePart)
                switchTransparency(part, true)
            end, 3657933537)
        elseif data.Class == "Water" then
            print("Wala2")
            adjustModel(model, function(part : BasePart)
                if part:GetAttribute(IsWaterAttributeKey) ~= nil then
                    part.Transparency = 0.5
                end
                if part:GetAttribute(IsParticleAttributeKey) ~= nil then
                    local particleEmitter = part:FindFirstChild("ParticleEmitter") :: ParticleEmitter ?
                    if particleEmitter then
                        particleEmitter.Enabled = true
                    end
                end
            end, 2218767018, true)
        elseif data.Class == "Circuit" then
            local SwitchPartName = "SwitchPart"
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local circuitModel = if model.Parent and model.Parent.Parent and model.Parent.Parent:GetAttribute("IsCircuitModel") then model.Parent.Parent else nil
            assert(circuitModel, "No circuit model detected!")
            local lampSwitchPart = model:FindFirstChild(SwitchPartName) :: BasePart?

            for _,lampModel in pairs(circuitModel:GetChildren()) do
                if CollectionService:HasTag(lampModel, "Lamp") then
                    for _, light in pairs(lampModel:GetDescendants()) do
                        if light:IsA("Light") then
                            light.Enabled = true
                            local neonPart = light.Parent :: BasePart ?
                            if neonPart then
                                neonPart.Material = Enum.Material.Neon
                            end
                        end
                    end
                end
            end
            if lampSwitchPart then
                local cf = lampSwitchPart.CFrame
                lampSwitchPart.CFrame = (cf - cf.Position)*CFrame.Angles(-50,0,0) + cf.Position

                playSound(9125620381, false,  lampSwitchPart)
            end
        elseif data.Class == "Television" then
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

            _maid:GiveTask(TVgui.Destroying:Connect(function()
                _maid:Destroy()
            end))
        end

    else

        if data.Class == "Blind" then
            adjustModel(model, function(part : BasePart)
                switchTransparency(part, false)
            end, 3657935906)
        elseif data.Class == "Water" then
            print("Wala1")
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
        elseif data.Class == "Circuit" then
            local SwitchPartName = "SwitchPart"
            if RunService:IsClient() then
                NetworkUtil.fireServer(ON_INTERACT, model)
                return
            end

            local circuitModel = if model.Parent and model.Parent.Parent and model.Parent.Parent:GetAttribute("IsCircuitModel") then model.Parent.Parent else nil
            assert(circuitModel, "No circuit model detected!")
            local lampSwitchPart = model:FindFirstChild(SwitchPartName) :: BasePart ?

            for _,lampModel in pairs(circuitModel:GetChildren()) do
                if CollectionService:HasTag(lampModel, "Lamp") then
                    for _, light in pairs(lampModel:GetDescendants()) do
                        if light:IsA("Light") then
                            light.Enabled = false
                            local neonPart = light.Parent :: BasePart ?
                            if neonPart then
                                neonPart.Material = Enum.Material.SmoothPlastic
                            end
                        end
                    end
                end
            end
            if lampSwitchPart then
                local cf = lampSwitchPart.CFrame
                lampSwitchPart.CFrame = (cf - cf.Position)*CFrame.Angles(50,0,0) + cf.Position

                playSound(9125620381, false,  lampSwitchPart)
            end
        elseif data.Class == "Television" then
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
    end
end

function Interactable.InteractNonSwitch(model : Model, plr : Player)
    local data = Interactable.getData(model)
    
    if data.Class == "CharacterCustomization" then
        if RunService:IsClient() then             
            NetworkUtil.fireServer(ON_INTERACT, model)
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
                end
            end
        else

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
            print("2?")
            NetworkUtil.invokeServer(ON_ITEM_OPTIONS_OPENED, model)
        end
    end
        
end

function Interactable.InteractOpening(model : Model,on : boolean)
    if RunService:IsServer() then
        local pivot = model:FindFirstChild("Pivot")
        local hingeConstraint = if pivot then pivot:FindFirstChild("HingeConstraint") :: HingeConstraint else nil

        local slides = model:FindFirstChild("Slides")

        if hingeConstraint  then --if it's a hinges opening
            if hingeConstraint.TargetAngle == 0 then
                for _,v in pairs(model:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                hingeConstraint.ServoMaxTorque = math.huge
                hingeConstraint.TargetAngle = 90
                playSound(833871080, false, pivot)
                task.wait(5)
                for _,v in pairs(model:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
                playSound(7038967181, false, pivot)
                hingeConstraint.TargetAngle = 0
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

function Interactable.init(maid : Maid)
    local slidingDoorsZone = {}

    for _,v in pairs(CollectionService:GetTagged("Door")) do
        local detectionZone = v:FindFirstChild("Detection")
        if detectionZone then
            table.insert(slidingDoorsZone, detectionZone)
        end
    end

    local zone = maid:GiveTask(Zone.new(slidingDoorsZone))
    
    maid:GiveTask(zone.playerEntered:Connect(function(plr : Player, zonePart : BasePart)
       -- print(plr.Name, "Entered")
        local model = zonePart.Parent :: Model
        Interactable.InteractOpening(model, true)
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
            Interactable.InteractOpening(model, false)
        end
        return
    end))
        
 
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
