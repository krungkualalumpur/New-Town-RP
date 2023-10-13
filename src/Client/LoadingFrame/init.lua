--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
local TEXT_SIZE = 20
local PADDING_SIZE = UDim.new(0,10)

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)
--remotes
--variables
--references
--local functions
--class
return function(
    maid : Maid,
    loadingText : string
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local loadingImage = _new("ImageLabel")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://10535813701"
    }) :: ImageLabel

    maid:GiveTask(RunService.RenderStepped:Connect(function()
        loadingImage.Rotation += 10
    end))

    local transp = _Value(0)

    local out = _new("Frame")({
        BackgroundTransparency = 0.75,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE, 
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,

            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = PADDING_SIZE
            }),
          
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.5, 0.1),
                Font = Enum.Font.GothamMedium,
                Text = loadingText,
                TextTransparency = transp:Tween(),
                TextStrokeTransparency = _Computed(function(num : number)
                    return math.clamp(num, 0.85, 1)
                end, transp):Tween(),
                TextColor3 = TEXT_COLOR,
                TextScaled = true,
                TextWrapped = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MinTextSize = 0,
                        MaxTextSize = TEXT_SIZE
                    })
                }
            }),
            _new("Frame")({
                Name = "LoadingIconFrame",
                LayoutOrder = 2,
                AnchorPoint = Vector2.new(0.5,0.5),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.08, 0.08),
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    }),
                    loadingImage,
                }
            }),
            _new("TextLabel")({
                LayoutOrder = 3,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.5, 0.05),
                Font = Enum.Font.GothamMedium,
                Text = "Please wait...",
                TextTransparency = 0,
                TextStrokeTransparency = 0.85,
                TextColor3 = TEXT_COLOR,
                TextScaled = true,
                TextWrapped = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MinTextSize = 0,
                        MaxTextSize = TEXT_SIZE*0.8
                    })
                }
            }),
           
        }
    })

    local t = tick()
    local bufferTime = 1
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        if tick() - t >= bufferTime then
            t = tick()
            transp:Set(if transp:Get() == 0 then 1 else 0)
            
            bufferTime = if transp:Get() == 0 then 1.5 else 0.25
        end
    end))

    return out
end
