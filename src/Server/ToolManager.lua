--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
type Maid = Maid.Maid
--constants
local WRITING_MAX_PTS = 50
--remotes
local ON_WRITING_FINISHED = "OnWritingFinished"
--variables
--references
local ToolsAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools")
--local functions
--class
local ToolManager = {}

function ToolManager.init(maid : Maid)
    local ToolCollections = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools")

    for _,v in pairs(CollectionService:GetTagged("Tool")) do
        for k, child in pairs(v:GetDescendants()) do
            if child:GetAttribute("IsTool") and not BackpackUtil.getToolFromName(child.Name) then
                local newTool = child:Clone()
                newTool:SetAttribute("Class", v:GetAttribute("Class"))
                newTool:SetAttribute("DisplayTypeName", v:GetAttribute("DisplayTypeName"))
                newTool:SetAttribute("OnRelease", v:GetAttribute("OnRelease"))
                newTool.Parent = ToolCollections
                CollectionService:AddTag(newTool, "Tool")               
            end
        end
        
        --set parents to replicated storage
        if v:IsDescendantOf(workspace) then
            local newTool = v:Clone()
            newTool:SetAttribute("Class", v:GetAttribute("Class"))
            newTool:SetAttribute("DisplayTypeName", v:GetAttribute("DisplayTypeName"))
            newTool:SetAttribute("OnRelease", v:GetAttribute("OnRelease"))
            newTool.Parent = ToolCollections
            CollectionService:AddTag(newTool, "Tool")
        end
    end

    maid:GiveTask(NetworkUtil.onServerEvent(ON_WRITING_FINISHED, function(plr : Player, pts : {Vector3})
        local count = 0

        local parts = {}

        for _,v in pairs(pts) do
            if count > WRITING_MAX_PTS then
                return
            end

            local part = Instance.new("Part")
            part.Size = Vector3.new(0.25, 0.25, 0.25)
            part.Position = v
            part.Anchored = true
            part.Color = Color3.fromRGB(0,0,0)
            part.Parent = workspace

            table.insert(parts, part)
          
            count += 1
        end

        task.spawn(function()
            task.wait(10)
            for _,v in pairs(parts) do
                local tween = game:GetService("TweenService"):Create(v, TweenInfo.new(0.25) , {Transparency = 1})
                tween:Play()
                tween:Destroy()
                local conn 
                conn = tween.Completed:Connect(function()
                    conn:Disconnect()
                    v:Destroy()
                end)            
            end
        end)
        return
    end))
end

return ToolManager