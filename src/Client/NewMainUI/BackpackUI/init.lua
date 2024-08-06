--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService= game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
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

type ToolData = BackpackUtil.ToolData<boolean>

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local PADDING_SIZE = UDim.new(0,15)
--remotes
--variables
--references
--local functions
local function getItemData()
    local allItems = CollectionService:GetTagged("Tool")
    local allItemsData = {}
    for _,v in pairs(allItems) do
        if not v:GetAttribute("DescendantsAreTools") then
            local toolData : ToolData = BackpackUtil.getData(v, true) :: any
            local toolAlreadyCollected = false
            for _,v in pairs(allItemsData) do
                if v.Name == toolData.Name then  
                    toolAlreadyCollected = true
                    break
                end
            end
            if not toolAlreadyCollected then
                table.insert(allItemsData, toolData)
            end
        end
    end
  
    return allItemsData
end

local function getItemButton(
    maid : Maid, 
    key : number,
    itemInfo: ToolData,
    onBackpackButtonAddClickSignal : Signal,
    isDark : CanBeState<boolean>
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)
    local viewportVisualZoom = 0.75

    local toolModel = BackpackUtil.getToolFromName(itemInfo.Name) 
    if toolModel then 
        toolModel = toolModel:Clone()
    end


    if not game:GetService("RunService"):IsRunning() then
        if not toolModel then
            local part = _new("Part")({
                CFrame = CFrame.new(),
                Size = Vector3.new(1,1,1)
            })

            toolModel = _new("Model")({
                PrimaryPart = part,
                Children = {
                    part
                }
            }) :: Model
        end
    end

    assert(toolModel)
    for _,v in pairs(toolModel:GetDescendants()) do
        if v:IsA("Script") or v:IsA("ModuleScript") or v:IsA("LocalScript") then
            v:Destroy() 
        end
    end

    if toolModel:IsA("BasePart") then
        viewportVisualZoom *= toolModel.Size.Magnitude*1.5
    elseif toolModel:IsA("Model") then
        viewportVisualZoom *= toolModel:GetExtentsSize().Magnitude*1
    end


    local out2 =_new("ImageButton")({
        BackgroundTransparency = 1,
        Children = {
            _bind(Sintesa.InterfaceUtil.ViewportFrame.ColdFusion.new(
                maid, 
                toolModel, 
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
                        itemInfo.Name, 
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
                onBackpackButtonAddClickSignal:Fire(itemInfo)
            end
        }
    }) 
    return out2
end

local function getItemTypeFrame(
    maid : Maid, 
    typeName : string,
    Items : State<{
        [number] : ToolData & {Key : number}
    }>,
    onBackpackButtonAddClickSignal : Signal,
    frameOrder : number,
    isDark : CanBeState<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)

    local itemFrameList = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0),
        Children = {
            _new("UIGridLayout")({
                CellPadding = UDim2.fromOffset(5, 5),
                CellSize = UDim2.fromOffset(100, 100)
            }),
        }
    }) :: Frame

    local out = _new("Frame")({
        LayoutOrder = frameOrder,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            }),
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(maid, 1, typeName, _Computed(function(dark : boolean)
                return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())  
            end, isDarkState), Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.TitleMedium)), 
            25),
            itemFrameList,
            _bind(Sintesa.Molecules.Divider.ColdFusion.new(maid, isDark))({
                LayoutOrder = 4
            })
        }
    }) :: Frame

 
    Items:ForValues(function(v : ToolData & {Key : number}, pairMaid : Maid)
        local _pairFuse = ColdFusion.fuse(pairMaid)
        local _pairValue = _pairFuse.Value

        local itemButton = getItemButton(
            pairMaid,
            v.Key,  
            v,
            onBackpackButtonAddClickSignal,
            isDarkState
        )
        
        itemButton.Parent = itemFrameList
        return v
    end)
    return out
end

--class
return function(
    maid : Maid,
    itemsOwned : ValueState<{[number] : ToolData}>,

    onBackpackButtonAddClickSignal : Signal,
    onBackpackButtonDeleteClickSignal : Signal,

    onBack : Signal,

    isDark : CanBeState<boolean>)


    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    itemsOwned = _Value(itemsOwned:Get())
    local width = 380

    local itemTypes = BackpackUtil.getAllItemClasses()

    local isDarkState = _import(isDark, isDark)
    local isVisible = _Value(true) --fixing the wierd state not working thing by attaching it to the properties table for the sake of updating the equip
    
    local isOnScroll = _Value(false)

    local inputText = _Value("")
    local fillerText = _Value("")

    local isSearchVisible = _Value(false)

    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)
   
    local header = _bind(Sintesa.Molecules.SmallTopTopAppBar.ColdFusion.new(
        maid, 
        isDarkState, 
        "Item", 
        Sintesa.TypeUtil.createFusionButtonData("Back", Sintesa.IconLists.navigation.arrow_back), 
        {
            Sintesa.TypeUtil.createFusionButtonData("Search", Sintesa.IconLists.action.search),
        }, 
        isOnScroll, 
        function(buttonData : Sintesa.ButtonData)
            if buttonData.Name == "Search" then
                isSearchVisible:Set(not isSearchVisible:Get())
            elseif buttonData.Name == "Back" then
                onBack:Fire()
            end
        end    
    ))({
        LayoutOrder = 1,
    })
    header.Size = UDim2.new(0,width- 27,0,header.Size.Y.Offset)
    
    local backpackUIListLayout =  _new("UIListLayout")({
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = PADDING_SIZE
    }) :: UIListLayout
    local backpackContentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        LayoutOrder = 4,
        Visible = _Computed(function(text : string)
            return #text == 0 
        end, inputText),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(1,1),
        Children = {
            backpackUIListLayout
        }
    }) :: ScrollingFrame

    local backpackSearchUIListLayout = _new("UIListLayout")({
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = PADDING_SIZE
    }) :: UIListLayout
    local searchContentFrameList = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0),
        Children = {
            _new("UIGridLayout")({
                CellPadding = UDim2.fromOffset(5, 5),
                CellSize = UDim2.fromOffset(100, 100)
            }),
           
        }
    }) :: Frame
    local searchContentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        LayoutOrder = 4,
        Visible = _Computed(function(text : string)
            return #text > 0
        end, inputText),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(1,0),
        Children = {
            _new("UIPadding")({
                -- PaddingBottom = PADDING_SIZE,
                -- PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            backpackSearchUIListLayout,
            searchContentFrameList
        }
    }) :: ScrollingFrame

    local function searchUpdate(toolSearchText : string)
        for _,v in pairs(searchContentFrameList:GetChildren()) do
            if v:IsA("GuiObject") then
                v:Destroy()
            end
        end 
        fillerText:Set("")
        if toolSearchText:find("%S") ~= nil then
            local toolsData = getItemData()

            for k,v in pairs(toolsData) do
                if v.Name:lower():find(toolSearchText:lower()) then
                    local itemButton = getItemButton(maid, k, v, onBackpackButtonAddClickSignal, isDarkState)
                    itemButton.Parent = searchContentFrameList
                end
            end
        end 
        return toolSearchText
    end

    local searchBarFrame = _new("Frame")({
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, width, 0, 0),
        BackgroundColor3 = containerColorState,
        Children = {
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
            _bind(Sintesa.Molecules.SearchBar.ColdFusion.new(
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
                LayoutOrder = 2,
                Visible = isSearchVisible
            })
        }
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
   
    local headerFrame = _new("Frame")({
        LayoutOrder = 1,
        Name = "ContentFrame",
        Visible = isVisible,
        --BackgroundColor3 = containerColorState,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.new(0,width,0,0),
        Children = {
           
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top
            }),
            header,
            searchBarFrame,
            _new("Frame")({
                LayoutOrder = 2, 
                Name = "Buffer",
                BackgroundColor3 = containerColorState,
                Size = UDim2.new(0, width, 0, 6)
            }),
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
                LayoutOrder = 3,
                Visible = _Computed(function(text : string, itext : string)
                    return #text > 0 and #itext > 0
                end, fillerText, inputText),
                BackgroundTransparency = 0,
                BackgroundColor3 = containerColorState,
                Size = UDim2.new(0, width, 0, 25),
                TextWrapped = true,
                Children = {
                    _new("UISizeConstraint")({
                        MaxSize = Vector2.new(width,200)
                    })
                }
            }),
            -- searchContentFrame,
            -- backpackContentFrame
        }
    }) :: GuiObject

    local contentFrame = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        --AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(0, width, 0, 0),
        Children = {
            _new("UIPadding")({
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top
            }),
            searchContentFrame,
            backpackContentFrame
        }
    })

    for k,typeName in pairs(itemTypes) do
        local itemsFiltered = _Computed(function(items : {[number] : ToolData})
            local allItems = CollectionService:GetTagged("Tool")
            local allItemsData = {}
            for _,v in pairs(allItems) do 
                if not v:GetAttribute("DescendantsAreTools") then
                    local toolData : ToolData = BackpackUtil.getData(v, true) :: any
                    local toolAlreadyCollected = false
                    for _,v in pairs(allItemsData) do
                        if v.Name == toolData.Name then  
                            toolAlreadyCollected = true
                            break
                        end
                    end
                    if not toolAlreadyCollected then
                        table.insert(allItemsData, toolData)
                    end
                end
            end
            local filteredItemsByTypes = {}
            for k,itemInfo : ToolData in pairs(allItemsData) do
                if itemInfo.Class == typeName then
                    local modifiedItemInfo : ToolData & {Key : number} = itemInfo :: any
                    modifiedItemInfo.Key = k
                    table.insert(filteredItemsByTypes, modifiedItemInfo)
                end
            end
            return filteredItemsByTypes
        end, itemsOwned, isVisible)

        local order = -string.byte(string.match(typeName, ".") or " ")
        local itemTypeFrame = getItemTypeFrame(
            maid, 
            typeName, 
            itemsFiltered,
            onBackpackButtonAddClickSignal,
            order,
            isDarkState
        )
        itemTypeFrame.Parent = backpackContentFrame
    end

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {    
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            headerFrame,
            contentFrame    
        }
    }) :: Frame

    do -- size adjustments
        local screenAbsoluteSize = _Value(workspace.CurrentCamera.ViewportSize)
        local headerFrameAbsoluteSize = _Value(headerFrame.AbsoluteSize)
        maid:GiveTask(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            screenAbsoluteSize:Set(workspace.CurrentCamera.ViewportSize)
        end))
        maid:GiveTask(headerFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            headerFrameAbsoluteSize:Set(headerFrame.AbsoluteSize)
        end))
        _bind(contentFrame)({
            Size = _Computed(function(absSize : Vector2, hfAbsSize : Vector2)
                return UDim2.fromOffset(width, absSize.Y - hfAbsSize.Y)
            end, screenAbsoluteSize, headerFrameAbsoluteSize)
        })
    end
    return out
end