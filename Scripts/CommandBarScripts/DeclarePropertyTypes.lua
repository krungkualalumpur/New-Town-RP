--!strict
local CollectionService = game:GetService("CollectionService")

local typeIndex = 0
local storedPropertyNames = {}

for _,v in pairs(CollectionService:GetTagged("Property")) do
    if not storedPropertyNames[v.Name] then
        typeIndex += 1
        storedPropertyNames[v.Name] = typeIndex
    end
    v:SetAttribute("HouseType", storedPropertyNames[v.Name])
end
