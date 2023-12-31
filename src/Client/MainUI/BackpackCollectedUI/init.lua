--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService= game:GetService("RunService")
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
local PADDING_SIZE = UDim.new(0,15)

local SELECT_COLOR = Color3.fromRGB(75, 210, 80)
--remotes
local GET_PLAYER_VEHICLES = "GetPlayerVehicles"
--variables
--references
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
        TextScaled = true,
        TextWrapped = true,
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

    local optionButtonsPosition = _Value(UDim2.new(2,0,0,0))

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
                if not itemInfo.IsEquipped then "Equip" else "Unequip",
                function()
                    onBackpackButtonEquipClickSignal:Fire(key, if not itemInfo.IsEquipped then itemInfo.Name else nil)
                end
            ),
            getButton(
                maid, 
                2,
                "Delete",
                function()
                    onBackpackButtonDeleteClickSignal:Fire(key, itemInfo.Name)
                end
            )
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
                optionButtonsPosition:Set(UDim2.fromScale(2, 0))
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
            onBackpackButtonEquipClickSignal,
            onBackpackButtonDeleteClickSignal
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


--class
return function(
    maid : Maid
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local content = _new("Frame")({
        Name = "Content",
        BackgroundTransparency = 0.9,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Horizontal
            }),
            _bind(getViewport(maid, ReplicatedStorage.Assets.Tools.Items.Book:Clone()))({
                BackgroundTransparency = 0,
                Size = UDim2.new(1,0,1,0),
               
            }),
            _bind(getViewport(maid, ReplicatedStorage.Assets.Tools.Items.Book:Clone()))({
                BackgroundTransparency = 0,
                Size = UDim2.new(1,0,1,0),
                
            }),
            _bind(getViewport(maid, ReplicatedStorage.Assets.Tools.Items.Book:Clone()))({
                BackgroundTransparency = 0,
                Size = UDim2.new(1,0,1,0),
               
            }),
        }
    })

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(0.025,0),
                PaddingBottom = UDim.new(0.025,0),
                PaddingLeft = UDim.new(0.025,0),
                PaddingRight = UDim.new(0.025,0)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1),
                Children = ({
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    content,
                  
                })
            })
            
        }
    })


    return out
end