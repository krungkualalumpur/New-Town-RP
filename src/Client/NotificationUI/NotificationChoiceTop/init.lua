--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
--packages
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
--modules
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type State<a> = ColdFusion.State<a>
type ValueState<a> = ColdFusion.ValueState<a>
type CanBeState<a> = ColdFusion.CanBeState<a>
--constants
local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(75, 210, 80)
local RED_COLOR = Color3.fromRGB(200,50,50)


local PADDING_SIZE = UDim.new(0.01,0)
--variables
--references
local Player = Players.LocalPlayer
--local functions
function PlaySound(id, parent, volumeOptional: number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = 350
    s.Looped = false
    s.Parent = parent or Player:WaitForChild("PlayerGui")
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end

local function getButton(
    maid : Maid,
    order : number,
    text : CanBeState<string>,
    fn : () -> (),
    color :  CanBeState<Color3> ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("TextButton")({
        AutoButtonColor = true,
        LayoutOrder = order,
        BackgroundColor3 = color,
        Size = UDim2.fromScale(0.25, 0.15),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = TEXT_COLOR,
        TextStrokeTransparency = 0.75,
        TextScaled = true,
        TextWrapped = true,
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("UITextSizeConstraint")({
                MaxTextSize = 20
            })
        },
        Events = {
            Activated = function()
                fn()
                --onClick:Fire(interactedItem)
            end
        }
    })
    return out
end
--class
return function(
    notifMaid : Maid,
    mainMessage : string,
    onConfirm : Signal,
    confirmText : string ?, 
    cancelText : string ?
)

    local _fuse = ColdFusion.fuse(notifMaid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
   
    
    local okButton = _bind(getButton(
        notifMaid, 
        1, 
        confirmText or "OK", 
        function()
            onConfirm:Fire()
            notifMaid:DoCleaning()
        end,
        BACKGROUND_COLOR
    ))({
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.4, 1),

    })

    local cancelButton = _bind(getButton(
        notifMaid, 
        1, 
        cancelText or "Cancel", 
        function()
            notifMaid:DoCleaning()
        end,
        BACKGROUND_COLOR
    ))({
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.4, 1),

    })

    local notifTextFrame = _new("TextLabel")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.75),
        Text = mainMessage,
        TextColor3 = TEXT_COLOR,
        TextStrokeTransparency = 0.8,
        TextScaled = true,
        TextWrapped = true,
        Children = {
            _new("UITextSizeConstraint")({
                MaxTextSize = 20
            })
        }
    })

    local confirmationFrame = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.2),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            okButton,
            cancelButton
        }
    })
    
    local content = _new("Frame")({
        BackgroundTransparency = 0.5,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.3, 0.15),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(0.1,0)
            }),
            _new("UIStroke")({
                Thickness = 1.2,
                Color = PRIMARY_COLOR
            }),   
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            notifTextFrame,
            confirmationFrame
        }  
    }) 

    local out = _new("Frame")({
        Size = UDim2.fromScale(1, 0.85),
        Position = UDim2.fromScale(0, 0.15),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            content
        }
    })

    local isExitButtonVisible = _Value(false)
    local exitButton = ExitButton.new(content :: Frame, isExitButtonVisible, function()
        notifMaid:DoCleaning()
        return
    end)

    if RunService:IsRunning() then
        PlaySound(1293433423)
    end

    return out
end
