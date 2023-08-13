--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

--constants
local PADDING_SIZE =  UDim.new(0, 5)

local BACKGROUND_COLOR = Color3.fromRGB(50,50,50)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)

local DELAY_TIME = 5
--variables
--references
--local functions
function getNotificationFrame(
    maid : Maid,
    text : string
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local pos = _Value(UDim2.fromScale(0, 1))
    local transp = _Value(1)

    local content = _new("Frame")({
        BackgroundTransparency = transp:Tween(),
        BackgroundColor3 = BACKGROUND_COLOR,
        Position = pos:Tween(),
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right
            }), 
            
            _new("UICorner")({}),
            _new("UIGradient")({
                Rotation = -90,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(
                        0,
                        BACKGROUND_COLOR
                    ), 
                    ColorSequenceKeypoint.new(
                        1,
                        PRIMARY_COLOR
                    )},
                    
                }
            ),

            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.8, 1),
                Text = text,
                TextTransparency = _Computed(function(val : number)
                    return if val < 1 then 0 else 1
                end, transp):Tween(),
                TextSize = 15,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = _Computed(function(val : number)
                    return val + 0.3
                end, transp):Tween(),
                TextWrapped = true
            })
        }
    })

    pos:Set(UDim2.fromScale(0, 0))
    transp:Set(0.5)

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.2, 0.2),
        
        Children = {
            _new("UIAspectRatioConstraint")({
                AspectRatio = 3,
            }),
            content
        }
    })

    task.spawn(function()
        task.wait(DELAY_TIME)
        pos:Set(UDim2.fromScale(0, -1))
        transp:Set(1)
        task.wait(0.5)
        maid:Destroy()
    end)
    
    return out
end
--class
return function(
    maid : Maid,
    textStatus : ValueState<string ?>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

  
    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            })
        }
    }) :: Frame

    local computedTextStatus = _Computed(function(text : string ?)
        print("pngp priestess ", text)
        if text then
            local _maid = Maid.new()
            local notifFrame = getNotificationFrame(
                _maid,   
                text
            )
            notifFrame.Parent = out
           print(notifFrame, " test")
        end
        return true
    end, textStatus)

    _bind(out)({
        Visible = computedTextStatus
    })

    return out 
end
