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
--constants
local PADDING_SIZE =  UDim.new(0.02, 0)

local BACKGROUND_COLOR = Color3.fromRGB(100,100,100)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 42, 42)
--variables
--references
--local functions
local function getImageButton(
    maid : Maid,
    ImageId : ColdFusion.State<number>,
    activatedFn : () -> (),
    buttonName : ColdFusion.State<string>,
    order : number
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local button = _new("ImageButton")({
        Name = buttonName,
        LayoutOrder = order,
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(1, 1),
        AutoButtonColor = true,
        Image = _Computed(function(id : number)
            return "rbxassetid://" .. tostring(id)
        end, ImageId),
        Children = {
            _new("UIStroke")({
                Thickness = 2,
                Color = PRIMARY_COLOR
            }),
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({}),
            _new("TextLabel")({
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.3),
                Position = UDim2.fromScale(0.25, 1.2),
                Text = buttonName,
                TextScaled = true,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeColor3 = SECONDARY_COLOR,
                TextStrokeTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        },
        Events = {
            Activated = activatedFn
        }
    })
    return button
end
--class
return function(
    maid : Maid,
    onSprintClick : Signal,

    sprintState : ColdFusion.State<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _import = _fuse.import

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local sprintButton 

    if game:GetService("UserInputService").KeyboardEnabled then
        sprintButton = getImageButton(maid, _Computed(function(isSprinting : boolean)
            return if isSprinting then 9525535512 else 9525534183 
        end, sprintState), function()
                onSprintClick:Fire()
        end, _Computed(function(isSprinting : boolean)
            return if isSprinting then "Running" else "Walking" 
        end, sprintState), 1)  
    end

    local out = _new("Frame")({
       -- Position = UDim2.fromScale(0, 0.85),
        Size = UDim2.fromScale(1, 0.08),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
             
            sprintButton
            --[[_new("ImageButton")({
                BackgroundTransparency = 0.5,
                AutoButtonColor = 1,
                Image = "rbxassetid://9525535512" , 
                Size = UDim2.fromScale(1, 1),
                Children = {
                    _new("UICorner")({}),
                    _new("UIAspectRatioConstraint")({})
                }
            })]]
        }
    })
    return out
end
