--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
--types
type Maid = Maid.Maid
type AnimationInfo = {
    Name : string,
    AnimationId : string
}

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local BACKGROUND_COLOR = Color3.fromRGB(190,190,190)
local TEXT_COLOR = Color3.fromRGB(25,25,25)
local PADDING_SIZE = UDim.new(0,15)
--variables
--references
--local functions
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

    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        Size = UDim2.fromScale(0.18, 0.15),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                Size = UDim2.fromScale(1, 0.3),
                RichText = true,
                Text = "<b>RP Name</b>"
            }),
            _new("TextBox")({
                BackgroundColor3 = BACKGROUND_COLOR,
                LayoutOrder = 2,
                PlaceholderText = "Insert your RP name here",
                PlaceholderColor3 = Color3.fromRGB(50,50,50),
                Size = UDim2.fromScale(1, 0.5)
            })
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
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.2, 1)
            }),
            contentFrame
        }
    })
    return out
end