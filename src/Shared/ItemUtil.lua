--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
--packages
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
export type ItemType = "Tool" | "Vehicle"

export type ItemInfo = {
    Name : string,
    Class : string,
    Type : ItemType
}
--constants
--variables
--references
--local functions
--class
local ItemUtil = {}

function ItemUtil.newData(
    name : string,
    class : string,
    type : string
)
    return {
        Name = name,
        Class = class,
        Type = type
    }
end

function ItemUtil.getData(model : Instance, classAsDisplayType : boolean) : ItemInfo 
    local itemType : ItemInfo = ItemUtil.getItemTypeByName(model.Name) :: any
    if CollectionService:GetTagged("Tool") then
        local toolData : ItemInfo = BackpackUtil.getData(model, classAsDisplayType) :: any
        assert(itemType)
        toolData.Type = itemType :: any
        return toolData
    elseif CollectionService:GetTagged("Vehicle") then
        return {
            Name = model.Name,
            Class = model:GetAttribute("Class"),
            Type = "Vehicle"
        }
    end
    error("No data for this object")
end

function ItemUtil.getItemFromName(name : string)
    local function getByTag(tag : string)
        for _,v in pairs(CollectionService:GetTagged(tag)) do
            if v.Name == name then
                return v
            end
        end
        return
    end
    
    
    return getByTag("Tool") or getByTag("Vehicle")
end

function ItemUtil.getClassFromName(name : string, classAsDisplayType : boolean) : string
    local item = ItemUtil.getItemFromName(name)
    local data = ItemUtil.getData(item, classAsDisplayType)
    return data.Class
end

function ItemUtil.getItemTypeByName(name : string) : ItemType ?
    local inst = ItemUtil.getItemFromName(name)
    return if CollectionService:HasTag(inst, "Tool") then "Tool" 
        elseif CollectionService:HasTag(inst, "Vehicle") then "Vehicle"
    else nil
end

return ItemUtil