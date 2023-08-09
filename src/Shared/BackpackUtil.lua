--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid

export type ToolData<isEquipped> = {
    Name : string,
    Class : string,
    IsEquipped : isEquipped
}
--constants
--variables
--references
--local functions
local function createWeld(handle: BasePart, part: BasePart)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = handle 
    weld.Parent = handle
    return weld
end
local function createTool(inst : Instance)
    local tool = Instance.new("Tool")
    local clonedInst = inst:Clone()
    clonedInst.Parent = tool
    if clonedInst:IsA("BasePart") then clonedInst.Anchored = false end
    for _,v in pairs(clonedInst:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = false
        end
    end
    tool.Name = clonedInst.Name

    --adds handle
    local cf, size 
    if clonedInst:IsA("Model") then
        cf, size =  clonedInst:GetBoundingBox()
    elseif clonedInst:IsA("BasePart") then
        cf, size = clonedInst.CFrame, clonedInst.Size
    else 
        cf, size = CFrame.new(), Vector3.new()
    end

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.CanCollide = false
    handle.Transparency = 1
    handle.CFrame, handle.Size = cf, size
    handle.Parent = tool
    --welds
    if clonedInst:IsA("BasePart") then
        createWeld(handle, clonedInst)
    end
    for _,v in pairs(clonedInst:GetDescendants()) do
        if v:IsA("BasePart") then
            createWeld(handle, v)
        end
    end

    return tool
end
--class
local BackpackUtil = {}

function BackpackUtil.getData(toolModel : Instance, classAsDisplayType : boolean) : ToolData<nil>
    return {
        Name = toolModel.Name,
        Class = if classAsDisplayType and toolModel:GetAttribute("DisplayTypeName") then toolModel:GetAttribute("DisplayTypeName") else toolModel:GetAttribute("ToolClass"),
    }
end

function BackpackUtil.getToolFromName(name : string): Instance ?
    for _, toolModel in pairs(CollectionService:GetTagged("Tool")) do
        local toolData = BackpackUtil.getData(toolModel, false)
        if (toolModel.Name == name) and toolData.Class then
            return toolModel
        end
    end
    return nil
end

function BackpackUtil.getAllItemClasses()
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

function BackpackUtil.getAllItemNames()
    local items = {}
    for _, toolModel in pairs(CollectionService:GetTagged("Tool")) do
       --[[ local alreadyNoted = false
        for _, v in pairs(items) do
            if v.Name == toolModel.Name then
                alreadyNoted = true
                break
            end
        end
        if not alreadyNoted then
            table.insert(items, toolModel)
        end]]
        if not table.find(items, toolModel.Name) then
            table.insert(items, toolModel.Name)
        end
    end
    return items
end

function BackpackUtil.createTool(inst : Instance)
    return createTool(inst)
end

--initializing backpack
function BackpackUtil.init(maid : Maid)
    local ToolCollections = Instance.new("Folder")
    ToolCollections.Name = "Tools"
    ToolCollections.Parent = ReplicatedStorage

    print(CollectionService:GetTagged("Tool"))
    for _,v in pairs(CollectionService:GetTagged("Tool")) do
        for k, child in pairs(v:GetDescendants()) do
            if child:GetAttribute("IsTool") and not BackpackUtil.getToolFromName(child.Name) then
                local newTool = child:Clone()
                newTool.Parent = ToolCollections
                CollectionService:AddTag(newTool, "Tool")
                newTool:SetAttribute("ToolClass", "Consumption")
                newTool:SetAttribute("DisplayTypeName", "Food")
            end
        end
    end
end

return BackpackUtil