--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
--types
export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number,
    DestroyLocked : boolean
}

type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
--constants
local PADDING_SIZE = UDim.new(0,15)
--remotes
--variables
--references
local vehicles = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Vehicles")
local SpawnedCarsFolder = workspace:FindFirstChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild("KeyValue") :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class") :: any,
        IsSpawned = model:IsDescendantOf(SpawnedCarsFolder),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId") :: any,
        DestroyLocked = model:GetAttribute("DestroyLocked") :: any
    }
end
local function getVehiclesData()
    local allVehicles = vehicles:GetChildren()
    local allVehiclesData = {}
    for _,v in pairs(allVehicles) do
        local vehicleData : VehicleData =  getVehicleData(v)
        table.insert(allVehiclesData, vehicleData)
    end
    return allVehiclesData
end
local function getVehicleClasses()
    local classes = {}
    local vehicles = getVehiclesData()
    for _,info in pairs(vehicles) do
        if not table.find(classes, info.Class) then 
            table.insert(classes, info.Class)
        end
    end
    return classes
end

local function getVehicleButton(
    maid : Maid, 
    key : number,
    dynamicVehicleInfo: State<VehicleData ?>,
    onVehicleButtonInteract : Signal,
    isDark : CanBeState<boolean>,
    classFilters : State<{string}>
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)
    

    local dynamicVehicleModel = _Computed(function(vehicleInfo : VehicleData ?)
        local vehicleModel  = if vehicleInfo then 
           vehicles:FindFirstChild(vehicleInfo.Name):Clone()
        else 
            nil

        if vehicleModel then
            vehicleModel:PivotTo(CFrame.new())

            for _,v in pairs(vehicleModel:GetDescendants()) do
                if v:IsA("Script") or v:IsA("ModuleScript") or v:IsA("LocalScript") then
                    v:Destroy() 
                end
            end
        else
            vehicleModel = _new("Part")({
                Transparency = 1
            })
        end
        return vehicleModel
    end, dynamicVehicleInfo)

    local out =_new("ImageButton")({
        BackgroundTransparency = 1,
        Visible = _Computed(function(info : VehicleData?, filters : {string})
            return if info then (if table.find(filters, info.Class) or (#filters == 0) then true else false) else false
        end, dynamicVehicleInfo, classFilters),
        Children = {
            _bind(Sintesa.InterfaceUtil.ViewportFrame.ColdFusion.new(
                maid, 
                dynamicVehicleModel, 
                40, 
                true, 
                isDarkState,
                Sintesa.SintesaEnum.ShapeStyle.ExtraSmall
            ))({
                Size = UDim2.new(1,0,1,0),
                Children = {
                    _new("UIListLayout")({
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                        maid, 
                        1, 
                        _Computed(function(info : VehicleData?)
                            return if info then info.Name else ""
                        end, dynamicVehicleInfo),
                        _Computed(function(dark  : boolean)
                            return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                        end, isDarkState),
                        Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
                        25
                    ))({
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextWrapped = true,
                        Children = {
                            _new("UISizeConstraint")({
                                MaxSize = Vector2.new(70,100)
                            })
                        }
                    })
                }
            })
        },
        Events = {
            Activated = function()
                local vehicleInfo = dynamicVehicleInfo:Get()
                onVehicleButtonInteract:Fire(key, vehicleInfo)
            end
        }
    }) 

    return out
end

--class

return function(
    maid : Maid,

    vehicleList : {[number] : State<VehicleData ?>},
    onVehicleSpawn : Signal,
    onVehicleDelete : Signal,
    
    onBack : Signal,

    isDark : CanBeState<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local width = 380
    --local isVisible = _Value(true) --fixing the wierd state not working thing by attaching it to the properties table for the sake of updating the equip

    local selectedPage = _Value("Vehicles")

    local isDarkState = _import(isDark, isDark)
    local isOnScroll = _Value(false)
    local isSearchVisible = _Value(false)
    local isFilterVisible = _Value(false)

    local classFilters : ValueState<{string}> = _Value({})

    local inputText = _Value("")
    local fillerText = _Value("")

    local onVehicleButtonInteract = maid:GiveTask(Signal.new())

    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)
   
    local header = _bind(Sintesa.Molecules.SmallTopTopAppBar.ColdFusion.new(
        maid, 
        isDarkState, 
        "Vehicle", 
        Sintesa.TypeUtil.createFusionButtonData("Back", Sintesa.IconLists.navigation.arrow_back), 
        {
            Sintesa.TypeUtil.createFusionButtonData("Filter", Sintesa.IconLists.content.filter_list),
            Sintesa.TypeUtil.createFusionButtonData("Search", Sintesa.IconLists.action.search),
        }, 
        isOnScroll, 
        function(buttonData : Sintesa.ButtonData)
            if buttonData.Name == "Search" then
                isSearchVisible:Set(not isSearchVisible:Get())
            elseif buttonData.Name == "Filter" then 
                isFilterVisible:Set(not isFilterVisible:Get())
            elseif buttonData.Name == "Back" then
                onBack:Fire()
            end
        end    
    ))({
        LayoutOrder = 1,
    }) :: GuiObject
    header.Size = UDim2.new(0,width- 50,0,header.Size.Y.Offset)

    local searchContentFrameList = _new("Frame")({
        LayoutOrder = 5,
        BackgroundTransparency = 1,
        --AutomaticSize = Enum.AutomaticSize.Y,
        Visible = _Computed(function(text : string)
            return #text > 0
        end, inputText),
        Size = _Computed(function(filter : boolean, search : boolean)
            return if filter or search then UDim2.fromScale(1, 0.7) else UDim2.fromScale(1, 0.8)
        end, isFilterVisible, isSearchVisible) ,
        Children = {
            _new("UIGridLayout")({
                CellPadding = UDim2.fromOffset(5, 5),
                CellSize = UDim2.fromOffset(100, 100)
            }),
           
        }
    }) :: Frame

    local function searchUpdate(toolSearchText : string)
        for _,v in pairs(searchContentFrameList:GetChildren()) do
            if v:IsA("GuiObject") then
                v:Destroy()
            end
        end 
        fillerText:Set("")
        if toolSearchText:find("%S") ~= nil then
            for k,v in pairs(vehicleList) do
                local vVal = v:Get()
                if vVal and vVal.Name:lower():find(toolSearchText:lower()) then
                    local itemButton = getVehicleButton(maid, k, v, onVehicleButtonInteract, isDarkState, classFilters)
                    itemButton.Parent = searchContentFrameList
                end
            end
        end 
        return toolSearchText
    end
    local searchBarFrame = _bind(Sintesa.Molecules.SearchBar.ColdFusion.new(
        maid, 
        isDarkState, 
        Sintesa.IconLists.search.manage_search, 
        "Search for items by name", 
        width - PADDING_SIZE.Offset*2,
        inputText,
        function()
            searchUpdate(inputText:Get())
        end

    ))({
        LayoutOrder = 3,
        Visible = isSearchVisible
    })
    do
        local t = tick()
        _new("StringValue")({
            Value = _Computed(function(toolSearchText : string)
                t = tick()
                if toolSearchText:find("%S") == nil then 
                    searchUpdate(toolSearchText)
                else
                    task.spawn(function()
                        fillerText:Set("Searching...")
                        task.wait(1)
                        if (tick() - t >= 1) then 
                            fillerText:Set("")
                            searchUpdate(toolSearchText)
                        end
                    end)
                end
                return toolSearchText
            end, inputText)
        })
    end   
    
    local filtersFrameContent =  _new("Frame")({
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.88, 0,0,0),
        Children = {
            _new("UIGridLayout")({
                CellSize = UDim2.fromOffset(100, 25)
            })
        }
    })
    local filtersFrame = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = isFilterVisible,
        Size = UDim2.new(1, 0,0,0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            }),
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                1, 
                "Filter: ", 
                _Computed(function(dark  : boolean)
                    return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                end, isDarkState),
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
                25
            ))({
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.12,0,0,25)
            }),
           filtersFrameContent,
        }
    })

    for k,className in pairs(getVehicleClasses()) do
        _bind(Sintesa.Molecules.FilterChip.ColdFusion.new(
            maid,
            className,
            function()
                local filters = classFilters:Get()
                local cl = table.find(filters, className) 
                if cl then
                    table.remove(filters, cl)
                else
                    table.insert(filters, className)
                end
                classFilters:Set(filters)
            end,
            isDarkState,
            _Computed(function(filters : {string}) 
                return if table.find(filters, className) then true else false
            end, classFilters),
        
            if className == "Motorcycle" then 
                Sintesa.IconLists.maps.two_wheeler
            elseif className == "Vehicle" then 
                Sintesa.IconLists.maps.directions_car
            elseif className == "Boat" then
                Sintesa.IconLists.maps.directions_boat
            else Sintesa.IconLists.social.emoji_transportation
        ))({
            LayoutOrder = k + 1,
            Parent = filtersFrameContent
        })
    end

    local vehicleUIGridLayout =   _new("UIGridLayout")({
        CellPadding = UDim2.fromOffset(5, 5),
        CellSize = UDim2.fromOffset(100, 100)
    }) :: UIGridLayout
    local newVehiclesContentFrame = _new("ScrollingFrame")({
        LayoutOrder = 5,
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Visible = _Computed(function(text : string)
            return #text == 0
        end, inputText),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = _Computed(function(filter : boolean, search : boolean)
            return if filter or search then UDim2.fromScale(1, 0.7) else UDim2.fromScale(1, 0.8)
        end, isFilterVisible, isSearchVisible) ,
        CanvasSize = UDim2.new(),
        Children = {
            vehicleUIGridLayout :: any,
        }
    }) :: ScrollingFrame
   
    for k,v in pairs(vehicleList) do
        local button = getVehicleButton(
            maid,
            k, 
            v,
            onVehicleButtonInteract,
            isDarkState,
            classFilters
        )
        button.Parent = newVehiclesContentFrame
    end
    maid:GiveTask(onVehicleButtonInteract:Connect(function(key : number, vehicleInfo : VehicleData ?)
        if vehicleInfo and vehicleInfo.IsSpawned then
            onVehicleSpawn:Fire(key, vehicleInfo.Name)
        elseif vehicleInfo and not vehicleInfo.IsSpawned then
            onVehicleSpawn:Fire(key, vehicleInfo.Name)
        end
    end))

    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        BackgroundColor3 = containerColorState,
        BackgroundTransparency = 0,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.new(0,width, 1, 0),
        Children = {
            _new("UIPadding")({
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }) ,
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = PADDING_SIZE
            }),
          
            header,
            searchBarFrame,

            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                3, 
                fillerText, 
                _Computed(function(dark  : boolean)
                    return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                end, isDarkState),
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
                25
            ))({
                Visible = _Computed(function(text : string, itext : string)
                    return #text > 0 and #itext > 0
                end, fillerText, inputText),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Children = {
                    _new("UISizeConstraint")({
                        MaxSize = Vector2.new(width,200)
                    })
                }
            }),

            filtersFrame,
            
            searchContentFrameList,

            newVehiclesContentFrame
        }
    }) :: GuiObject
    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
           
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("Frame")({
                LayoutOrder = 0,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.035, 1)
            }),
            contentFrame        
        }
    }) :: Frame

    return out 
end
