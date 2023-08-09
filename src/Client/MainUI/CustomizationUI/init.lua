--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
--types
type Maid = Maid.Maid
type AnimationInfo = {
    Name : string,
    AnimationId : string
}
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local BACKGROUND_COLOR = Color3.fromRGB(190,190,190)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(25,25,25)
local TERTIARY_COLOR = Color3.fromRGB(0,0,0)

local TEXT_COLOR = Color3.fromRGB(25,25,25)
local PADDING_SIZE = UDim.new(0,15)
--variables
--references
--local functions
local function getButton(
    maid : Maid, 
    text : CanBeState<string>, 
    fn : () -> (),
    layoutOrder : number 
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
        LayoutOrder = layoutOrder,
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0,
        Size = UDim2.new(0.2, 0,0.4,0),
        Text = text,
        TextColor3 = TEXT_COLOR,

        Children = {
            _new("UICorner")({}),
            _new("UIGradient")({}),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center

            })
        },
        Events = {
            Activated = function()
                fn()
            end
        }
    })
    return out
end

local function getSelectButton(maid : Maid, text : string, fn : () -> (), layoutOrder)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = getButton(maid, text, fn, layoutOrder)
    _bind(out)({
        Children = {
            _new("Frame")({
                Size = UDim2.fromScale(0.8, 0.2),
                Children = {
                    _new("UICorner")({})
                }
            })
        }
    })

    return out
end

local function getAccessoryButton(
    maid : Maid, 
    AccessoryId : number
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local Width = 48
    local Height = 48

    local out = _new("ImageButton")({
        AutoButtonColor = true,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = SECONDARY_COLOR,
        Children = {
            _new("UIStroke")({
                Color = SECONDARY_COLOR,
                Thickness = 1.5
            }),
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                Text = "Tjinta"
            }),
            _new("ImageLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.85),
                Image = "https://www.roblox.com/Thumbs/Asset.ashx?width="..Width.."&height="..Height.."&assetId="..AccessoryId,

                Children = {
                    _new("UIAspectRatioConstraint")({})
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
 
    local RPName = _new("Frame")({
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.18, 0.15),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.05, 0),
                RichText = true,
                Text = "<b>RP Name</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            _new("TextBox")({
                BackgroundColor3 = TERTIARY_COLOR,
                BackgroundTransparency = 0.5,
                LayoutOrder = 2,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0,
                TextScaled = true,
                TextWrapped = true,
                PlaceholderText = "Insert your RP name here",
                PlaceholderColor3 = BACKGROUND_COLOR,
                Size = UDim2.new(1, 0, 0.45, 0),
            }),
            getButton(maid, "Apply", function()

            end, 3)
        }
    })

    local characterCustomizationFrame = _new("Frame")({
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.5, 0.6),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE,
            }),
            _new("Frame")({
                Name = "PageOpts",
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = PADDING_SIZE,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    getSelectButton(
                        maid, 
                        "Face", 
                        function()
                        end, 
                        1
                    ),
                    getSelectButton(
                        maid, 
                        "Shirt", 
                        function()
                        end, 
                        2
                    ),
                    getSelectButton(
                        maid, 
                        "Pants", 
                        function()
                        end, 
                        3
                    ),
                    getSelectButton(
                        maid, 
                        "Accessories", 
                        function()
                        end, 
                        4
                    ),
                    --[[_new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    })]]
                }
            }),
            _new("ScrollingFrame")({
                Name = "Contents",
                BackgroundTransparency = 1,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.8),
                CanvasSize = UDim2.new(),
                Children = {
                    _new("UICorner")({}),
                    _new("UIPadding")({
                        PaddingBottom = PADDING_SIZE,
                        PaddingTop = PADDING_SIZE,
                        PaddingRight = PADDING_SIZE,
                        PaddingLeft = PADDING_SIZE
                    }),
                    _new("UIGridLayout")({
                        CellPadding = UDim2.fromOffset(5, 5),
                        CellSize = UDim2.fromOffset(100, 100)
                    }),
                    getAccessoryButton(
                        maid, 
                        21635565
                    ),
                    getAccessoryButton(
                        maid, 
                        10361759114
                    ),
                    getAccessoryButton(
                        maid, 
                        10115360545
                    )
                    
                }
            })

        }
    })

    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                Padding = PADDING_SIZE,
            }),
            RPName,
            characterCustomizationFrame
        }
    })

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
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.fromScale(0.035, 1)
            }),
            contentFrame,
        }
    })
    return out
end