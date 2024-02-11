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
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))
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
local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(25,25,25)
local TERTIARY_COLOR = Color3.fromRGB(80,80,80)
local PADDING_SIZE = UDim.new(0,15)

local SELECT_COLOR = Color3.fromRGB(75, 210, 80)
--remotes
local GET_PLAYER_VEHICLES = "GetPlayerVehicles"
--variables
--references
local vehicles = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Vehicles")
--local functions
local function getButton(
    maid : Maid, 
    order : number,
    text : CanBeState<string>, 
    fn : () -> (),
    color : Color3 ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("TextButton")({
        LayoutOrder = order,
        AutoButtonColor = true,
        BackgroundColor3 = color or BACKGROUND_COLOR,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 0.5),
        Font = Enum.Font.Gotham,
        Text = text,
        TextStrokeTransparency = 0.5,
        TextColor3 = PRIMARY_COLOR,

        Children = {
            _new("UICorner")({}),
            _new("UIGradient")({})
        },
        Events = {
            Activated = function()
                fn()
            end
        }
    })

    return out
end

local function getItemButton(
    maid : Maid, 
    key : number,
    itemInfo: ToolData,
    onBackpackButtonAddClickSignal : Signal
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

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

    if toolModel then
         
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
    end

    local cf, size 
    if toolModel and toolModel:IsA("Model") then
        cf, size = toolModel:GetBoundingBox()  
    elseif toolModel and toolModel:IsA("BasePart") then 
        cf, size = toolModel.CFrame, toolModel.Size
    end
    local viewportCam = _new("Camera")({
        CFrame = if toolModel then (if toolModel:IsA("Model") and toolModel.PrimaryPart then 
            CFrame.lookAt(cf.Position + cf.LookVector*size.Z + cf.RightVector*size.X + cf.UpVector, cf.Position) 
        elseif toolModel:IsA("BasePart") then
            CFrame.lookAt(toolModel.Position + toolModel.CFrame.LookVector*size.Z + toolModel.CFrame.RightVector*size.X + toolModel.CFrame.UpVector, toolModel.Position) 
        else CFrame.new()) else nil
    })

    local optionButtonsPosition = _Value(UDim2.new(if not UserInputService.TouchEnabled then 2 else 0,0,0,0))

    local optionButtonsFrame = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Position = optionButtonsPosition:Tween(0.1),
        Size = UDim2.fromScale(1,1),
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
            }),
            getButton(
                maid, 
                1,
                "Get",
                function()
                    onBackpackButtonAddClickSignal:Fire(itemInfo)
                end,
                TERTIARY_COLOR
            ),
            --[[getButton(
                maid, 
                2,
                "Delete",
                function()
                    onBackpackButtonDeleteClickSignal:Fire(key, itemInfo.Name)
                end
            )]]
            --getButton(maid, text, fn)
        }
    })

    local out = _new("ImageButton")({
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            _new("UIStroke")({
                Color = SECONDARY_COLOR,
                Thickness = 1.5
            }),
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                Font = Enum.Font.Gotham,
                Text = itemInfo.Name,
                TextScaled = true,
                TextWrapped = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = 15,
                        MinTextSize = 0,
                    })
                }
            }),
            _new("ViewportFrame")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.75),
                CurrentCamera = viewportCam,
                
                Children = {
                    _new("UIPadding")({
                        PaddingBottom = PADDING_SIZE,
                        PaddingTop = PADDING_SIZE,
                        PaddingLeft = PADDING_SIZE,
                        PaddingRight = PADDING_SIZE
                    }),
                   
                    optionButtonsFrame,

                    viewportCam,
                    _new("WorldModel")({
                        Children = {
                            toolModel
                        }
                    })
                }
            })
        },
        Events = {
            MouseEnter = function()
                optionButtonsPosition:Set(UDim2.fromScale(0, 0))
            end,
            MouseLeave = function()
                optionButtonsPosition:Set(UDim2.fromScale(if  not UserInputService.TouchEnabled then 2 else 0, 0))
            end
        }
    })

    return out
end

local function getVehicleButton(
    maid : Maid, 
    key : number,
    dynamicVehicleInfo: ValueState<VehicleData ?>,
    onVehicleButtonInteract : Signal
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

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
        end
        return vehicleModel
    end, dynamicVehicleInfo)

    
   
    local viewportCam = _new("Camera")({
        CFrame = _Computed(function(vehicleModel : Instance ?) 
            local viewportVisualZoom = 0.75

            local cf, size
            if vehicleModel then
                if vehicleModel:IsA("BasePart") then
                    viewportVisualZoom *= vehicleModel.Size.Magnitude*1.5
                elseif vehicleModel:IsA("Model") then
                    viewportVisualZoom *= vehicleModel:GetExtentsSize().Magnitude*1
                end
            
                
                if vehicleModel:IsA("Model") then
                    cf, size = vehicleModel:GetBoundingBox()  
                elseif vehicleModel and vehicleModel:IsA("BasePart") then 
                    cf, size = vehicleModel.CFrame, vehicleModel.Size
                end
            end

            local camCf = if vehicleModel then (if vehicleModel:IsA("Model") and vehicleModel.PrimaryPart then 
                CFrame.lookAt(cf.Position + cf.LookVector*size.Z + cf.RightVector*size.X + cf.UpVector, cf.Position) 
            elseif vehicleModel:IsA("BasePart") then
                CFrame.lookAt(vehicleModel.Position + vehicleModel.CFrame.LookVector*size.Z + vehicleModel.CFrame.RightVector*size.X + vehicleModel.CFrame.UpVector, vehicleModel.Position) 
            else CFrame.new()) else CFrame.new()

            return camCf
        end, dynamicVehicleModel) 
    })
    

   --[[ if not game:GetService("RunService"):IsRunning() then
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
    end]]

    local optionButtonsPosition =  _Value(if  not UserInputService.TouchEnabled then UDim2.new(2,0,0,0) else UDim2.new())

    local optionButtonsFrame = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Position = optionButtonsPosition:Tween(0.1),
        Size = UDim2.fromScale(1,1),
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
            }),
            getButton(
                maid, 
                1,
                _Computed(function(vehicleInfo : VehicleData ?)
                    return if vehicleInfo and vehicleInfo.IsSpawned then "Despawn" elseif vehicleInfo and not vehicleInfo.IsSpawned then "Spawn" else ""
                end, dynamicVehicleInfo),
                function()
                    local vehicleInfo = dynamicVehicleInfo:Get()
                    onVehicleButtonInteract:Fire(key, vehicleInfo)
                end,
                TERTIARY_COLOR
            ),
            --[[getButton(
                maid, 
                2,
                "Delete",
                function()
                    onBackpackButtonDeleteClickSignal:Fire(key, itemInfo.Name)
                end
            )]]
            --getButton(maid, text, fn)
        }
    })

    local out = _new("ImageButton")({
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Visible = _Computed(function(vehicleInfo : VehicleData ?)
            return if vehicleInfo then true else false
        end, dynamicVehicleInfo),
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            _new("UIStroke")({
                Color = SECONDARY_COLOR,
                Thickness = 1.5
            }),
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                Font = Enum.Font.Gotham,
                Text =  _Computed(function(vehicleInfo : VehicleData ?)
                    return if vehicleInfo then vehicleInfo.Name else ""
                end, dynamicVehicleInfo),
                TextScaled = true,
                TextWrapped = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = 15,
                        MinTextSize = 0,
                    })
                }
            }),
            _new("ViewportFrame")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.75),
                CurrentCamera = viewportCam,
                
                Children = {
                    _new("UIPadding")({
                        PaddingBottom = PADDING_SIZE,
                        PaddingTop = PADDING_SIZE,
                        PaddingLeft = PADDING_SIZE,
                        PaddingRight = PADDING_SIZE
                    }),
                   
                    optionButtonsFrame,

                    viewportCam,
                    _new("WorldModel")({
                        Children = {
                           dynamicVehicleModel
                        }
                    })
                }
            })
        },
        Events = {
            MouseEnter = function()
                optionButtonsPosition:Set(UDim2.fromScale(0, 0))
            end,
            MouseLeave = function()
                optionButtonsPosition:Set(UDim2.fromScale(if  not UserInputService.TouchEnabled then 2 else 0, 0))
            end
        }
    })

    return out
end

local function getItemTypeFrame(
    maid : Maid, 
    typeName : string,
    Items : State<{
        [number] : ToolData & {Key : number}
    }>,
    onBackpackButtonAddClickSignal : Signal,
    frameOrder : number
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

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
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

        }
    }) :: Frame

    
    local isNAFrame = _new("TextLabel")({
        LayoutOrder = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0, 0.25),
        Text = "EMPTY LIST \n (collect by interacting with items)",
        TextStrokeTransparency = 0.69,
        TextTransparency = 0.5,
        TextScaled = true,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = PRIMARY_COLOR,
    }) :: TextLabel

    local out = _new("Frame")({
        LayoutOrder = frameOrder,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0.9,
        Size = UDim2.new(1, 0, 0, 0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                Name = "Title",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                LayoutOrder = 1,
                TextSize = 25,
                RichText = true,
                Font = Enum.Font.Gotham,
                Text = typeName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            isNAFrame,
            itemFrameList
        }
    }) :: Frame

 
    Items:ForValues(function(v : ToolData & {Key : number}, pairMaid : Maid)
        local _pairFuse = ColdFusion.fuse(pairMaid)
        local _pairValue = _pairFuse.Value

        local itemButton = getItemButton(
            pairMaid,
            v.Key,  
            v,
            onBackpackButtonAddClickSignal
        )
        
        itemButton.Parent = itemFrameList
        return v
    end)

    local strVal = _new("StringValue")({
        Value = _Computed(function(items) 
            isNAFrame.Visible = #items == 0
            itemFrameList.Visible = not isNAFrame.Visible
            return ""
        end, Items)
    })
    

    return out
end

local function getSelectButton(maid : Maid, order : number, text : string, isSelected : State<boolean>, fn : () -> (), color : Color3?)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = getButton(maid, order, text, fn, color)
    _bind(out)({
        AutoButtonColor = false,
        BackgroundColor3 = color,
        Size = UDim2.new(0.25, 0,1,0),
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
            _new("Frame")({
                BackgroundColor3 = SELECT_COLOR,
                Visible = isSelected,
                Size = _Computed(function(selected : boolean)
                    return if selected then UDim2.fromScale(0.8, 0.1) else UDim2.fromScale(0, 0.15)
                end, isSelected):Tween(0.2),
                Children = {
                    _new("UICorner")({})
                }
            })
        }
    })

    return out
end
--class
return function(
    maid : Maid,
    itemsOwned : ValueState<{[number] : ToolData}>,

    onBackpackButtonAddClickSignal : Signal,
    onBackpackButtonDeleteClickSignal : Signal,

    vehicleList : {[number] : ValueState<VehicleData ?>},
    onVehicleSpawn : Signal,
    onVehicleDelete : Signal 
)
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    itemsOwned = _Value(itemsOwned:Get())

    local itemTypes = BackpackUtil.getAllItemClasses()

    local isVisible = _Value(true) --fixing the wierd state not working thing by attaching it to the properties table for the sake of updating the equip
    
    local selectedPage = _Value("Items")
    
    local header = _new("Frame")({
        Name = "Header",
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE,

            }),
            getSelectButton(maid, 1, "Items", _Computed(function(page)
                return page == "Items"
            end, selectedPage),function()
                selectedPage:Set("Items")
            end),
            getSelectButton(maid, 2, "Vehicles", _Computed(function(page) 
                return page == "Vehicles"
            end, selectedPage),function()
                selectedPage:Set("Vehicles")
            end),
        }
    })
    
    local backpackUIListLayout =  _new("UIListLayout")({
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = PADDING_SIZE
    }) :: UIListLayout
    local backpackContentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        Visible = _Computed(function(page : string)
           return page == "Items" 
        end, selectedPage),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0.74,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(1,0.8),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1,0)
            }),
            backpackUIListLayout,
            --[[_new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.06),
                RichText = true,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                Text = "<b>Backpack</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5
            }) ]]
        }
    }) :: ScrollingFrame

    _bind(backpackUIListLayout)({
        Events = {
            Changed = function()
                backpackContentFrame.CanvasSize =  UDim2.new(0,0,0,backpackUIListLayout.AbsoluteContentSize.Y + PADDING_SIZE.Offset*2)
            end
        }
    })

    local function getButtonInfo(
        signal : Signal,
        buttonName : string
    )
        return 
            {
                Signal = signal,
                ButtonName = buttonName
            }
        
    end
    local options = {
        getButtonInfo(onVehicleSpawn, "Spawn"),
        getButtonInfo(onVehicleDelete, "Delete")
    }
    --[[local vehicleNamesList = _Computed(function(list : {[number] : VehicleData})
        local namesList = {}
        for _,v in pairs(list) do
            table.insert(namesList, v.Name)
        end
        return namesList
    end, vehicleList)]]


    local vehicleUIGridLayout =   _new("UIGridLayout")({
        CellPadding = UDim2.fromOffset(5, 5),
        CellSize = UDim2.fromOffset(100, 100)
    }) :: UIGridLayout
    local newVehiclesContentFrame = _new("ScrollingFrame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0.74,
        Visible = _Computed(function(page : string)
            return page == "Vehicles" 
        end, selectedPage),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0.8),
        CanvasSize = UDim2.new(),
        Children = {
            vehicleUIGridLayout :: any,
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }) ,
        }
    }) :: ScrollingFrame
    _bind(vehicleUIGridLayout)({
        Events = {
            Changed = function()
                newVehiclesContentFrame.CanvasSize = UDim2.fromOffset(0, vehicleUIGridLayout.AbsoluteContentSize.Y + PADDING_SIZE.Offset*2)
            end
        }
    })

    local onVehicleButtonInteract = maid:GiveTask(Signal.new())
    for k,v in pairs(vehicleList) do
        local button = getVehicleButton(
            maid,
            k, 
            v,
            onVehicleButtonInteract
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

    --[[local vehiclesContentFrame = _bind(ListUI(maid, "", vehicleNamesList, _Value(UDim2.new()), _Computed(function(page : string)
        return page == "Vehicles" 
    end, selectedPage), options))({
        Size = UDim2.fromScale(1, 0.8)
    })]]
    
   
    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        Visible = isVisible,
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(0.3,1),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1,0)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            --[[_new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.06),
                RichText = true,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                Text = "<b>Backpack</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5
            }) ]]
            header,
            backpackContentFrame,
            newVehiclesContentFrame
            --vehiclesContentFrame
        }
    }) :: GuiObject

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
            order
        )
        itemTypeFrame.Parent = backpackContentFrame
    end

    local out = _new("Frame")({
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
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
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

    --[[if RunService:IsRunning() then   
        task.spawn(function()
            do --init
                local contentFrame = vehiclesContentFrame:WaitForChild("ContentFrame") :: Frame
                _bind(contentFrame)({
                    Events = {
                        ChildAdded = function(child : Instance)
                            if child:IsA("Frame") then
                                for k, vehicleData : VehicleData in pairs(vehicleList:Get()) do
                                    if k == child.LayoutOrder then
                                        local spawnButton = child:WaitForChild("SubOptions"):WaitForChild("SpawnButton") :: TextButton
                                        spawnButton.Text = if vehicleData.IsSpawned then "Despawn" else "Spawn"
                                        if vehicleData.DestroyLocked == true then
                                            local deleteButton = child:WaitForChild("SubOptions"):WaitForChild("DeleteButton") :: TextButton
                                            deleteButton.Visible = false
                                        end
                                    end
                                end
                            end
                            
                        end
                    }
                })
               
            end
        end)
    end]]

    return out
end