--!strict
--services
local CollectionService = game:GetService("CollectionService")
--packages
--modules
--types
export type InteractableData = {
    Class : string,
    IsSwitch : boolean ?
}
--constants
--references
--variables
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
        if CollectionService:GetTagged("Door") then
            Interactable.InteractSwing(model,true)
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

function Interactable.InteractSwitch(model : Model, on : boolean)
    local data = Interactable.getData(model)
    assert(data.IsSwitch ~= nil, "IsSwitch attribute non-existant!")
    
    data.IsSwitch = not data.IsSwitch
    Interactable.setData(model, data)
end

function Interactable.InteractSwing(model : Model,on : boolean)
    local pivot = model:FindFirstChild("Pivot")
    local hingeConstraint = if pivot then pivot:FindFirstChild("HingeConstraint") :: HingeConstraint else nil

    if hingeConstraint then
        hingeConstraint.ServoMaxTorque = math.huge
        hingeConstraint.TargetAngle = 90
        task.wait(3)
        hingeConstraint.TargetAngle = 0
    end
end

return Interactable
