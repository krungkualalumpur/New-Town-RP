--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
local CustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("NewCustomizationUI"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new()

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local onCatalogTry = maid:GiveTask(Signal.new())
    local onColorCustomize = maid:GiveTask(Signal.new())
    local onCatalogDelete = maid:GiveTask(Signal.new())
    local onCatalogBuy = maid:GiveTask(Signal.new())

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
    local onCharacterReset = maid:GiveTask(Signal.new())

    local onScaleChange = maid:GiveTask(Signal.new())
    local onScaleConfirmChange = maid:GiveTask(Signal.new())

    local onRPNameChange = maid:GiveTask(Signal.new())
    local onDescChange = maid:GiveTask(Signal.new())

    local charSaveExample = game:GetService("ServerStorage"):WaitForChild("aryoseno11") :: Model

    local onCustomizationSave = maid:GiveTask(Signal.new())
    local onSavedCustomizationLoad = maid:GiveTask(Signal.new())
    local onSavedCustomizationDelete = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local saves = _Value({
        [1] = CustomizationUtil.GetInfoFromCharacter(charSaveExample:Clone())
    })

    task.spawn(function()
        task.wait(10)
        saves:Set({
            [1] = CustomizationUtil.GetInfoFromCharacter(charSaveExample:Clone())
            
        })
    end) 

    local isVisible = _Value(true)

    local customizationUI = CustomizationUI(
        maid,

        onCatalogTry,
        onColorCustomize,
        onCatalogDelete,
        onCatalogBuy,
        onCustomizationSave,
        onSavedCustomizationLoad,
        onSavedCustomizationDelete,

        onCharacterReset,

        onScaleChange,
        onScaleConfirmChange,

        onRPNameChange,
        onDescChange,

        onBack,
        saves,
 
        function(param)
            local list = {"All"}
            if param:lower() == "featured" then
            elseif param:lower() == "faces" then
                table.clear(list)
                --local cat = CatalogSearchParams.new()
                --cat.AssetTypes = {Enum.AssetType.DynamicHead}
                table.insert(list, "Classic")
                table.insert(list, "3D")
                table.insert(list, "Dynamic")
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
            elseif param:lower() == "packs" then 
                table.insert(list, "Animation Packs")
                table.insert(list, "Emotes")
                table.insert(list, "Bundles")
            end
            return list
        end,

        function(
            category : string, 
            subCategory : string,
            keyWord : string,

            catalogSortType : Enum.CatalogSortType ?, 
            catalogSortAggregation : Enum.CatalogSortAggregation ?, 
            creatorType : Enum.CreatorType ?,

            minPrice : number ?,
            maxPrice : number ?
        )
            keyWord = " " .. keyWord

            local params = CatalogSearchParams.new()
            params.SortType = catalogSortType or params.SortType
            params.SortAggregation = catalogSortAggregation or params.SortAggregation
            params.IncludeOffSale = false
            params.MinPrice = minPrice or params.MinPrice
            params.MaxPrice = maxPrice or params.MaxPrice

            print(params.SortAggregation, catalogSortAggregation)
            category = category:lower()
            subCategory = subCategory:lower()

            if category == "featured" then
                params.CategoryFilter = Enum.CatalogCategoryFilter.Featured
            elseif category == "faces" then
                params.AssetTypes = {Enum.AvatarAssetType.Face, Enum.AvatarAssetType.FaceAccessory}
                if subCategory == "classic" then
                    params.AssetTypes = {Enum.AvatarAssetType.Face}
                elseif subCategory == "3d" then
                    params.SearchKeyword = "3D face";
                    params.AssetTypes = {Enum.AvatarAssetType.FaceAccessory} 
                elseif subCategory == "dynamic" then
                    params.AssetTypes = {} 
                    params.BundleTypes = {Enum.BundleType.DynamicHead}
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
                    params.BundleTypes = {
                        Enum.BundleType.Shoes,
                    }
                    params.AssetTypes = {}
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
            elseif category == "packs" then
                local assetTypes = {}

                for _,v : Enum.AvatarAssetType in pairs(Enum.AvatarAssetType:GetEnumItems()) do
                    if string.find(v.Name:lower(), "animation") then
                        table.insert(assetTypes, v)
                    end
                end
                
                params.AssetTypes = assetTypes
                params.BundleTypes = {Enum.BundleType.Animations, Enum.BundleType.BodyParts}

                if subCategory == "animation packs" then
                    params.AssetTypes = {}
                    params.BundleTypes = {Enum.BundleType.Animations}
                elseif subCategory == "emotes" then
                    params.AssetTypes = assetTypes
                    params.BundleTypes = {}
                elseif subCategory == "bundles" then
                    params.AssetTypes = {}
                    params.BundleTypes = {Enum.BundleType.BodyParts}
                end
            end

            params.SearchKeyword = params.SearchKeyword .. keyWord

            local catalogPages 
            local function getCatalogPages()
                local s, e = pcall(function() 
                    catalogPages = AvatarEditorService:SearchCatalog(params) 
                end) 
                return s,e
            end
            local s, e =  getCatalogPages()
            if not s and type(e) == "string" then
                warn("Error: " .. e)
                return catalogPages
            end            

            return catalogPages
        end,
        function(avatarAssetType : Enum.AvatarAssetType, itemTypeName : string, id : number)
            local recommendeds =  AvatarEditorService:GetRecommendedAssets(avatarAssetType, id)
            local catalogInfos = {}

            for _,v in pairs(recommendeds) do
                local SimplifiedCatalogInfo : CustomizationUtil.SimplifiedCatalogInfo = {} :: any
                SimplifiedCatalogInfo.Id = v.Item.AssetId
                SimplifiedCatalogInfo.Name = v.Item.Name
                SimplifiedCatalogInfo.ItemType = itemTypeName
                SimplifiedCatalogInfo.CreatorName = v.Creator.Name
                SimplifiedCatalogInfo.Price = v.Product.PriceInRobux
                table.insert(catalogInfos, SimplifiedCatalogInfo)
            end
          
            return catalogInfos
        end,
        isVisible
    )
    customizationUI.Parent = target

    maid:GiveTask(onCatalogTry:Connect(function(catalogInfo : CustomizationUI.SimplifiedCatalogInfo)
        print(catalogInfo.Id, " test try?")
    end))

    maid:GiveTask(onColorCustomize:Connect(function(color : Color3, char : ValueState<Model>)
        print(color, " on color customize")
    end))

    maid:GiveTask(onCatalogDelete:Connect(function(catalogInfo : CustomizationUI.SimplifiedCatalogInfo)
        print(catalogInfo.Id, " on delete")
    end))

    maid:GiveTask(onCatalogBuy:Connect(function(catalogInfo : CustomizationUI.SimplifiedCatalogInfo)
        print(catalogInfo.Id, " on catalog buy")
    end))

    maid:GiveTask(onCustomizationSave:Connect(function()
        print(" on save")
    end))
    maid:GiveTask(onSavedCustomizationLoad:Connect(function(k, content)
        print(k, content, " on load")
    end))
    maid:GiveTask(onSavedCustomizationDelete:Connect(function(k, content)
        print(k, content, " on delete")
    end))
    maid:GiveTask(onCharacterReset:Connect(function()
        print("Reset Character")
    end))


    maid:GiveTask(onRPNameChange:Connect(function(inputted : string)
        print("On RP Change :", inputted)
    end))
    maid:GiveTask(onDescChange:Connect(function(inputted : string)
        print("On Desc change :", inputted)
    end))

    return function()
        isVisible:Set(false)
        maid:Destroy()
    end 
end
