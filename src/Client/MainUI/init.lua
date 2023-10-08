--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
local AnimationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("AnimationUI"))
local NewCustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"))
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
local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(42, 42, 42)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)

local TEXT_COLOR = Color3.fromRGB(255,255,255)

local PADDING_SIZE = UDim.new(0,10)
--remotes
local GET_PLAYER_BACKPACK = "GetPlayerBackpack"

local SAVE_CHARACTER_SLOT = "SaveCharacterSlot"
local LOAD_CHARACTER_SLOT = "LoadCharacterSlot"
local DELETE_CHARACTER_SLOT = "DeleteCharacterSlot"

local ON_ROLEPLAY_BIO_CHANGE = "OnRoleplayBioChange"
--variables
--references
local Player = Players.LocalPlayer
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

local function getCharacter(fromWorkspace : boolean, plr : Player ?)
    local char 
    if RunService:IsRunning() then 
        if not fromWorkspace then
            char = Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) 
        else
            for _,charModel in pairs(workspace:GetChildren()) do
                local humanoid = charModel:FindFirstChild("Humanoid")
                print(charModel:IsA("Model"), humanoid, humanoid and humanoid:IsA("Humanoid"), charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name))
                if charModel:IsA("Model") and humanoid and humanoid:IsA("Humanoid") and charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name) then
                    charModel.Archivable = true
                    char = charModel:Clone()
                    charModel.Archivable = false
                    break
                end
            end
        end
        
    else 
        char = game.ServerStorage.aryoseno11:Clone() 
    end
    
    return char
end

local function getEnumItemFromName(enum : Enum, enumItemName : string) 
    local enumItem 
    for _, item : EnumItem in pairs(enum:GetEnumItems()) do
        if item.Name == enumItemName then
            enumItem = item
            break
        end
    end
    return enumItem
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
        BackgroundTransparency = 0,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(0, 0.05),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        AutoButtonColor = true,
        Font = Enum.Font.Gotham,
        Text = "\t<b>" .. buttonName .. "</b>\t",
        TextColor3 = TEXT_COLOR,
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
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.5, 0.1),
        AutoButtonColor = true,
        Image = "rbxassetid://" .. tostring(ImageId),
        Children = {
           
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({}),
            _new("TextLabel")({
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.3),
                Position = UDim2.fromScale(1.2, 0.5),
                Font = Enum.Font.Gotham,
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
        BackgroundColor3 = BACKGROUND_COLOR,
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

    local TouchEnabled      = UserInputService.TouchEnabled
    local KeyboardEnabled   = UserInputService.KeyboardEnabled
    local MouseEnabled      = UserInputService.MouseEnabled
    local GamepadEnabled    = UserInputService.GamepadEnabled

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
                Font = Enum.Font.Gotham,
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
                        Font = Enum.Font.Gotham,
                        Text = if KeyboardEnabled then "L Click" elseif TouchEnabled then "Touch" elseif GamepadEnabled then "A" else nil,
                        TextColor3 = PRIMARY_COLOR
                    }),

                }
            }),
            _bind(getButton(
                maid,
                "X" ,
                function()
                    for k,v in pairs(backpack:Get()) do
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
                        UIStatus:Set(if UIStatus:Get() ~= "Backpack" then "Backpack" else nil)
                    end, "Backpack", 1),
                    getImageButton(maid, 11955884948, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Animation" then "Animation" else nil)
                    end, "Animation", 2),
                    getImageButton(maid, 13285102351, function()
                        UIStatus:Set(if UIStatus:Get() ~= "Customization" then "Customization" else nil)
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

    local onCatalogTry = maid:GiveTask(Signal.new())
    local onCustomizeColor = maid:GiveTask(Signal.new())
    local onCatalogDelete = maid:GiveTask(Signal.new())
    local onCatalogBuy = maid:GiveTask(Signal.new())

    local onCustomizationSave = maid:GiveTask(Signal.new())
    local onSavedCustomizationLoad = maid:GiveTask(Signal.new())
    local onSavedCustomizationDelete = maid:GiveTask(Signal.new())

    local onRPNameChange = maid:GiveTask(Signal.new())
    local onDescChange = maid:GiveTask(Signal.new())

    local saveList = _Value({})
  
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
                    getAnimInfo("Laugh", 6487643897),
                    getAnimInfo("No", 6487627276),
                    getAnimInfo("Point", 507770453),
                    getAnimInfo("Sad", 6487647687),
                    getAnimInfo("Shy", 6487659854),
                    getAnimInfo("Standing", 6485373010),
                    getAnimInfo("Wave", 507770239),
                    getAnimInfo("Yawning", 6487651939),
                    getAnimInfo("Yes", 6487622514),

                },
                onAnimClickSignal
            ) :: Frame
            animationUI.Parent = out
            statusMaid:GiveTask(onAnimClickSignal:Connect(function(animInfo : AnimationInfo)
                AnimationUtil.playAnim(Players.LocalPlayer, animInfo.AnimationId, false)
            end))

            getExitButton(animationUI)
        elseif status == "Customization" then
            local customizationUI = NewCustomizationUI(
                statusMaid,

                onCatalogTry,
                onCustomizeColor,

                onCatalogDelete,
                onCatalogBuy,

                onCustomizationSave,
                onSavedCustomizationLoad,
                onSavedCustomizationDelete,

                onCharacterReset,

                onRPNameChange,
                onDescChange,

                saveList,

                function(param)
                    local list = {"All"}
                    if param:lower() == "featured" then
                    elseif param:lower() == "faces" then
                        table.clear(list)
                        --local cat = CatalogSearchParams.new()
                        --cat.AssetTypes = {Enum.AssetType.DynamicHead}
                        table.insert(list, "Classic")
                        table.insert(list, "3D")
                        table.insert(list, "Dynamic")
                    elseif param:lower() == "clothing" then
                        table.insert(list, "Shirts")
                        table.insert(list, "Pants")
                        table.insert(list, "Jackets")
                        table.insert(list, "TShirts")
                        table.insert(list, "Shoes")
                    elseif param:lower() == "accessories" then
                        table.insert(list, "Hats")
                        table.insert(list, "Faces")
                        table.insert(list, "Necks")
                        table.insert(list, "Shoulder")
                        table.insert(list, "Front")
                        table.insert(list, "Back")
                        table.insert(list, "Waist")
                    elseif param:lower() == "Hair" then
                    elseif param:lower() == "packs" then 
                        table.insert(list, "Animation Packs")
                        table.insert(list, "Emotes")
                        table.insert(list, "Bundles")
                    end
                    return list
                end,

                function(
                    category : string, 
                    subCategory : string,
                    keyWord : string,

                    catalogSortType : Enum.CatalogSortType ?, 
                    catalogSortAggregation : Enum.CatalogSortAggregation ?, 
                    creatorType : Enum.CreatorType ?,

                    minPrice : number ?,
                    maxPrice : number ?
                )
                    keyWord = " " .. keyWord

                    local params = CatalogSearchParams.new()
                    params.SortType = catalogSortType or params.SortType
                    params.SortAggregation = catalogSortAggregation or params.SortAggregation
                    params.IncludeOffSale = false
                    params.MinPrice = minPrice or params.MinPrice
                    params.MaxPrice = maxPrice or params.MaxPrice

                    -- print(params.SortAggregation, catalogSortAggregation)
                    category = category:lower()
                    subCategory = subCategory:lower()

                    if category == "featured" then
                        params.CategoryFilter = Enum.CatalogCategoryFilter.Featured
                    elseif category == "faces" then
                        params.AssetTypes = {Enum.AvatarAssetType.Face, Enum.AvatarAssetType.FaceAccessory}
                        if subCategory == "classic" then
                            params.AssetTypes = {Enum.AvatarAssetType.Face}
                        elseif subCategory == "3d" then
                            params.SearchKeyword = "3D face";
                            params.AssetTypes = {Enum.AvatarAssetType.FaceAccessory} 
                        elseif subCategory == "dynamic" then
                            params.AssetTypes = {} 
                            params.BundleTypes = {Enum.BundleType.DynamicHead}
                        end
                    elseif category == "clothing" then
                        params.AssetTypes = {
                            Enum.AvatarAssetType.Shirt,
                            Enum.AvatarAssetType.Pants,
                            Enum.AvatarAssetType.TShirt,

                            Enum.AvatarAssetType.JacketAccessory,
                            Enum.AvatarAssetType.ShirtAccessory,
                            Enum.AvatarAssetType.TShirtAccessory,
                            Enum.AvatarAssetType.PantsAccessory,

                            Enum.AvatarAssetType.LeftShoeAccessory,
                            Enum.AvatarAssetType.RightShoeAccessory,
                        }
                        
                        if subCategory == "shirts" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.Shirt,
                                Enum.AvatarAssetType.ShirtAccessory,
                            }
                        elseif subCategory == "pants" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.Pants,
                                Enum.AvatarAssetType.PantsAccessory,
                            }
                        elseif subCategory == "tshirts" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.TShirt,
                                Enum.AvatarAssetType.TShirtAccessory,
                            }
                        elseif subCategory == "jackets" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.JacketAccessory,
                            }
                        elseif subCategory == "shoes" then
                            params.BundleTypes = {
                                Enum.BundleType.Shoes,
                            }
                            params.AssetTypes = {}
                        end
                    elseif category == "accessories" then
                        params.AssetTypes = {
                            Enum.AvatarAssetType.Hat,
                            Enum.AvatarAssetType.FaceAccessory,
                            Enum.AvatarAssetType.NeckAccessory,
                            Enum.AvatarAssetType.ShoulderAccessory,
                            Enum.AvatarAssetType.FrontAccessory,
                            Enum.AvatarAssetType.BackAccessory,
                            Enum.AvatarAssetType.WaistAccessory
                        }
                        
                        if subCategory == "hats" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.Hat
                            }
                        elseif subCategory == "faces" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.FaceAccessory
                            }
                        elseif subCategory == "necks" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.NeckAccessory
                            }
                        elseif subCategory == "shoulder" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.ShoulderAccessory
                            }
                        elseif subCategory == "front" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.FrontAccessory
                            }
                        elseif subCategory == "back" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.BackAccessory
                            }
                        elseif subCategory == "waist" then
                            params.AssetTypes = {
                                Enum.AvatarAssetType.WaistAccessory
                            }
                        end
                    elseif category == "hair" then
                        params.AssetTypes = {
                            Enum.AvatarAssetType.HairAccessory,
                        }
                    elseif category == "packs" then
                        local assetTypes = {}

                        for _,v : Enum.AvatarAssetType in pairs(Enum.AvatarAssetType:GetEnumItems()) do
                            if string.find(v.Name:lower(), "animation") then
                                table.insert(assetTypes, v)
                            end
                        end
                        
                        params.AssetTypes = assetTypes
                        params.BundleTypes = {Enum.BundleType.Animations, Enum.BundleType.BodyParts}

                        if subCategory == "animation packs" then
                            params.AssetTypes = {}
                            params.BundleTypes = {Enum.BundleType.Animations}
                        elseif subCategory == "emotes" then
                            params.AssetTypes = assetTypes
                            params.BundleTypes = {}
                        elseif subCategory == "bundles" then
                            params.AssetTypes = {}
                            params.BundleTypes = {Enum.BundleType.BodyParts}
                        end
                    end

                    params.SearchKeyword = params.SearchKeyword .. keyWord

                    local catalogPages 
                    local function getCatalogPages()
                        local s, e = pcall(function() 
                            catalogPages = AvatarEditorService:SearchCatalog(params) 
                        end)
                        return s,e
                    end
                    local s, e =  getCatalogPages()
                    if not s and type(e) == "string" then
                        warn("Error: " .. e)
                        return catalogPages
                    end            

                    return catalogPages
                end,
                function(avatarAssetType : Enum.AvatarAssetType, itemTypeName : string, id : number)
                    local recommendeds =  AvatarEditorService:GetRecommendedAssets(avatarAssetType, id)
                    local catalogInfos = {}

                    for _,v in pairs(recommendeds) do
                        local SimplifiedCatalogInfo = {} :: any
                        SimplifiedCatalogInfo.Id = v.Item.AssetId
                        SimplifiedCatalogInfo.Name = v.Item.Name
                        SimplifiedCatalogInfo.ItemType = itemTypeName
                        SimplifiedCatalogInfo.CreatorName = v.Creator.Name
                        SimplifiedCatalogInfo.Price = v.Product.PriceInRobux
                        table.insert(catalogInfos, SimplifiedCatalogInfo)
                    end
                    
                    return catalogInfos
                end,
                _Value(true)
            )

            customizationUI.Parent = target
        end
        return ""
    end, UIStatus)

    
    maid:GiveTask(onCatalogTry:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType)

        CustomizationUtil.Customize(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        char:Set(getCharacter(true))
    end))

    maid:GiveTask(onCustomizeColor:Connect(function(color : Color3, char : ValueState<Model>)
        CustomizationUtil.CustomizeBodyColor(Player, color)
        char:Set(getCharacter(true))
        return
    end))

    maid:GiveTask(onCatalogDelete:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType) 
        CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        char:Set(getCharacter(true))
    end))

    maid:GiveTask(onCatalogBuy:Connect(function(catalogInfo : NewCustomizationUI.SimplifiedCatalogInfo, char : ValueState<Model>)
        local itemType = getEnumItemFromName(Enum.AvatarItemType, catalogInfo.ItemType) 

        MarketplaceService:PromptProductPurchase(Player, catalogInfo.Id)
        --CustomizationUtil.DeleteCatalog(Player, catalogInfo.Id, itemType :: Enum.AvatarItemType)
        --char:Set(getCharacter(true))
    end))


    maid:GiveTask(onCustomizationSave:Connect(function()
        local saveData = NetworkUtil.invokeServer(SAVE_CHARACTER_SLOT)
        saveList:Set(saveData)
    end))

    maid:GiveTask(onSavedCustomizationLoad:Connect(function(k, content)
        local saveData =  NetworkUtil.invokeServer(LOAD_CHARACTER_SLOT, k, content)
        saveList:Set(saveData)
    end))

    maid:GiveTask(onSavedCustomizationDelete:Connect(function(k, content)
        local saveData = NetworkUtil.invokeServer(DELETE_CHARACTER_SLOT, k, content)
        saveList:Set(saveData)
    end))

    maid:GiveTask(onRPNameChange:Connect(function(inputted : string)
        print("On RP Change :", inputted) 
        NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerName", inputted)
    end))
    maid:GiveTask(onDescChange:Connect(function(inputted : string)
        print("On Desc change :", inputted)
        NetworkUtil.fireServer(ON_ROLEPLAY_BIO_CHANGE, "PlayerBio", inputted)
    end))

    local strVal = _new("StringValue")({
        Value = strval  
    })
    
    return out
end
