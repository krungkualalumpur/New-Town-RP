--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

--types
type Maid = Maid.Maid
type AnimationInfo = {
    Name : string,
    AnimationId : string
}
type Signal = Signal.Signal

type CustomizationPage = CustomizationList.CustomizationClass

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local CHARACTER_BUNDLE_ID_ATTRIBUTE_KEY = "BundleId"

local BACKGROUND_COLOR = Color3.fromRGB(190,190,190)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(25,25,25)
local TERTIARY_COLOR = Color3.fromRGB(0,0,0)

local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RESET_COLOR = Color3.fromRGB(200,100,100)

local TEXT_COLOR = Color3.fromRGB(25,25,25)
local PADDING_SIZE = UDim.new(0,15)
--variables
--references
--local functions
local function getButton(
    maid : Maid, 
    text : CanBeState<string>, 
    fn : () -> (),
    layoutOrder : number 
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
        LayoutOrder = layoutOrder,
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 0,
        Size = UDim2.new(0.4, 0,0.15,0),
        Text = text,
        TextColor3 = TEXT_COLOR,
        RichText = true,

        Children = {
            _new("UICorner")({}),
            _new("UIGradient")({}),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center

            })
        },
        Events = {
            Activated = function()
                fn()
            end
        }
    })
    return out
end

local function getSelectButton(maid : Maid, text : string, isSelected : State<boolean>, fn : () -> (), layoutOrder)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = getButton(maid, text, fn, layoutOrder)
    _bind(out)({
        AutoButtonColor = false,
        BackgroundColor3 = PRIMARY_COLOR,
        Size = UDim2.new(0.15, 0,0.5,0),
        Children = {
            _new("Frame")({
                BackgroundColor3 = SELECT_COLOR,
                Visible = isSelected,
                Size = _Computed(function(selected : boolean)
                    return if selected then UDim2.fromScale(0.8, 0.2) else UDim2.fromScale(0, 0.2)
                end, isSelected):Tween(0.2),
                Children = {
                    _new("UICorner")({})
                }
            })
        }
    })

    return out
end

local function getAccessoryButton(
    maid : Maid, 
    customizationData : CustomizationList.Customization,
    isVisible : State<boolean>,
    onButtonClick : Signal,
    isEquipped : ValueState<boolean>?,
    selectedBundle : ValueState<CustomizationList.Customization ?>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("ImageButton")({
        AutoButtonColor = true,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = SECONDARY_COLOR,
        Visible = isVisible,
        Children = {
            _new("UIStroke")({
                Color = SECONDARY_COLOR,
                Thickness = 1.5
            }),
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                TextScaled = true,
                Text = customizationData.Name
            }),
            _new("ImageLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.75),
                Image = CustomizationUtil.getAssetImageFromId(customizationData.TemplateId, customizationData.Class == "Bundle"),

                Children = {
                    _new("UIAspectRatioConstraint")({}),
                    _new("UIListLayout")({
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),
                    _new("ImageLabel")({
                        LayoutOrder = 3,
                        Visible = isEquipped or false,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.3, 0.3),
                        Image = "rbxassetid://12622542256",
                        Children = {}
                    })
                }
            }),
           
        },
        Events = {
            Activated = function()
                onButtonClick:Fire(customizationData, isEquipped, selectedBundle)
                --[[if game:GetService("RunService"):IsRunning() then
                    CustomizationUtil.Customize(game.Players.LocalPlayer, AccessoryId)
                end]]
            end
        }
    })

    return out
end

--class
return function(
    maid : Maid,
    Customizations : {CustomizationList.Customization},
    onCostumeButtonClick : Signal,

    onNameCustomeButtonClick : Signal,
    onCharacterResetClick : Signal
  --  AvatarTypeState : ValueState<AvatarType ?>
)
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
 
    local customizationPage : ValueState<CustomizationPage ?> = _Value("Face") :: any
    local RPNameTextBox = _new("TextBox")({
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0.5,
        LayoutOrder = 2,
        TextColor3 = PRIMARY_COLOR,
        TextStrokeTransparency = 0,
        TextScaled = true,
        TextWrapped = true,
        PlaceholderText = "Insert your RP name here",
        PlaceholderColor3 = BACKGROUND_COLOR,
        Size = UDim2.new(1, 0, 0.15, 0),
        Children = {
            _new("UITextSizeConstraint")({
                MinTextSize = 0,
                MaxTextSize = 15
            })
        }
    }) :: TextBox
    local bioTextBox = _new("TextBox")({
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0.5,
        LayoutOrder = 6,
        TextColor3 = PRIMARY_COLOR,
        TextStrokeTransparency = 0,
        TextScaled = true,
        TextWrapped = true,
        PlaceholderText = "Insert your bio here",
        PlaceholderColor3 = BACKGROUND_COLOR,
        Size = UDim2.new(1, 0, 0.15, 0),
        Children = {
            _new("UITextSizeConstraint")({
                MinTextSize = 0,
                MaxTextSize = 15
            })
        }
    }):: TextBox

    local RPName = _new("Frame")({
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.18*2, 0.35),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.08, 0),
                TextScaled = true,
                RichText = true,
                TextSize = 18,
                Text = "<b>Roleplay Name</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            RPNameTextBox,
            getButton(maid, "Apply", function()
                onNameCustomeButtonClick:Fire("PlayerName" :: CustomizationUtil.DescType, RPNameTextBox.Text)
            end, 3),

            _new("Frame")({
                Name = "Buffer",
                LayoutOrder = 4,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.05),
            }),

            _new("TextLabel")({
                LayoutOrder = 5,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.08, 0),
                RichText = true,
                Text = "<b>Bio</b>",
                TextScaled = true,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            bioTextBox,
            getButton(maid, "Apply", function()
                onNameCustomeButtonClick:Fire("PlayerBio" :: CustomizationUtil.DescType, bioTextBox.Text)
            end, 7)
        }
    })
    
    local charCosContent =  _new("ScrollingFrame")({
        Name = "Contents",
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Size = UDim2.fromScale(1, 0.8),
        CanvasSize = UDim2.new(),
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIGridLayout")({
                CellPadding = UDim2.fromOffset(5, 5),
                CellSize = UDim2.fromOffset(100, 100)
            }),
        }
    })
    local characterCustomizationFrame = _new("Frame")({
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(0.5*2, 0.6),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("Frame")({
                Name = "PageOpts",
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = PADDING_SIZE,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    getSelectButton(
                        maid, 
                        "Face", 
                        _Computed(function(customPage : CustomizationPage ?) 
                            return if customPage == "Face" then true else false 
                        end, customizationPage),
                        function()
                            customizationPage:Set("Face")
                        end, 
                        1
                    ),
                    getSelectButton(
                        maid, 
                        "Shirt", 
                        _Computed(function(customPage : CustomizationPage ?) 
                            return if customPage == "Shirt" then true else false 
                        end, customizationPage),
                        function()
                            customizationPage:Set("Shirt")
                        end, 
                        2
                    ),
                    getSelectButton(
                        maid, 
                        "Pants", 
                        _Computed(function(customPage : CustomizationPage ?) 
                            return if customPage == "Pants" then true else false 
                        end, customizationPage),
                        function()
                            customizationPage:Set("Pants")
                        end, 
                        3
                    ),
                    getSelectButton(
                        maid, 
                        "Accessories", 
                        _Computed(function(customPage : CustomizationPage ?) 
                            return if customPage == "Accessory" then true else false 
                        end, customizationPage),
                        function()
                            customizationPage:Set("Accessory")
                        end, 
                        4 
                    ), getSelectButton(
                        maid, 
                        "Bundles", 
                        _Computed(function(customPage : CustomizationPage ?) 
                            return if customPage == "Bundle" then true else false 
                        end, customizationPage),
                        function()
                            customizationPage:Set("Bundle")
                        end, 
                        5 
                    )
                    --[[_new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    }),
                    _new("TextButton")({
                        BackgroundColor3 = BACKGROUND_COLOR,
                        Size = UDim2.fromScale(0.2, 1),
                        Text = "Test",
                        Children = {
                            _new("UICorner")({})
                        }
                    })]]
                }
            }),
            charCosContent
        }
    }) 

    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.5, 1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                Padding = PADDING_SIZE,
            }),
            RPName,
            characterCustomizationFrame
        }
    })

    local contentFrame2 = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.42, 1),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _bind(getButton(maid, "<b>\t Reset Outfit \t</b>", function()
                onCharacterResetClick:Fire(false)
            end, 1))({
                BackgroundColor3 = RESET_COLOR,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 0.05),
                TextColor3 = PRIMARY_COLOR
            }),

          _bind(getButton(maid, "<b>\t Clear Outfit \t</b>", function()
                onCharacterResetClick:Fire(true)
            end, 2))({
                BackgroundColor3 = SELECT_COLOR,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 0.05),
                TextColor3 = PRIMARY_COLOR
            }),

            --[[_new("Frame")({
                LayoutOrder = 3,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 0.1),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = PADDING_SIZE
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 0,
                        Text = "Avatar Type",
                        TextColor3 = PRIMARY_COLOR,
                        TextStrokeTransparency = 0.5,
                        TextWrapped = true,
                        TextSize = 16,
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(0.2, 1)
                    }),
                    _bind(getSelectButton(
                        maid, 
                        "\t R6 \t", 
                        _Computed(function(avatarType : AvatarType ?) 
                            return if avatarType == "R6" then 
                                    true 
                            else false
                        end, AvatarTypeState),
                        function()
                            AvatarTypeState:Set(if AvatarTypeState:Get() ~= "R6" then "R6" else nil)
                        end, 
                        1
                    ))({
                        BackgroundColor3 = PRIMARY_COLOR,
                        Size = UDim2.fromScale(0.18, 0.5),
                        TextColor3 = TEXT_COLOR,
                        TextSize = 15
                    }),
 
                    _bind(getSelectButton(
                        maid, 
                        "\t R15 \t", 
                        _Computed(function(avatarType : AvatarType ?) 
                            return if avatarType == "R15" then 
                                    true
                            else false
                        end, AvatarTypeState),
                        function()
                            AvatarTypeState:Set(if AvatarTypeState:Get() ~= "R15" then "R15" else nil)
                        end, 
                        2
                    ))({
                        BackgroundColor3 = PRIMARY_COLOR,
                        Size = UDim2.fromScale(0.18, 0.5),
                        TextColor3 = TEXT_COLOR,
                        TextSize = 15
                    }),
                    
                    _bind(getSelectButton(
                        maid, 
                        "\t RThro \t", 
                        _Computed(function(avatarType : AvatarType ?) 
                            return if avatarType == "RThro" then 
                                    true
                            else false
                        end, AvatarTypeState),
                        function()
                            AvatarTypeState:Set(if AvatarTypeState:Get() ~= "RThro" then "RThro" else nil)
                        end, 
                        3
                    ))({
                        BackgroundColor3 = PRIMARY_COLOR,
                        Size = UDim2.fromScale(0.18, 0.5),
                        TextColor3 = TEXT_COLOR,
                        TextSize = 15
                    }),
                }
            })]]

        }
    })

    local out = _new("Frame")({
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
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.fromScale(0.035, 1)
            }),
            contentFrame,
            contentFrame2
        }
    })

    --customization items
    local selectedBundle : ValueState<CustomizationList.Customization?>  = _Value(nil :: any)
    for _, custom in pairs(Customizations) do
        local isVisible = _Computed(function(page : CustomizationPage ?)
            return if custom.Class == page then true else false 
        end, customizationPage)
        
        local isEquipped

        if (custom.Class == "Accessory") or (custom.Class == "Bundle") then
            isEquipped = _Value(false)
        end

        local button = getAccessoryButton(
            maid,  
            custom,
            isVisible,
            onCostumeButtonClick,
            isEquipped,
            selectedBundle
        )
        button.Parent = charCosContent

        if game:GetService("RunService"):IsRunning() then
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()

            if isEquipped then
                for _,v in pairs(character:GetChildren()) do
                    if (v:IsA("Accessory") and (CustomizationUtil.getAccessoryId(v) == custom.TemplateId))  then
                        isEquipped:Set(true)
                        break
                    end
                end

                if custom.Class == "Bundle" then
                    if tonumber(CustomizationUtil.getBundleIdFromCharacter(character)) == tonumber(custom.TemplateId) then
                        isEquipped:Set(true)
                        selectedBundle:Set(custom)
                    end

                    local strVal = _Computed(function(bundle : CustomizationList.Customization ?)
                        if bundle and (bundle.TemplateId == custom.TemplateId) then
                            isEquipped:Set(true)
                        else
                            isEquipped:Set(false)
                        end
                        return ""
                    end, selectedBundle)

                    _new("StringValue")({
                        Value = strVal
                    })

                end
            end

          
        end

       
    end

    return out
end