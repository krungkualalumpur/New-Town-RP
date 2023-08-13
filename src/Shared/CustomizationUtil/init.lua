--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
--types
type Maid = Maid.Maid
export type DescType = "PlayerName" | "PlayerBio"
--constants
--remotes
local ON_CUSTOMIZE_AVATAR_NAME = "OnCustomizeAvatarName"
local ON_CUSTOMIZE_CHAR = "OnCustomizeCharacter"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"

--variables
--references
--local functions
--class
local CustomizationUtil = {}

function CustomizationUtil.getAccessoryId(accessory : Accessory)
    return accessory:GetAttribute("CustomeId")
end

function CustomizationUtil.getAssetImageFromId(id : number, width : number ?, height : number ?)
    local Width = width or 48
    local Height = height or 48
    return "https://www.roblox.com/Thumbs/Asset.ashx?width=".. tostring(Width).."&height=".. tostring(Height) .."&assetId=".. tostring(id)
end

function CustomizationUtil.Customize(plr : Player, customizationId : number)
    if RunService:IsServer() then
        local character = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local asset = InsertService:LoadAsset(customizationId)
        local assetInstance = asset:GetChildren()[1]
        assert(asset, "Unable to load the asset")

        if assetInstance:IsA("Decal") then
            --it's a face
            local head = character:FindFirstChild("Head") :: BasePart or nil
            local face = if head then head:FindFirstChild("face") :: Decal else nil
            if face then 
                face.Texture = assetInstance.Texture
            end
        elseif assetInstance:IsA("Accessory") then
            local existingAccessory = character:FindFirstChild(assetInstance.Name)
            if not existingAccessory then
                humanoid:AddAccessory(assetInstance)
                assetInstance:SetAttribute("CustomeId", customizationId)
            else
                existingAccessory:Destroy()
            end
        elseif assetInstance:IsA("Shirt") then
            local shirt = character:FindFirstChild("Shirt") :: Shirt or Instance.new("Shirt")
            shirt.Parent = character
            shirt.ShirtTemplate = assetInstance.ShirtTemplate
        elseif assetInstance:IsA("Pants") then
            local pants = character:FindFirstChild("Pants") :: Pants or Instance.new("Pants")
            pants.Parent = character
            pants.PantsTemplate = assetInstance.PantsTemplate
        end
        asset:Destroy()  
    else
        NetworkUtil.invokeServer(ON_CUSTOMIZE_CHAR, customizationId)
    end 
end

function CustomizationUtil.setDesc(plr : Player, descType : DescType, descName : string)
    if RunService:IsServer() then
        local displayNameGUIName = "DisplayNameGUI"
        local frameName = "Frame"
        local nameTextName = "NameText"
        local biotextName = "BioText"

        local textColor = Color3.fromRGB(255,255,255)

        local character = plr.Character or plr.CharacterAdded:Wait()
        
        local billboardGui = character:FindFirstChild(displayNameGUIName) :: BillboardGui or Instance.new("BillboardGui")
        billboardGui.Name = displayNameGUIName
        billboardGui.ExtentsOffsetWorldSpace = Vector3.new(0,1.25,0)
        billboardGui.Size = UDim2.fromScale(3, 1.5)
        billboardGui.Parent = character
    
        local frame = billboardGui:FindFirstChild(frameName) :: Frame or Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundTransparency = 1
        frame.Name = frameName
        frame.Parent = billboardGui

        local uilistlayout = frame:FindFirstChild("UIListLayout") :: UIListLayout or Instance.new("UIListLayout") 
        uilistlayout.Padding = UDim.new(0, 10)
        uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
        uilistlayout.Parent = frame

        local nameText = frame:FindFirstChild(nameTextName) :: TextLabel or Instance.new("TextLabel")
        nameText.Size = UDim2.fromScale(1,0.4)
        nameText.TextColor3 = textColor
        nameText.TextStrokeTransparency = 0.5
        nameText.TextScaled = true
        nameText.Name =  nameTextName
        nameText.BackgroundTransparency = 1
        nameText.LayoutOrder = 1
        nameText.Parent = frame

        local bioText= frame:FindFirstChild(biotextName) :: TextLabel or Instance.new("TextLabel")
        bioText.Size = UDim2.fromScale(1,0.3)
        bioText.Name = biotextName
        bioText.TextColor3 = textColor
        bioText.TextStrokeTransparency = 0.5
        bioText.TextScaled = true
        bioText.BackgroundTransparency = 1
        bioText.LayoutOrder = 2
        bioText.Parent = frame


        --filters
        local result : TextFilterResult
        local s, e = pcall(function()
            result = TextService:FilterStringAsync(descName, plr.UserId)
        end)
        descName = result:GetNonChatStringForBroadcastAsync()
        if not s or not descName then
            error(e or "Desc name not av")
        end

        if descType == "PlayerName" then
            nameText.Text = descName
        elseif descType == "PlayerBio" then
            bioText.Text = descName
        end
    else
        NetworkUtil.invokeServer(ON_CUSTOMIZE_AVATAR_NAME, descType, descName)
    end
end

function CustomizationUtil.init(maid : Maid)
    if RunService:IsServer() then
        NetworkUtil.onServerInvoke(ON_CUSTOMIZE_CHAR, function(plr : Player, customisationId : number)
            CustomizationUtil.Customize(plr, customisationId)
            return nil
        end)
        NetworkUtil.onServerInvoke(ON_CUSTOMIZE_AVATAR_NAME, function(plr : Player, descType : DescType, descName : string)
            CustomizationUtil.setDesc(plr, descType, descName)
            return nil
        end)
        maid:GiveTask(NetworkUtil.onServerEvent(ON_CHARACTER_APPEARANCE_RESET, function(plr : Player)
            local character = plr.Character or plr.CharacterAdded:Wait()

            local humanoid = character:WaitForChild("Humanoid") :: Humanoid

            local temp_hum_desc = game.Players:GetHumanoidDescriptionFromUserId(1) --gross method/hacky
            local hum_desc = game.Players:GetHumanoidDescriptionFromUserId(plr.UserId)

            if hum_desc then
                humanoid:ApplyDescription(temp_hum_desc)
                humanoid:ApplyDescription(hum_desc)
            end
        end))
    end
end

return CustomizationUtil