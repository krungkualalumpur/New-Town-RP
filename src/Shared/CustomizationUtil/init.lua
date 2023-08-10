--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
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
local ON_CUSTOMIZE_CHAR = "OnCustomizeCharacter"
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

function CustomizationUtil.setDesc(plr : Player, descType : DescType)
    if descType == "PlayerName" then
        
    elseif descType == "PlayerBio" then
        
    end
end

function CustomizationUtil.init(maid : Maid)
    if RunService:IsServer() then
        NetworkUtil.onServerInvoke(ON_CUSTOMIZE_CHAR, function(plr : Player, customisationId : number)
            CustomizationUtil.Customize(plr, customisationId)
            return nil
        end)
    end
end

return CustomizationUtil