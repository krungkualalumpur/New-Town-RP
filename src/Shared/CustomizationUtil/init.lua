--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

--types
type Maid = Maid.Maid
export type CharacterData = {
    Accessories : {[number] : number},

    Shirt : number,
    Pants : number,
    TShirt : number,
    Face : number,

    Torso : number,
    LeftArm : number,
    RightArm : number,
    LeftLeg : number,
    RightLeg : number,
    Head : number,

    BodyColor : Color3
}

export type DescType = "PlayerName" | "PlayerBio"
export type CharacterInfo = {
    AvatarType : "R6" | "R15" | "RThro"
}

export type InfoFromHumanoidDesc = {
    ["AccessoryType"] : Enum.AccessoryType,
    ["AssetId"] : number,
    ["IsLayered"] : boolean,
    ["Order"] : number ?,
    ["Puffiness"] : number ?
}

export type CatalogInfo = {
    ["Id"] : number,
    ["ItemType"] : string,
    ["AssetType"] : string,
    ["BundleType"] : string,
    ["Name"] : string,
    ["Description"] : string,
    ["ProductId"] : number,
    ["Genres"] : {[number] : string},
    ["BundledItems"]: {
      [number] : {
        ["Owned"] : boolean,
        ["Id"] : string,
        ["Name"] : string,
        ["Type"] : string
      }
    },
    ["ItemStatus"] : {
        [number] : string
    },
    ["ItemRestrictions"] : {
        [number] : string
    },
    ["CreatorType"]: string,
    ["CreatorTargetId"]: number,
    ["CreatorName"] : string,
    ["Price"]: number,
    ["PremiumPricing"] : {
      ["PremiumDiscountPercentage"] : number,
      ["PremiumPriceInRobux"] : number
    },
    ["LowestPrice"] : number,
    ["PriceStatus"]: string,
    ["UnitsAvailableForConsumption"] : number,
    ["PurchaseCount"] : number,
    ["FavoriteCount"] : number,
}

export type SimplifiedCatalogInfo = {
    ["Id"] : number,
    ["ItemType"] : string,
    ["Name"] : string ?,
    ["Price"] : number ?,
    ["CreatorName"] : string ?,
}

--constants
--remotes
local CHARACTER_BUNDLE_ID_ATTRIBUTE_KEY = "BundleId"

local CATALOG_FOLDER_NAME = "CatalogFolder"

local ON_CUSTOMIZE_AVATAR_NAME = "OnCustomizeAvatarName"
local ON_CUSTOMIZE_CHAR = "OnCustomizeCharacter"
local ON_CUSTOMIZE_CHAR_COLOR = "OnCustomizeCharColor"
local ON_DELETE_CATALOG = "OnDeleteCatalog"

local GET_AVATAR_FROM_CHARACTER_DATA = "GetAvatarFromCharacterData"
local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"

--variables
--references
--local cleanHumanoidDesc = Instance.new("HumanoidDescription")
local partHeadTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Others"):WaitForChild("PartHeadTemplate")

--local functions
local function getEnumItemFromName(enum : Enum, enumItemName : string) 
    local enumItem 
    for _, item : EnumItem in pairs(enum:GetEnumItems()) do
        if item.Name == enumItemName then
            enumItem = item
            break
        end
    end
    return enumItem
end

local function getCharacter(fromWorkspace : boolean, plr : Player ?)
    local char 
    if RunService:IsRunning() then 
        if not fromWorkspace then
            char = Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) 
        else
            for _,charModel in pairs(workspace:GetChildren()) do
                local humanoid = charModel:FindFirstChild("Humanoid")
               -- print(charModel:IsA("Model"), humanoid, humanoid and humanoid:IsA("Humanoid"), charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name))
                if charModel:IsA("Model") and humanoid and humanoid:IsA("Humanoid") and charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name) then
                    charModel.Archivable = true
                    char = charModel:Clone()
                    charModel.Archivable = false
                    break
                end
            end
        end
        
    else 
        char = game.ServerStorage.aryoseno11:Clone() 
    end
    
    return char
end


local function getHumanoidDescriptionAccessory(
    assetId : number,
    enumAccessoryType : Enum.AccessoryType,
    isLayered : boolean,
    order : number,
    puffiness : number ?
) : InfoFromHumanoidDesc
    return {AssetId = assetId, AccessoryType = enumAccessoryType, IsLayered = isLayered, Order = order, Puffiness = puffiness}
end


local function importBundle(id) : Model ?
	local folder = Instance.new('Model')
	folder.Name = tostring(id)

	--[[local packageInfo = marketplaceService:GetProductInfo(id)
	folder.Name = packageInfo.Name or tostring(id)
	local assetIds = assetService:GetAssetIdsForPackage(id)]]
	local assetIds = {}
	local bundleDetails 

    local function getBundleDetail()
        local s, e = pcall(function()
            bundleDetails =	AssetService:GetBundleDetailsAsync(id)
        end)
        if not s and e then
            warn("Error loading bundle: " .. e)
        end
    end

    getBundleDetail()

	if not bundleDetails then
        local count = 0
        repeat count += 1; getBundleDetail() until (count >= 15) or (bundleDetails) ~= nil
        if not bundleDetails then
            return nil
        end
	end
	
	if bundleDetails then
		if bundleDetails.Items then
			folder.Name = tostring(id) ..' - ' .. (bundleDetails.Name or '')
			for _,itemData in pairs(bundleDetails.Items) do
				if itemData.Type == "Asset" and itemData.Id then
					table.insert(assetIds, itemData.Id)
				end
			end
		end
	end

	for _, assetId in pairs(assetIds) do
		local assetModel = if RunService:IsClient() then NetworkUtil.invokeServer(GET_CATALOG_FROM_CATALOG_INFO, assetId):Clone() else InsertService:LoadAsset(assetId)
		if assetModel:IsA('Model') then
			local name = tostring(assetId)
			--[[local success2, err = pcall(function()
				local assetInfo = MarketplaceService:GetProductInfo(assetId)
				if assetInfo then

					local typeId = assetInfo.AssetTypeId
					if typeId then
						--name = assetTypeDictionary[typeId] or name
					end
				end
			end)]]
			assetModel.Name = name
		end
		assetModel.Parent = folder
	end
	return folder
end

local function applyBundle(character : Model, bundleFolder : Model)
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid ?
    local humanoidDesc = if humanoid then humanoid:GetAppliedDescription() else nil

    assert(humanoid and humanoidDesc) 
	humanoid:RemoveAccessories() 
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	
	local rigTypeName = humanoid.RigType.Name .. if humanoid.RigType == Enum.HumanoidRigType.R15 then 'Fixed' else ""
	local rigTypeAnimName = humanoid.RigType.Name .. "Anim"

	for _,asset : any in pairs(bundleFolder:GetChildren()) do
		for _,child in pairs(asset:GetChildren()) do
			if child:IsA("Folder") and child.Name == rigTypeName then
				for _, bodyPart in pairs(child:GetChildren()) do
					local old = character:FindFirstChild(bodyPart.Name)
					if old then
						old:Destroy()
					end
					bodyPart.Parent = character
					humanoid:BuildRigFromAttachments()
				end
			elseif child:IsA("Accessory") or child:IsA("CharacterAppearance") or child:IsA("Tool") then
				child.Parent = character
			elseif child:IsA("Decal") and (child.Name == 'face' or child.Name == 'Face') then
				local head = character:FindFirstChild('Head')
				if head then
					for _,headChild in pairs(head:GetChildren()) do
						if headChild and (headChild.Name == 'face' or headChild.Name == 'Face') then
							headChild:Destroy()
						end
					end
					child.Parent = head
				end
			elseif child:IsA('SpecialMesh') then
				local head = character:FindFirstChild('Head')
				if head then
					if head:IsA('MeshPart') then
						-- Replace meshPart with a head part
						local newHead = partHeadTemplate:clone()
						newHead.Name = 'Head'
						newHead.Color = head.Color
						for _,v in pairs(head:GetChildren()) do
							if v:IsA('Decal') then
								v.Parent = newHead
							end
						end

						head:Destroy()
						newHead.Parent = character
						humanoid:BuildRigFromAttachments()
						head = newHead
					end
					for _,headChild in pairs(head:GetChildren()) do
						if headChild and headChild:IsA('SpecialMesh') then
							headChild:Destroy()
						end
					end
					child.Parent = head
				end
            elseif child.Name == rigTypeAnimName then --todo: handle animations

                for _,animVal : Instance in pairs(child:GetChildren()) do
                    local animType = animVal.Name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end :: (string) -> string) .. "Animation" 
            
                    local animation = animVal:GetChildren()[1] 
                    if animation:IsA("Animation") then
                        --if animType == "RunAnimation" then 
                        local s, e = pcall(function() humanoidDesc[animType] = tonumber(asset.Name:match("%d+")) end) --hacky way to bypass the tedious properties conditions
                        if not s and type(e) == "string" then warn("Error in loading animation: " .. e) end
                    end

                end


			--else
				--print('Not sure what to do with this class:', child.ClassName)
			end
			
		end
	end

	humanoid:BuildRigFromAttachments()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    if RunService:IsServer() then humanoid:ApplyDescription(humanoidDesc) end
end

local function applyBundleByHumanoidDescription(character : Model, bundleId : number, customizeFn : (id : number, passedItemType : Enum.AvatarItemType, character : Model, passedAssetTypeId : number?, isDelete : boolean) -> ())
    local bundleDetails 
    local function getBundleDetail()
        local s, e = pcall(function() 
            bundleDetails =	AssetService:GetBundleDetailsAsync(bundleId)
        end)
        if not s and e then
            warn("Error loading bundle: " .. e)
        end
    end

    getBundleDetail()

	if not bundleDetails then
        local count = 0
        repeat count += 1; getBundleDetail() until (count >= 15) or (bundleDetails) ~= nil
        if not bundleDetails then
            return nil
        end
	end

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid 
    --local humanoidDesc = humanoid:GetAppliedDescription()

    for _,itemDetails in pairs(bundleDetails.Items) do
        print(itemDetails)
        if itemDetails.Type == "Asset" and itemDetails.Id then
            customizeFn(itemDetails.Id, Enum.AvatarItemType.Asset, character, nil, false)
        end
    end

    return
end

local function weldAttachments(attach1 : Attachment, attach2 : Attachment)
    if (attach1.Parent and attach1.Parent:IsA("BasePart")) and  (attach2.Parent and attach2.Parent:IsA("BasePart")) then
        local weld = Instance.new("Weld")
        weld.Part0 = attach1.Parent
        weld.Part1 = attach2.Parent
        weld.C0 = attach1.CFrame
        weld.C1 = attach2.CFrame
        weld.Parent = attach1.Parent
        return weld
    end
    error("Bad attachment parents")
end
 
local function buildWeld(weldName, parent, part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Name = weldName
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = parent
    return weld
end
 
local function findFirstMatchingAttachment(model : Model, name) : Attachment ?
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("Attachment") and child.Name == name then
            return child
        elseif not child:IsA("Accoutrement") and not child:IsA("Tool") then -- Don't look in hats or tools in the character
            local foundAttachment = findFirstMatchingAttachment(child :: Model, name)
            if foundAttachment then
                return foundAttachment
            end
        end
    end
    return nil
end
 
local function addAccoutrement(character : Model, accoutrement : Accessory)  
    accoutrement.Parent = character
    local handle = accoutrement:FindFirstChild("Handle") :: BasePart
    if handle then
        local accoutrementAttachment = handle:FindFirstChildOfClass("Attachment")
        if accoutrementAttachment then
            local characterAttachment = findFirstMatchingAttachment(character, accoutrementAttachment.Name)
            if characterAttachment then
                weldAttachments(characterAttachment, accoutrementAttachment)
            end
        else
            local head = character:FindFirstChild("Head") :: BasePart
            if head then
                local attachmentCFrame = CFrame.new(0, 0.5, 0)
                local hatCFrame = accoutrement.AttachmentPoint
                buildWeld("HeadWeld", head, head, handle, attachmentCFrame, hatCFrame)
            end
        end
    end
end

local function processingHumanoidDescById(id : number, passedItemType : Enum.AvatarItemType, character : Model, passedAssetTypeId : number?, isDelete : boolean)
    local function getInfo(passedId : number, passedItemType : Enum.AvatarItemType) : (any, Enum.InfoType)
        local info , infoType = nil, if (passedItemType == Enum.AvatarItemType.Asset) then Enum.InfoType.Asset elseif (passedItemType == Enum.AvatarItemType.Bundle) then Enum.InfoType.Bundle else nil
        print(passedItemType, passedItemType == Enum.AvatarItemType.Asset, passedItemType == Enum.AvatarItemType.Bundle)

        local s,e = pcall(function() 
            info = MarketplaceService:GetProductInfo(passedId, infoType) 
            --InsertService:LoadAsset(id):Destroy() 
        end)
        --if not s and e then
        --    infoType = Enum.InfoType.Bundle
        --    s, e = pcall(function() info = MarketplaceService:GetProductInfo(id, infoType) end)
            --print("now its bundle toip")
       -- end
        if not s and e then
            warn ("unable to load the catalog info by the given id: " .. tostring(e))
            return info, Enum.InfoType.Asset
        end
        assert(infoType, "Unable to find the infotype by the item type")
        return info, infoType
    end
    
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local humanoidDesc = if humanoid then humanoid:GetAppliedDescription() else nil

    if humanoidDesc then
        local accessories = humanoidDesc:GetAccessories(true)
        
        --sorting out orders
        local function sortAccessoryOrder()
            for k,v in pairs(accessories) do
                accessories[k].IsLayered = true
                if not v.Order then
                    accessories[k].Order = math.clamp(k - 1, 0, math.huge)
                end
            end
        end

        local function hasAccessory(id : number) : InfoFromHumanoidDesc ?
            for _,v in pairs(accessories) do 
                if v.AssetId == id then
                    return v
                end
            end
            return nil
        end

        sortAccessoryOrder()

        local passedInfo, passedInfoType = getInfo(id, passedItemType)
        local assetTypeId = if passedInfo then passedInfo.AssetTypeId else passedAssetTypeId
        if passedInfoType == Enum.InfoType.Asset then
            local ownedCurrentAccessory = hasAccessory(id)
            if not ownedCurrentAccessory and passedInfo then -- and pls check if its accesssory or non accessory stuff...
                local desiredOrder = #accessories
                if assetTypeId == Enum.AssetType.Hat.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Hat, true, desiredOrder)) --islayered for accessoreis true but false for shirts etc!!
                    --humanoidDesc.HatAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.HairAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Hair, true, desiredOrder)) 
                    --humanoidDesc.HairAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.FaceAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Face, true, desiredOrder)) 
                    --humanoidDesc.FaceAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.BackAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Back, true, desiredOrder)) 
                    --humanoidDesc.BackAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.NeckAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Neck, true, desiredOrder)) 
                    --humanoidDesc.NeckAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.FrontAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Front, true, desiredOrder)) 
                    --humanoidDesc.FrontAccessory = "rbxassetid://" .. tostring(customizationId)
                elseif assetTypeId == Enum.AssetType.WaistAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Waist, true, desiredOrder)) 
                    --humanoidDesc.WaistAccessory = "rbxassetid://" .. tostring(customizationId)

                elseif assetTypeId == Enum.AssetType.ShirtAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Shirt, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.PantsAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Pants, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.TShirtAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.TShirt, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.DressSkirtAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.DressSkirt, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.EyebrowAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Eyebrow, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.EyelashAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Eyelash, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.ShortsAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Shorts, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.ShoulderAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Shoulder, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.LeftShoeAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.LeftShoe, true, desiredOrder)) 
                elseif assetTypeId == Enum.AssetType.RightShoeAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.RightShoe, true, desiredOrder))
                elseif assetTypeId == Enum.AssetType.JacketAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Jacket, true, desiredOrder))
                elseif assetTypeId == Enum.AssetType.SweaterAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Sweater, true, desiredOrder))
                elseif assetTypeId == Enum.AssetType.NeckAccessory.Value then
                    table.insert(accessories, getHumanoidDescriptionAccessory(id, Enum.AccessoryType.Neck, true, desiredOrder))
                end
            elseif ownedCurrentAccessory and passedInfo and isDelete then
                table.remove(accessories, table.find(accessories, ownedCurrentAccessory))
                sortAccessoryOrder()
            end

            local modifiedIdFromIsDelete = if not isDelete then id else 0
            if assetTypeId == Enum.AssetType.Shirt.Value then
                humanoidDesc.Shirt = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.Pants.Value then
                humanoidDesc.Pants = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.TShirt.Value then
                humanoidDesc.GraphicTShirt = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.Torso.Value then
                humanoidDesc.Torso = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.Face.Value then
                humanoidDesc.Face = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.LeftArm.Value then
                humanoidDesc.LeftArm = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.RightArm.Value then
                humanoidDesc.RightArm = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.LeftLeg.Value then
                humanoidDesc.LeftLeg = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.RightLeg.Value then
                humanoidDesc.RightLeg = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.Head.Value then
                humanoidDesc.Head = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.DynamicHead.Value then
                humanoidDesc.Head = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.RunAnimation.Value then
                humanoidDesc.RunAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.FallAnimation.Value then
                humanoidDesc.FallAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.IdleAnimation.Value then
                humanoidDesc.IdleAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.JumpAnimation.Value then
                humanoidDesc.JumpAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.MoodAnimation.Value then
                humanoidDesc.MoodAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.SwimAnimation.Value then
                humanoidDesc.SwimAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.WalkAnimation.Value then
                humanoidDesc.WalkAnimation = modifiedIdFromIsDelete
            elseif assetTypeId == Enum.AssetType.ClimbAnimation.Value then 
                humanoidDesc.ClimbAnimation = modifiedIdFromIsDelete
            end
 
            humanoidDesc:SetAccessories(accessories, true)
            --humanoid:ApplyDescription(cleanHumanoidDesc)
            humanoid:ApplyDescription(humanoidDesc)
        elseif passedInfoType == Enum.InfoType.Bundle and passedInfo then
            --[[local function getHumanoidDescriptionBundle(bundleId)
                local function getOutfitId()
                    if bundleId <= 0 then
                        return nil
                    end
                    local info = game.AssetService:GetBundleDetailsAsync(bundleId)
                    if not info then
                        return nil
                    end
                    for _,item in pairs(info.Items) do
                        if item.Type == "UserOutfit" then
                            return item.Id
                        end
                    end 
                    return nil
                end
                local itemId = getOutfitId()
                return if (itemId and itemId > 0) then game.Players:GetHumanoidDescriptionFromOutfitId(itemId) else nil
            end]]

            --local newHumanoidDesc = getHumanoidDescriptionBundle(id)
            
            --the recent correct versi...
            --[[local bundleFolder = importBundle(id)
            if bundleFolder then  applyBundle(character, bundleFolder) end
            humanoid = character:WaitForChild("Humanoid") :: Humanoid
            local newHumanoidDesc = humanoid:GetAppliedDescription()
            newHumanoidDesc:SetAccessories(accessories, true)
            print(accessories, newHumanoidDesc:GetAccessories(true))
            if not humanoid:IsDescendantOf(game) then
                humanoid.AncestryChanged:Wait()
            end
            humanoid:ApplyDescription(newHumanoidDesc)]]

            applyBundleByHumanoidDescription(character, id, processingHumanoidDescById)

            --if passedInfo.Items then
                --for _,v : {Id : number, Name : string, Type : string} in pairs(passedInfo.Items) do
                    --print(v.Name, ' konuull')
                    --local bundleItemType = getEnumItemFromName(Enum.AvatarItemType, v.Type)
                    --processingHumanoidDescById(v.Id, bundleItemType :: Enum.AvatarItemType)
            -- end 
            --end

            --CustomizationUtil.ApplyBundleFromId(character, customizationId)
        end
    end
end

local function adjustCharacterColorByCharacterData(character : Model, characterData : CharacterData)
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid ?
    local humanoidDesc = if humanoid then humanoid:GetAppliedDescription() else nil
    local color = characterData.BodyColor

    if humanoid and humanoidDesc then
        humanoidDesc.HeadColor = color
        humanoidDesc.TorsoColor = color
        humanoidDesc.LeftArmColor = color
        humanoidDesc.LeftLegColor = color
        humanoidDesc.RightArmColor = color
        humanoidDesc.RightLegColor = color

        humanoid:ApplyDescription(humanoidDesc)
    end
end

local function getCatalogFolder()
    local catalogFolder = ReplicatedStorage:FindFirstChild(CATALOG_FOLDER_NAME) :: Folder or Instance.new("Folder")
    catalogFolder.Name = CATALOG_FOLDER_NAME
    catalogFolder.Parent = ReplicatedStorage
    return catalogFolder
end
--class
local CustomizationUtil = {}

function CustomizationUtil.getBundleIdFromCharacter(char : Model) : number
    return char:GetAttribute(CHARACTER_BUNDLE_ID_ATTRIBUTE_KEY) or 0 
end

function CustomizationUtil.getAccessoryId(accessory : Accessory) : number
    return accessory:GetAttribute("CustomeId")
end

function CustomizationUtil.getAssetImageFromId(id : number, isBundle : boolean, width : number ?, height : number ?)
    local Width = width or 150
    local Height = height or 150
    return if not isBundle then
        "https://www.roblox.com/Thumbs/Asset.ashx?width=".. tostring(Width).."&height=".. tostring(Height) .."&assetId=".. tostring(id)
    else
        "rbxthumb://type=BundleThumbnail&id=" .. id .. "&w=" .. tostring(Width) .."&h=" .. tostring(Height)
end

function CustomizationUtil.getFaceTextureFromChar(character : Model)
    local head = character:FindFirstChild("Head") :: BasePart or nil
    local face = if head then head:FindFirstChild("face") :: Decal else nil
    if face then 
        return face.Texture
    end
    error("Unable to find face on the character")
end

function CustomizationUtil.setCustomeFromTemplateId(plr  : Player, customeType : "Shirt" | "Pants" | "Face", customId : number)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local shirt = char:WaitForChild("Shirt", 5) :: Shirt or Instance.new("Shirt")
    local pants = char:WaitForChild("Pants", 5) :: Pants or Instance.new("Pants")

    shirt.Parent = char
    pants.Parent = char

    local head = char:WaitForChild("Head", 5) :: BasePart or nil
    local face = if head then (head:WaitForChild("face", 5) or Instance.new("Decal")) :: Decal else nil
    if face then face.Parent = head end

    if customeType == "Shirt" then
        shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. tostring(customId)
    elseif customeType == "Pants" then
        pants.PantsTemplate = "http://www.roblox.com/asset/?id=" .. tostring(customId)
    elseif customeType == "Face" then
        if face then
            face.Texture = "http://www.roblox.com/asset/?id=" .. tostring(customId)
        end
    end
end

function CustomizationUtil.ApplyBundleFromId(character : Model, id : number)
    local bundleFolder = importBundle(id)
    if bundleFolder then  applyBundle(character, bundleFolder) end
end

function CustomizationUtil.GetInfoFromCharacter(character :Model) : CharacterData
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local humanoidDesc = humanoid:GetAppliedDescription()

    local accessoryIds = {}
    for _,v in pairs(humanoidDesc:GetAccessories(true)) do
        table.insert(accessoryIds, v.AssetId)
    end

    return {
        Accessories = accessoryIds,

        Shirt = humanoidDesc.Shirt,
        Pants = humanoidDesc.Pants,
        TShirt = humanoidDesc.GraphicTShirt,
        Face = humanoidDesc.Face,

        Torso = humanoidDesc.Torso,
        LeftArm = humanoidDesc.LeftArm,
        RightArm = humanoidDesc.RightArm,
        LeftLeg = humanoidDesc.LeftLeg,
        RightLeg = humanoidDesc.RightLeg,
        Head = humanoidDesc.Head,

        BodyColor = humanoidDesc.HeadColor
    }
end

function CustomizationUtil.SetInfoFromCharacter(character : Model, characterData : CharacterData)    
    for _,accessoryId in pairs(characterData.Accessories) do
        processingHumanoidDescById(accessoryId, Enum.AvatarItemType.Asset, character, nil, false)
    end
    processingHumanoidDescById(characterData.Face, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.Face.Value, false)
    processingHumanoidDescById(characterData.Head, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.Head.Value, false)
    processingHumanoidDescById(characterData.LeftArm, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.LeftArm.Value, false)
    processingHumanoidDescById(characterData.LeftLeg, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.LeftLeg.Value, false)
    processingHumanoidDescById(characterData.Pants, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.Pants.Value, false)
    processingHumanoidDescById(characterData.RightArm, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.RightArm.Value, false)
    processingHumanoidDescById(characterData.RightLeg, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.RightLeg.Value, false)
    processingHumanoidDescById(characterData.Shirt, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.Shirt.Value, false)
    processingHumanoidDescById(characterData.TShirt, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.TShirt.Value, false)
    processingHumanoidDescById(characterData.Torso, Enum.AvatarItemType.Asset, character, Enum.AvatarAssetType.Torso.Value, false)

    adjustCharacterColorByCharacterData(character, characterData)
    return
end

function CustomizationUtil.Customize(plr : Player, customizationId : number, itemType : Enum.AvatarItemType, assetTypeId : number ?)
    if RunService:IsServer() then
        local character = plr.Character or plr.CharacterAdded:Wait()

        processingHumanoidDescById(customizationId, itemType, character, assetTypeId, false)        
    else
        NetworkUtil.invokeServer(ON_CUSTOMIZE_CHAR, customizationId, itemType)
    end 
end

function CustomizationUtil.CustomizeBodyColor(plr : Player, color : Color3)
    if RunService:IsServer() then
        local character = plr.Character or plr.CharacterAdded:Wait()

        local characterData = CustomizationUtil.GetInfoFromCharacter(character)
        characterData.BodyColor = color
        adjustCharacterColorByCharacterData(character, characterData)
    else
        NetworkUtil.invokeServer(ON_CUSTOMIZE_CHAR_COLOR, color)
    end
    
    return
end

function CustomizationUtil.DeleteCatalog(plr : Player, customizationId : number, itemType : Enum.AvatarItemType, assetTypeId : number ?)
    if RunService:IsServer() then
        local character = plr.Character or plr.CharacterAdded:Wait()
        processingHumanoidDescById(customizationId, itemType, character, assetTypeId, true)
    elseif RunService:IsClient() then
        NetworkUtil.invokeServer(ON_DELETE_CATALOG, customizationId, itemType)
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

function CustomizationUtil.getCustomizationDataById(id : number) : CustomizationList.Customization ?
    for _,v in pairs(CustomizationList) do
        if v.TemplateId == id then
            return v
        end
    end
    return nil
end

function CustomizationUtil.GetAvatarFromCatalogInfo(catalogInfo : SimplifiedCatalogInfo)
    local previewChar = getCharacter(true)
    if previewChar then
        local humanoid = previewChar:FindFirstChild("Humanoid") :: Humanoid ?
        if humanoid then
            
            local asset
            local s, e = pcall(function() asset = if RunService:IsRunning() and RunService:IsClient() then NetworkUtil.invokeServer(GET_CATALOG_FROM_CATALOG_INFO, catalogInfo.Id):Clone() else game:GetService("InsertService"):LoadAsset(catalogInfo.Id) end)
    
            local marketInfo  
            local s2, e2 = pcall(function()
                marketInfo = game:GetService("MarketplaceService"):GetProductInfo(catalogInfo.Id, if catalogInfo.ItemType == "Asset" then Enum.InfoType.Asset elseif catalogInfo.ItemType == "Bundle" then Enum.InfoType.Bundle else nil)
            end) 
            local catalogModel
            if s and not e then
                catalogModel = asset:GetChildren()[1] :: Accessory ?
                if catalogModel then
                    previewChar:PivotTo(CFrame.new())
                    --print(previewChar, " hossen!! ")
                    if catalogModel:IsA("Accessory") then
                        addAccoutrement(previewChar :: Model, catalogModel)
                    elseif  catalogModel:IsA("Shirt") then
                        local shirt = previewChar:FindFirstChild("Shirt") :: Shirt or Instance.new("Shirt")
                        shirt.ShirtTemplate = catalogModel.ShirtTemplate
                        shirt.Parent = previewChar
                    elseif catalogModel:IsA("Pants") then
                        local pants = previewChar:FindFirstChild("Pants") :: Pants or Instance.new("Pants")
                        pants.PantsTemplate = catalogModel.PantsTemplate
                        pants.Parent = previewChar
                    elseif catalogModel:IsA("Decal")  then
                        local head = previewChar:WaitForChild("Head", 5) :: BasePart or nil
                        local face = if head then (head:WaitForChild("face", 5) or Instance.new("Decal")) :: Decal else nil
                        if face then 
                            previewChar:PivotTo(CFrame.new(0, -1.5, -2.5))
                            face.Parent = head 
                            face.Texture = catalogModel.Texture
                        end
                    end
                    -- print(catalogModel:FindFirstChild("AccessoryWeld").C0, catalogModel:FindFirstChild("AccessoryWeld").C1)   
                end 
            end

            if marketInfo then
                if marketInfo.BundleType == Enum.BundleType.Animations.Name and marketInfo.Items then
                    for _,item : {Id : number, Name : string, Type : string} in pairs(marketInfo.Items) do
                        if item.Id then
                            if item.Name:lower():find("idle") then
                                local animator = humanoid:FindFirstChild("Animator") :: Animator
                                local anim = Instance.new("Animation")
                                anim.AnimationId = "rbxassetid://" .. tostring(item.Id)
                                animator:LoadAnimation(anim)
                            end
                        end
                    end 
                elseif marketInfo.BundleType == Enum.BundleType.BodyParts.Name and marketInfo.Items then
                    CustomizationUtil.ApplyBundleFromId(previewChar, catalogInfo.Id)
                end
                if marketInfo.AssetTypeId then
                    for _,enum : EnumItem in pairs(Enum.AvatarAssetType:GetEnumItems()) do
                        if enum.Name:lower():find("animation") and (enum.Value == marketInfo.AssetTypeId) then
                            local animator = humanoid:FindFirstChild("Animator") :: Animator
                            local anim = Instance.new("Animation")
                            anim.AnimationId = "rbxassetid://" .. tostring(catalogInfo.Id)
                            animator:LoadAnimation(anim)
                        end
                    end
                end
            -- catalogInfo.
            end
        end
    end
    return previewChar
end

function CustomizationUtil.getAvatarPreviewByCharacterData(characterData : CharacterData)
    if RunService:IsServer() then
        local character = Players:CreateHumanoidModelFromUserId(1)
       --[[ local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local rigTypeName = humanoid.RigType.Name .. if humanoid.RigType == Enum.HumanoidRigType.R15 then 'Fixed' else ""
    	local rigTypeAnimName = humanoid.RigType.Name .. "Anim"

        --clear up int accessories
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("Accessory") then
                v:Destroy()
            end
        end

        for _,accessoryId in pairs(characterData.Accessories) do
            local asset = InsertService:LoadAsset(accessoryId)
            asset.Parent = character
        end

        for propertyIndex, propertyValue in pairs(characterData) do
            if type(propertyValue) == "number" then
                local asset = InsertService:LoadAsset(propertyValue)

                for _,child in pairs(asset:GetChildren()) do
                    if child:IsA("Folder") and child.Name == rigTypeName then
                        for _, bodyPart in pairs(child:GetChildren()) do
                            local old = character:FindFirstChild(bodyPart.Name)
                            if old then
                                old:Destroy()
                            end
                            bodyPart.Parent = character
                            humanoid:BuildRigFromAttachments()
                        end
                    elseif child:IsA("Accessory") or child:IsA("CharacterAppearance") or child:IsA("Tool") then
                        child.Parent = character
                    elseif child:IsA("Decal") and (child.Name == 'face' or child.Name == 'Face') then
                        local head = character:FindFirstChild('Head')
                        if head then
                            for _,headChild in pairs(head:GetChildren()) do
                                if headChild and (headChild.Name == 'face' or headChild.Name == 'Face') then
                                    headChild:Destroy()
                                end
                            end
                            child.Parent = head
                        end
                    elseif child:IsA('SpecialMesh') then
                        local head = character:FindFirstChild('Head')
                        if head then
                            if head:IsA('MeshPart') then
                                -- Replace meshPart with a head part
                                local newHead = partHeadTemplate:clone()
                                newHead.Name = 'Head'
                                newHead.Color = head.Color
                                for _,v in pairs(head:GetChildren()) do
                                    if v:IsA('Decal') then
                                        v.Parent = newHead
                                    end
                                end
        
                                head:Destroy()
                                newHead.Parent = character
                                humanoid:BuildRigFromAttachments()
                                head = newHead
                            end
                            for _,headChild in pairs(head:GetChildren()) do
                                if headChild and headChild:IsA('SpecialMesh') then
                                    headChild:Destroy()
                                end
                            end
                            child.Parent = head
                        end
                    elseif child.Name == rigTypeAnimName then --todo: handle animations
        
                        for _,animVal : Instance in pairs(child:GetChildren()) do
                            local animType = animVal.Name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end :: (string) -> string) .. "Animation" 
                    
                            local animation = animVal:GetChildren()[1] 
                            if animation:IsA("Animation") then
                                --if animType == "RunAnimation" then 
                                local s, e = pcall(function() humanoidDesc[animType] = tonumber(asset.Name:match("%d+")) end) --hacky way to bypass the tedious properties conditions
                                if not s and type(e) == "string" then warn("Error in loading animation: " .. e) end
                            end
        
                        end
        
        
                    --else
                        --print('Not sure what to do with this class:', child.ClassName)
                    end
                end
            end
        end
        
        humanoid:BuildRigFromAttachments()]]
        character.Parent = getCatalogFolder()
        CustomizationUtil.SetInfoFromCharacter(character, characterData)
        return character
    else
        if RunService:IsRunning() then
            return NetworkUtil.invokeServer(GET_AVATAR_FROM_CHARACTER_DATA, characterData):Clone()
        end
    end
    return nil
end

return CustomizationUtil