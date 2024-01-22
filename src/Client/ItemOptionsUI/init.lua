--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

export type OptInfo = {
    Type : ItemUtil.ItemType,
    Name : string,
    Desc : string
} 

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
local TEXT_SIZE = 25

local PADDING_SIZE =  UDim.new(0.02, 0)

local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.new(0.705882, 0.639216, 0.019608)
local TERTIARY_COLOR = Color3.fromRGB(25,25,25)

--variables
--references
--local functions
local function getButton(
    maid : Maid,
    text : string,
    onClick : Signal,
    interactedItem : Instance
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
        LayoutOrder = 4,
        Size = UDim2.fromScale(0.25, 0.15),
        Text = text,
        Children = {
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                onClick:Fire(interactedItem)
            end
        }
    })
    return out
end

local function getOptButton(
    maid : Maid,
    optInfo : OptInfo,
    onSelected : Signal,
    currentOptInfo : State<OptInfo ?>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local toolInstance = ItemUtil.getItemFromName(optInfo.Name) 

    local out = _new("ImageButton")({
        Size =  UDim2.fromScale(1, 0.125),

        Children = {
            _new("UIGradient")({
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(215,215,215))
                },
                Rotation = 90
            }),
            _new("UICorner")({}),
            _new("UIStroke")({
                Transparency = _Computed(function(currentOptInfoVal : OptInfo ?)
                    return if currentOptInfoVal == optInfo then 0.1 else 1 
                end, currentOptInfo):Tween(),
                Thickness = 3,
                Color = SECONDARY_COLOR,
            }),

            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
          
            _new("TextLabel")({
                LayoutOrder = 1,
                Name = "FoodName",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.5, 1),
                Font = Enum.Font.SourceSansSemibold,
                Text = optInfo.Name:upper(),
                TextScaled = true,
                TextColor3 = SECONDARY_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = TEXT_SIZE
                    })
                }
            }),
            _new("Frame")({
                LayoutOrder = 2,
                Name = "Buffer",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.36, 1)
            }),
            _new("Frame")({
                LayoutOrder = 3,
                Name = "Price",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0.08,0),
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        Name = "Test",
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.15, 0.2),
                        Font = Enum.Font.SourceSansSemibold,
                        Text = if toolInstance then ItemUtil.getData(toolInstance, true).Class else "",
                        TextColor3 = SECONDARY_COLOR,
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 2,
                        Name = "Price",
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.15, 0.2),
                        Font = Enum.Font.SourceSansSemibold,
                        Text = "Rp. 0",
                        TextColor3 = SECONDARY_COLOR,
                        
                    })
                },
            }),
           --[[  _new("TextLabel")({
                LayoutOrder = 3,
                Name = "Price",
                TextYAlignment = Enum.TextYAlignment.Bottom,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.15, 1),
                Font = Enum.Font.SourceSansSemibold,
                Text = "Rp. 0",
                TextColor3 = SECONDARY_COLOR,
                
            }) ]]
        },

        Events = {
            Activated = function()
                onSelected:Fire(optInfo)
            end
        }
    })

    return out
end
--class
return function(
    maid : Maid,
    listName : string,
    ToolsList : {[number] : OptInfo},

    currentOptInfo : ValueState<OptInfo ?>,

    onItemGet : Signal,

    interactedItem : Instance
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local ListContent = _new("ScrollingFrame")({
        LayoutOrder = 2,
        Name = "Contents",
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 0.9),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE
            })
        }
    })

    local out = _new("Frame")({
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,

        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("Frame")({
                LayoutOrder = 1,
                Name = "ContentFrame",
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(0.25, 0.9),
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _new("UICorner")({}),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        Name = 'Title',
                        BackgroundColor3 = SECONDARY_COLOR,
                        RichText = true,
                        Text = "<b> " .. listName:upper() .. "</b>",
                        TextColor3 = PRIMARY_COLOR,
                        TextScaled = true,
                        TextStrokeTransparency = 0.9,
                        Size = UDim2.fromScale(1, 0.08),
                        Children = {
                            _new("UITextSizeConstraint")({
                                MaxTextSize = TEXT_SIZE,
                            }),

                            _new("UICorner")({}),
                            _new("UIGradient")({
                                Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(210,210,210)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
                                })
                            })
                        }
                    }),
                    ListContent
                }
            })
        }
    }) 


    local itemViewportFrame =   _new("ViewportFrame")({
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.25),
        Children = {
            _new("UIAspectRatioConstraint")({})
        }
    }) :: ViewportFrame

    local currentCam = _new("Camera")({
        Parent = itemViewportFrame,
        CFrame = _Computed(function(optInfo : OptInfo ?)
            for _,v in pairs(itemViewportFrame:GetChildren()) do
                if v:IsA("Model") or v:IsA("WorldModel") then
                    v:Destroy()
                end
            end
            local modelDisplay = if optInfo then ItemUtil.getItemFromName(optInfo.Name) else nil
            if modelDisplay then modelDisplay:Clone().Parent = itemViewportFrame end

            return if modelDisplay and modelDisplay:IsA("Model") and modelDisplay.PrimaryPart then CFrame.lookAt(modelDisplay.PrimaryPart.Position + ((modelDisplay.PrimaryPart.CFrame.LookVector*0.5 + modelDisplay.PrimaryPart.CFrame.RightVector + modelDisplay.PrimaryPart.CFrame.UpVector)*modelDisplay.PrimaryPart.Size), modelDisplay.PrimaryPart.Position) else CFrame.new()
        end, currentOptInfo)
    }) :: Camera
    
    itemViewportFrame.CurrentCamera = currentCam
    
    local selectedInfoFrame = _new("Frame")({
        LayoutOrder = 0,
        Visible = _Computed(function(info : OptInfo ?)
            return if info then true else false
        end, currentOptInfo),
        BackgroundTransparency = 0.8,
        BackgroundColor3 = TERTIARY_COLOR,
        Position = UDim2.fromScale(0, 0.24),
        Size = UDim2.fromScale(1, 0.5),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                TextColor3 = PRIMARY_COLOR,
                Text = _Computed(function(info : OptInfo ?)
                    return if info then info.Name else ""
                end, currentOptInfo),
                TextScaled = true,
                TextStrokeTransparency = 0.8,
            }),
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.35),
                TextColor3 = PRIMARY_COLOR,
                Text = _Computed(function(info : OptInfo ?)
                    return if info then info.Desc else ""
                end, currentOptInfo),
                TextScaled = true,
                TextStrokeTransparency = 0.8,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = TEXT_SIZE*0.75
                    })
                }
            }),
            itemViewportFrame,
            getButton(
                maid,
                "Get",
                onItemGet,

                interactedItem
            )
        }
    })
    local selectedInfoParent = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.35, 1),
        Children = {
            selectedInfoFrame
        }
    })
    selectedInfoParent.Parent = out

    local onListSelected = maid:GiveTask(Signal.new())

    for _,v in pairs(ToolsList) do
        print(v.Name)
        local button = getOptButton(
            maid, 
            v,
            onListSelected,

            currentOptInfo
        )
        button.Parent = ListContent
    end

    maid:GiveTask(onListSelected:Connect(function(optInfo : OptInfo)
        currentOptInfo:Set(if currentOptInfo:Get() ~= optInfo then optInfo else nil)
    end))


    return out
end
