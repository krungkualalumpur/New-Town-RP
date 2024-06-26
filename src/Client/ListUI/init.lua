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
local PADDING_SIZE =  UDim.new(0, 5)

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
    onClick : () -> ()
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out = _new("TextButton")({
        Name = text .. "Button",
        AutoButtonColor = true,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 0.3),
        Text = text,
        TextColor3 = PRIMARY_COLOR,
        TextStrokeTransparency = 0.8,
        TextScaled = true,
        Children = {
            _new("UICorner")({}),
            _new("UITextSizeConstraint")({
                MaxTextSize = 15
            }),
        },
        Events = {
            Activated = function()
                onClick()
            end
        }
    }) :: TextButton

    return out
end

local function getListFrame(
    maid : Maid, 
    listName : string, 
    order : number,
    subOptions : {
        [number] : {
            ButtonName : string, 
            Signal : Signal
        }
    }
)    

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local subOptionsFrame = _new("Frame")({
        Name = "SubOptions",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.23, 1),
        Children = {
            _new("UIListLayout")({
                Padding = UDim.new(PADDING_SIZE.Scale*2, PADDING_SIZE.Offset*2),
                VerticalAlignment = Enum.VerticalAlignment.Center
            })
        }
    })

    local out = _new("Frame")({
        Name = listName,
        LayoutOrder = order,
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 0, 70),
        
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),

            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Text = listName,
                TextWrapped = true,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.7,
                Size = UDim2.fromScale(0.75, 1)
            }),
            subOptionsFrame
           
        },
        --[[Events = {
            Activated = function()
                onClick:Fire(order, text)
            end
        }]]
    })
    
    for _,v in pairs(subOptions) do
        local button 
        button = getButton(
            maid, 
            v.ButtonName,
            function()
                v.Signal:Fire(order, listName, button)
            end
        )
        button.Parent = subOptionsFrame
    end

    return out
end
--class 
return function(
    maid : Maid,
    titleName : string,
    list : State<{[number] : string}>,
    position : State<UDim2>,
    isVisible : State<boolean>,
    subOptions : {
        [number] : {
            ButtonName : string, 
            Signal : Signal
        }
    }
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local contentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.85),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 5,
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
                Size = UDim2.fromScale(1, if titleName:match("[^%s]") then 0.15 else 0),
                Text = titleName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.6,
                TextScaled = true
            }),
            contentFrame
        }
    })

    local stateMaid = maid:GiveTask(Maid.new())
  
    local val = _Computed(function(listVal)
        stateMaid:DoCleaning()
        
        for k,v in pairs(listVal) do
            local button = getListFrame(
                stateMaid, 
                v, 
                k,
                subOptions
            )
            button.Parent = contentFrame
        end
        return ""
    end, list)
 
    local stringValue = _new("StringValue")({
        Value = val
    })

    return out
end
