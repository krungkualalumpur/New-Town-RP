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
local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))

local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

export type UIStatus = "Backpack" | "Animation" | "Customization" | nil
type ToolData = BackpackUtil.ToolData<boolean>
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
    buttonName : string,
    activatedFn : () -> (),
    order : number
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
        AutoButtonColor = true,
        BackgroundTransparency = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromScale(0, 0.05),
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        Text = "\t<b>" .. buttonName .. "</b>\t",
        TextColor3 = SECONDARY_COLOR,
        Children = {
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                activatedFn()
            end
        }
    })

    return out
end

function getImageButton(
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

local function getViewport(
    maid : Maid,

    objectToTrack : Instance
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local currentCam = _new("Camera")({
        CFrame = if objectToTrack:IsA("Model") and objectToTrack.PrimaryPart then 
            CFrame.lookAt(objectToTrack.PrimaryPart.Position + objectToTrack.PrimaryPart.CFrame.LookVector*objectToTrack:GetExtentsSize().Magnitude, objectToTrack.PrimaryPart.Position)
        elseif objectToTrack:IsA("BasePart") then
            CFrame.lookAt(objectToTrack.Position + objectToTrack.CFrame.LookVector*objectToTrack.Size.Magnitude, objectToTrack.Position)
        else
            nil
    })

    local out = _new("ViewportFrame")({
        CurrentCamera = currentCam,
        Children = {
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({}),
        
            currentCam,
            
            _new("WorldModel")({
                Children = {
                    objectToTrack
                }
            })
        }
    })
    return out
end

--class
return function(
    maid : Maid,

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,
    UIStatus : ValueState<UIStatus>,

    backpackOnEquip : Signal,
    backpackOnDelete : Signal,

    nameOnCustomize : Signal,

    onCharacterReset : Signal,

    target : Instance
)    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local viewportMaid = maid:GiveTask(Maid.new())
    local statusMaid = maid:GiveTask(Maid.new())
 
    local onEquipFrame = _new("Frame")({
        LayoutOrder = 1, 
        Parent = target,
        AnchorPoint = Vector2.new(0.5,0),
        Visible = _Computed(function(items : {[number] : ToolData})
            local isVisible = false
            for _,v in pairs(items) do
                if v.IsEquipped then
                    isVisible = true
                end
            end
            return isVisible
        end, backpack),
        Position = UDim2.fromScale(0.5, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(10,200,10),
        Size = UDim2.fromScale(0.1, 1),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1),
                Text = _Computed(function(items : {[number] : ToolData})
                    local text = "" 
                    for _,v in pairs(items) do
                        if v.IsEquipped then
                            text = v.Name
                            break
                        end
                    end
                    return text
                end, backpack),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,

                TextScaled = true,
                Children = {
                    _new("UITextSizeConstraint")({
                        MaxTextSize = 25
                    })
                }
            }),
          
            _bind(getButton(
                maid,
                "INTERACT" ,
                function()
                    for _,v in pairs(backpack:Get()) do
                        if v.IsEquipped then
                            local toolModel = BackpackUtil.getToolFromName(v.Name)
                            if toolModel then
                                local toolData = BackpackUtil.getData(toolModel, false)
                                ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                            end
                            break
                        end
                    end  
                end,
                3
            ))({
                Children = {
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),
                    _new("TextLabel")({
                        BackgroundColor3 = SECONDARY_COLOR,
                        BackgroundTransparency = 0.5,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        TextSize = 14,
                        Text = "L Click",
                        TextColor3 = PRIMARY_COLOR
                    }),

                }
            }),
            _bind(getButton(
                maid,
                "X" ,
                function()
                    for k,v in pairs(backpack:Get()) do
                        print(v)
                        if v.IsEquipped == true then
                            backpackOnEquip:Fire(k)
                            break
                        end
                    end  
                   
                end,
                4
            ))({
                BackgroundColor3 = Color3.fromRGB(255,10,10),
                TextColor3 = PRIMARY_COLOR
            })
            --[[_new("TextButton")({
                LayoutOrder = 3,
                AutoButtonColor = true,
                BackgroundTransparency = 0,
                Size = UDim2.fromScale(1, 0.05),
                RichText = true,
                Text = "<b>INTERACT</b>",
                TextColor3 = SECONDARY_COLOR,
                Children = {
                    _new("UICorner")({})
                },
                Events = {
                    Activated = function()      
                        for _,v in pairs(backpack:Get()) do
                            if v.IsEquipped then
                                local toolModel = BackpackUtil.getToolFromName(v.Name)
                                if toolModel then
                                    local toolData = BackpackUtil.getData(toolModel, false)
                                    ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
                                end
                                break
                            end
                        end  
                        --ToolActions.onToolActivated(, foodInst, player, toolData)
                    end
                }
            })]],
        }
    })

    local val =  _Computed(function(backpackList : {[number] : ToolData})
        viewportMaid:DoCleaning()
        local object 
        
        for _,v in pairs(backpackList) do
            if v.IsEquipped then
                local oriobject = BackpackUtil.getToolFromName(v.Name)
                if oriobject then object = oriobject:Clone() end 
                break
            end
        end
        
        if object then
            _bind(getViewport(
                viewportMaid,
                object 
            ))({
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.1),
                BackgroundTransparency = 0.5,
                BackgroundColor3 = BACKGROUND_COLOR,
                Parent = onEquipFrame
            })

            print("sangaat")
        end  
        return ""
    end, backpack)

    _new("StringValue")({
        Value = val
    })

    local out = _new("Frame")({
        Parent = target,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            _new("Frame")({
                LayoutOrder = 0,
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
                    getImageButton(maid, 2815418737, function()
                        print(UIStatus:Get())
                        UIStatus:Set(if UIStatus:Get() ~= "Backpack" then "Backpack" else nil)
                        print(UIStatus:Get())
                    end, "Backpack", 1),
                    getImageButton(maid, 11127689024, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Animation" then "Animation" else nil)
                        print(UIStatus:Get())
                    end, "Animation", 2),
                    getImageButton(maid, 13285102351, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Customization" then "Customization" else nil)
                        print(UIStatus:Get())
                    end, "Customization", 3)
                    --getImageButton(maid, 227600967),

                }
            }),

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
  
    local strval = _Computed(function(status : UIStatus)
        statusMaid:DoCleaning() 
        if status == "Backpack" then
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
                AnimationUtil.playAnim(Players.LocalPlayer, animInfo.AnimationId, false)
            end))

            getExitButton(animationUI)
        elseif status == "Customization" then
            local onCustomeButtonClick = statusMaid:GiveTask(Signal.new())

            local CustomizationUI = CustomizationUI(
                statusMaid,
                CustomizationList,
                onCustomeButtonClick,

                nameOnCustomize,
                onCharacterReset
            ) :: Frame
            CustomizationUI.Parent = out

            statusMaid:GiveTask(onCustomeButtonClick:Connect(function(custom : CustomizationList.Customization, isEquipped : ValueState<boolean>?, selectedBundle : ValueState<CustomizationList.Customization ?>)
                if game:GetService("RunService"):IsRunning() then
                    CustomizationUtil.Customize(game.Players.LocalPlayer, custom.TemplateId)
                end
                if isEquipped  and game:GetService("RunService"):IsRunning() then 
                    print("Custome clicked ", custom.Name, custom.TemplateId) 

                    local player = Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    
                    local equipped 
                    for _,v in pairs(character:GetChildren()) do
                        if v:IsA("Accessory") and (CustomizationUtil.getAccessoryId(v) == custom.TemplateId) then
                            equipped = v
                            break
                        end
                    end

                    local bundleId = CustomizationUtil.getBundleIdFromCharacter(character)
                    if bundleId == custom.TemplateId then
                        equipped = true
                        selectedBundle:Set(custom)
                    end
                   -- local currentAccessory = character:FindFirstChild(customeModelName)
                    isEquipped:Set(if equipped then true else false)
                elseif isEquipped and not game:GetService("RunService"):IsRunning() then
                    isEquipped:Set(not isEquipped:Get())
                end
            end))

            getExitButton(CustomizationUI)
        end
        return ""
    end, UIStatus)

    local strVal = _new("StringValue")({
        Value = strval  
    })
    
    return out
end
