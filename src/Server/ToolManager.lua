--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
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

local ON_PHONE_MESSAGE_START = "OnPhoneMessageStart"
--variables
--references
local ToolsAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools")
--local functions
--class
local ToolManager = {}

function ToolManager.onToolOnBackpack(tool : Tool, char : Model)
    --set up collision group
    for _,v in pairs(tool:GetDescendants()) do
        if v:IsA("BasePart") and char.PrimaryPart then
            v.CollisionGroup = char.PrimaryPart.CollisionGroup
        end
    end

    --
    if tool.Name:lower() == "identity card" then
        local toolModel = tool:FindFirstChild(tool.Name) :: Model ?
        assert(toolModel and toolModel.PrimaryPart)
        local surfaceGui = toolModel.PrimaryPart:WaitForChild("SurfaceGui")
        local idText = surfaceGui:WaitForChild("Details"):WaitForChild("Id") :: TextLabel 
        local plrNameText = surfaceGui:WaitForChild("Details"):WaitForChild("PlayerName") :: TextLabel 
        local accountAgeText = surfaceGui:WaitForChild("Details"):WaitForChild("AccountAge") :: TextLabel 
        local citizenshipText = surfaceGui:WaitForChild("Details"):WaitForChild("Citizenship") :: TextLabel
        local avatarImage = surfaceGui:WaitForChild("AvatarImage") :: ImageLabel

        local plr = Players:GetPlayerFromCharacter(char)
        
        if plr then
            local plrRoleName = plr:GetRoleInGroup(5255603)
    
            idText.Text = `Identity Number: {plr.UserId}`
            plrNameText.Text = `Name: {char.Name}`
            accountAgeText.Text = `Account age: {plr.AccountAge}`
            citizenshipText.Text = `Citizenship: {if plrRoleName:lower() == "guest" then "Tourist" else plrRoleName}`
            avatarImage.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end
    end
end

function ToolManager.init(maid : Maid)
    local ToolCollections = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools")

    for _,v in pairs(CollectionService:GetTagged("Tool")) do
        local hasIsTool = false
        for k, child in pairs(v:GetDescendants()) do
            if child:GetAttribute("IsTool") and not BackpackUtil.getToolFromName(child.Name) then
                hasIsTool = true
                local newTool = child:Clone()
                newTool:SetAttribute("Class", v:GetAttribute("Class"))
                newTool:SetAttribute("DisplayTypeName", v:GetAttribute("DisplayTypeName"))
                newTool:SetAttribute("OnRelease", v:GetAttribute("OnRelease"))
                newTool.Parent = ToolCollections
                CollectionService:AddTag(newTool, "Tool")      
                --if child.Name == "Part" then
                --    print(child)         
                --end
            end
        end
        
        --set parents to replicated storage
        if v:IsDescendantOf(workspace) and not ToolCollections:FindFirstChild(v.Name) and not hasIsTool then
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

    NetworkUtil.onServerInvoke(ON_PHONE_MESSAGE_START, function(sender : Player, recieverName : string, msgText : string)
        local reciever = Players:FindFirstChild(recieverName)
        assert(reciever and reciever:IsA("Player"))
        NetworkUtil.invokeClient(ON_PHONE_MESSAGE_START, reciever, sender.Name, msgText)
        return nil 
    end)

    NetworkUtil.getRemoteFunction(ON_PHONE_MESSAGE_START)
end

return ToolManager