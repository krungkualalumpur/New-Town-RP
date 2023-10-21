--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local TextChatService = game:GetService("TextChatService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
local TEXT_SIZE = 16
local STR_CHAR_LIMIT =  10

local PADDING_SIZE = UDim.new(0,10)
local PADDING_SIZE_SCALE = UDim.new(0.15,0)

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)
--variables
--references
--local functions
local function getButton( 
    maid : Maid,
    order : number,
    text : CanBeState<string> ?,
    fn : (() -> ()) ?,
    color : Color3 ?
) : TextButton
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out  = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = color or BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 1),
        LayoutOrder = order,
        Font = Enum.Font.Gotham,
        Text = text,
        TextWrapped = true,
        TextStrokeTransparency = 0.7,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    }) :: TextButton
    return out
end

--class
return function(
    maid : Maid,
    msgTitle : string,
    msgDesc : string,
    isConfirmMode : boolean,
    onConfirm : (() -> ()),
    onCancel : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local okButton, cancelButton =  _bind(getButton( 
        maid,
        1,
        _Value("OK"),
        onConfirm,
        SELECT_COLOR
    ))({
        Size = UDim2.fromScale(0.25, 1),
        Font = Enum.Font.Gotham,
        TextScaled = true,
        Children = {
            _new("UITextSizeConstraint")({
                MinTextSize = 0,
                MaxTextSize = TEXT_SIZE*1.5
            })
        }
    }), if not isConfirmMode then  _bind(getButton( 
        maid,
        1,
        _Value("Cancel"),
        onCancel    
    ))({
        Size = UDim2.fromScale(0.3, 1),
        TextScaled = true,
        Children = {
            _new("UITextSizeConstraint")({
                MinTextSize = 0,
                MaxTextSize = TEXT_SIZE*1.5
            })
        }
    }) else nil


    local content = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.new(0.25,0,0.25,0),
        Children = {
            _new("UIAspectRatioConstraint")({
                AspectRatio = 2,
            }),
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
            _new("UICorner")({
                CornerRadius = UDim.new(0.1,0),
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.2),
                Font = Enum.Font.Gotham,
                Text = "<b>" .. msgTitle .. "</b>",
                TextSize = TEXT_SIZE*1.5,
                TextColor3 = PRIMARY_COLOR,
                RichText = true,
                TextScaled = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MinTextSize = 0,
                        MaxTextSize = TEXT_SIZE*2
                    })
                }
            }),
            _new("Frame")({
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.01)
            }),
            _new("TextLabel")({
                LayoutOrder = 3,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                Font = Enum.Font.Gotham,
                Text = msgDesc,
                TextSize = TEXT_SIZE,
                TextColor3 = PRIMARY_COLOR,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Children = {
                    _new("UITextSizeConstraint")({
                        MinTextSize = 0,
                        MaxTextSize = TEXT_SIZE
                    })
                }
            }),
            _new("Frame")({
                LayoutOrder = 4,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.2),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                    }),
                    okButton,
                    cancelButton :: any
                }
            })
        }
    })

    local pos = _Value(UDim2.fromScale(0, 0.5))

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Position = pos:Tween(0.5),
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            }),
            content
        }
    })
    pos:Set(UDim2.fromScale(0, 0))
    return out
end
