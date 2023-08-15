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

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
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
    order : number,
    onClick : Signal
)    

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    return _new("TextButton")({
        LayoutOrder = order,
        AutoButtonColor = true,
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0.6,
        Size = UDim2.fromScale(1, 0.25),
        Text = text,
        TextWrapped = true,
        TextColor3 = PRIMARY_COLOR,
        TextStrokeTransparency = 0.7,
        Children = {
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                onClick:Fire(order, text)
            end
        }
    })
end
--class
return function(
    maid : Maid,
    titleName : string,
    list : {[number] : string},
    position : State<UDim2>,
    isVisible : State<boolean>,
    OnOptionClick : Signal 
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local contentFrame = _new("ScrollingFrame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.85),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
        }
    })

    local out = _new("Frame")({
        Visible = isVisible,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = position,
        Size = UDim2.fromScale(0.25, 0.25),
        Children = {
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 0,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                Text =  titleName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.6,
                TextScaled = true
            }),
            contentFrame
        }
    })

    for k,v in pairs(list) do
        local button = getButton(
            maid, 
            v, 
            k,
            OnOptionClick
        )
        button.Parent = contentFrame
    end
    
    return out
end
