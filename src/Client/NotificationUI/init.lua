--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

--constants
local PADDING_SIZE =  UDim.new(0, 5)

local BACKGROUND_COLOR = Color3.fromRGB(50,50,50)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)

local DELAY_TIME = 5
--variables
--references
--local functions
local function getSound(soundId : number, target : Instance ?)
    local maid = Maid.new()

    local sound = maid:GiveTask(Instance.new("Sound"))
    sound.SoundId = "rbxassetid://"..tostring(soundId)
    sound.Parent = target
    sound:Play()
    maid:GiveTask(sound.Ended:Connect(function()
        maid:Destroy()
    end))
    return
end

function getNotificationFrame(
    maid : Maid,
    isDark : State<boolean>,
    text : string
)

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local pos = _Value(UDim2.fromScale(0, 1))
    local transp = _Value(1)

    local content = Sintesa.Molecules.Snackbar.ColdFusion.new(maid, isDark, function() end)

    pos:Set(UDim2.fromScale(0, 0))
    transp:Set(0.5)

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        
        Children = {
            _new("UIAspectRatioConstraint")({
                AspectRatio = 3,
            }),
            --content
        }
    })

    task.spawn(function()
        task.wait(DELAY_TIME)
        pos:Set(UDim2.fromScale(0, -1))
        transp:Set(1)
        task.wait(0.5)
        maid:Destroy()
    end)
    
    return content
end
--class
return function(
    maid : Maid,
    isDark : CanBeState<boolean>,
    textStatus : ValueState<string ?>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)
    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })
        }
    }) :: Frame

    local computedTextStatus = _Computed(function(text : string ?)
        if text then
            getSound(6647898215, out.Parent)
            local _maid = Maid.new()
            local notifFrame = getNotificationFrame(
                _maid,   
                isDarkState,
                text
            )
            notifFrame.Parent = out
        end
        return true
    end, textStatus)

    _bind(out)({
        Visible = computedTextStatus
    })

    return out 
end
