--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local InteractSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("InteractSys"))
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
local MainUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"))
local SideOptions = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("SideOptions"))
local NotificationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"))
local MapUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MapUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local NewCustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"))

local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))

local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = ItemOptionsUI.OptInfo

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

export type VehicleData = ItemUtil.ItemInfo & {
    IsSpawned : string,
    Key : number ?
}

type GuiSys = {
    __index : GuiSys,
    _Maid : Maid,
    MainUI : GuiObject,
    NotificationUI : GuiObject,
    MapUI : MapUI.MapHUD,

    NotificationStatus : ValueState<string ?>,

    new : () -> GuiSys,
    Notify : (GuiSys, text : string) -> nil,
    Destroy : (GuiSys) -> nil,
    init : (maid : Maid) -> ()
}
--constants
local MAX_DISTANCE = 18

local LIST_TYPE_ATTRIBUTE = 'ListType'
--remotes
local ON_OPTIONS_OPENED = "OnOptionsOpened"
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local ADD_BACKPACK = "AddBackpack" 

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"

local SPAWN_VEHICLE = "SpawnVehicle"
local ADD_VEHICLE = "AddVehicle"
local DELETE_VEHICLE = "DeleteVehicle"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"
--variables
local Player = Players.LocalPlayer
--references
--local functions
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

local function getListButtonInfo(
    signal : Signal,
    buttonName : string
)
    return 
        {
            Signal = signal,
            ButtonName = buttonName
        }
    
end
--class
local currentGuiSys : GuiSys

local guiSys : GuiSys = {} :: any
guiSys.__index = guiSys

function guiSys.new()
    local maid = Maid.new()
    
    local target = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local notificationUItarget = _new("ScreenGui")({
        Name = "NotificationScreenGui",
        Parent = Player:WaitForChild("PlayerGui"),
        DisplayOrder = 10
    })

    local interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType> = _Value(Enum.KeyCode.E) :: any
    
    local self : GuiSys = setmetatable({}, guiSys) :: any
    self._Maid = maid
    self.NotificationStatus = _Value(nil :: string ?)

    local backpack = _Value(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))

    local backpackOnEquip = maid:GiveTask(Signal.new())
    local backpackOnDelete = maid:GiveTask(Signal.new())
    
    local nameCustomizationOnClick = maid:GiveTask(Signal.new()) 

    local onCharacterReset = maid:GiveTask(Signal.new())

    local MainUIStatus : ValueState<MainUI.UIStatus> = _Value(nil) :: any

    self.MainUI = MainUI(
        maid,
        backpack,
        
        MainUIStatus,

        backpackOnEquip,
        backpackOnDelete,

        nameCustomizationOnClick,
        
        onCharacterReset,

        target
    )

    maid:GiveTask(nameCustomizationOnClick:Connect(function(descType, text)
        CustomizationUtil.setDesc(Player, descType, text)
    end))

    maid:GiveTask(backpackOnEquip:Connect(function(toolKey : number, toolName : string ?)
        NetworkUtil.invokeServer(
            EQUIP_BACKPACK,
            toolKey,
            toolName
        )
    end))
    maid:GiveTask(backpackOnDelete:Connect(function(toolKey : number, toolName : string)
        NetworkUtil.invokeServer(
            DELETE_BACKPACK,
            toolKey,
            toolName
        )
    end))


    self.NotificationUI = NotificationUI(
        maid,
        self.NotificationStatus
    )


    do
        local charMaid = maid:GiveTask(Maid.new()) 

        local onSprintClick = maid:GiveTask(Signal.new())
        local sprintState = _Value(false)
        local function onCharAdded(char : Model)
            charMaid:DoCleaning()
            charMaid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
                if char:GetAttribute("IsSprinting") == true then
                    sprintState:Set(true)
                else
                    sprintState:Set(false)
                end
            end))
        end
        local sideOptionsUI = SideOptions(
            maid, 
            onSprintClick,

            sprintState
        )
        sideOptionsUI.Parent = target
        
        onCharAdded(Player.Character or Player.CharacterAdded:Wait())

        maid:GiveTask(onSprintClick:Connect(function()
            local char = Player.Character
            if char then
                char:SetAttribute("IsSprinting", not char:GetAttribute("IsSprinting"))
            end
        end))

        maid:GiveTask(Player.CharacterAdded:Connect(onCharAdded))
    end


    --map ui
    local plrCf = _Value(CFrame.new())
    local mapUI = MapUI.new(maid, plrCf, _Value(true))
    mapUI.Instance.Parent = target

    local charMaid = maid:GiveTask(Maid.new())

    local function cfSetup(char : Model)
        charMaid:DoCleaning()
 
        charMaid:GiveTask(RunService.Stepped:Connect(function()
            if char.PrimaryPart then
                plrCf:Set(char.PrimaryPart.CFrame)
            end
        end))
    end

    cfSetup(Player.Character or Player.CharacterAdded:Wait())
    maid:GiveTask(Player.CharacterAdded:Connect(function(char : Model)
        cfSetup(char)
    end))
 
    self.MainUI.Parent = target
    self.NotificationUI.Parent = notificationUItarget
    self.MapUI = mapUI

    currentGuiSys = self

    local proxPrompt = _new("ProximityPrompt")({
        RequiresLineOfSight = false
    }) :: ProximityPrompt
    InteractSys.init(maid, proxPrompt, interactKeyCode)

    maid:GiveTask(NetworkUtil.onClientEvent(UPDATE_PLAYER_BACKPACK, function(newbackpackval : {BackpackUtil.ToolData<boolean>})
        backpack:Set(newbackpackval)
    end))

    local currentOptInfo : ValueState<OptInfo ?> = _Value(nil) :: any   
    local onItemGet = maid:GiveTask(Signal.new())

    local isExitButtonVisible = _Value(true)

    NetworkUtil.onClientInvoke(ON_OPTIONS_OPENED, function(
        listName : string,
        inst : Instance
    )
        local _maid = Maid.new()
        local _fuse = ColdFusion.fuse(_maid)
        local _new = _fuse.new
        local _import = _fuse.import
        local _bind = _fuse.bind
        local _clone = _fuse.clone
    
        local _Computed = _fuse.Computed
        local _Value = _fuse.Value
        
        local cam = workspace.CurrentCamera

        local position = _Value(UDim2.new())
        local isVisible = _Value(true)

        local list = _Value({}) 
        
        local buttonlistsInfo = {}

        if inst:GetAttribute(LIST_TYPE_ATTRIBUTE) == "Vehicle" then
            local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            if not plrIsVIP then 
                MarketplaceService:PromptGamePassPurchase(Player, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                _maid:Destroy()
                return nil 
            end
            
            list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            
            local onVehicleSpawn = maid:GiveTask(Signal.new())
            local onVehicleDelete = maid:GiveTask(Signal.new())

            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleSpawn, "Spawn"))
            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleDelete, "Delete"))

            maid:GiveTask(onVehicleSpawn:Connect(function(key, val : string)
                local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                local spawnerZones = spawnerZonesPointer.Value

                NetworkUtil.invokeServer(
                    SPAWN_VEHICLE, 
                    key,
                    val,
                    spawnerZones
                )
            end))

            maid:GiveTask(onVehicleDelete:Connect(function(key, val)
                NetworkUtil.invokeServer(
                    DELETE_VEHICLE,
                    key
                )

                list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            end))
        end

        local listUI =  ListUI(
            _maid, 
            listName, 
            list,
            position,
            isVisible,
            buttonlistsInfo
        ) :: GuiObject

        ExitButton.new(
            listUI, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        listUI.Parent = target

        _maid:GiveTask(RunService.Stepped:Connect(function()
            local worldPos 
            local pos, isOnRange
            if inst:IsA("Model") then
                local cf, _ = inst:GetBoundingBox()
                pos, isOnRange = cam:WorldToScreenPoint(cf.Position)
                worldPos = cf.Position
            elseif inst:IsA("BasePart") then
                pos, isOnRange = cam:WorldToScreenPoint(inst.Position)
                worldPos = inst.Position
            end
            if pos and (isOnRange ~= nil) then
                position:Set(UDim2.fromOffset(pos.X, pos.Y))
                isVisible:Set(isOnRange)

                if Player.Character and worldPos and ((worldPos - Player.Character.PrimaryPart.Position).Magnitude >= MAX_DISTANCE) then
                    maid.ItemOptionsUI = nil
                end
            end
        end))

        return nil
    end)

    NetworkUtil.onClientInvoke(ON_ITEM_OPTIONS_OPENED, function(
        listName : string,
        ToolsList : {[number] : OptInfo},
        interactedItem : Instance
    )
        local _maid = Maid.new()
        currentOptInfo:Set(nil)
        
        local itemOptionsUI: GuiObject = ItemOptionsUI(
            _maid,
            listName, 
            ToolsList,

            currentOptInfo,

            onItemGet,

            interactedItem
        ) :: GuiObject
        ExitButton.new(
            itemOptionsUI:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        itemOptionsUI.Parent = target

        --managing player list
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        maid.OnItemOptionsUIDestroy = itemOptionsUI.Destroying:Connect(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            maid.OnItemOptionsUIDestroy = nil
        end)

        return nil
    end)

    maid:GiveTask(onItemGet:Connect(function(inst : Instance)
        local optInfo : ItemOptionsUI.OptInfo ? = currentOptInfo:Get()
        local char = Player.Character or Player.CharacterAdded:Wait()
        
        if optInfo then
            if optInfo.Type == "Tool" then
                NetworkUtil.invokeServer(
                    ADD_BACKPACK,
                    optInfo.Name
                )
            elseif optInfo.Type == "Vehicle" then
                NetworkUtil.invokeServer(
                    ADD_VEHICLE,
                    optInfo.Name
                )
                --local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                --local spawnerZones = spawnerZonesPointer.Value
                
                --NetworkUtil.invokeServer(
                --    SPAWN_VEHICLE,
                --    optInfo.Name,
                --    spawnerZones
                --)
            end
        end
        currentOptInfo:Set(nil)
    end))

    maid:GiveTask(onCharacterReset:Connect(function(isClear : boolean)
        NetworkUtil.fireServer(ON_CHARACTER_APPEARANCE_RESET, isClear)
    end))

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

   local onCatalogTry = maid:GiveTask(Signal.new())
   local onCatalogDelete = maid:GiveTask(Signal.new())

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
  local onRPNameChange = maid:GiveTask(Signal.new())
  local onDescChange = maid:GiveTask(Signal.new())

   local customizationUI = NewCustomizationUI(
       maid,

       onCatalogTry,
       onCatalogDelete,

       onRPNameChange,
       onDescChange,

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
               warn("Error: " .. e)
               return catalogPages
           end            

           return catalogPages
       end,
       function(avatarAssetType : Enum.AvatarAssetType, itemTypeName : string, id : number)
           local recommendeds =  AvatarEditorService:GetRecommendedAssets(avatarAssetType, id)
           local catalogInfos = {}

           for _,v in pairs(recommendeds) do
               local SimplifiedCatalogInfo = {} :: any
               SimplifiedCatalogInfo.Id = v.Item.AssetId
               SimplifiedCatalogInfo.Name = v.Item.Name
               SimplifiedCatalogInfo.ItemType = itemTypeName
               SimplifiedCatalogInfo.CreatorName = v.Creator.Name
               SimplifiedCatalogInfo.Price = v.Product.PriceInRobux
               table.insert(catalogInfos, SimplifiedCatalogInfo)
           end
         
           return catalogInfos
       end,
       _Value(true)
   )
   customizationUI.Parent = target

   maid:GiveTask(onCatalogTry:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
       print(catalogInfo.Id, " test try?")
       CustomizationUtil.Customize(Player, catalogInfo.Id)
       char:Set(getCharacter(true))
       print("test treh.")
   end))

   maid:GiveTask(onCatalogDelete:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo)
       print("motorik ", catalogInfo.Id)
       CustomizationUtil.Customize(Player, catalogInfo.Id)
   end))

   maid:GiveTask(onRPNameChange:Connect(function(inputted : string)
       print("On RP Change :", inputted)
   end))
   maid:GiveTask(onDescChange:Connect(function(inputted : string)
       print("On Desc change :", inputted)
   end))
    customizationUI.Parent = target

    print(customizationUI, " customization loaded")

    --setting default backpack to untrue it 
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    return self 
end

function guiSys:Notify(text : string)
    print("Test1")
    self.NotificationStatus:Set(nil)
    print(self.NotificationStatus:Get())
    task.wait(0.1)
    self.NotificationStatus:Set(text)
    print(self.NotificationStatus:Get())
    return
end

function guiSys:Destroy()
    self._Maid:Destroy()

    local t : GuiSys = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end
    
    setmetatable(self, nil)
    return
end

function guiSys.init(maid : Maid)
    local newGuiSys = maid:GiveTask(guiSys.new())

    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)