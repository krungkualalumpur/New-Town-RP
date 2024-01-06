--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

--constants
local PADDING_SIZE =  UDim.new(0.02, 0)

local BACKGROUND_COLOR = Color3.fromRGB(100,100,100)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 42, 42)
local TERTIARY_COLOR = Color3.new(0.023529, 0.741176, 0.262745)
local WARN_COLOR = Color3.fromRGB(200,50,50)

local TEXT_COLOR = Color3.fromRGB(255,255,255)
--variables
--references
--local functions

function getButton(
    maid : Maid,
    buttonName : string,
    activatedFn : () -> (),
    order : number,
    color : Color3 ?,
    isRatioConstraint : boolean ?
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
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        AutoButtonColor = true,
        Font = Enum.Font.Gotham,
        Text = "" .. buttonName .. "",
        TextScaled = true,
        TextColor3 = TEXT_COLOR,
        Children = {
            _new("UICorner")({}),
            if isRatioConstraint then _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            }) else _new("Frame")({})
        },
        Events = {
            Activated = function()
                activatedFn()
            end
        },
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

    houseIndex : ValueState<number>,
    houseName : ValueState<string>,

    onNext : Signal,
    onPrevious : Signal,
    onClaim : Signal,

    onBack : Signal,

    minValue : number ?,
    maxValue : number ?
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
        Size = UDim2.fromScale(1, 0.9),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.2),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),

                    _bind(getButton(
                        maid, 
                        "&lt;", 
                        function()
                            onPrevious:Fire()
                        end, 
                        1,
                        TERTIARY_COLOR,
                        true
                    ))({
                        Visible = _Computed(function(index : number)
                            return if minValue and index <= minValue then false else true
                        end, houseIndex),
                        Size = UDim2.fromScale(0.25, 1)
                    }),

                    _new("TextLabel")({
                        LayoutOrder = 2,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.5, 1),
                        RichText = true,
                        Text = _Computed(function(name : string)
                            return "<b>" .. name .. "</b>"
                        end, houseName),
                        TextColor3 = TEXT_COLOR,
                        TextScaled = true,
                        Children = {
                            _new("UITextSizeConstraint")({
                                MinTextSize = 5,
                                MaxTextSize = 50
                            })
                        }
                    }), 

                    _bind(getButton(
                        maid, 
                        "&gt;", 
                        function()
                            onNext:Fire()
                        end, 
                        3,
                        TERTIARY_COLOR,
                        true
                    ))({
                        Visible = _Computed(function(index : number)
                            return if maxValue and index >= maxValue then false else true
                        end, houseIndex),
                        Size = UDim2.fromScale(0.25, 1)
                    }),
                }
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.09),
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    _bind(getButton(maid, "Claim", function()
                        print("Claim fires")
                        onClaim:Fire(onBack, houseIndex:Get()) 
                     end, 2, TERTIARY_COLOR))({
                         Size = UDim2.fromScale(0.2, 1)
                     }),
                    _bind(getButton(maid, "Back", function()
                        onBack:Fire() 
                     end, 2, SECONDARY_COLOR))({
                         Size = UDim2.fromScale(0.2, 1)
                     }),
                }
            })
          
        }
    })

    return out
end