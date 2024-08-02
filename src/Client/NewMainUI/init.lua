--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
local RoleplayUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("RoleplayUI"))
local NewCustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"))
local CustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("CustomizationUI"))
local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local HouseUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("HouseUI"))
local VehicleUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("VehicleUI"))
local ColorWheel = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColorWheel"))
local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))
local StatusUtil = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("StatusUtil"))

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))

local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))

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

local PADDING_SIZE = UDim.new(0.01,0)

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

local ON_ANIMATION_SET = "OnAnimationSet"
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

return function(
    maid : Maid,

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,
    UIStatus : ValueState<UIStatus>,
    vehiclesList : ValueState<{[number] : VehicleData}>,
    currentJob : ValueState<Jobs.JobData ?>,
    date : ValueState<string>,
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

    onNotify : Signal,

    onItemCartSpawn : Signal,
    onJobChange : Signal,

    onCharacterReset : Signal,

    target : Instance)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local mainPageMaid = maid:GiveTask(Maid.new())

    local isDark = false

    local isMainUIPageVisible = _Value(true)
    local isExitButtonVisible = _Value(true)

    local currentPage : ValueState<UIStatus?> = _Value(nil) :: any

    local onBackpackButtonAddClickSignal = maid:GiveTask(Signal.new())
    local onBackpackButtonDeleteClickSignal = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local function getExitButton(ui : GuiObject, onCloseButtonClick : () -> ())
        local exitButton = ExitButton.new(
            ui:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            onCloseButtonClick
            
        ) 
        exitButton.Instance.Parent = ui:FindFirstChild("ContentFrame")
        return exitButton.Instance 
    end

    local function switchPage(pageName : UIStatus?)
        mainPageMaid:DoCleaning()

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

                    onBack
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
            else
                
            end
        end
        isMainUIPageVisible:Set(currentPage:Get() == nil)
    end

    local backpackUI = Sintesa.Molecules.FAB.ColdFusion.new(maid, Sintesa.IconLists.places.backpack, function()
        switchPage("Backpack")
    end, isDark)
    local customizationUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.social.person, function()
        switchPage("Customization")
    end, isDark)
    local houseUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.places.house, function()
        switchPage("House")
    end, isDark)
    local vehicleUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.maps.directions_car, function()
        switchPage("Vehicle")
    end, isDark)
    local roleplayUI = Sintesa.Molecules.FAB.ColdFusion.new(maid,Sintesa.IconLists.maps.theater_comedy, function()
        switchPage("Roleplay")
    end, isDark)

    local buttonsFrame = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.75),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,

            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }),
            backpackUI,
            customizationUI,
            houseUI,
            vehicleUI,
            roleplayUI
        }
    })
    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Visible = isMainUIPageVisible,
        Size = UDim2.fromScale(0.15, 1),
        Position = UDim2.fromScale(1 - 0.15, 0),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center, 
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }),
            buttonsFrame
        } 
    })
    -- local function onButtonClicked(buttonData : Sintesa.ButtonData)
    --     print(buttonData.Name)
    -- end
    --print(Sintesa.IconLists)
    -- local out = Sintesa.Molecules.NavigationRail.ColdFusion.new(maid, isDark, "Main Menu", {
    --     Sintesa.TypeUtil.createFusionButtonData("Backpack", Sintesa.IconLists.places.backpack)
    -- }, onButtonClicked, true, function()

    -- end)

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
    return out
end
