--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local FeedbackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("FeedbackUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
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
--remotes
local SEND_ANALYTICS = "SendAnalytics"
--variables
--references
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
        TextXAlignment = Enum.TextXAlignment.Center,
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
        Size = UDim2.fromScale(0.75, 0.75),
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
    onSprintClick : Signal,

    sprintState : ColdFusion.State<boolean>,

    onFeedbackSend : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _import = _fuse.import

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local isExitButtonVisible = _Value(true)
    
    local function getExitButton(ui : GuiObject)
        local exitButton = ExitButton.new(
            ui :: GuiObject, 
            isExitButtonVisible,
            function()
                ui.Parent = nil
                return nil 
            end
        ) 
        exitButton.Instance.Parent = ui
    end
    
    local sprintButton 

    if game:GetService("UserInputService").KeyboardEnabled then
        sprintButton = getImageButton(maid, _Computed(function(isSprinting : boolean)
            return if isSprinting then 9525535512 else 9525534183 
        end, sprintState), function()
                onSprintClick:Fire()
        end, _Computed(function(isSprinting : boolean)
            return if isSprinting then "Running" else "Walking" 
        end, sprintState), 1)  

        if RunService:IsRunning() then
            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "sprint_button")
        end
    end

    local feedbackUI = FeedbackUI(
        maid,
        onFeedbackSend
    )

    getExitButton(feedbackUI)

    local feedBackScreenGui = _new("ScreenGui")({
        Parent = if RunService:IsRunning() then game.Players.LocalPlayer.PlayerGui else game:GetService("CoreGui")
    })

    local feedbackButton = _bind(getButton(maid, "Leave a feedback", function()
        feedbackUI.Parent = feedBackScreenGui 
        print(feedbackUI, feedbackUI.Parent)
        if RunService:IsRunning() then
            NetworkUtil.fireServer(SEND_ANALYTICS, "Events", "Interface", "feedback_button")
        end
        return
    end, 2, BACKGROUND_COLOR))({Size = UDim2.fromScale(1, 0.6)})

    local out = _new("Frame")({
        Position = UDim2.fromScale(0, 0.05),
        Size = UDim2.fromScale(1, 0.065),
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
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
             
            sprintButton,
            feedbackButton
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
