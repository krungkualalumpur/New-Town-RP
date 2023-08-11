--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = {
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
local SECONDARY_COLOR = Color3.new(0.678431, 0.615686, 0.027451)
local TERTIARY_COLOR = Color3.fromRGB(25,25,25)

--variables
--references
--local functions
local function getButton(
    maid : Maid,
    text : string,
    onClick : Signal
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
        LayoutOrder = 3,
        Size = UDim2.fromScale(0.25, 0.15),
        Text = text,
        Children = {
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                onClick:Fire()
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
            _new("TextLabel")({
                LayoutOrder = 3,
                Name = "Price",
                TextYAlignment = Enum.TextYAlignment.Bottom,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.15, 1),
                Font = Enum.Font.SourceSansSemibold,
                Text = "Rp. 0",
                TextColor3 = SECONDARY_COLOR,
                
            })
        },

        Events = {
            Activated = function()
                onSelected:Fire(optInfo)
                print("Test uey!")
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
    OnListClicked : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local currentOptInfo : ValueState<OptInfo ?> = _Value(nil) :: any

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
                Size = UDim2.fromScale(0.25, 1),
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


    local onItemGet = maid:GiveTask(Signal.new())
    local selectedInfoFrame = _new("Frame")({
        LayoutOrder = 0,
        Visible = _Computed(function(info : OptInfo ?)
            return if info then true else false
        end, currentOptInfo),
        BackgroundTransparency = 0.8,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(0.35, 0.45),
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
                Size = UDim2.fromScale(1, 0.55),
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
            getButton(
                maid,
                "Get",
                onItemGet
            )
        }
    })
    selectedInfoFrame.Parent = out

    maid:GiveTask(onItemGet:Connect(function()
        print("Test")
    end))

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
        print("Soul on fire")
    end))


    return out
end
