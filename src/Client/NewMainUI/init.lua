--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting =  game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("BackpackUI"))
local RoleplayUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("RoleplayUI"))
local NewCustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("NewCustomizationUI"))
local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local HouseUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("HouseUI"))
local VehicleUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("VehicleUI"))
local OwnershipUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("OwnershipUI"))
local ColorWheel = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColorWheel"))

local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))
local StatusUtil = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("StatusUtil"))

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))

local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
local CustomEnums = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))

local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type UIStatus = StatusUtil.UIStatus
type ToolData = BackpackUtil.ToolData<boolean>
export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}
type AnimationInfo = {
    Name : string,
    AnimationId : string
}

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
--constants
local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 42, 42)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)

local TEXT_COLOR = Color3.fromRGB(255,255,255)

local PADDING_SIZE = UDim.new(0,15)

local DAY_VALUE_KEY = "DayValue"

--remotes
local GET_PLAYER_BACKPACK = "GetPlayerBackpack"

local GET_CHARACTER_SLOT = "GetCharacterSlot"
local SAVE_CHARACTER_SLOT = "SaveCharacterSlot"
local LOAD_CHARACTER_SLOT = "LoadCharacterSlot"
local DELETE_CHARACTER_SLOT = "DeleteCharacterSlot"

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"
local ON_JOB_CHANGE = "OnJobChange"
local ON_ITEM_THROW = "OnItemThrow"

local ON_ROLEPLAY_BIO_CHANGE = "OnRoleplayBioChange"

local ON_AVATAR_ANIMATION_SET = "OnAvatarAnimationSet"
local ON_AVATAR_RAW_ANIMATION_SET = "OnAvatarRawAnimationSet"
local GET_CATALOG_FROM_CATALOG_INFO = "GetCatalogFromCatalogInfo"

local ON_HOUSE_CHANGE_COLOR = "OnHouseChangeColor"
local ON_VEHICLE_CHANGE_COLOR = "OnVehicleChangeColor"

local SEND_ANALYTICS = "SendAnalytics"
--variables
--references
local Player = Players.LocalPlayer
local HousesFolder = workspace:WaitForChild("Assets"):WaitForChild("Houses")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
local houses = workspace:WaitForChild("Assets"):WaitForChild("Houses")
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
                print(charModel:IsA("Model"), humanoid, humanoid and humanoid:IsA("Humanoid"), charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name))
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
local function playCharacterAnimation(char : Model, id : number)   
    
    if RunService:IsServer() then
        local plr = Players:GetPlayerFromCharacter(char)
        assert(plr)
        NetworkUtil.fireClient(ON_AVATAR_ANIMATION_SET, plr, char, id)
    else  
        local maid = Maid.new()
        local charHumanoid = char:WaitForChild("Humanoid") :: Humanoid
        local animator = charHumanoid:WaitForChild("Animator") :: Animator
    
        local catalogAsset = maid:GiveTask(NetworkUtil.invokeServer(GET_CATALOG_FROM_CATALOG_INFO, id):Clone())
        local animation = catalogAsset:GetChildren()[1]
        local animationTrack = maid:GiveTask(animator:LoadAnimation(animation))
        --animationTrack.Looped = false
        animationTrack:Play()
        --animationTrack.Ended:Wait()
        local function stopAnimation()
            animationTrack:Stop()
            maid:Destroy()
        end
        maid:GiveTask(char.AncestryChanged:Connect(function()
            if char.Parent == nil then
                stopAnimation()
            end
        end))
        maid:GiveTask(charHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if charHumanoid.MoveDirection.Magnitude ~= 0 and not charHumanoid.Sit then
                stopAnimation()
            end
        end))

    end
end
local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild("KeyValue") :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class") :: string,
        IsSpawned = model:IsDescendantOf(SpawnedCarsFolder),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId") :: number,
        DestroyLocked = model:GetAttribute("DestroyLocked") :: boolean
    }
end
local function getVehicleFromPlayer(plr : Player) : Model ?
    for _,vehicleModel in pairs(SpawnedCarsFolder:GetChildren()) do
        local vehicleData = getVehicleData(vehicleModel)
        if vehicleData.OwnerId == plr.UserId then
            return vehicleModel
        end
    end
    return nil
end

local function getHouseOfPlayer(plr : Player)
    for _,house in pairs(houses:GetChildren()) do
        local playerPointer = house:FindFirstChild("OwnerPointer")
        if playerPointer and playerPointer.Value == plr then
            return house
        end
    end
    return false
end

return function(
    maid : Maid,

    isDark : CanBeState<boolean>,

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,
    UIStatus : ValueState<UIStatus>,
    vehiclesList : ValueState<{[number] : VehicleData}>,
    currentJob : ValueState<Jobs.JobData ?>,
    date : ValueState<string>,

    houseColor : ValueState<Color3>,
    vehicleColor : ValueState<Color3>,

    isOwnHouse : ValueState <boolean>,
    isOwnVehicle : ValueState <boolean>,
    isHouseLocked : ValueState<boolean>,
    isVehicleLocked : ValueState<boolean>,

    backpackOnAdd : Signal,
    backpackOnDelete : Signal,
    onVehicleSpawn : Signal,
    onVehicleDelete : Signal,

    onHouseLocked : Signal,
    onVehicleLocked : Signal,

    onHouseClaim : Signal,

    onAnimClick : Signal,

    onNotify : Signal,

    onItemCartSpawn : Signal,
    onJobChange : Signal,

    onCharacterReset : Signal,

    onHouseOrVehicleColorConfirm : Signal,

    target : Instance)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)

    local mainPageMaid = maid:GiveTask(Maid.new())

    local isMainUIPageVisible = _Value(true)
    local isExitButtonVisible = _Value(true)

    local currentPage : ValueState<UIStatus?> = _Value(nil) :: any

    local houseIndex = _Value(1)
    local houseName = _Value("House 1")
    local toolTipText : ValueState<string?> = _Value(nil) :: any

    local onBackpackButtonAddClickSignal = maid:GiveTask(Signal.new())
    local onBackpackButtonDeleteClickSignal = maid:GiveTask(Signal.new())

    local onHouseNext = maid:GiveTask(Signal.new())
    local onHousePrev = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())
    
    local customizationSaveList = _Value({})
   
    local function createCustomizationUI()
        local isVisible =_Value(true)
   
        local onCatalogTry: Signal = mainPageMaid:GiveTask(Signal.new())
        local onCustomizeColor = mainPageMaid:GiveTask(Signal.new())
        local onCatalogDelete = mainPageMaid:GiveTask(Signal.new())
        local onCatalogBuy = mainPageMaid:GiveTask(Signal.new())
    
        local onCustomizationSave = mainPageMaid:GiveTask(Signal.new())
        local onSavedCustomizationLoad = mainPageMaid:GiveTask(Signal.new())
        local onSavedCustomizationDelete = mainPageMaid:GiveTask(Signal.new())
    
        local onScaleChange = maid:GiveTask(Signal.new())
        local onScaleConfirmChange = mainPageMaid:GiveTask(Signal.new())
        
        local onRPNameChange = mainPageMaid:GiveTask(Signal.new())
        local onDescChange = mainPageMaid:GiveTask(Signal.new())
        
   
        local out = NewCustomizationUI(
            mainPageMaid,

            onCatalogTry,
            onCustomizeColor,

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
            customizationSaveList,

            function(param)
                local list = {"All"}
                if param:lower() == "featured" then
                elseif param:lower() == "faces" then
                    table.clear(list)
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

                -- print(params.SortAggregation, catalogSortAggregation)
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
                    local errorMsg = "Error: " .. e
                    onNotify:Fire(errorMsg)
                    warn(errorMsg)
                    return catalogPages
                end            

                return catalogPages
            end,
            function(avatarAssetType : Enum.AvatarAssetType, itemTypeName : string, id : number)
                local recommendeds =  AvatarEditorService:GetRecommendedAssets(avatarAssetType, id)
                local catalogInfos = {}

                for _,v in pairs(recommendeds) do
                    local SimplifiedCatalogInfo : NewCustomizationUI.SimplifiedCatalogInfo = {} :: any
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

        out.Parent = target

        mainPageMaid:GiveTask(_new("StringValue")({
            Value = _Computed(function(visible : boolean)
                if not visible then
                    UIStatus:Set()
                    --print(UIStatus:Get(), ' noradivomo??')
                end
                return ""
            end, isVisible)
        }))

        customizationSaveList:Set(NetworkUtil.invokeServer(GET_CHARACTER_SLOT)) 

        local loadingMaid = mainPageMaid:GiveTask(Maid.new())
        mainPageMaid:GiveTask(onCatalogTry:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
            local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType)
    
            LoadingFrame(loadingMaid, "Applying the change").Parent = target
            CustomizationUtil.Customize(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
            char:Set(getCharacter(true))
    
            local s, e = pcall(function()
                playCharacterAnimation(char:Get(), catalogInfo.Id)
            end) -- temp read failed
            if not s and (type(e) == "string") then
                warn("Error loading animation: " .. tostring(e))
            end
    
            loadingMaid:DoCleaning()
        end))
    
        mainPageMaid:GiveTask(onCustomizeColor:Connect(function(color : Color3, char : ValueState<Model>)
            CustomizationUtil.CustomizeBodyColor(Player, color)
            char:Set(getCharacter(true))
            return
        end))
    
        mainPageMaid:GiveTask(onCatalogDelete:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
            local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType) 
            CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
            char:Set(getCharacter(true))
        end))
    
        mainPageMaid:GiveTask(onCatalogBuy:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
            MarketplaceService:PromptPurchase(Player, catalogInfo.Id)
            --CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
            --char:Set(getCharacter(true))
        end))
    
    
        mainPageMaid:GiveTask(onCustomizationSave:Connect(function()
            local saveData = NetworkUtil.invokeServer(SAVE_CHARACTER_SLOT)
            customizationSaveList:Set(saveData)
        end))
    
        local notifMaid = mainPageMaid:GiveTask(Maid.new())
        mainPageMaid:GiveTask(onSavedCustomizationLoad:Connect(function(k, content)
            notifMaid:DoCleaning()
            local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure to load this character slot (Save " .. tostring(k) .. ")?", false, function()
                notifMaid:DoCleaning()
                local loadingFrame =  LoadingFrame(loadingMaid, "Loading the character")
                loadingFrame.Parent = target
                local pureContent = table.clone(content)
                pureContent.CharModel = nil
                local saveData =  NetworkUtil.invokeServer(LOAD_CHARACTER_SLOT, k, pureContent)
                customizationSaveList:Set(saveData)
                content.CharModel:Set(getCharacter(true)) 
                loadingMaid:DoCleaning()
            end, function()
                notifMaid:DoCleaning()
            end)
            notif.Parent = target
    
        end))
    
        mainPageMaid:GiveTask(onSavedCustomizationDelete:Connect(function(k, content)
            notifMaid:DoCleaning()
            local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure to remove this character slot (Save " .. tostring(k) .. ") forever?", false, function()
                notifMaid:DoCleaning()
                local saveData = NetworkUtil.invokeServer(DELETE_CHARACTER_SLOT, k, content)
                customizationSaveList:Set(saveData)
                loadingMaid:DoCleaning()
            end, function()
                notifMaid:DoCleaning()
            end)
            notif.Parent = target
    
        end))
    
        mainPageMaid:GiveTask(onScaleChange:Connect(function(humanoidDescProperty : string, value : number, char : ValueState<Model>, isPreview : boolean)
            loadingMaid:DoCleaning()
            local character = getCharacter(true)
            local loadingFrame = LoadingFrame(loadingMaid, "Loading Character Scales")
            loadingFrame.Parent = target
            
            local characterData = CustomizationUtil.GetInfoFromCharacter(character)
            local s, e =  pcall(function() characterData[humanoidDescProperty] = value end)
            if not s and e then
                warn(e)
            end
            if isPreview then
                char:Set(CustomizationUtil.getAvatarPreviewByCharacterData(characterData))
           -- else
                --CustomizationUtil.SetInfoFromCharacter(character, characterData)
               -- char:Set(getCharacter(true))
            end
            loadingMaid:DoCleaning()
        end))
    
        mainPageMaid:GiveTask(onScaleConfirmChange:Connect(function(characterData, char : ValueState<Model>)
            loadingMaid:DoCleaning()
            local loadingFrame = LoadingFrame(loadingMaid, "Applying Character Scales")
            loadingFrame.Parent = target
            
            local character = Player.Character
            CustomizationUtil.SetInfoFromCharacter(character, characterData)
    
           
            loadingMaid:DoCleaning()
        end))
    
    
        mainPageMaid:GiveTask(onRPNameChange:Connect(function(inputted : string)
            NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerName", inputted)
        end))
        mainPageMaid:GiveTask(onDescChange:Connect(function(inputted : string)
            NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerBio", inputted)
        end))
        return out
    end
   
    local function switchPage(pageName : UIStatus?)
        local camera = workspace.CurrentCamera

        local function reset()
            camera.CameraType = Enum.CameraType.Custom
            local blur = Lighting:FindFirstChild("Blur")
            if blur then blur.Enabled = false end
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            mainPageMaid:DoCleaning()
        end

        reset()

        if currentPage:Get() == pageName then 
            currentPage:Set(nil)
        else
            currentPage:Set(pageName)  
            
            if pageName == "Backpack" then
                local backpackPageUI = BackpackUI(
                    mainPageMaid,
                    backpack,
            
                    onBackpackButtonAddClickSignal,
                    onBackpackButtonDeleteClickSignal,

                    onBack,

                    isDark
                )
            
                backpackPageUI.Parent = target

                -- getExitButton(backpackPageUI, function()
                --     switchPage(nil)
                --     game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
                --     return nil 
                -- end)
                if game:GetService("RunService"):IsRunning() then
                    backpack:Set(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))
                    vehiclesList:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
                end
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
            elseif pageName == "House" then
                local housesList = {}

                if RunService:IsRunning() then
                    for _,house in pairs(HousesFolder:GetChildren()) do
                        local houseIndex = house:GetAttribute("Index")
                        if houseIndex then
                            housesList[houseIndex] = house 
                        end
                    end
                end

                houseIndex:Set(1)
                --houseName:Set("House 1")
                local function updateCamCf()
                    if RunService:IsRunning() then
                        camera.CameraType = Enum.CameraType.Scriptable

                        local index = houseIndex:Get()
                        local house = housesList[index] :: Model
                        local cf, size 
                        if house.PrimaryPart then
                            cf, size = house.PrimaryPart.CFrame, house.PrimaryPart.Size
                        else    
                            cf, size = house:GetBoundingBox()
                        end
                        camera.CFrame = CFrame.lookAt(cf.Position + cf.LookVector*size.Z*0.65 + cf.UpVector*size.Y*0.5, cf.Position)
                    end
                end
              
                _new("StringValue")({
                    Value = _Computed(function(index : number)
                        houseName:Set(if housesList[index] then housesList[index].Name else "")
                        return ""
                    end, houseIndex)
                })

                local housePageUI = HouseUI(
                    mainPageMaid, 
                    houseIndex, 
                    houseName, 
                    onHouseNext, 
                    onHousePrev,
                    onHouseClaim,
                    onBack,
                    1,
                    #housesList
                )
                housePageUI.Parent = target

                updateCamCf()

                maid:GiveTask(onHouseNext:Connect(function()
                    houseIndex:Set(houseIndex:Get() + 1) 
        
                    updateCamCf()
                end))
                maid:GiveTask(onHousePrev:Connect(function()
                    houseIndex:Set(houseIndex:Get() - 1)
        
                    updateCamCf()
                end))
            elseif pageName == "Vehicle" then
                local function getNewVehiclesListVersion(maxNum : number ?) : {[number] : ValueState<VehicleData ?>}
                    local defMaxNum = maxNum or 50
                    local newVehicleListVersion = {}
                    for i = 1, defMaxNum do
                        table.insert(newVehicleListVersion, _Value(nil))
                    end
                    return newVehicleListVersion :: any
                end
                
                local newVehiclesListVersion = getNewVehiclesListVersion()
                _new("StringValue")({
                    Value = _Computed(function(list : {[number] : VehicleData})
                        --[[for k, vehicleData in pairs(list) do
                            local dynamicVehicleData = newVehiclesListVersion[k]
                            if dynamicVehicleData then
                                dynamicVehicleData:Set(vehicleData)
                            end
                            print(k, vehicleData, dynamicVehicleData, " seyy!")
                        end]]
                        for k, dynamicVehicleData in pairs(newVehiclesListVersion) do
                            local vehicleData = list[k]
                            dynamicVehicleData:Set(vehicleData)
                            
                        end
                        return ""
                    end, vehiclesList)
                })

                local vehicleUI = VehicleUI( 
                    mainPageMaid,
                
                    newVehiclesListVersion,

                    onVehicleSpawn,
                    onVehicleDelete,

                    onBack,
                    
                    isDark
                ) 
                vehicleUI.Parent = target
                print(vehicleUI)
            elseif pageName == "Roleplay" then
                local animations : {CustomEnums.AnimationAction} = {
                    CustomEnums.AnimationAction.Dance1,
                    CustomEnums.AnimationAction.Dance2,
                    CustomEnums.AnimationAction.GetOut,
                    CustomEnums.AnimationAction.Happy,
                    CustomEnums.AnimationAction.Laugh,
                    CustomEnums.AnimationAction.No,
                    CustomEnums.AnimationAction.Point,
                    CustomEnums.AnimationAction.Sad,
                    CustomEnums.AnimationAction.Shy,
                    CustomEnums.AnimationAction.Standing,
                    CustomEnums.AnimationAction.Wave,
                    CustomEnums.AnimationAction.Yawning,
                    CustomEnums.AnimationAction.Yes
                }

                local roleplayPageUI = RoleplayUI(
                    mainPageMaid,
                    animations,
                
                    onAnimClick,
                    onItemCartSpawn,
                    onJobChange,
                    onBack,

                    backpack,
                    
                    currentJob,
                    Jobs.getJobs(),

                    isDark
                )
                roleplayPageUI.Parent = target
            elseif pageName == "Customization" then
                local customizationUI = createCustomizationUI()
                customizationUI.Parent = target
            end
        end
        isMainUIPageVisible:Set(currentPage:Get() == nil)
    end

    local ownershipUI = OwnershipUI(
        maid,
        isDarkState,

        houseColor,
        vehicleColor,

        isOwnHouse,
        isOwnVehicle,
        isHouseLocked,
        isVehicleLocked,

        onHouseLocked,
        onVehicleLocked,

        onVehicleSpawn,

        onHouseOrVehicleColorConfirm,

        target
    )
    -- local backpackUI = Sintesa.Molecules.FAB.ColdFusion.new(maid, Sintesa.IconLists.places.backpack, function()
    --     switchPage("Backpack")
    -- end, isDark)
    -- local customizationUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.social.person, function()
    --     switchPage("Customization")
    -- end, isDark)
    -- local houseUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.places.house, function()
    --     switchPage("House")
    -- end, isDark)
    -- local vehicleUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.social.emoji_transportation, function()
    --     switchPage("Vehicle")
    -- end, isDark)
    -- local roleplayUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.social.emoji_emotions, function()
    --     switchPage("Roleplay")
    -- end, isDark)

    -- local buttonsFrame = _new("Frame")({
    --     BackgroundTransparency = 1,
    --     Size = UDim2.fromScale(1, 0.75),
    --     Children = {
    --         _new("UIPadding")({
    --             PaddingTop = PADDING_SIZE,
    --             PaddingBottom = PADDING_SIZE,
    --             PaddingLeft = PADDING_SIZE,
    --             PaddingRight = PADDING_SIZE,

    --         }),
    --         _new("UIListLayout")({
    --             Padding = PADDING_SIZE,
    --             SortOrder = Enum.SortOrder.LayoutOrder,
    --             VerticalAlignment = Enum.VerticalAlignment.Center,
    --             HorizontalAlignment = Enum.HorizontalAlignment.Right,
    --         }),
    --         backpackUI,
    --         customizationUI,
    --         houseUI,
    --         vehicleUI,
    --         roleplayUI
    --     }
    -- })
    -- local out = _new("Frame")({
    --     BackgroundTransparency = 1,
    --     Visible = isMainUIPageVisible,
    --     Size = UDim2.fromScale(0.15, 1),
    --     Position = UDim2.fromScale(1 - 0.15, 0),
    --     Children = {
    --         _new("UIListLayout")({
    --             Padding = PADDING_SIZE,
    --             SortOrder = Enum.SortOrder.LayoutOrder,
    --             VerticalAlignment = Enum.VerticalAlignment.Center, 
    --             HorizontalAlignment = Enum.HorizontalAlignment.Right,
    --         }),
    --         buttonsFrame
    --     } 
    -- })
    local function onButtonClicked(buttonData : Sintesa.ButtonData)
        --print(buttonData.Name)
        switchPage(buttonData.Name :: UIStatus)
    end

    -- local navBar = Sintesa.Molecules.NavigationBar.ColdFusion.new(maid, isDark, "Main Menu", {
    --     Sintesa.TypeUtil.createFusionButtonData("Backpack", Sintesa.IconLists.places.backpack, _Computed(function(page : UIStatus)
    --         return page == "Backpack"
    --     end, currentPage),  nil),
    --     Sintesa.TypeUtil.createFusionButtonData("Customization", Sintesa.IconLists.social.person),
    --     Sintesa.TypeUtil.createFusionButtonData("House", Sintesa.IconLists.places.house),
    --     Sintesa.TypeUtil.createFusionButtonData("Vehicle", Sintesa.IconLists.social.emoji_transportation),
    --     Sintesa.TypeUtil.createFusionButtonData("Roleplay", Sintesa.IconLists.social.emoji_emotions),

    -- }, onButtonClicked)
    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)

    local toolTip = _bind(Sintesa.Molecules.PlainToolTip.ColdFusion.new(maid, isDark, _Computed(function(str : string?)
        return str or ""
    end, toolTipText)))({
        Visible = _Computed(function(txt : string?)
            return if txt then true else false
        end, toolTipText) 
    }) :: GuiObject
    toolTip.Parent = target

    local backpackButton = Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, Sintesa.IconLists.places.backpack, _Value(false), function()
        switchPage("Backpack")
    end, isDarkState, 32)
    local customizationButton = Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, Sintesa.IconLists.social.person, _Value(false), function()
        switchPage("Customization")
    end, isDarkState, 32)
    local houseButton = Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, Sintesa.IconLists.places.house, _Value(false), function()
        switchPage("House")
    end, isDarkState, 32)
    local vehicleButton = Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, Sintesa.IconLists.social.emoji_transportation, _Value(false), function()
        switchPage("Vehicle")
    end, isDarkState, 32)
    local roleplayButton = Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, Sintesa.IconLists.social.emoji_emotions, _Value(false), function()
        switchPage("Roleplay")
    end, isDarkState, 32)

    local navBar = _new("Frame")({
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        Size = UDim2.fromOffset(0, 35),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            _new("Frame")({LayoutOrder = 0, Name = "Buffer", BackgroundTransparency = 1, Size = UDim2.new(0,PADDING_SIZE.Offset*0.5,0,0)}),
            _bind(backpackButton)({
                LayoutOrder = 1,
                Events = {
                    MouseEnter = function()
                        toolTipText:Set("Backpack")
                        toolTip.Position = UDim2.new(
                            0, backpackButton.AbsolutePosition.X + backpackButton.AbsoluteSize.X*0.5 + toolTip.AbsoluteSize.X*0.5, 
                            0, backpackButton.AbsolutePosition.Y 
                        )
                    end,
                    MouseLeave = function()
                        toolTipText:Set(nil)
                    end
                }
            }),
            _bind(customizationButton)({
                LayoutOrder = 2,
                Events = {
                    MouseEnter = function()
                        toolTipText:Set("Customization")
                        toolTip.Position = UDim2.new(
                            0, customizationButton.AbsolutePosition.X + customizationButton.AbsoluteSize.X*0.5 + toolTip.AbsoluteSize.X*0.5, 
                            0, customizationButton.AbsolutePosition.Y
                        )
                    end,
                    MouseLeave = function()
                        toolTipText:Set()
                    end
                }
            }),
            _bind(houseButton)({
                LayoutOrder = 3,
                Events = {
                    MouseEnter = function()
                        toolTipText:Set("House")
                        toolTip.Position = UDim2.new(
                            0, houseButton.AbsolutePosition.X + houseButton.AbsoluteSize.X*0.5 + toolTip.AbsoluteSize.X*0.5, 
                            0, houseButton.AbsolutePosition.Y
                        )
                    end,
                    MouseLeave = function()
                        toolTipText:Set()
                    end
                }
            }),
            _bind(vehicleButton)({
                LayoutOrder = 4,
                Events = {
                    MouseEnter = function()
                        toolTipText:Set("Vehicle")
                        toolTip.Position = UDim2.new(
                            0, vehicleButton.AbsolutePosition.X + vehicleButton.AbsoluteSize.X*0.5 + toolTip.AbsoluteSize.X*0.5, 
                            0, vehicleButton.AbsolutePosition.Y
                        )
                    end,
                    MouseLeave = function()
                        toolTipText:Set()
                    end
                }
            }),
            _bind(roleplayButton)({
                LayoutOrder = 5,
                Events = {
                    MouseEnter = function()
                        toolTipText:Set("Roleplay")
                        toolTip.Position = UDim2.new(
                            0, roleplayButton.AbsolutePosition.X + roleplayButton.AbsoluteSize.X*0.5 + toolTip.AbsoluteSize.X*0.5, 
                            0, roleplayButton.AbsolutePosition.Y 
                        )
                    end,
                    MouseLeave = function()
                        toolTipText:Set()
                    end
                }
            }),
        --    _new("Frame")({LayoutOrder = 6, Name = "Buffer",  BackgroundTransparency = 1, Size = UDim2.new(0,PADDING_SIZE.Offset*0.5,0,0)}),
        }
    })
    local out = _new("Frame")({
        Name = "MainUI",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Parent = target,
        Children = {
            _new("Frame")({
                Name = "Header",
                Size = UDim2.new(1,0,0,35),
                BackgroundTransparency = 1,
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    }),
                    _new("Frame")({
                        LayoutOrder = 1,
                        Name = "Header",
                        Size = UDim2.new(0,180,1,0),
                        BackgroundTransparency = 1,
                    }),
                    _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                        maid, 
                        2, 
                        date,
                        _Computed(function(dark  : boolean)
                            return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_surface())
                        end, isDarkState),
                        Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.TitleMedium)), 
                        50
                    ))({
                        
                        TextStrokeTransparency = 0.5,
                        TextStrokeColor3 = _Computed(function(dark  : boolean)
                            return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurface())
                        end, isDarkState)
                    }),
                }
            }),
           
            _new("Frame")({
                Name = "Footer",
                BackgroundTransparency = 1,
                Position = _Computed(function(status : UIStatus)
                    return if status then UDim2.fromOffset(0,navBar.Size.Y.Offset) else UDim2.fromScale(0, 0)
                end, currentPage):Tween(0.5),
                Size = UDim2.new(1,0,1,0),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    navBar
                }
            }),
           
        }
    }) 

    maid:GiveTask(onBackpackButtonAddClickSignal:Connect(function(toolData : ToolData)
        backpackOnAdd:Fire(toolData)
       
    end))
    maid:GiveTask(onBackpackButtonDeleteClickSignal:Connect(function(toolKey : number, toolName : string)
        backpackOnDelete:Fire(toolKey, toolName)
    end))

    maid:GiveTask(onBack:Connect(function()
        switchPage(nil)
    end))
    out.Parent = target
    return out :: GuiObject
end
