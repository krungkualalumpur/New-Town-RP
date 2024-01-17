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
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
--constants
local TEXT_SIZE = 15

local PADDING_SIZE = UDim.new(0,10)
local PADDING_SIZE_SCALE = UDim.new(0.15,0)

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)

local SNAP_NUMBER = 50
--variables
--references
--local functions
local function roundNumber(num : number, snapNum : number)
    return math.round(num*snapNum)/snapNum
end
local function getHorizontalSlider(
    maid : Maid,
    order : number,
    pos : ValueState<UDim2>,
    isVisible : State<boolean>,
    isRound : boolean,

    onPress : (() -> ())?,
    onRelease : (() -> ())??
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
        AnchorPoint = Vector2.new(0.5, 0.3),
        Size = UDim2.fromScale(0.1, 2.5),
        Position = _Computed(function(udim2 : UDim2)
            return if isRound then UDim2.fromScale(roundNumber(udim2.X.Scale, SNAP_NUMBER), udim2.Y.Scale) else udim2
        end, pos),
        Children = {
            _new("UICorner")({}),
            _new("UIStroke")({
                Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = PRIMARY_COLOR
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            })
        } 
    }) :: TextButton

    local sliderMaid = _maid:GiveTask(Maid.new())
    --local sliderConn
 
    local mouse = Players.LocalPlayer:GetMouse()
    local intMouseX, intMouseY = mouse.X, mouse.Y

    _bind(slider)({
        Events = {
            MouseButton1Down = function()
                sliderMaid.update = RunService.RenderStepped:Connect(function()
                    local intPos = pos:Get()
                    local currentMouseX = ((mouse.X - intMouseX)/mouse.ViewSizeX)
                    local sliderPosX = math.clamp((intPos.X.Scale + currentMouseX), 0, 1)
                    --print(intPos.X.Scale, " - ", intMouseX)
                    pos:Set(UDim2.fromScale(sliderPosX, 0))
                    intMouseX = mouse.X
                end)
                if onPress then
                    onPress()
                end
            end
        }
    })
    

    local out = _new("Frame")({
        LayoutOrder = order,
        Name = _Computed(function(visible : boolean)
            sliderMaid:DoCleaning()
            if visible then
                sliderMaid:GiveTask(UserInputService.InputEnded:Connect(function(input : InputObject, gpe : boolean)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) or (input.KeyCode == Enum.KeyCode.ButtonA) then
                        if sliderMaid.update and onRelease then
                            onRelease()
                        end
                        sliderMaid.update = nil
                        intMouseX = slider.AbsolutePosition.X
                        
                    end
                end))
            end
            return "ValueBar"
        end, isVisible),
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.new(1, 0, 0,10),
        Children = {
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
            _new("Frame")({
                BackgroundColor3 = SELECT_COLOR,
                Size = _Computed(function(udim2 : UDim2)
                    return if isRound then UDim2.fromScale(roundNumber(udim2.X.Scale, SNAP_NUMBER), 1) else UDim2.fromScale(udim2.X.Scale, 1)
                end, pos),
                --Size = _Computed(function(u2 : UDim2)
                    -- print("Keluarge")
                    --return UDim2.fromScale(u2.X.Scale, 1)
                --end, pos) --UDim2.fromScale(0.5, 1)
            }),
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

local function getListFrame(
    maid : Maid,
    listName : string,
    
    onSlideChange : Signal,
    char : ValueState<Model>,

    isVisible : State<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local sliderPos = _Value(UDim2.fromScale(0.5, 0))

    local modifiedListName = listName:gsub(" ", "")
    local out = _new("Frame")({
        Name = _Computed(function(pos : UDim2)
            return ""
        end, sliderPos),
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.1,0),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),

            }),
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.15, 1),
                Font = Enum.Font.Gotham,
                Text = listName,
                TextColor3 = PRIMARY_COLOR,
                TextWrapped = true,
                TextScaled = true
            }),
            _bind(getHorizontalSlider(maid, 2, sliderPos, _Computed(function()
                return true
            end), true, nil, function()
                onSlideChange:Fire(modifiedListName, sliderPos:Get().X.Scale, char, true)
            end))({
                Size = UDim2.new(0.85, 0, 0, 5)
            })
        }
    })

    do
        _new("StringValue")({
            Value = _Computed(function(visible : boolean)
                if visible then
                    local character = char:Get()
                    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
                    local humanoidDescription = humanoid:WaitForChild("HumanoidDescription") :: HumanoidDescription
                    local value 
                    local s, e = pcall(function() value = humanoidDescription[modifiedListName] end)
                    if not s and e then
                        warn(e)
                    elseif s and value then
                        sliderPos:Set(UDim2.fromScale(value, sliderPos:Get().Y.Scale))
                    end
                end
                return ""
            end, isVisible)
        })
       

    end
    return out
end

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


--class
return function(
    maid : Maid,

    onScaleChange : Signal,
    onScaleConfirmChange : Signal,
    
    onBack : Signal,

    char : ValueState<Model>,
    currentPage : ValueState<GuiObject?>,
    mainMenuPage : GuiObject
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    --local a = Instance.new("HumanoidDescription") :: HumanoidDescription
    local header = _new("Frame")({
        LayoutOrder = 1,
        Name = "HeaderFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _bind(getButton(maid, 1, "<", function()
                --CurrentCategory:Set(nil)
                onBack:Fire()
                -- print("lagi nyambel")
                -- onCustomizeBodyColor:Fire(selectedColor:Get(), char)
                -- currentPage:Set(mainMenuPage)
            end, TERTIARY_COLOR))({
                Name = "Back",
                Size = UDim2.fromScale(0.1, 1),
                TextScaled = true 
            }),
            _new("Frame")({
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.8),
                BackgroundTransparency = 1,
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.8),
                        TextScaled = true,
                        Font = Enum.Font.GothamBold,
                        Text = "Body Scale",
                        TextColor3 = TEXT_COLOR,
                        TextXAlignment = Enum.TextXAlignment.Center
                    }),
                    --[[_bind(getTextBox(maid, 2,"Search...", function(text : string)
                       
                        onSearch:Fire(text)
                    end))({
                        Size = UDim2.fromScale(1, 0.7)
                    })]]
                }
            })
        }
    })

    local footer =  _new("Frame")({
        LayoutOrder = 3,
        Name = "ConfirmationFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE_SCALE,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
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
            _bind(getButton(maid, 1, "✓", function()
                local character = char:Get()
                local characterData = CustomizationUtil.GetInfoFromCharacter(character)
                onScaleConfirmChange:Fire(characterData, char)
                onBack:Fire()
                --currentPage:Set(mainMenuPage)
                -- print("lagi nyambel")
                -- onCustomizeBodyColor:Fire(selectedColor:Get(), char)
                -- currentPage:Set(mainMenuPage)
            end, SELECT_COLOR))({
                Size = UDim2.fromScale(0.8, 0.8),
                TextScaled = true,
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            })
        }
    })
 
    local isVisible = _Value(false)
    local content = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.75),
        Children = {
            
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),

            }),
            getListFrame(
                maid,
                "Head Scale",
                onScaleChange,
                char,
                isVisible
            ),
            getListFrame(
                maid,
                "Depth Scale",
                onScaleChange,
                char,
                isVisible
            ),
            getListFrame(
                maid,
                "Width Scale",
                onScaleChange,
                char,
                isVisible
            ),
            getListFrame(
                maid,
                "Height Scale",
                onScaleChange,
                char,
                isVisible
            ),
            getListFrame(
                maid,
                "Body Type Scale",
                onScaleChange,
                char,
                isVisible
            ),
            getListFrame(
                maid,
                "Proportion Scale",
                onScaleChange,
                char,
                isVisible
            ),
        }
    }) :: Frame

    local out = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.5,PADDING_SIZE_SCALE.Offset*0.5),
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.25,PADDING_SIZE_SCALE.Offset*0.25),
            }),           
            header,
            content,
            footer
        }
    }) :: Frame

    _bind(out)({
        Visible = isVisible
    })

    local strVal = _new("StringValue")({
        Value = _Computed(function(page : GuiObject ?)
            local isBodySizeCustomizationPage = (page == out)
            isVisible:Set(isBodySizeCustomizationPage)
            return ""
        end, currentPage)    
    })
    
    return out 
end
