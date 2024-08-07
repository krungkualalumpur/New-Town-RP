--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)

local PADDING_SIZE = UDim.new(0,10)
--variables
--references
--local functions
local function getButton( 
    maid : Maid,
    order : number,
    text : CanBeState<string> ?,
    fn : (() -> ()) ?,
    color : Color3 ?
) : TextButton
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out  = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = color or BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 1),
        LayoutOrder = order,
        Font = Enum.Font.Gotham,
        Text = text,
        TextWrapped = true,
        TextStrokeTransparency = 0.7,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    }) :: TextButton
    return out
end

local function getSlider(
    maid : Maid,
    order : number,
    pos : ValueState<UDim2>,
    isVisible : State<boolean>
)
    local _maid = Maid.new()    

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local slider = _new("TextButton")({
        BackgroundColor3 = BACKGROUND_COLOR,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromScale(1, 0.06),
        Children = {
            _new("UICorner")({}),
            _new("UIStroke")({
                Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = PRIMARY_COLOR
            })
        }
    }) :: TextButton

    local sliderMaid = _maid:GiveTask(Maid.new())
    --local sliderConn
 
    local mouse = Players.LocalPlayer:GetMouse()
    local intMouseX, intMouseY = mouse.X, mouse.Y
    _bind(slider)({
        Position = pos,
        Events = {
            MouseButton1Down = function()
                sliderMaid.update = RunService.RenderStepped:Connect(function()
                    local intPos = pos:Get()
                    local currentMouseY = (mouse.Y - intMouseY)/mouse.ViewSizeY
                    --print(intPos.Y.Scale, " - ", currentMouseY)
                    pos:Set(UDim2.fromScale(0, math.clamp((intPos.Y.Scale + currentMouseY), 0, 1)))
                    intMouseY = mouse.Y
                end)
            end
        }
    })
    

    local out = _new("Frame")({
        Name = _Computed(function(visible : boolean)
            sliderMaid:DoCleaning()
            if visible then
                sliderMaid:GiveTask(UserInputService.InputEnded:Connect(function(input : InputObject, gpe : boolean)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) or (input.KeyCode == Enum.KeyCode.ButtonA) then
                        sliderMaid.update = nil
                        intMouseY = slider.AbsolutePosition.Y
                    end
                end))
            end
            return "ValueBar"
        end, isVisible),
        BackgroundColor3 = PRIMARY_COLOR,
        Size = UDim2.fromScale(0.1, 1),
        Children = {
            _new("UIGradient")({
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
                },
                Rotation = 90
            }),
            _new("UICorner")({}),
            --[[_bind(getButton(maid, 1, nil, function()  
                print("AA")
            end, BACKGROUND_COLOR))({
                Size = UDim2.fromScale(1, 0.06),
                Children = {
                    _new("UIStroke")({
                        Thickness = 2,
                        Color = PRIMARY_COLOR
                    })
                }
            }),]]
            slider
        },  
    })

    _maid:GiveTask(out.AncestryChanged:Connect(function()
        if out.Parent == nil then
            _maid:Destroy()
        end
    end))
    
    return out
end

--class
return function(
    maid : Maid,

    isDark : CanBeState<boolean>,
    selectedColor : ValueState<Color3>,

    onColorConfirm : Signal,
    onBack : Signal,

    colorWheelTitle : string,

    onConfirmParams : (() -> ... any) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind 
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local isDarkState = _import(isDark, isDark)

    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)
    local containerVariantColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surfaceVariant())
    end, isDarkState)
    local textColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_onSurface())
    end, isDarkState)
    local textVariantColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_onSurfaceVariant())
    end, isDarkState)

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), 
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        }
    })

    local sliderPos = _Value(UDim2.fromScale(0, 0.5))

    local colorWheelHeader = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.06),
        Children = {
          
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(PADDING_SIZE.Scale*0.2, PADDING_SIZE.Offset*0.2),
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            }),
            
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                1, 
                colorWheelTitle, 
                textColorState, 
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.TitleMedium)), 
                20
            ))({}),
            -- _new("TextLabel")({
            --     LayoutOrder = 2,
            --     BackgroundTransparency = 1,
            --     Font = Enum.Font.GothamBold,
            --     Size = UDim2.fromScale(1, 1),
            --     Text = colorWheelTitle,
            --     TextColor3 = textColorState,
            --     TextScaled = true,
            --     TextXAlignment = Enum.TextXAlignment.Center
            -- })
        },
        
    })

    local interactableColorWheel = _new("ImageButton")({
        Name = "ColorWheel",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Rotation = -90,
        Image = "rbxassetid://7017517837",
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(100,0)
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            }),
           
        },
    }) :: ImageButton

    local colorWheelFrame = _new("Frame")({
        Name = "ColorWheelFrame",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.fromScale(0.8, 1),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1000,0)
            }),

            interactableColorWheel
        }
    }) :: Frame

    local colorWheelTracker =  _new("Frame")({
        Name = "MouseTrackerEffect",
        Visible = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.05, 0.05),
       -- Position = UDim2.fromScale(0.5, 0.5),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1000,0)
            })
        },
        Parent = colorWheelFrame
    }) :: Frame

    local colorWheelPage = _new("Frame")({
        BackgroundTransparency = _Computed(function(pos : UDim2)
            local color = selectedColor:Get()
            local h,s,v = color:ToHSV()
            selectedColor:Set(Color3.fromHSV(h, s, pos.Y.Scale))
            return 0
        end, sliderPos),
        BackgroundColor3 = containerColorState,
        Size = UDim2.new(0, 400, 0, 300),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(0, 10)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Padding = UDim.new(0, PADDING_SIZE.Offset)
            }),
            _new("UIPadding")({
                PaddingTop = UDim.new(0, PADDING_SIZE.Offset),
                PaddingBottom = UDim.new(0, PADDING_SIZE.Offset),
                PaddingLeft = UDim.new(0, PADDING_SIZE.Offset),
                PaddingRight = UDim.new(0, PADDING_SIZE.Offset),

            }),
            colorWheelHeader,
            _new("Frame")({
                Name = "ColorSettings",
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.7),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, PADDING_SIZE.Offset*0.5),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }),
                    colorWheelFrame,
                }
            }),
            _new("Frame")({
                Name = "SelectedColorFooter",
                LayoutOrder = 3,
                BackgroundTransparency = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(0.9, 0.17),
                Children = {
                 
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        Padding = UDim.new(PADDING_SIZE.Scale*0.1, PADDING_SIZE.Offset*0.1)
                    }),
                    _new("Frame")({
                        Name = "SelectedColorDetail",
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromOffset(230, 40),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                FillDirection = Enum.FillDirection.Horizontal,  
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(PADDING_SIZE.Scale*0.25, PADDING_SIZE.Offset*0.25)
                            }),
                            _new("Frame")({
                                Name = "ColorDisplay",
                                BackgroundColor3 = selectedColor, 
                                Size = UDim2.fromScale(0.75/4, 1),
                               
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                1, 
                                "R",
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                Size = UDim2.fromOffset(20, 100)
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                2, 
                                _Computed(function(color : Color3)                                   
                                    return "\t" .. tostring(math.round(color.R*255)) .. "\t"
                                end, selectedColor),
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                BackgroundTransparency = 0,
                                BackgroundColor3 = containerVariantColorState,
                                Size = UDim2.fromOffset(20, 20)
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                3, 
                                "G",
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                Size = UDim2.fromOffset(20, 100)
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                4, 
                                _Computed(function(color : Color3)                                   
                                    return "\t" .. tostring(math.round(color.G*255)) .. "\t"
                                end, selectedColor),
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                BackgroundTransparency = 0,
                                BackgroundColor3 = containerVariantColorState,
                                Size = UDim2.fromOffset(20, 20)
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                5, 
                                "B",
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                Size = UDim2.fromOffset(20, 100)
                            }),
                            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                                maid, 
                                6, 
                                _Computed(function(color : Color3)                                   
                                    return "\t" .. tostring(math.round(color.B*255)) .. "\t"
                                end, selectedColor),
                                textColorState,
                                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelSmall)), 
                                50
                            ))({
                                BackgroundTransparency = 0,
                                BackgroundColor3 = containerVariantColorState,
                                Size = UDim2.fromOffset(20, 20)
                            }),
                            
                        }
                    }),
                    _new("Frame")({
                        Name = "ConfirmationFrame",
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Size = UDim2.new(0,100,0,60),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = PADDING_SIZE,
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Left
                            }),
                            --[[_bind(getButton(maid, 1, "X", function()
                                char:Set(getCharacter(true))
                                currentPage:Set(mainMenuPage)
                            end, RED_COLOR))({
                                Name = "Cancel",
                                Size = UDim2.fromScale(0.5, 0.5),
                                TextScaled = true,
                                Children = {
                                    _new("UIAspectRatioConstraint")({
                                        AspectRatio = 1
                                    })
                                }
                            }),]]
                            Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, "Confirm", function()   
                                if onConfirmParams then
                                    onColorConfirm:Fire(onConfirmParams())
                                else
                                    onColorConfirm:Fire()
                                end
                            end, isDarkState),
                            Sintesa.Molecules.TextCommonButton.ColdFusion.new(maid, "Close", function() 
                                onBack:Fire()
                            end, isDarkState),
                            -- _bind(getButton(maid, 1, "✓", function()
                            --     if onConfirmParams then
                            --         onColorConfirm:Fire(onConfirmParams())
                            --     else
                            --         onColorConfirm:Fire()
                            --     end
                            -- end, SELECT_COLOR))({
                            --     Size = UDim2.fromScale(0.5, 0.5),
                            --     TextScaled = true
                            -- }),
                            -- Sintesa.Molecules.button.ColdFusion.new(maid, "X", function()
                            --     onBack:Fire()
                            -- end),
                            -- _bind(getButton(maid, 1, "x", function()
                            --     onBack:Fire()
                            -- end, RED_COLOR))({
                            --     Size = UDim2.fromScale(0.5, 0.5),
                            --     TextScaled = true,
                            --     Children = {
                                  
                            --     }
                            -- }),
                        }
                    })
                }
            }),
        }
    }) :: Frame

    local slider = getSlider(maid, 2, sliderPos, _Value(true))

    local color = selectedColor:Get()
    local h,s,v = color:ToHSV()
    sliderPos:Set(UDim2.fromScale(0, v))
    selectedColor:Set(color)
    
    slider.Parent = colorWheelPage:WaitForChild("ColorSettings")

    do
        local colorWheelMaid = maid:GiveTask(Maid.new())
        local mouse = Players.LocalPlayer:GetMouse()
        _bind(interactableColorWheel)({
            
            Events = {
                MouseButton1Down = function()
                    colorWheelMaid.update = RunService.RenderStepped:Connect(function()
                        local mousePosX, mousePosY = mouse.X - (interactableColorWheel.AbsolutePosition.X + interactableColorWheel.AbsoluteSize.X*0.5), mouse.Y - (interactableColorWheel.AbsolutePosition.Y + interactableColorWheel.AbsoluteSize.Y*0.5)
                        --selectedColor:Set()
                        --print(mousePosX, mousePosY)
                        local rad = math.atan2(mousePosY,mousePosX)
                        -- local v2Unit = Vector2.new(mousePosX, mousePosY).Unit
                        --print(math.deg(rad), math.deg(rad) + 180)
                        local angle = (rad + math.pi)
                        local hue = (angle)/(2*math.pi)
                        local saturation = math.clamp((Vector2.new(mousePosX, mousePosY).Magnitude)/(interactableColorWheel.AbsoluteSize.X*0.5), 0, 1)
                        local intColor = selectedColor:Get()    
                        local _,_,value = intColor:ToHSV()
                        selectedColor:Set(Color3.fromHSV(hue, saturation, value))
                        colorWheelTracker.Visible = true
                        colorWheelTracker.Position = UDim2.fromOffset(mouse.X - colorWheelFrame.AbsolutePosition.X, mouse.Y - colorWheelFrame.AbsolutePosition.Y)
                    end)
                    --print(interactableColorWheel.AbsoluteSize.X*0.5, Vector2.new(mousePosX, mousePosY).Magnitude, (Vector2.new(mousePosX, mousePosY).Magnitude)/(interactableColorWheel.AbsoluteSize.X*0.5))

                    --print("deg: ", math.deg(angle), hue)
                end,
                MouseButton1Up = function()
                    colorWheelMaid.update = nil
                end
            }
        })       
    end

    colorWheelPage.Parent = out


    return out
end
