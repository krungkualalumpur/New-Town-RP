--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
local CustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"))

--types
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new()

    local onAccessoryTry = maid:GiveTask(Signal.new())
    local onAccessoryDelete = maid:GiveTask(Signal.new())

    --task.spawn(function()
        --print(AvatarEditorService:GetItemDetails(16630147, Enum.AvatarItemType.Asset))
        --local params = CatalogSearchParams.new()
        --params.SearchKeyword = "featured"
        --params.BundleTypes = {Enum.BundleType.Animations}
        
       -- local result = AvatarEditorService:SearchCatalog(params)
        --print(result:GetCurrentPage())
        --local s,e = pcall(function() result:AdvanceToNextPageAsync() end) 
        --if not s and e then warn(e) end 
        --print(result:GetCurrentPage())
   -- end)

    local customizationUI = CustomizationUI(
        maid,

        onAccessoryTry,
        onAccessoryDelete,

        function(param)
            local list = {"All"}
            if param:lower() == "featured" then
            elseif param:lower() == "faces" then
                table.clear(list)
                --local cat = CatalogSearchParams.new()
                --cat.AssetTypes = {Enum.AssetType.DynamicHead}
                table.insert(list, "Classic")
                table.insert(list, "New")
            elseif param:lower() == "clothing" then
                table.insert(list, "Shirts")
                table.insert(list, "Pants")
                table.insert(list, "Jackets")
                table.insert(list, "TShirts")
                table.insert(list, "Shoes")
            elseif param:lower() == "accessories" then
                table.insert(list, "Hats")
                table.insert(list, "Faces")
                table.insert(list, "Necks")
                table.insert(list, "Shoulder")
                table.insert(list, "Front")
                table.insert(list, "Back")
                table.insert(list, "Waist")
            elseif param:lower() == "Hair" then
            elseif param:lower() == "Animation Packs" then               
            end
            return list
        end,

        function(category : string, subCategory : string)
            local params = CatalogSearchParams.new()
            print(subCategory)
            category = category:lower()
            subCategory = subCategory:lower()

            if category == "featured" then
                params.CategoryFilter = Enum.CatalogCategoryFilter.Featured
            elseif category == "faces" then
                params.AssetTypes = {Enum.AvatarAssetType.Face, Enum.AvatarAssetType.FaceAccessory}
                if subCategory == "classic" then
                    params.AssetTypes = {Enum.AvatarAssetType.Face}
                elseif subCategory == "new" then
                    params.SearchKeyword = "3D face";
                    params.AssetTypes = {Enum.AvatarAssetType.FaceAccessory}
                end
            elseif category == "clothing" then
                params.AssetTypes = {
                    Enum.AvatarAssetType.Shirt,
                    Enum.AvatarAssetType.Pants,
                    Enum.AvatarAssetType.TShirt,

                    Enum.AvatarAssetType.JacketAccessory,
                    Enum.AvatarAssetType.ShirtAccessory,
                    Enum.AvatarAssetType.TShirtAccessory,
                    Enum.AvatarAssetType.PantsAccessory,

                    Enum.AvatarAssetType.LeftShoeAccessory,
                    Enum.AvatarAssetType.RightShoeAccessory,
                }
                
                if subCategory == "shirts" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.Shirt,
                        Enum.AvatarAssetType.ShirtAccessory,
                    }
                elseif subCategory == "pants" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.Pants,
                        Enum.AvatarAssetType.PantsAccessory,
                    }
                elseif subCategory == "tshirts" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.TShirt,
                        Enum.AvatarAssetType.TShirtAccessory,
                    }
                elseif subCategory == "jackets" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.JacketAccessory,
                    }
                elseif subCategory == "shoes" then
                    params.SearchKeyword = "Shoes" 
                end
            elseif category == "accessories" then
                params.AssetTypes = {
                    Enum.AvatarAssetType.Hat,
                    Enum.AvatarAssetType.FaceAccessory,
                    Enum.AvatarAssetType.NeckAccessory,
                    Enum.AvatarAssetType.ShoulderAccessory,
                    Enum.AvatarAssetType.FrontAccessory,
                    Enum.AvatarAssetType.BackAccessory,
                    Enum.AvatarAssetType.WaistAccessory
                }
                
                if subCategory == "hats" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.Hat
                    }
                elseif subCategory == "faces" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.FaceAccessory
                    }
                elseif subCategory == "necks" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.NeckAccessory
                    }
                elseif subCategory == "shoulder" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.ShoulderAccessory
                    }
                elseif subCategory == "front" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.FrontAccessory
                    }
                elseif subCategory == "back" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.BackAccessory
                    }
                elseif subCategory == "waist" then
                    params.AssetTypes = {
                        Enum.AvatarAssetType.WaistAccessory
                    }
                end
            elseif category == "hair" then
                params.AssetTypes = {
                    Enum.AvatarAssetType.HairAccessory,
                }
            elseif category == "animation packs" then
                local assetTypes = {
                    Enum.AvatarAssetType.RunAnimation
                }

                for _,v : Enum.AvatarAssetType in pairs(Enum.AvatarAssetType:GetEnumItems()) do
                    if string.find(v.Name:lower(), "animation") then
                        table.insert(assetTypes, v)
                    end
                end

                params.AssetTypes = assetTypes
            end
            local catalogPages = AvatarEditorService:SearchCatalog(params)
            return catalogPages
        end
    )
    customizationUI.Parent = target

    return function()
        maid:Destroy()
    end 
end
