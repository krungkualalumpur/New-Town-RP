--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

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
local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))

local CustomEnum = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
local ChoiceActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChoiceActions"))

local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = ItemOptionsUI.OptInfo

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
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
local DAY_VALUE_KEY = "DayValue"
--remotes
local ON_OPTIONS_OPENED = "OnOptionsOpened"
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local ON_ITEM_CART_SPAWN = "OnItemCartSpawn"

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
local ON_NOTIF_CHOICE_INIT = "OnNotifChoiceInit"

local ON_JOB_CHANGE = "OnJobChange"

local ON_HOUSE_CLAIMED = "OnHouseClaimed"
local ON_HOUSE_LOCKED = "OnHouseLocked"
local ON_VEHICLE_LOCKED = "OnVehicleLocked"

local SEND_FEEDBACK = "SendFeedback"
--variables
local Player = Players.LocalPlayer
--references
local dayValue = workspace:WaitForChild(DAY_VALUE_KEY) :: IntValue
--local functions
function PlaySound(id, parent, volumeOptional: number ?)
	task.spawn(function()
		local s = Instance.new("Sound")

		s.Name = "Sound"
		s.SoundId = id
		s.Volume = volumeOptional or 1
        s.RollOffMaxDistance = 350
		s.Looped = false
		s.Parent = parent or Player:FindFirstChild("PlayerGui")
		s:Play()
		task.spawn(function() 
            s.Ended:Wait()
		    s:Destroy()
        end)
	end)
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

local function getDayEnumFromNum(num : number) : CustomEnum.Day
    for _,v in pairs(CustomEnum.Day:GetEnumItems()) do
        if v.Value == num then
            return v
        end
    end
    error("Unable to find the enum")
end

local function getCurrentDay() : CustomEnum.Day
    return getDayEnumFromNum(workspace:WaitForChild(DAY_VALUE_KEY).Value)
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
    
    local buttonlistsInfo = {}

    local notificationUItarget = _new("ScreenGui")({
        Name = "NotificationScreenGui",
        Parent = Player:WaitForChild("PlayerGui"),
        IgnoreGuiInset = true,
        DisplayOrder = 10
    })

    local interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType> = _Value(Enum.KeyCode.E) :: any
    
    local self : GuiSys = setmetatable({}, guiSys) :: any
    self._Maid = maid
    self.NotificationStatus = _Value(nil :: string ?)

    local backpack = _Value(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))
    local vehicleList = _Value({}) 
    local date = _Value(string.format("%s\n%s", getCurrentDay().Name, NumberUtil.NumberToClock(game.Lighting.ClockTime, false)))

    local backpackOnAdd = maid:GiveTask(Signal.new())
    local backpackOnDelete = maid:GiveTask(Signal.new())
    local onNotify = maid:GiveTask(Signal.new())
    
    local nameCustomizationOnClick = maid:GiveTask(Signal.new()) 

    local onItemCartSpawn = maid:GiveTask(Signal.new())
    local onJobChange = maid:GiveTask(Signal.new())
    local onVehicleSpawn = maid:GiveTask(Signal.new())
    local onVehicleDelete = maid:GiveTask(Signal.new())

    local onHouseLocked = maid:GiveTask(Signal.new())
    local onVehicleLocked = maid:GiveTask(Signal.new())
    local onHouseClaim =  maid:GiveTask(Signal.new())

    table.insert(buttonlistsInfo, getListButtonInfo(onVehicleSpawn, "Spawn"))
    table.insert(buttonlistsInfo, getListButtonInfo(onVehicleDelete, "Delete"))

    local onCharacterReset = maid:GiveTask(Signal.new())

    local MainUIStatus : ValueState<MainUI.UIStatus> = _Value(nil) :: any

    local isOwnHouse = _Value(false)
    local isOwnVehicle = _Value(false)

    local houseIsLocked = _Value(true)
    local vehicleIsLocked = _Value(true)


    self.MainUI = MainUI(
        maid,
        backpack,
        
        MainUIStatus,

        vehicleList,
        date,
        isOwnHouse,
        isOwnVehicle,
        houseIsLocked,
        vehicleIsLocked,

        backpackOnAdd,
        backpackOnDelete,
        onVehicleSpawn,
        onVehicleDelete,
        onHouseLocked,
        onVehicleLocked,
        onHouseClaim,
        onNotify,

        onItemCartSpawn,
        onJobChange,
        
        onCharacterReset,

        target
    )
   
    maid:GiveTask(game.Lighting.Changed:Connect(function()
        date:Set(string.format("%s, %s", getCurrentDay().Name, NumberUtil.NumberToClock(game.Lighting.ClockTime*60*60, false)))
    end))

    maid:GiveTask(nameCustomizationOnClick:Connect(function(descType, text)
        CustomizationUtil.setDesc(Player, descType, text)
    end))

    maid:GiveTask(backpackOnAdd:Connect(function(toolData : BackpackUtil.ToolData<boolean>)
        NetworkUtil.invokeServer(
            ADD_BACKPACK,
            toolData.Name
        )
    end))
    maid:GiveTask(backpackOnDelete:Connect(function(toolKey : number, toolName : string)
        NetworkUtil.invokeServer(
            DELETE_BACKPACK,
            toolKey,
            toolName
        )
    end))

    maid:GiveTask(onNotify:Connect(function(msg : string)
        self:Notify(msg)
    end))

    
    maid:GiveTask(onItemCartSpawn:Connect(function(selectedItems : {[number] : BackpackUtil.ToolData<boolean>}, cartSpawnedState : ValueState<boolean>)
        MainUIStatus:Set(nil)

        local itemCart =  NetworkUtil.invokeServer(ON_ITEM_CART_SPAWN, selectedItems)
        if itemCart then
            cartSpawnedState:Set(true)
        else
            cartSpawnedState:Set(false)
        end
        print(itemCart)
    end))
    
    maid:GiveTask(onJobChange:Connect(function(job)
        NetworkUtil.fireServer(ON_JOB_CHANGE, job)
    end))

    maid:GiveTask(onHouseLocked:Connect(function()
        local lock = houseIsLocked:Get()
        local currentLockState =  NetworkUtil.invokeServer(ON_HOUSE_LOCKED, not lock)
        houseIsLocked:Set(currentLockState)
    end))

    maid:GiveTask(onVehicleLocked:Connect(function()
        local lock = vehicleIsLocked:Get()
        local currentLockState = NetworkUtil.invokeServer(ON_VEHICLE_LOCKED, not lock)
        vehicleIsLocked:Set(currentLockState)
    end))

    self.NotificationUI = NotificationUI(
        maid,
        self.NotificationStatus
    )


    do
        local charMaid = maid:GiveTask(Maid.new()) 
        local onFeedbackSend = maid:GiveTask(Signal.new())

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

            sprintState,
            onFeedbackSend
        )
        sideOptionsUI.Parent = target
        
        onCharAdded(Player.Character or Player.CharacterAdded:Wait())

        maid:GiveTask(onSprintClick:Connect(function()
            local char = Player.Character
            if char then
                char:SetAttribute("IsSprinting", not char:GetAttribute("IsSprinting"))
            end
        end))

        maid:GiveTask(onFeedbackSend:Connect(function(feedbackText : string)
            print("Feedback sent!")
            NetworkUtil.fireServer(SEND_FEEDBACK, feedbackText)
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

    maid:GiveTask(NetworkUtil.onClientEvent(ON_HOUSE_CLAIMED, function(house : Model ?)
        if house then
            isOwnHouse:Set(true)
            houseIsLocked:Set(true)
        else
            isOwnHouse:Set(false)
        end
    end))

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
        
        local localButtonListsInfo = {}
        local cam = workspace.CurrentCamera

        local position = _Value(UDim2.new())
        local isVisible = _Value(true)
        
        local onVehicleSpawnZone = _maid:GiveTask(Signal.new())
        table.insert(localButtonListsInfo, getListButtonInfo(onVehicleSpawnZone, "Spawn"))
        table.insert(localButtonListsInfo, getListButtonInfo(onVehicleDelete, "Delete"))

        local list 
        if inst:GetAttribute(LIST_TYPE_ATTRIBUTE) == "Vehicle" then
            --[[local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            if not plrIsVIP then 
                MarketplaceService:PromptGamePassPurchase(Player, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                _maid:Destroy()
                return nil 
            end]]
            
            local currentVehicleList = NetworkUtil.invokeServer(GET_PLAYER_VEHICLES)
            vehicleList:Set(currentVehicleList)
            
            list = _Computed(function(list : {[number] : VehicleData})
                local namesList = {}
                for _,v in pairs(list) do
                    table.insert(namesList, v.Name)
                end
                return namesList
            end, vehicleList)
        end
        
        local listUI =  ListUI(
            _maid, 
            listName, 
            list,
            position,
            isVisible,
            localButtonListsInfo
        ) :: GuiObject
   
        if RunService:IsRunning() and inst:GetAttribute(LIST_TYPE_ATTRIBUTE) == "Vehicle" then   
            do --init
                local contentFrame = listUI:WaitForChild("ContentFrame") :: Frame
                for k,v in pairs(contentFrame:GetChildren()) do
                    if v:IsA("Frame") then
                        for k2, v2 in pairs(vehicleList:Get()) do
                            if k2 == v.LayoutOrder then
                                local spawnButton = v:WaitForChild("SubOptions"):WaitForChild("SpawnButton") :: TextButton
                                spawnButton.Text = if v2.IsSpawned then "Despawn" else "Spawn"
                                if v2.DestroyLocked == true then
                                    local deleteButton = v:WaitForChild("SubOptions"):WaitForChild("DeleteButton") :: TextButton
                                    deleteButton.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end

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
        
        _maid:GiveTask(onVehicleSpawnZone:Connect(function(key, val : string, button : TextButton)
            local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
            local spawnerZones = spawnerZonesPointer.Value
            local vehicles : {[number] : VehicleData} = NetworkUtil.invokeServer(
                SPAWN_VEHICLE, 
                key,
                val,
                spawnerZones
            )

            for _,v in pairs(button.Parent.Parent.Parent:GetDescendants()) do
                if v:IsA("TextButton") and v.Text == "Despawn" then
                    v.Text = "Spawn"
                end
            end
            
            local vehicleData = vehicles[key] 
            if vehicleData and vehicleData.IsSpawned then
                button.Text = "Despawn"
                isOwnVehicle:Set(true)
                vehicleIsLocked:Set(false)
            else
                button.Text = "Spawn"
                isOwnVehicle:Set(false)
            end
            --print(vehicles)
        end))

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

    
    do
        local _maid = maid:GiveTask(Maid.new())
      
        maid:GiveTask(NetworkUtil.onClientEvent(ON_JOB_CHANGE, function(jobData)
            _maid:DoCleaning()

            local _fuse = ColdFusion.fuse(_maid)
            local _new = _fuse.new
            local _Value = _fuse.Value
                
            local dynamicPos = _Value(UDim2.fromScale(-1, 0.5))
            local dynamicTransp = _Value(1)

            local out =  _new("ImageLabel")({
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.3, 0.3),
                Position = dynamicPos:Tween(0.2),
                Image = string.format("rbxassetid://%d", jobData.ImageId),
                ImageTransparency = dynamicTransp:Tween(0.2),
                Parent = target,
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            })

            dynamicTransp:Set(0)
            dynamicPos:Set(UDim2.fromScale(0.5, 0.5))
            task.wait(2)
            dynamicTransp:Set(1)
            dynamicPos:Set(UDim2.fromScale(1, 0.5))
            task.wait(0.2)
            _maid:DoCleaning()
        end))
    end

    local notifMaid = maid:GiveTask(Maid.new())
    NetworkUtil.onClientInvoke(ON_NOTIF_CHOICE_INIT, function(actionName : string, eventTitle : string, eventDesc : string, isConfirm : boolean)
        notifMaid:DoCleaning()
      
        local notificationChoiceUI = NotificationChoice(notifMaid, eventTitle, eventDesc, isConfirm, function()
            --print("Test1") action name ..]
            ChoiceActions.triggerEvent(actionName)
            notifMaid:DoCleaning()

        end)
        notificationChoiceUI.Parent = target

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

    maid:GiveTask(onCharacterReset:Connect(function(char : ValueState<Model>)
        notifMaid:DoCleaning()
        local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure you want to reset your character? All unsaved progress will be lost.", false, function()
            notifMaid:DoCleaning()
            local loadingFrame = LoadingFrame(notifMaid, "Resetting character, please what")
            loadingFrame.Parent = target
            NetworkUtil.invokeServer(ON_CHARACTER_APPEARANCE_RESET)
            char:Set(getCharacter(true))
            notifMaid:DoCleaning()
        end, function()
            notifMaid:DoCleaning()
        end)
        notif.Parent = target
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

   maid:GiveTask(onVehicleSpawn:Connect(function(key, val : string, button : TextButton)
        local vehicles : {[number] : VehicleData} = NetworkUtil.invokeServer(
            SPAWN_VEHICLE, 
            key,
            val
        )

        for _,v in pairs(button.Parent.Parent.Parent:GetDescendants()) do
            if v:IsA("TextButton") and v.Text == "Despawn" then
                v.Text = "Spawn"
            end
        end

        local vehicleData = vehicles[key] 
        if vehicleData and vehicleData.IsSpawned then
            button.Text = "Despawn"
            isOwnVehicle:Set(true)
            vehicleIsLocked:Set(false)
        else
            button.Text = "Spawn"
            isOwnVehicle:Set(false)
        end
        --print(vehicles)
    end))
    maid:GiveTask(onVehicleDelete:Connect(function(key, val)
        NetworkUtil.invokeServer(
            DELETE_VEHICLE,
            key
        )

        local vehicles = NetworkUtil.invokeServer(GET_PLAYER_VEHICLES)
        vehicleList:Set(vehicles)
        --print(vehicles, " dun dun dun?")
    end))

    maid:GiveTask(onHouseClaim:Connect(function(onBack : Signal, houseIndex : number)
        local houses = workspace:WaitForChild("Assets"):WaitForChild("Houses")

        for _, house in pairs(houses:GetChildren()) do
            local currentHouseIndex = house:GetAttribute("Index")
            local claimsModel = house:FindFirstChild("Claims")
            local claimButton = if claimsModel then claimsModel:FindFirstChild("ClaimButton") else nil
            local claimerPointer = if claimButton then claimButton:FindFirstChild("ClaimerPointer") else nil

            if (currentHouseIndex == houseIndex) and (claimerPointer) and (claimerPointer.Value) then
                self:Notify(("House already owned by %s"):format(claimerPointer.Value.Name))
                return
            end
        end
        onBack:Fire()
        NetworkUtil.fireServer(ON_HOUSE_CLAIMED, houseIndex)
    end))

    --setting default backpack to untrue it 
    --game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    return self 
end

function guiSys:Notify(text : string)
   -- print("Test1")
    self.NotificationStatus:Set(nil)
   -- print(self.NotificationStatus:Get())
    task.wait(0.1)
    self.NotificationStatus:Set(text)
   -- print(self.NotificationStatus:Get())
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