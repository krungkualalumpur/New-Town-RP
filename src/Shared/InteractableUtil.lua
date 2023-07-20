--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
export type InteractableData = {
    Class : string,
    IsSwitch : boolean ?
}
--constants
local ON_INTERACT = "On_Interact"
local SOUND_NAME = "SFX"
--references
--variables
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

function Interactable.Interact(model : Model)
    if model.PrimaryPart then
        if CollectionService:HasTag(model, "Door") or CollectionService:HasTag(model, "Window") then
            Interactable.InteractSwing(model,true)
        end

        local interactableData = Interactable.getData(model)
        if (CollectionService:HasTag(model, "Switch")) and (interactableData.Class) and (interactableData.IsSwitch ~= nil) then
            Interactable.InteractSwitch(model)
        end
        --just for fun :P
        --local exp = Instance.new("Explosion")
        --exp.BlastRadius = 35
        --exp.BlastPressure = 1000
        --exp.ExplosionType = Enum.ExplosionType.Craters
        --exp.Position = model.PrimaryPart.Position
        --exp.Parent = workspace
       
    end
end

function Interactable.InteractToolGiver(model : Model)
    return
end

function Interactable.InteractSwitch(model : Model)
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
            adjustModel(model, function(part : BasePart)
                if part:GetAttribute("isWater") then
                    switchTransparency(part, true)
                end
            end, 2218767018, true)
        end
    else
        if data.Class == "Blind" then
            adjustModel(model, function(part : BasePart)
                switchTransparency(part, false)
            end, 3657935906)
        elseif data.Class == "Water" then
            adjustModel(model, function(part : BasePart)
                if part:GetAttribute("isWater") then
                    switchTransparency(part, false)
                end
            end, 2218767018, true)
        end
    end
end

function Interactable.InteractSwing(model : Model,on : boolean)
    if RunService:IsServer() then
        local pivot = model:FindFirstChild("Pivot")
        local hingeConstraint = if pivot then pivot:FindFirstChild("HingeConstraint") :: HingeConstraint else nil

        if hingeConstraint then
            hingeConstraint.ServoMaxTorque = math.huge
            hingeConstraint.TargetAngle = 90
            task.wait(3)
            hingeConstraint.TargetAngle = 0
        end
    elseif RunService:IsClient() then
        NetworkUtil.fireServer(ON_INTERACT, model)
    end
end

return Interactable
