--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules

local ColorWheel = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColorWheel"))
--types
type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

type Maid = Maid.Maid
type Signal = Signal.Signal
--constants
local PADDING_SIZE =  UDim.new(0, 10)
--remotes
local SEND_ANALYTICS = "SendAnalytics"
--variables
--references
--local functions
--class
return function(
    maid : Maid,

    isDark : CanBeState<boolean>,

    houseColor : ValueState<Color3>,
    vehicleColor : ValueState<Color3>,

    isOwnHouse : ValueState <boolean>,
    isOwnVehicle : ValueState <boolean>,
    isHouseLocked : ValueState<boolean>,
    isVehicleLocked : ValueState<boolean>,

    onHouseLocked : Signal,
    onVehicleLocked : Signal,

    onVehicleSpawn : Signal,

    onColorConfirm : Signal,

    target : Instance
    )

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _import = _fuse.import

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local ownershipMaid = maid:GiveTask(Maid.new())

    local isDarkState = _import(isDark, isDark)

    --local isSelected = _Value(false)
    local onOwnershipPageBack = maid:GiveTask(Signal.new())
    
    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surfaceContainerHigh())
    end, isDarkState)

    local height = 50
    local onVehicleLock = function()
        onVehicleLocked:Fire()
    end
    local onVehiclePaint = function()
        ownershipMaid:DoCleaning()
        local colorWheel = ColorWheel(
            ownershipMaid,
            isDarkState,

            vehicleColor,

            onColorConfirm,
            onOwnershipPageBack,

            "Vehicle Color",

            function()
                return "Vehicle"
            end
        )
        colorWheel.Parent = target
    end

    local onVehicleDelete = function()
        onVehicleSpawn:Fire()
    end

    local onHouseLock = function()
        onHouseLocked:Fire()
    end
    local onHousePaint = function()
        ownershipMaid:DoCleaning()
        local colorWheel = ColorWheel(
            ownershipMaid,

            isDarkState,

            houseColor,

            onColorConfirm,
            onOwnershipPageBack,

            "House Color",

            function()
                return "House"
            end
        )
        colorWheel.Parent = target
    end

    local vehicleSettingUI = _new("Frame")({
        LayoutOrder = 1,
        Visible = isOwnVehicle,
        BackgroundTransparency = 1,
        --BackgroundColor3 = containerColorState,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(height, 0),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                0, 
                "Vehicle",
                containerColorState,
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.BodyMedium)), 
                15
            ))({Size = UDim2.new(0,height,0,0), TextXAlignment = Enum.TextXAlignment.Left}),
            _new("Frame")({
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _bind(Sintesa.Molecules.FAB.ColdFusion.new(
                        maid, 
                        _Computed(function(locked : boolean) 
                            return if locked then Sintesa.IconLists.action.lock else Sintesa.IconLists.action.lock_open
                        end, isVehicleLocked), 
                        onVehicleLock,
                        isDarkState,
                        40
                    ))({
                        LayoutOrder = 1
                    }),
                    _bind(Sintesa.Molecules.FAB.ColdFusion.new(
                        maid, 
                        Sintesa.IconLists.editor.format_color_fill, 
                        onVehiclePaint,
                        isDarkState,
                        40
                    ))({
                        LayoutOrder = 2
                    }),
                    _bind(Sintesa.Molecules.FAB.ColdFusion.new(
                        maid, 
                        Sintesa.IconLists.action.delete, 
                        onVehicleDelete,
                        isDarkState,
                        40
                    ))({
                        LayoutOrder = 3
                    }),
                }
            })
        }
    })
    
    local houseSettingUI = _new("Frame")({
        LayoutOrder = 2,
        Visible = isOwnHouse,
        BackgroundTransparency = 1,
        --BackgroundColor3 = containerColorState,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(height, 0),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                0, 
                "House",
                containerColorState,
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.BodyMedium)), 
                15
            ))({Size = UDim2.new(0,height,0,0), TextXAlignment = Enum.TextXAlignment.Left}),
            _new("Frame")({
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _bind(Sintesa.Molecules.FAB.ColdFusion.new(
                        maid, 
                        _Computed(function(locked : boolean) 
                            return if locked then Sintesa.IconLists.action.lock else Sintesa.IconLists.action.lock_open
                        end, isHouseLocked), 
                        onHouseLock,
                        isDarkState,
                        40
                    ))({
                        LayoutOrder = 1
                    }),
                    _bind(Sintesa.Molecules.FAB.ColdFusion.new(
                        maid, 
                        Sintesa.IconLists.editor.format_color_fill, 
                        onHousePaint,
                        isDarkState,
                        40
                    ))({
                        LayoutOrder = 2
                    }),
                }
            }),
           
        }
    })

    local content = _new("Frame")({
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(height, 0),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            }),
            houseSettingUI,
            vehicleSettingUI
        }
    })
    local out = _new("Frame")({
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = target,
        Children = {       
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            content   
        }
    })

    maid:GiveTask(onOwnershipPageBack:Connect(function()
        ownershipMaid:DoCleaning()
    end))

    return out
end
