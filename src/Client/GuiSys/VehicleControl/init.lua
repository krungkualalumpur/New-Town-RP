--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

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

    hornSignal : Signal,
    headlightSignal : Signal,
    leftSignal : Signal,
    rightSignal : Signal,
    hazardSignal : Signal,
    waterSpraySignal : Signal ?,

    onMove : Signal
)
    local height = 35
    local isDark = false

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)

    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)

    local content =  _new("Frame")({
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.X,
        Size =  UDim2.fromOffset(0, height),
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            _new("UICorner")({
                CornerRadius = UDim.new(0,5)
            })
        }
    })

    
    local lightButton =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 3047402270, _Value(false), function()  
        headlightSignal:Fire()
    end, isDarkState, height - 10))({
        LayoutOrder = 1,
        Parent = content
    })
    local leftSignalButton =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 7077158348, _Value(false), function()  
        leftSignal:Fire()
    end, isDarkState, height - 10))({
        LayoutOrder = 2,
        Parent = content
    })
    local rightSignalButton =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 7077158534, _Value(false), function()  
        rightSignal:Fire()
    end, isDarkState, height - 10))({
        LayoutOrder = 3,
        Parent = content
    })
    local hazardButton =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 12089594444, _Value(false), function()  
        hazardSignal:Fire()
    end, isDarkState, height - 10))({
        LayoutOrder = 4,
        Parent = content
    })
    local hornButton =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 12339036604, _Value(false), function()  
        hornSignal:Fire()
    end, isDarkState, height - 10))({
        LayoutOrder = 5,
        Parent = content
    })
    if waterSpraySignal then
        local waterSpraySignal =  _bind(Sintesa.Molecules.StandardIconButton.ColdFusion.new(maid, 13492318033, _Value(false), function()  
            waterSpraySignal:Fire()
        end, isDarkState, height - 10))({
            LayoutOrder = 5,
            Parent = content
        })
    end
    -- local lightButton = getImageButton(maid, 3047402270, function()
    --     headlightSignal:Fire()
    -- end, "", 1, false)
    -- lightButton.Parent = content 
    -- local leftSignalButton = getImageButton(maid, 7077158348, function()
    --     leftSignal:Fire()
    -- end, "", 2, false)
    -- leftSignalButton.Parent = content 
    -- local rightSignalButton = getImageButton(maid, 7077158534, function()
    --     rightSignal:Fire()
    -- end, "", 3, false)
    -- rightSignalButton.Parent = content 
    -- local hazardButton = getImageButton(maid, 12089594444, function()
    --     hazardSignal:Fire()
    -- end, "", 4, false)
    -- hazardButton.Parent = content  
    -- local hornButton = getImageButton(maid, 6824924955, function()
    --     hornSignal:Fire()
    -- end, "", 5, false)
    -- hornButton.Parent = content 
    
    -- if waterSpraySignal then
    --     local waterSprayButton = getImageButton(maid, 13492318033, function()
    --         waterSpraySignal:Fire()
    --     end, "", 5, false)
    --     waterSprayButton.Parent = content 
    -- end

    local controlArrow = _new("TextButton")({
        AnchorPoint = Vector2.new(0.5,0.5),
        AutoButtonColor = true,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.3, 0.3),
        TextScaled = true,
        Font = Enum.Font.ArialBold,
        Text = "<",
        TextColor3 = Color3.fromRGB(255,255,255),
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
          
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
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
