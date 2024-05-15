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
local function getItemInfo(
    class : string,
    name : string
)
    return {
        Class = class,
        Name = name
    }
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


local function playAnimation(char : Model, id : number)   
    
    if RunService:IsServer() then
        local plr = Players:GetPlayerFromCharacter(char)
        assert(plr)
        NetworkUtil.fireClient(ON_ANIMATION_SET, plr, char, id)
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

local function getAnimInfo(
    animName : string,
    animId : number
)
    return {
        Name = animName,
        AnimationId = "rbxassetid://" .. tostring(animId)
    }   
end

function getButton(
    maid : Maid,
    buttonName : string,
    activatedFn : () -> (),
    order : number
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("TextButton")({
        Name = buttonName .. "Button",
        LayoutOrder = order,
        BackgroundTransparency = 0,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(0, 0.05),
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        AutoButtonColor = true,
        Font = Enum.Font.Gotham,
        Text = "<b>" .. buttonName .. "</b>",
        TextColor3 = TEXT_COLOR,
        TextScaled = true,
        TextWrapped = true,
        Children = {
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 2.5,
            }),
            _new("UITextSizeConstraint")({
                MaxTextSize = 10,
                MinTextSize = 1
            })
        },
        Events = {
            Activated = function()
                activatedFn()
            end
        }
    })

    return out
end

function getImageButton(
    maid : Maid,
    ImageId : CanBeState<number>,
    activatedFn : () -> (),
    buttonName : CanBeState<string>,
    order : number,
    textAnimated : boolean
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local imageTextPos = _Value(UDim2.fromScale(1.2, 0.5))
    local imageTextTransp = _Value(0.5)

    local ImageIdImported = _import(ImageId, ImageId)

    local interval = 1.8
    local imageText = _new("TextLabel")({
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 0.3),
        Position = imageTextPos:Tween(interval*0.9),
        Font = Enum.Font.GothamBold,
        Text = buttonName,
        TextColor3 = PRIMARY_COLOR,
        TextSize = 11,
        TextStrokeColor3 = SECONDARY_COLOR,
        TextTransparency = imageTextTransp:Tween(interval*0.9),
        TextStrokeTransparency = _Computed(function(transp : number)
            return math.clamp( transp,0.5, 1)
        end, imageTextTransp):Tween(interval*0.9),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if textAnimated then
        local t = tick()
        local animState = "Back"
        maid:GiveTask(RunService.RenderStepped:Connect(function()
            if tick() - t >= interval then
                t = tick()
                imageTextPos:Set(UDim2.fromScale(if animState == "Back" then 1.15 else 1.4, 0.5))
                imageTextTransp:Set(if animState == "Back" then 0 else 0.25)
                animState = if animState == "Back" then "Forth" else "Back"
            end
        end))
    else
        imageTextPos:Set(UDim2.fromScale(0.25, 0.8))
    end

    local button = _new("ImageButton")({
        Name = buttonName,
        LayoutOrder = order,
        BackgroundColor3 = TERTIARY_COLOR,
        ZIndex = -((order - 1)%2),
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.33, 0.06),
        AutoButtonColor = true,
        Image = _Computed(function(imageId : number)
            return "rbxassetid://" .. tostring(imageId)
        end, ImageIdImported) ,
        Children = {
            _new("UISizeConstraint")({
                MaxSize = Vector2.new(40, 40),
                MinSize = Vector2.new(0, 0),
            }),
            _new("UICorner")({}),
            --_new("UIAspectRatioConstraint")({}),
            imageText
        },
        Events = {
            Activated = activatedFn
        }
    })


    return button
end

local function getViewport(
    maid : Maid,

    objectToTrack : Instance
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local currentCam = _new("Camera")({
        CFrame = if objectToTrack:IsA("Model") and objectToTrack.PrimaryPart then 
            CFrame.lookAt(objectToTrack.PrimaryPart.Position + objectToTrack.PrimaryPart.CFrame.LookVector*objectToTrack:GetExtentsSize().Magnitude, objectToTrack.PrimaryPart.Position)
        elseif objectToTrack:IsA("BasePart") then
            CFrame.lookAt(objectToTrack.Position + objectToTrack.CFrame.LookVector*objectToTrack.Size.Magnitude, objectToTrack.Position)
        else
            nil
    })

    local out = _new("ViewportFrame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        CurrentCamera = currentCam,
        Children = {
            _new("UICorner")({}),
            _new("UIStroke")({
                Thickness = 1.5,
                Color = BACKGROUND_COLOR
            }),
            _new("UIAspectRatioConstraint")({}),
        
            currentCam,
            
            _new("WorldModel")({
                Children = {
                    objectToTrack
                }
            })
        }
    })
    return out
end

local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild("KeyValue") :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class"),
        IsSpawned = model:IsDescendantOf(SpawnedCarsFolder),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId"),
        DestroyLocked = model:GetAttribute("DestroyLocked")
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
--class
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

    target : Instance
)    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

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

    local TouchEnabled      = UserInputService.TouchEnabled
    local KeyboardEnabled   = UserInputService.KeyboardEnabled
    local MouseEnabled      = UserInputService.MouseEnabled
    local GamepadEnabled    = UserInputService.GamepadEnabled

    --local viewportMaid = maid:GiveTask(Maid.new())
    local ownershipMaid = maid:GiveTask(Maid.new())
    local statusMaid = maid:GiveTask(Maid.new())

    local houseColor = _Value(Color3.fromRGB())
    local vehicleColor = _Value(Color3.fromRGB())

    local onColorConfirm = maid:GiveTask(Signal.new())
    local onBack = maid:GiveTask(Signal.new())

    local ownershipFrame = _new("Frame")({
        Parent = target,
        AnchorPoint = Vector2.new(0.5,1),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.9, 0.6),
        Size = UDim2.fromScale(0.1, 0.25),
        Children = {
            _new("UIListLayout")({
                Padding = UDim.new(0.1, 0), 
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("Frame")({
                BackgroundColor3 = TEXT_COLOR,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                Visible = _Computed(function(isOwn : boolean)
                    ownershipMaid:DoCleaning()
                    
                    local house = getHouseOfPlayer(Player)
                    if house then
                        local walls = house:FindFirstChild("Walls") 
                        local paints = if walls then walls:FindFirstChild("Paints") else nil
                
                        if paints then
                            for _,v in pairs(paints:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    houseColor:Set(v.Color)
                                    break
                                end
                            end
                        end
                    end
                    return isOwn
                end, isOwnHouse),
                Children = {
                    _new("UIListLayout")({
                        Padding = UDim.new(0.1, 0), 
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.1),
                        Font = Enum.Font.Gotham,
                        Text = "House",
                        TextColor3 = TEXT_COLOR,
                    }),
                    _new("Frame")({
                        LayoutOrder = 2,
                        BackgroundColor3 = TEXT_COLOR,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.5),
                        Children = {
                            _new("UIGridLayout")({
                                FillDirection = Enum.FillDirection.Horizontal,
                                CellPadding = UDim2.fromOffset(5, 5),
                                CellSize = UDim2.fromScale(0.4, 1),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center
                            }),
                            getImageButton(
                                maid, 
                                _Computed(function(isLocked : boolean) 
                                    return if isLocked then 15117261700 else 10695825676
                                end, isHouseLocked), 
                                function()
                                    onHouseLocked:Fire()
                                end, 
                                "", 
                                1, 
                                false
                            ),
                            getImageButton(
                                maid, 
                                12334709462, 
                                function()
                                    ownershipMaid:DoCleaning()
                                    local colorWheel = ColorWheel(
                                        ownershipMaid,

                                        houseColor,

                                        onColorConfirm,
                                        onBack,

                                        "House Color",

                                        function()
                                            return "House"
                                        end
                                    )
                                    colorWheel.Parent = target
                                end, 
                                "", 
                                2, 
                                false
                            )
                        }
                    })
                }
            }),
           _new("Frame")({
                BackgroundColor3 = TEXT_COLOR,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                Visible = _Computed(function(isOwn : boolean)
                    ownershipMaid:DoCleaning()
                    local vehicleModel = getVehicleFromPlayer(Player)
                    if vehicleModel then
                        local bodyModel = vehicleModel:FindFirstChild("Body")
                        local internalBody = if bodyModel then bodyModel:FindFirstChild("Body") else nil
                        local paints = if internalBody then internalBody:FindFirstChild("Paints") else nil

                        if paints then
                            for _,v in pairs(paints:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    vehicleColor:Set(v.Color)
                                    break
                                end
                            end
                        end
                    end
                    
                    return isOwn
                end, isOwnVehicle),
                Children = {
                    _new("UIListLayout")({
                        Padding = UDim.new(0.1, 0), 
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.1),
                        Font = Enum.Font.Gotham,
                        Text = "Vehicle",
                        TextColor3 = TEXT_COLOR,
                    }),
                    _new("Frame")({
                        LayoutOrder = 2,
                        BackgroundColor3 = TEXT_COLOR,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.5),
                        Children = {
                            _new("UIGridLayout")({
                                FillDirection = Enum.FillDirection.Horizontal,
                                CellPadding = UDim2.fromOffset(5, 5),
                                CellSize = UDim2.fromScale(0.4, 1),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center
                            }),
                            getImageButton(
                                maid, 
                                _Computed(function(isLocked : boolean) 
                                    return if isLocked then 15117261700 else 10695825676
                                end, isVehicleLocked), 
                                function()
                                    onVehicleLocked:Fire()
                                end, 
                                "", 
                                1, 
                                false
                            ),
                            getImageButton(
                                maid, 
                                11768918600, 
                                function()
                                    onVehicleSpawn:Fire()
                                end, 
                                "", 
                                2, 
                                false
                            ),
                            getImageButton(
                                maid, 
                                12334709462, 
                                function()
                                    ownershipMaid:DoCleaning()
                                    local colorWheel = ColorWheel(
                                        ownershipMaid,

                                        vehicleColor,

                                        onColorConfirm,
                                        onBack,

                                        "Vehicle Color",

                                        function()
                                            return "Vehicle"
                                        end
                                    )
                                    colorWheel.Parent = target
                                end, 
                                "", 
                                3, 
                                false
                            )
                        }
                    })
                }
            }),
        }
    })

    maid:GiveTask(onColorConfirm:Connect(function(confirmType : "House" | "Vehicle")
        if confirmType == "House" then
            NetworkUtil.invokeServer(ON_HOUSE_CHANGE_COLOR, houseColor:Get())
        elseif confirmType == "Vehicle" then
            NetworkUtil.invokeServer(ON_VEHICLE_CHANGE_COLOR, vehicleColor:Get())
        end
    end))
    maid:GiveTask(onBack:Connect(function()
        ownershipMaid:DoCleaning()
    end))

    local function onThrow()
        if not RunService:IsRunning() then
            return
        end
        for _,v in pairs(backpack:Get()) do
            if v.IsEquipped then
                local toolModel = BackpackUtil.getToolFromName(v.Name)
                if toolModel then
                    --local toolData = BackpackUtil.getData(toolModel, false)
                    --ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                    local toolData = BackpackUtil.getData(toolModel, false)
                    NetworkUtil.fireServer(ON_ITEM_THROW, toolData)
                end
                break
            end
        end  
    end

    local function onDelete()
        if not RunService:IsRunning() then
            return
        end

        for k,v in pairs(backpack:Get()) do
            if v.IsEquipped then
                local toolModel = BackpackUtil.getToolFromName(v.Name)
                if toolModel then
                    --local toolData = BackpackUtil.getData(toolModel, false)
                    --ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                    local toolData = BackpackUtil.getData(toolModel, false)
                    backpackOnDelete:Fire(k, toolData.Name)
                end
                break
            end
        end  
    end

    local onEquipFrame = _new("Frame")({
        LayoutOrder = 1, 
        Parent = target,
        AnchorPoint = Vector2.new(0.5,0.05),
        Visible = _Computed(function(items : {[number] : ToolData})
            local isVisible = false
            for _,v in pairs(items) do
                if v.IsEquipped then
                    isVisible = true
                end
            end
            return isVisible
        end, backpack),
        Position = UDim2.fromScale(0.9, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(10,200,10),
        Size = UDim2.fromScale(0.15, 1),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0.025, 0), 
            }),
            --[[_new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1),
                Font = Enum.Font.Gotham,
                Text = _Computed(function(items : {[number] : ToolData})
                    local text = "" 
                    for _,v in pairs(items) do
                        if v.IsEquipped then
                            text = v.Name
                            break
                        end
                    end
                    return text
                end, backpack),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,

                TextScaled = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = 25
                    })
                }
            }),]]
          
            _bind(getButton(
                maid,
                "INTERACT" ,
                function()
                    if not RunService:IsRunning() then
                        return
                    end
                    for _,v in pairs(backpack:Get()) do
                        if v.IsEquipped then
                            local toolModel = BackpackUtil.getToolFromName(v.Name)
                            if toolModel then
                                local toolData = BackpackUtil.getData(toolModel, false)
                                ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                            end
                            break
                        end
                    end  
                end,
                3
            ))({
                AutomaticSize = Enum.AutomaticSize.None,
                Size = UDim2.fromScale(1, 0.1),
                Children = {
                    _new("UIStroke")({
                        Color = PRIMARY_COLOR,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1
                    }),
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),
                    _new("TextLabel")({
                        BackgroundColor3 = SECONDARY_COLOR,
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(0.75, 0.3),
                        Font = Enum.Font.Gotham,
                        Text = if KeyboardEnabled then "L Click" elseif TouchEnabled then "Touch" elseif GamepadEnabled then "A" else nil,
                        TextScaled = true,
                        TextColor3 = PRIMARY_COLOR
                    }),

                }
            }),
            _bind(getButton(
                maid,
                "THROW" ,
                onThrow,
                4
            ))({
                AutomaticSize = Enum.AutomaticSize.None,
                Size = UDim2.fromScale(1, 0.1),
                Children = {
                    _new("UIStroke")({
                        Color = PRIMARY_COLOR,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1
                    }),
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),
                    _new("TextLabel")({
                        BackgroundColor3 = SECONDARY_COLOR,
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(0.75, 0.3),
                        Font = Enum.Font.Gotham,
                        Text = if KeyboardEnabled then "F" elseif TouchEnabled then "Touch" elseif GamepadEnabled then "B" else nil,
                        TextScaled = true,
                        TextColor3 = PRIMARY_COLOR
                    }),

                }
            }),
            _bind(getButton(
                maid,
                "X" ,
                onDelete,
                5
            ))({
                BackgroundColor3 = Color3.fromRGB(255,50,50),
                AutomaticSize = Enum.AutomaticSize.None,
                TextScaled = true,
                Size = UDim2.fromScale(0.45, 0.05),
                Children = {
                    _new("UIStroke")({
                        Color = PRIMARY_COLOR,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1
                    }),
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),
                    _new("TextLabel")({
                        BackgroundColor3 = SECONDARY_COLOR,
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(0.75, 0.3),
                        Font = Enum.Font.Gotham,
                        Text = if KeyboardEnabled then "X" elseif TouchEnabled then "Touch" elseif GamepadEnabled then "X" else nil,
                        TextScaled = true,
                        TextColor3 = PRIMARY_COLOR
                    }),

                }
            }),
            --[[_bind(getButton(
                maid,
                "X" ,
                function()
                    for k,v in pairs(backpack:Get()) do
                        if v.IsEquipped == true then
                            backpackOnEquip:Fire(k)
                            break
                        end
                    end  
                   
                end,
                5
            ))({
                BackgroundColor3 = Color3.fromRGB(255,10,10),
                Size = UDim2.fromScale(1, 0.05),
                TextColor3 = PRIMARY_COLOR
            })]]
            --[[_new("TextButton")({
                LayoutOrder = 3,
                AutoButtonColor = true,
                BackgroundTransparency = 0,
                Size = UDim2.fromScale(1, 0.05),
                RichText = true,
                Text = "<b>INTERACT</b>",
                TextColor3 = SECONDARY_COLOR,
                Children = {
                    _new("UICorner")({})
                },
                Events = {
                    Activated = function()      
                        for _,v in pairs(backpack:Get()) do
                            if v.IsEquipped then
                                local toolModel = BackpackUtil.getToolFromName(v.Name)
                                if toolModel then
                                    local toolData = BackpackUtil.getData(toolModel, false)
                                    ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                                end
                                break
                            end
                        end  
                        --ToolActions.onToolActivated(, foodInst, player, toolData)
                    end
                }
            })]]
        }
    })

    if RunService:IsRunning() then
        InputHandler:Map("ThrowItemConsole", "Keyboard", {Enum.KeyCode.F}, "Press", onThrow, function()

        end)
        InputHandler:Map("ThrowItemPC", "Console", {Enum.KeyCode.ButtonB}, "Press", onThrow, function()

        end)

        InputHandler:Map("DeleteItemConsole", "Keyboard", {Enum.KeyCode.X}, "Press", onDelete, function()

        end)
        InputHandler:Map("DeleteItemPC", "Console", {Enum.KeyCode.ButtonX}, "Press", onDelete, function()

        end)
       
    end
    --[[local val =  _Computed(function(backpackList : {[number] : ToolData})
        viewportMaid:DoCleaning()
        local object 
        
        for _,v in pairs(backpackList) do
            if v.IsEquipped then
                local oriobject = BackpackUtil.getToolFromName(v.Name)
                if oriobject then object = oriobject:Clone() end 
                break
            end
        end
        
        if object then
            _bind(getViewport(
                viewportMaid,
                object 
            ))({
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.1),
                Parent = onEquipFrame
            })
        end  
        return ""
    end, backpack)

    _new("StringValue")({
        Value = val
    })]]

    
    local dateFrame = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.9, 1),
        Visible = _Computed(function(status : UIStatus)
            return status == nil 
        end, UIStatus),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Children = {
                    _new("TextLabel")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(10, 1),
                        Text = date,
                        TextScaled = true,
                        TextSize = 100,
                        TextColor3 = TEXT_COLOR,
                        TextStrokeTransparency = 0.5,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        Children = {
                            _new("UITextSizeConstraint")({
                                MinTextSize = 5,
                                MaxTextSize = 25
                            })
                        }
                    })
                }
            })
        }
    })

    local backpackText = _Value("")
    local roleplayText = _Value("")
    local customizationText = _Value("")
    local vehicleText = _Value("")
    local houseText = _Value("")

    local alertColor = _Value(Color3.fromRGB(255,50,50))

    local mainOptions =  _new("Frame")({
        LayoutOrder = 0,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.1, 0.4),
        Position = UDim2.fromScale(0, 0),   
        Children = {
            _new("Frame")({
                Name = "BufferFrame",
                BackgroundTransparency = 1,  
                Position = UDim2.fromScale(0, 0.37),
                Size = UDim2.fromScale(0.92, 0.8),
                Children = {
                    _new("UIGridLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        CellSize = UDim2.fromScale(0.4, 0.2),  
                        StartCorner = Enum.StartCorner.TopLeft, 
                        VerticalAlignment = Enum.VerticalAlignment.Top   
                    }),   
                   --[[ _new("Frame")({
                        LayoutOrder = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.48)
                    }),]]
                   _bind(getImageButton(maid, 2815418737, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Backpack" then "Backpack" else nil)
                        backpackText:Set("")
                        roleplayText:Set("")
                        customizationText:Set("")
                        vehicleText:Set("")
                        houseText:Set("")
        
                        if RunService:IsRunning() then
                            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "backpack_button")
                        end
                    end, backpackText, 2, true))({
                        Children = {
                            --[[_new("TextLabel")({
                                BackgroundTransparency = _Computed(function(backpackList : {[number] : ToolData})
                                    task.spawn(function()
                                        alertColor:Set(PRIMARY_COLOR)
                                        task.wait(0.1)
                                        alertColor:Set(SECONDARY_COLOR)
                                    end)
                                    return 0.1
                                end, backpack),
                                BackgroundColor3 = alertColor:Tween(0.1),
                                Position = UDim2.fromScale(0.7, 0.7),
                                Size = UDim2.fromScale(0.4, 0.4),
                                RichText = true,
                                TextColor3 = TEXT_COLOR,
                                Text = _Computed(function(backpackList : {[number] : ToolData})
                                    return "<b>" .. #backpackList .. "</b>"
                                end, backpack),
                                TextScaled = true,
                                Children = {
                                    _new("UICorner")({
                                        CornerRadius = UDim.new(1,0)
                                    })
                                }
                            })]]
                        },
                        Events = {
                            MouseEnter = function()
                                backpackText:Set("← Tools")
                            end,
                            MouseLeave = function()
                                backpackText:Set("")
                            end
                        }
                    }),
                    _bind(getImageButton(maid, 11955884948, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Roleplay" then "Roleplay" else nil)
                        backpackText:Set("")
                        roleplayText:Set("")
                        customizationText:Set("")
                        vehicleText:Set("")
                        houseText:Set("")
        
                        if RunService:IsRunning() then
                            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "roleplay_button")
                        end
                    end, roleplayText, 3, true))({
                        Events = {
                            MouseEnter = function()
                                roleplayText:Set("← Actions")
                            end,
                            MouseLeave = function()
                                roleplayText:Set("")
                            end
                        }
                    }),
                    _bind(getImageButton(maid, 13285102351, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Customization" then "Customization" else nil)
                        backpackText:Set("")
                        roleplayText:Set("")
                        customizationText:Set("")
                        vehicleText:Set("")
                        houseText:Set("")
        
                        if RunService:IsRunning() then
                            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "customization_button")
                        end
                    end, customizationText, 1, true))({
                        Events = {
                            MouseEnter = function()
                                customizationText:Set("← Customization")
                            end,
                            MouseLeave = function()
                                customizationText:Set("")
                            end
                        }
                    }),
                   
                    _bind(getImageButton(maid, 279461710, function()
                        UIStatus:Set(if UIStatus:Get() ~= "House" then "House" else nil)
                        backpackText:Set("")
                        roleplayText:Set("")
                        customizationText:Set("")
                        vehicleText:Set("")
                        houseText:Set("")
                        
                        if RunService:IsRunning() then
                            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "house_button")
                        end
                    end, houseText, 1, true))({
                        Events = {
                            MouseEnter = function()
                                houseText:Set("← House")
                            end,
                            MouseLeave = function()
                                houseText:Set("")
                            end
                        }
                    }),
                    _bind(getImageButton(maid, 7013364587, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Vehicle" then "Vehicle" else nil)
                        backpackText:Set("")
                        roleplayText:Set("")
                        customizationText:Set("")
                        vehicleText:Set("")
                        houseText:Set("")
                        
                        if RunService:IsRunning() then
                            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "vehicle_button")
                        end
                    end, vehicleText, 1, true))({
                        Events = {
                            MouseEnter = function()
                                vehicleText:Set("← Vehicle")
                            end,
                            MouseLeave = function()
                                vehicleText:Set("")
                            end
                        }
                    }),
                    _new("Frame")({
                        BackgroundTransparency = 1,
                        LayoutOrder = 6,
                        Size = UDim2.fromScale(1, 0.48)
                    }),
                    _bind(dateFrame)({
                        LayoutOrder = 7,
                        Size = UDim2.fromScale(2, 0.05)
                    })
                }
            }),
            
        }
    }) :: Frame

    local JobFrame = _new("Frame")({
        BackgroundTransparency = 1,
        Visible = _Computed(function(job : Jobs.JobData ?)
            return if job ~= nil then true else false
        end, currentJob),
        AnchorPoint = Vector2.new(0.5,0.5),
        Size = UDim2.fromScale(0.2, 0.05),
        Position = UDim2.fromScale(0.5, 0.2),
        Parent = target,
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _bind(getButton(
                maid, 
                "Quit Job", 
                function()
                    onJobChange:Fire()
                end, 
                1
            ))({
                AutomaticSize = Enum.AutomaticSize.None,
                TextWrapped = true,
                Size = UDim2.fromScale(0.6, 1),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextScaled = true,
                Children = {
                    _new("UIStroke")({
                        Color = PRIMARY_COLOR,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1
                    })
                },
            }),
        }
    })
    local out = _new("Frame")({
        Name = "MainUI",
        Parent = target,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            --dateFrame,
            
            mainOptions,
            --secondaryOptions
        }
    }) :: Frame

    local isExitButtonVisible = _Value(true)
    
    local function getExitButton(ui : GuiObject)
        local exitButton = ExitButton.new(
            ui:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            function()
                UIStatus:Set(nil)
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
                return nil 
            end
        ) 
        exitButton.Instance.Parent = ui:FindFirstChild("ContentFrame")
    end

    local housesList = {}

    if RunService:IsRunning() then
        for _,house in pairs(HousesFolder:GetChildren()) do
            local houseIndex = house:GetAttribute("Index")
            if houseIndex then
                housesList[houseIndex] = house 
            end
        end
    end

    local houseIndex = _Value(1)
    local houseName = _Value("House 1")

    
    local function updateCamCf()
        if RunService:IsRunning() then
            local camera = workspace.CurrentCamera
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

    local onCatalogTry = maid:GiveTask(Signal.new())
    local onCustomizeColor = maid:GiveTask(Signal.new())
    local onCatalogDelete = maid:GiveTask(Signal.new())
    local onCatalogBuy = maid:GiveTask(Signal.new())

    local onCustomizationSave = maid:GiveTask(Signal.new())
    local onSavedCustomizationLoad = maid:GiveTask(Signal.new())
    local onSavedCustomizationDelete = maid:GiveTask(Signal.new())

    local onScaleChange = maid:GiveTask(Signal.new())
    local onScaleConfirmChange = maid:GiveTask(Signal.new())

    local onRPNameChange = maid:GiveTask(Signal.new())
    local onDescChange = maid:GiveTask(Signal.new())
    
    local onHouseNext = maid:GiveTask(Signal.new())
    local onHousePrev = maid:GiveTask(Signal.new())
    local onHouseBack = maid:GiveTask(Signal.new())

    local saveList = _Value({})

    local strval = _Computed(function(status : UIStatus)
        statusMaid:DoCleaning() 

        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

        mainOptions.Visible = (status == nil) 
        if status == "Backpack" then
            local onBackpackButtonAddClickSignal = statusMaid:GiveTask(Signal.new())
            local onBackpackButtonDeleteClickSignal = statusMaid:GiveTask(Signal.new())

            statusMaid:GiveTask(onBackpackButtonAddClickSignal:Connect(function(toolData : ToolData)
                backpackOnAdd:Fire(toolData)
               
            end))
            statusMaid:GiveTask(onBackpackButtonDeleteClickSignal:Connect(function(toolKey : number, toolName : string)
                backpackOnDelete:Fire(toolKey, toolName)
            end))

            local backpackUI = BackpackUI(
                statusMaid,
                backpack,

                onBackpackButtonAddClickSignal,
                onBackpackButtonDeleteClickSignal
            )

            backpackUI.Parent = out
            
            getExitButton(backpackUI)
            if game:GetService("RunService"):IsRunning() then
                backpack:Set(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))
                vehiclesList:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            end
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        elseif status == "Roleplay" then 
            local jobsList = Jobs.getJobs()

            local onAnimClickSignal = statusMaid:GiveTask(Signal.new())
            local roleplayUI = RoleplayUI(
                statusMaid, 
                {
                    getAnimInfo("Dance1", 6487673963),
                    getAnimInfo("Dance2", 6487678676),
                    getAnimInfo("Get Out", 6487639560),
                    getAnimInfo("Happy", 6487656144),
                    getAnimInfo("Laugh", 6487643897),
                    getAnimInfo("No", 6487627276),
                    getAnimInfo("Point", 507770453),
                    getAnimInfo("Sad", 6487647687),
                    getAnimInfo("Shy", 6487659854),
                    getAnimInfo("Standing", 6485373010),
                    getAnimInfo("Wave", 507770239),
                    getAnimInfo("Yawning", 6487651939),
                    getAnimInfo("Yes", 6487622514),

                },
                onAnimClickSignal,
                onItemCartSpawn,
                onJobChange,
                backpack,
                jobsList,
                UIStatus :: any
            ) :: Frame
            roleplayUI.Parent = out
            statusMaid:GiveTask(onAnimClickSignal:Connect(function(animInfo : AnimationInfo)
                AnimationUtil.playAnim(Players.LocalPlayer, animInfo.AnimationId, false)
            end))

            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
            --getExitButton(roleplayUI)
        elseif status == "Customization" then
            local isVisible =_Value(true)
            local customizationUI = NewCustomizationUI(
                statusMaid,

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

                saveList,

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

            customizationUI.Parent = target

            statusMaid:GiveTask(_new("StringValue")({
                Value = _Computed(function(visible : boolean)
                    if not visible then
                        UIStatus:Set()
                        --print(UIStatus:Get(), ' noradivomo??')
                    end
                    return ""
                end, isVisible)
            }))

            saveList:Set(NetworkUtil.invokeServer(GET_CHARACTER_SLOT)) 
        elseif status == "House" then            
            local houseUI = HouseUI(
                statusMaid, 
                houseIndex, 
                houseName, 
                onHouseNext, 
                onHousePrev,
                onHouseClaim,
                onHouseBack,
                1,
                #housesList
            )
            houseUI.Parent = target

            updateCamCf()
        elseif status == "Vehicle" then
            local vehicleUI = VehicleUI(
                statusMaid,
                
                newVehiclesListVersion,

                onVehicleSpawn,
                onVehicleDelete
            ) 
            vehicleUI.Parent = out

            getExitButton(vehicleUI)
        end
        return ""
    end, UIStatus)

    
    local loadingMaid = maid:GiveTask(Maid.new())
    maid:GiveTask(onCatalogTry:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType)

        LoadingFrame(loadingMaid, "Applying the change").Parent = target
        CustomizationUtil.Customize(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        char:Set(getCharacter(true))

        local s, e = pcall(function()
            playAnimation(char:Get(), catalogInfo.Id)
        end) -- temp read failed
        if not s and (type(e) == "string") then
            warn("Error loading animation: " .. tostring(e))
        end

        loadingMaid:DoCleaning()
    end))

    maid:GiveTask(onCustomizeColor:Connect(function(color : Color3, char : ValueState<Model>)
        CustomizationUtil.CustomizeBodyColor(Player, color)
        char:Set(getCharacter(true))
        return
    end))

    maid:GiveTask(onCatalogDelete:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType) 
        CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        char:Set(getCharacter(true))
    end))

    maid:GiveTask(onCatalogBuy:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        MarketplaceService:PromptPurchase(Player, catalogInfo.Id)
        --CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        --char:Set(getCharacter(true))
    end))


    maid:GiveTask(onCustomizationSave:Connect(function()
        local saveData = NetworkUtil.invokeServer(SAVE_CHARACTER_SLOT)
        saveList:Set(saveData)
    end))

    local notifMaid = maid:GiveTask(Maid.new())
    maid:GiveTask(onSavedCustomizationLoad:Connect(function(k, content)
        notifMaid:DoCleaning()
        local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure to load this character slot (Save " .. tostring(k) .. ")?", false, function()
            notifMaid:DoCleaning()
            local loadingFrame =  LoadingFrame(loadingMaid, "Loading the character")
            loadingFrame.Parent = target
            local pureContent = table.clone(content)
            pureContent.CharModel = nil
            local saveData =  NetworkUtil.invokeServer(LOAD_CHARACTER_SLOT, k, pureContent)
            saveList:Set(saveData)
            content.CharModel:Set(getCharacter(true)) 
            loadingMaid:DoCleaning()
        end, function()
            notifMaid:DoCleaning()
        end)
        notif.Parent = target

    end))

    maid:GiveTask(onSavedCustomizationDelete:Connect(function(k, content)
        notifMaid:DoCleaning()
        local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure to remove this character slot (Save " .. tostring(k) .. ") forever?", false, function()
            notifMaid:DoCleaning()
            local saveData = NetworkUtil.invokeServer(DELETE_CHARACTER_SLOT, k, content)
            saveList:Set(saveData)
            loadingMaid:DoCleaning()
        end, function()
            notifMaid:DoCleaning()
        end)
        notif.Parent = target

    end))

    maid:GiveTask(onScaleChange:Connect(function(humanoidDescProperty : string, value : number, char : ValueState<Model>, isPreview : boolean)
        loadingMaid:DoCleaning()
        local character = getCharacter(true)
        --local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        -- character.Parent = workspace
        --if humanoidDescProperty == "HeadScale" then
        --    local headScale  = humanoid:WaitForChild("HeadScale") :: NumberValue
        --    headScale.Value = value 
        --    print(headScale)
        --end
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

    maid:GiveTask(onScaleConfirmChange:Connect(function(characterData, char : ValueState<Model>)
        loadingMaid:DoCleaning()
        local loadingFrame = LoadingFrame(loadingMaid, "Applying Character Scales")
        loadingFrame.Parent = target
        
        local character = Player.Character
        CustomizationUtil.SetInfoFromCharacter(character, characterData)

       
        loadingMaid:DoCleaning()
    end))


    maid:GiveTask(onRPNameChange:Connect(function(inputted : string)
        print("On RP Change :", inputted) 
        NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerName", inputted)
    end))
    maid:GiveTask(onDescChange:Connect(function(inputted : string)
        print("On Desc change :", inputted)
        NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerBio", inputted)
    end))

    if RunService:IsRunning() then
        local camera = workspace.CurrentCamera
        
        maid:GiveTask(onHouseNext:Connect(function()
            houseIndex:Set(houseIndex:Get() + 1) 

            updateCamCf()
        end))
        maid:GiveTask(onHousePrev:Connect(function()
            houseIndex:Set(houseIndex:Get() - 1)

            updateCamCf()
        end))

        maid:GiveTask(onHouseBack:Connect(function()
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = Players.LocalPlayer.Character:WaitForChild("Humanoid")
            UIStatus:Set()
        end))
    end

    local strVal = _new("StringValue")({
        Value = strval  
    })

    return out
end
