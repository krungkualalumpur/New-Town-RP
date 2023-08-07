--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
local AnimationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("AnimationUI"))
local RPNameUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("RPNameUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))

--types
type Maid = Maid.Maid

type UIStatus = "Backpack" | "Animation" | "RP_Name" | nil

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
local BACKGROUND_COLOR = Color3.fromRGB(100,100,100)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 32, 190)

local PADDING_SIZE = UDim.new(0,10)
--variables
--references
--local functions
local function getItemInfo(
    class : string,
    name : string
)
    return {
        Class = class,
        Name = name
    }
end

local function getAnimInfo(
    animName : string,
    animId : number
)
    return {
        Name = animName,
        AnimationId = "rbxassetid://" .. tostring(animId)
    }   
end

function getButton(
    maid : Maid,
    ImageId : number,
    activatedFn : () -> (),
    buttonName : string,
    order : number
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
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.5, 0.1),
        AutoButtonColor = true,
        Image = "rbxassetid://" .. tostring(ImageId),
        Children = {
            _new("UIAspectRatioConstraint")({}),
            _new("TextLabel")({
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 0.8,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.3),
                Position = UDim2.fromScale(1, 0.5),
                Text = buttonName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeColor3 = SECONDARY_COLOR,
                TextStrokeTransparency = 0.5
    
            })
        },
        Events = {
            Activated = activatedFn
        }
    })
    return button
end
--class
return function(maid : Maid)
    print("nailak")
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local statusMaid = maid:GiveTask(Maid.new())
    local UIStatus : ValueState<UIStatus> = _Value(nil) :: any


    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.1, 1),
                Position = UDim2.fromScale(0, 0),   
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    }),   
                    getButton(maid, 2815418737, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Backpack" then "Backpack" else nil)
                    end, "Backpack", 1),
                    getButton(maid, 7059328055, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Animation" then "Animation" else nil)
                    end, "Animation", 2),
                    getButton(maid, 5755108026, function()
                        UIStatus:Set(if UIStatus:Get() ~= "RP_Name" then "RP_Name" else nil)
                    end, "RP_Name", 3)
                    --getButton(maid, 227600967),

                }
            })
        }
    }) :: Frame

    
    local function getExitButton(ui : GuiObject)
        
        local exitButton = ExitButton.new(
            ui:WaitForChild("ContentFrame") :: GuiObject, 
            _Value(true),
            function()
                UIStatus:Set(nil)
                return nil 
            end
        ) 
        exitButton.Instance.Parent = ui:FindFirstChild("ContentFrame")
    end
    
    _Computed(function(status : UIStatus)
        statusMaid:DoCleaning() 
        if status == "Backpack" then
            local backpackUI = BackpackUI(
                statusMaid,
                BackpackUtil.getItemClasses(),
                _Value({
                    getItemInfo("Food", "Banana"),
                    getItemInfo("Food", "Umaga")
                })
            )

            backpackUI.Parent = out
            
            getExitButton(backpackUI)
        elseif status == "Animation" then 
            local animationUI = AnimationUI(
                statusMaid, {
                    getAnimInfo("Hepi", 1212010),
                    getAnimInfo("Sed", 1212010)
                }   
            ) :: Frame
            animationUI.Parent = out

            getExitButton(animationUI)
        elseif status == "RP_Name" then
            local RPNameUI = RPNameUI(statusMaid) :: Frame
            RPNameUI.Parent = out

            getExitButton(RPNameUI)
        end
        return nil
    end, UIStatus)
    return out
end
