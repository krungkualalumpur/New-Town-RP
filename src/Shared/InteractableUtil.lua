--!strict
--services
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
    
end

return Interactable
