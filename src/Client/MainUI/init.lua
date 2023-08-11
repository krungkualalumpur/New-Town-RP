--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
local AnimationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("AnimationUI"))
local CustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("CustomizationUI"))
local ToolsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ToolsUI"))

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))

local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

export type UIStatus = "Backpack" | "Animation" | "Customization" | nil
type AnimationInfo = {
    Name : string,
    AnimationId : string
}

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
local BACKGROUND_COLOR = Color3.fromRGB(100,100,100)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 42, 42)

local PADDING_SIZE = UDim.new(0,10)
--remotes
local GET_PLAYER_BACKPACK = "GetPlayerBackpack"

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
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.5, 0.1),
        AutoButtonColor = true,
        Image = "rbxassetid://" .. tostring(ImageId),
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
                Position = UDim2.fromScale(1.2, 0.5),
                Text = buttonName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeColor3 = SECONDARY_COLOR,
                TextStrokeTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left
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

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,
    UIStatus : ValueState<UIStatus>,

    backpackOnEquip : Signal,
    backpackOnDelete : Signal,

    nameOnCustomize : Signal
)    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local statusMaid = maid:GiveTask(Maid.new())

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
                        print(UIStatus:Get())
                        UIStatus:Set(if UIStatus:Get() ~= "Backpack" then "Backpack" else nil)
                        print(UIStatus:Get())
                    end, "Backpack", 1),
                    getButton(maid, 11127689024, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Animation" then "Animation" else nil)
                        print(UIStatus:Get())
                    end, "Animation", 2),
                    getButton(maid, 13285102351, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Customization" then "Customization" else nil)
                        print(UIStatus:Get())
                    end, "Customization", 3)
                    --getButton(maid, 227600967),

                }
            })
        }
    }) :: Frame

    local isExitButtonVisible = _Value(true)
    local function getExitButton(ui : GuiObject)
        local exitButton = ExitButton.new(
            ui:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            function()
                UIStatus:Set(nil)
                return nil 
            end
        ) 
        exitButton.Instance.Parent = ui:FindFirstChild("ContentFrame")
    end
  
    local val = _Computed(function(status : UIStatus)
        print("test1?")
        statusMaid:DoCleaning() 
        if status == "Backpack" then
            print("Test2?")
            local onBackpackButtonEquipClickSignal = statusMaid:GiveTask(Signal.new())
            local onBackpackButtonDeleteClickSignal = statusMaid:GiveTask(Signal.new())

            statusMaid:GiveTask(onBackpackButtonEquipClickSignal:Connect(function(toolKey : number, toolName : string ?)
                backpackOnEquip:Fire(toolKey, toolName)
               
            end))
            statusMaid:GiveTask(onBackpackButtonDeleteClickSignal:Connect(function(toolKey : number, toolName : string)
                backpackOnDelete:Fire(toolKey, toolName)
            end))

            local backpackUI = BackpackUI(
                statusMaid,
                BackpackUtil.getAllItemClasses(),
                backpack,

                onBackpackButtonEquipClickSignal,
                onBackpackButtonDeleteClickSignal
            )

            backpackUI.Parent = out
            
            getExitButton(backpackUI)
            if game:GetService("RunService"):IsRunning() then
                backpack:Set(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))
            end
        elseif status == "Animation" then 
            local onAnimClickSignal = statusMaid:GiveTask(Signal.new())
            local animationUI = AnimationUI(
                statusMaid, 
                {
                    getAnimInfo("Dance1", 6487673963),
                    getAnimInfo("Dance2", 6487678676),
                    getAnimInfo("Get Out", 6487639560),
                    getAnimInfo("Happy", 6487656144),
                },
                onAnimClickSignal
            ) :: Frame
            animationUI.Parent = out
            statusMaid:GiveTask(onAnimClickSignal:Connect(function(animInfo : AnimationInfo)
                AnimationUtil.playAnim(Players.LocalPlayer, animInfo.AnimationId)
            end))

            getExitButton(animationUI)
        elseif status == "Customization" then
            local onCustomeButtonClick = statusMaid:GiveTask(Signal.new())
            print(onCustomeButtonClick)

            local CustomizationUI = CustomizationUI(
                statusMaid,
                CustomizationList,
                onCustomeButtonClick,

                nameOnCustomize

            ) :: Frame
            CustomizationUI.Parent = out

            statusMaid:GiveTask(onCustomeButtonClick:Connect(function(costumeName : string, costumeId : number, isEquipped : ValueState<boolean>?)
                if game:GetService("RunService"):IsRunning() then
                    CustomizationUtil.Customize(game.Players.LocalPlayer, costumeId)
                end
                if isEquipped  and game:GetService("RunService"):IsRunning() then 
                    print("Custome clicked ", costumeName, costumeId) 

                    local player = Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    
                    local currentAccessory 
                    for _,v in pairs(character:GetChildren()) do
                        if v:IsA("Accessory") and (CustomizationUtil.getAccessoryId(v) == costumeId) then
                            currentAccessory = v
                            break
                        end
                    end
                   -- local currentAccessory = character:FindFirstChild(customeModelName)
                    isEquipped:Set(if currentAccessory then true else false)
                elseif isEquipped and not game:GetService("RunService"):IsRunning() then
                    isEquipped:Set(not isEquipped:Get())
                end
            end))

            getExitButton(CustomizationUI)
        end
        return ""
    end, UIStatus)

    local strVal = _new("StringValue")({
        Value = val  
    })
    
    return out
end
