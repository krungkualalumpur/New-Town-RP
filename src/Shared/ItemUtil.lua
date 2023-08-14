--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
--packages
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
export type ItemInfo = {
    Name : string,
    Class : string,
}
--constants
--variables
--references
--local functions
--class
local ItemUtil = {}

function ItemUtil.getData(model : Instance, classAsDisplayType : boolean) : ItemInfo
    if CollectionService:GetTagged("Tool") then
        return BackpackUtil.getData(model, classAsDisplayType)
    end
    return {
        Class = model:GetAttribute("Class"),
        Name = model.Name
    }
end

function ItemUtil.getItemFromName(name : string)
    local function getByTag(tag : string)
        for _,v in pairs(CollectionService:GetTagged(tag)) do
            local itemData = ItemUtil.getData(v, true)
            if itemData.Name == name then
                return v
            end
        end
        return
    end
    
    
    return getByTag("Tool") or getByTag("Vehicle")
end

return ItemUtil