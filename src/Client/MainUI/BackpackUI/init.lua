--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type ToolData = BackpackUtil.ToolData<boolean>

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local BACKGROUND_COLOR = Color3.fromRGB(190,190,190)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(25,25,25)
local PADDING_SIZE = UDim.new(0,15)
--remotes
--variables
--references
--local functions
local function getButton(
    maid : Maid, 
    text : CanBeState<string>, 
    fn : () -> ()
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.6,
        Size = UDim2.fromScale(1, 0.5),
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
    onBackpackButtonEquipClickSignal : Signal,
    onBackpackButtonDeleteClickSignal : Signal
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
        if toolModel:IsA("BasePart") then
            viewportVisualZoom *= toolModel.Size.Magnitude
        elseif toolModel:IsA("Model") then
            viewportVisualZoom *= toolModel:GetExtentsSize().Magnitude
        end
    end

    local viewportCam = _new("Camera")({
        CFrame = if toolModel then (if toolModel:IsA("Model") and toolModel.PrimaryPart then 
            CFrame.lookAt(toolModel.PrimaryPart.Position + toolModel.PrimaryPart.CFrame.LookVector/viewportVisualZoom + toolModel.PrimaryPart.CFrame.RightVector/viewportVisualZoom + toolModel.PrimaryPart.CFrame.UpVector/viewportVisualZoom, toolModel.PrimaryPart.Position) 
        elseif toolModel:IsA("BasePart") then
            CFrame.lookAt(toolModel.Position + toolModel.CFrame.LookVector/viewportVisualZoom + toolModel.CFrame.RightVector/viewportVisualZoom + toolModel.CFrame.UpVector/viewportVisualZoom, toolModel.Position) 
        else CFrame.new()) else nil
    })

    local out = _new("ImageButton")({
        BackgroundTransparency = 0.5,
        BackgroundColor3 = SECONDARY_COLOR,
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
                Text = itemInfo.Name
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
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
                    }),

                    getButton(
                        maid, 
                        if not itemInfo.IsEquipped then "Equip" else "Unequip",
                        function()
                            onBackpackButtonEquipClickSignal:Fire(key, if not itemInfo.IsEquipped then itemInfo.Name else nil)
                        end
                    ),
                    getButton(
                        maid, 
                        "Delete",
                        function()
                            onBackpackButtonDeleteClickSignal:Fire(key, itemInfo.Name)
                        end
                    ),

                    viewportCam,
                    _new("WorldModel")({
                        Children = {
                            toolModel
                        }
                    })
                }
            })
        }
    })

    return out
end

local function getItemTypeFrame(
    maid : Maid, 
    typeName : string,
    Items : State<{
        [number] : ToolData
    }>,
    onBackpackButtonEquipClickSignal : Signal,
    onBackpackButtonDeleteClickSignal : Signal
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
    })

    local out = _new("Frame")({
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
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
                Text = typeName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            itemFrameList
        }
    })

 
    Items:ForPairs(function(k, v : ToolData, pairMaid : Maid)
        local _pairFuse = ColdFusion.fuse(pairMaid)
        local _pairValue = _pairFuse.Value

        local itemButton = getItemButton(
            pairMaid,
            k,
            v,
            onBackpackButtonEquipClickSignal,
            onBackpackButtonDeleteClickSignal
        )
        
        itemButton.Parent = itemFrameList
        return k, v
    end)

    return out
end
--class
return function(
    maid : Maid,
    itemTypes : {[number] : string},
    itemsOwned : ValueState<{[number] : ToolData}>,

    onBackpackButtonEquipClickSignal : Signal,
    onBackpackButtonDeleteClickSignal : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value


    local isVisible = _Value(true) --fixing the wierd state not working thing by attaching it to the properties table for the sake of updating the equip
    local contentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        Visible = isVisible,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.74,
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
            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.06),
                RichText = true,
                TextScaled = true,
                Text = "<b>Backpack</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5
            }) 
        }
    }) :: GuiObject

    for k,typeName in pairs(itemTypes) do
        local itemsFiltered = _Computed(function(items : {[number] : ToolData})
            local filteredItemsByTypes = {}
            for _,itemInfo : ToolData in pairs(items) do
                if itemInfo.Class == typeName then
                    table.insert(filteredItemsByTypes, itemInfo)
                end
            end
            return filteredItemsByTypes
        end, itemsOwned, isVisible)
        local itemTypeFrame = getItemTypeFrame(
            maid, 
            typeName, 
            itemsFiltered,
            onBackpackButtonEquipClickSignal,
            onBackpackButtonDeleteClickSignal
        )
        itemTypeFrame.Parent = contentFrame

       --[[ task.spawn(function()
            task.wait(1) 
            items:Set({"Indonesia", " deaaw"})
        end)]]

        
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