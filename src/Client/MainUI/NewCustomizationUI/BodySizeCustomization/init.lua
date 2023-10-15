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
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
--constants
local TEXT_SIZE = 15
local STR_CHAR_LIMIT =  10

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
--variables
--references
--local functions
local function getHorizontalSlider(
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
        AnchorPoint = Vector2.new(0.5, 0.3),
        Size = UDim2.fromScale(0.1, 2.5),
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
        Position = pos,
        Events = {
            MouseButton1Down = function()
                sliderMaid.update = RunService.RenderStepped:Connect(function()
                    local intPos = pos:Get()
                    local currentMouseX = (mouse.X - intMouseX)/mouse.ViewSizeX
                    print(intPos.X.Scale, " - ", intMouseX)
                    pos:Set(UDim2.fromScale(math.clamp((intPos.X.Scale + currentMouseX), 0, 1), 0))
                    intMouseX = mouse.X
                end)
            end
        }
    })
    

    local out = _new("Frame")({
        LayoutOrder = order,
        Name = _Computed(function(visible : boolean)
            sliderMaid:DoCleaning()
            if visible then
                sliderMaid:GiveTask(UserInputService.InputEnded:Connect(function(input : InputObject, gpe : boolean)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
                Size = _Computed(function(u2 : UDim2)
                    -- print("Keluarge")
                    return UDim2.fromScale(u2.X.Scale, 1)
                end, pos) --UDim2.fromScale(0.5, 1)
            }),
            slider
        },  
    })

    _maid:GiveTask(out.Destroying:Connect(function()
        _maid:Destroy()
    end))
    
    return out
end

local function getListFrame(
    maid : Maid,
    listName : string
    --, continue dis!
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local sliderPos = _Value(UDim2.fromScale(0.5, 0))

    local out = _new("Frame")({
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
                Size = UDim2.fromScale(0.15, 1),
                Text = listName,
                TextWrapped = true,
                TextScaled = true
            }),
            _bind(getHorizontalSlider(maid, 2, sliderPos, _Computed(function()
                return true
            end)))({
                Size = UDim2.new(0.85, 0, 0, 5)
            })
        }
    })
    return out
end

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


    return _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.68, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE_SCALE,
                PaddingBottom = PADDING_SIZE_SCALE,
                PaddingRight = PADDING_SIZE_SCALE,
                PaddingLeft = PADDING_SIZE_SCALE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE_SCALE,
            }),
            getListFrame(
                maid,
                "Body Scale"
            )
          
        }
    }) :: Frame
end
