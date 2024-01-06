--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)

local TEXT_COLOR = Color3.fromRGB(255,255,255)

local MAX_FEEDBACK_LETTER = 100
--variables
--references
local Player = Players.LocalPlayer
--local functions

function getButton(
    maid : Maid,
    buttonName : string,
    activatedFn : () -> (),
    order : number,
    color : Color3 ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("TextButton")({
        Name = buttonName .. "Button",
        LayoutOrder = order,
        BackgroundTransparency = 0,
        BackgroundColor3 = color or TERTIARY_COLOR,
        Size = UDim2.fromScale(0.25, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        RichText = true,
        AutoButtonColor = true,
        Font = Enum.Font.Gotham,
        Text = "\t<b>" .. buttonName .. "</b>\t",
        TextScaled = true,
        TextColor3 = TEXT_COLOR,
        Children = {
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 2
            })
        },
        Events = {
            Activated = function()
                activatedFn()
            end
        },
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    return out
end

local function getImageButton(
    maid : Maid,
    ImageId : ColdFusion.State<number>,
    activatedFn : () -> (),
    buttonName : ColdFusion.State<string>,
    order : number,
    color : Color3 ?
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
        BackgroundColor3 = color or BACKGROUND_COLOR,
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
                Position = UDim2.fromScale(0, 1.2),
                Font = Enum.Font.Gotham,
                Text = buttonName,
                TextScaled = true,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeColor3 = SECONDARY_COLOR,
                TextStrokeTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center
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

    OnFeedbackSend : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _import = _fuse.import

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local feedbackText = _Value("")
     
    local textBox =  _new("TextBox")({
        Size = UDim2.fromScale(0.95, 0.6),
        Font = Enum.Font.GothamBold,
        PlaceholderText = "Your feedback means alot for the growth of this city!",
        TextColor3 = SECONDARY_COLOR,
        TextScaled = true,
        Children = {
            _new("UITextSizeConstraint")({
                MaxTextSize = 20,
                MinTextSize = 5
            })
        },
    })

    local out : Frame 
    
    out = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.5),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(0.025,0)
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),

            _new("TextLabel")({
                BackgroundTransparency = 1, 
                Size = UDim2.fromScale(1, 0.15),
                Font = Enum.Font.GothamBold,
                Text = "Feedback",
                TextColor3 = PRIMARY_COLOR,
                TextScaled = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = 35,
                        MinTextSize = 5
                    })
                }
            }),

            _bind(textBox)({
                Events = {
                    Changed = function()
                        feedbackText:Set(textBox.Text:sub(1, MAX_FEEDBACK_LETTER))
                        textBox.Text = feedbackText:Get()
                        --textBox.Text = textBox.Text:sub(1, 100)
                        return
                    end
                }
            }),

            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.05),
                Text = _Computed(function(text : string)
                    return ("%d/%d"):format(#text , MAX_FEEDBACK_LETTER)
                end, feedbackText),
                TextColor3 = TEXT_COLOR,
                TextXAlignment = Enum.TextXAlignment.Right
            }),

            _bind(getButton(maid, "Send Feedback", function()
                OnFeedbackSend:Fire(textBox.Text, out)
            end, 1))({
                Size = UDim2.fromScale(0.5, 0.12)
            })
        }
        
    }) :: Frame
    return out
end
