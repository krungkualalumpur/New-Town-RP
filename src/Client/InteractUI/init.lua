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
local PADDING_SIZE =  UDim.new(0, 10)

local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
--variables
--references
--local functions
--class
return function(
    maid : Maid,
    interactKeyCode : State<Enum.KeyCode>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("Frame")({
        Size = UDim2.fromScale(0.125, 0.075),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
            }),
            _new("UICorner")({}),

            _new("TextLabel")({
                Size = UDim2.fromScale(0.25, 1),
                BackgroundColor3 = BACKGROUND_COLOR,
                TextScaled = true,
                Text =  _Computed(function(keyCode : Enum.KeyCode)
                    return keyCode.Name
                end, interactKeyCode)
            }),
            _new("TextLabel")({
                Size = UDim2.fromScale(0.75, 1),
                Text = "Interact",
            }),
            _new("ObjectValue")({
                Name = "InstancePointer"
            })
        }
    }) :: Frame
    return out 
end
