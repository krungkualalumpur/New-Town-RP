--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local PADDING_SIZE =  UDim.new(0, 25)

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
            MouseButton1Down = function()
                onClick()
            end
        }
    }) :: TextButton

    return out   
end

function getImageButton(
    maid : Maid,
    ImageId : number,
    activatedFn : () -> (),
    buttonName : string,
    order : number,
    textAnimated : boolean
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local imageTextPos = _Value(UDim2.fromScale(0, 1.2))
    local imageTextTransp = _Value(0.5)

    local interval = 1.8
    local imageText = _new("TextLabel")({
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 0.3),
        Position = imageTextPos:Tween(interval*0.9),
        Font = Enum.Font.GothamBold,
        Text = buttonName,
        TextColor3 = PRIMARY_COLOR,
        TextSize = 15,
        TextStrokeColor3 = SECONDARY_COLOR,
        TextTransparency = imageTextTransp:Tween(interval*0.9),
        TextStrokeTransparency = _Computed(function(transp : number)
            return math.clamp( transp,0.5, 1)
        end, imageTextTransp):Tween(interval*0.9),
        TextXAlignment = Enum.TextXAlignment.Center
    })

    if textAnimated then
        local t = tick()
        local animState = "Back"
        maid:GiveTask(RunService.RenderStepped:Connect(function()
            if tick() - t >= interval then
                t = tick()
                imageTextPos:Set(UDim2.fromScale(if animState == "Back" then 1.15 else 1.4, 0.5))
                imageTextTransp:Set(if animState == "Back" then 0 else 0.25)
                animState = if animState == "Back" then "Forth" else "Back"
            end
        end))
    end

    local button = _new("ImageButton")({
        Name = buttonName,
        LayoutOrder = order,
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.5, 0.1),
        AutoButtonColor = true,
        Image = "rbxassetid://" .. tostring(ImageId),
        Children = {
           
            _new("UICorner")({}),
            imageText
        },
        Events = {
            MouseButton1Down = activatedFn
        }
    })


    return button
end
--class
return function(
    maid : Maid,

    hornSignal : Signal,
    headlightSignal : Signal,
    leftSignal : Signal,
    rightSignal : Signal,
    hazardSignal : Signal,
    waterSpraySignal : Signal ?,

    onMove : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local content =  _new("Frame")({
        LayoutOrder = 2,
        Size =  UDim2.fromScale(1, 0.25),
        BackgroundTransparency = 1,
        Children = {
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1.5,
            }),
            _new("UIGridLayout")({
                CellSize = UDim2.fromScale(0.25,0.35),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        }
    })

   
    local lightButton = getImageButton(maid, 3047402270, function()
        headlightSignal:Fire()
    end, "", 1, false)
    lightButton.Parent = content 
    local leftSignalButton = getImageButton(maid, 7077158348, function()
        leftSignal:Fire()
    end, "", 2, false)
    leftSignalButton.Parent = content 
    local rightSignalButton = getImageButton(maid, 7077158534, function()
        rightSignal:Fire()
    end, "", 3, false)
    rightSignalButton.Parent = content 
    local hazardButton = getImageButton(maid, 12089594444, function()
        hazardSignal:Fire()
    end, "", 4, false)
    hazardButton.Parent = content  
    local hornButton = getImageButton(maid, 6824924955, function()
        hornSignal:Fire()
    end, "", 5, false)
    hornButton.Parent = content 
    
    if waterSpraySignal then
        local waterSprayButton = getImageButton(maid, 13492318033, function()
            waterSpraySignal:Fire()
        end, "", 5, false)
        waterSprayButton.Parent = content 
    end

    local controlArrow = _new("TextButton")({
        AnchorPoint = Vector2.new(0.5,0.5),
        AutoButtonColor = true,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.3, 0.3),
        TextScaled = true,
        Font = Enum.Font.ArialBold,
        Text = "<",
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(0.25,0),
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            })
        },
        
    })

    local out = _new("Frame")({
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            
            
            _new("Frame")({
                LayoutOrder = 1,
                Size =  UDim2.fromScale(1, 0.1),
                BackgroundTransparency = 1,
            }),
            content,
            _new("Frame")({
                LayoutOrder = 3,
                BackgroundTransparency = 1,
                Visible = if not RunService:IsStudio() then UserInputService.TouchEnabled else true,
                Size = UDim2.fromScale(0.85, 0.8),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    }),
                   
                    _new("Frame")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.4, 1),
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 0.75
                            }),
                            _clone(controlArrow)({
                                Rotation = 90,
                                Position = UDim2.fromScale(0.5, 0.27),
                                Events = {
                                    MouseButton1Down = function()
                                        onMove:Fire("Forward")
                                    end,
                                    MouseButton1Up = function()
                                        onMove:Fire("Brake")
                                    end,
                                }
                            }),
                            _clone(controlArrow)({
                                Position = UDim2.fromScale(0.35, 0.5),
                                Events = {
                                    MouseButton1Down = function()
                                        onMove:Fire("Left")
                                    end,
                                    MouseButton1Up = function()
                                        onMove:Fire("Straight")
                                    end,
                                }
                            }),
                            _clone(controlArrow)({
                                Rotation = 180,
                                Position = UDim2.fromScale(0.65, 0.5),
                                Events = {
                                    MouseButton1Down = function()
                                        onMove:Fire("Right")
                                    end,
                                    MouseButton1Up = function()
                                        onMove:Fire("Straight")
                                    end,
                                }
                            }),
                            _clone(controlArrow)({
                                Rotation = -90,
                                Position = UDim2.fromScale(0.5, 0.73),
                                Events = {
                                    MouseButton1Down = function()
                                        onMove:Fire("Backward")
                                    end,
                                    MouseButton1Up = function()
                                        onMove:Fire("Brake")
                                    end,
                                }
                            }),
                        }
                    })
                }
            })
        }
    })
    return out
end
