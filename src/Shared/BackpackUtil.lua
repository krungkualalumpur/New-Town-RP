--!strict
--services
local CollectionService = game:GetService("CollectionService")
--packages
--modules
--types
export type ToolData = {
    Name : string,
    Class : string
}
--constants
--variables
--references
--local functions
--class
local BackpackUtil = {}

function BackpackUtil.getData(toolModel : Instance) : ToolData
    return {
        Name = toolModel.Name,
        Class = toolModel:GetAttribute("ToolClass")
    }
end

function BackpackUtil.getItemClasses()
    local classes = {}
    for _, toolModel in pairs(CollectionService:GetTagged("Tool")) do
        local className = toolModel:GetAttribute("DisplayTypeName") or toolModel:GetAttribute("ToolClass")
        if className then
            if not table.find(classes, className) then
                table.insert(classes, className) 
            end
        end 
    end
    return classes
end

return BackpackUtil