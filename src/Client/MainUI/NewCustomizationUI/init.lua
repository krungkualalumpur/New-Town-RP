--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

--types
type Category = {SubCategories : {[number] : string}, CategoryName : string}
type CatalogInfo = {
    ["Id"] : number,
    ["ItemType"] : string,
    ["AssetType"] : string,
    ["BundleType"] : string,
    ["Name"] : string,
    ["Description"] : string,
    ["ProductId"] : number,
    ["Genres"] : {[number] : string},
    ["BundledItems"]: {
      [number] : {
        ["Owned"] : boolean,
        ["Id"] : string,
        ["Name"] : string,
        ["Type"] : string
      }
    },
    ["ItemStatus"] : {
        [number] : string
    },
    ["ItemRestrictions"] : {
        [number] : string
    },
    ["CreatorType"]: string,
    ["CreatorTargetId"]: number,
    ["CreatorName"] : string,
    ["Price"]: number,
    ["PremiumPricing"] : {
      ["PremiumDiscountPercentage"] : number,
      ["PremiumPriceInRobux"] : number
    },
    ["LowestPrice"] : number,
    ["PriceStatus"]: string,
    ["UnitsAvailableForConsumption"] : number,
    ["PurchaseCount"] : number,
    ["FavoriteCount"] : number
}

type SimplifiedCatalogInfo = {
    ["Id"] : number,
    ["ItemType"] : string,
    ["Name"] : string ?,
    ["Price"] : number ?
}

type InfoFromHumanoidDesc = {
    ["AccessoryType"] : Enum.AccessoryType,
    ["AssetId"] : number,
    ["IsLayered"] : boolean,
    ["Order"] : number ?,
    ["Puffiness"] : number ?
}

type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local TEXT_SIZE = 15

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
local function getSignal(maid : Maid, fn : (... any) -> ())
    local out = maid:GiveTask(Signal.new())

    maid:GiveTask(out:Connect(function(...)
        fn(...)
    end))

    return out 
end

local function getCharacter()
    return if RunService:IsRunning() then Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) else game.ServerStorage.aryoseno11:Clone()
end

local function getHumanoidDescriptionAccessory(
    assetId : number,
    enumAccessoryType : Enum.AccessoryType,
    isLayered : boolean,
    order : number ?,
    puffiness : number ?
) : InfoFromHumanoidDesc
    return {AssetId = assetId, AccessoryType = enumAccessoryType, IsLayered = isLayered, Order = order, Puffiness = puffiness}
end

local function convertAccessoryToSimplifiedCatalogInfo(infoFromHumanoidDesc : InfoFromHumanoidDesc) : SimplifiedCatalogInfo
    return {
        Id = infoFromHumanoidDesc.AssetId,
        ItemType = infoFromHumanoidDesc.AccessoryType.Name
    }
end

local function getButton( 
    maid : Maid,
    order : number,
    text : CanBeState<string> ?,
    fn : (() -> ()) ?,
    color : Color3 ?
) : TextButton
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out  = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = color or BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 1),
        LayoutOrder = order,
        Text = text,
        TextWrapped = true,
        TextStrokeTransparency = 0.7,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    }) :: TextButton
    return out
end

local function getCatalogButton(
    maid : Maid,
    order : number,
    catalogInfo : SimplifiedCatalogInfo,
    buttons : {
        [number] : {
            Name : string,
            Signal : Signal
        }
    },
    isSelected : ValueState<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed


    local content = _new("ImageLabel")({
        BackgroundColor3 = SECONDARY_COLOR,
        Image = CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
        Size = UDim2.new(1, 0,0.8,0), 
        LayoutOrder = 2,
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
        } 
    })

    for k,v in pairs(buttons) do
        local button = _bind(getButton(maid, k, nil, function()

        end))({
            BackgroundTransparency = _Computed(function(selected : boolean)
                return if selected then 0 else 1
            end, isSelected):Tween(0.1),
            Size = _Computed(function(selected : boolean)
                return if selected then UDim2.fromScale(1, 0.3) else UDim2.fromScale(0, 0.3)
            end, isSelected):Tween(0.1),
            Text = v.Name,
            TextTransparency = _Computed(function(selected : boolean)
                return if selected then 0 else 1
            end, isSelected):Tween(0.1),
          --  Visible = isSelected,
            TextScaled = true,
            Children = {
                _new("UICorner")({}),
            }
        })
        button.Parent = content    
    end 

    local out = _new("TextButton")({
        LayoutOrder = order,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80,1,0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            content,
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                RichText = true,
                TextScaled = true,
                Text = "<b>" .. (catalogInfo.Name or "") .. "</b>",
                TextColor3 = TEXT_COLOR,
                TextStrokeTransparency = 0.5
            })
        }
    }) :: TextButton

    return out
end

local function getImageButton(
    maid : Maid,
    order : number,
    image : string,
    text : string ?,
    fn : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone


    local previewFrame = _new("Frame")({
        LayoutOrder = 2,
        ClipsDescendants = true,
        Name = "PreviewFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1,0.7),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })
        }
    })

    local out = _new("ImageButton")({
        Name = text or "",
        LayoutOrder = order,
        AutoButtonColor = true,
        Image = image,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIListLayout")({ 
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            
            previewFrame
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    })

    if text then
        _new("TextLabel")({
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0.3,0),
            RichText = true,
            TextSize = TEXT_SIZE,
            TextWrapped = true,
            Text = "<b>" .. text:upper() .. "</b>",
            Parent = out,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        })
    end

    return out
end

local function getCategoryButton(
    maid : Maid,
    order : number,
    categoryName : string,
    fn : () -> (),
    isVisible : State<boolean>,
    getCatalogPages : (
        categoryName : string, 
        subCategory : string, 
        keyWord : string,

        catalogSortType : Enum.CatalogSortType ?, 
        catalogSortAggregation : Enum.CatalogSortAggregation ?, 
        creatorType : Enum.CreatorType ?,

        minPrice : number ?,
        maxPrice : number ?
    ) -> CatalogPages,
    accessoryDisplayCount : number?
)
    local color = Color3.fromRGB(math.random(100,255),math.random(100,255),math.random(100,255))

    local _maid = Maid.new()

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _bind(getImageButton(_maid, order, "", categoryName, fn))({
        Children = {
            _new("UIGradient")({
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(color.R*255 - 50, color.G*255 - 50, color.B*255 - 50))
                }),
              
                Rotation = 90
            }),
        }
    })
    local catalogDisplays : ValueState<{[number] : CatalogInfo}> = _Value({}) :: any
    local previewFrame = out:FindFirstChild("PreviewFrame")
    local catalogPages
        --print("wth1?")
    task.spawn(function()

        _new("StringValue")({
            Value = _Computed(function(visible : boolean)
                if visible then
                    --currentCatalogPage:Get()
                        catalogPages = catalogPages or getCatalogPages(categoryName, "All", "")

                        if catalogPages then
                            local currentCatalogPage = catalogPages:GetCurrentPage()
                    
                            local i = 1
                            
                            local t = tick()
                    
                            _maid.Loop = RunService.RenderStepped:Connect(function()
                                if tick() - t >= 5 then
                                    t = tick()
                                    
                                    local accessoriesDisplay = {}
                                                                        
                                    for _i = 1, (accessoryDisplayCount or 1) do
                                        table.insert(accessoriesDisplay, currentCatalogPage[i])
                                        i = if currentCatalogPage[i + 1] then (i + 1) else 1
                                    end
                                    print(#accessoriesDisplay)
                                    catalogDisplays:Set(accessoriesDisplay) 

                                end
                            end)
                        end
                
            
                else
                    _maid.Loop = nil
                end
                return "" 
            end, isVisible)
        })

        local catalogMaid = _maid:GiveTask(Maid.new())

        _new("StringValue")({
            Value = _Computed(function(catalogs : {[number] : CatalogInfo})
                print(previewFrame, " juri!")
                catalogMaid:DoCleaning()

                for k,catalogInfo in pairs(catalogs) do
                    local transp = _Value(1)
                    catalogMaid:GiveTask(_new("ImageLabel")({
                        BackgroundTransparency = 1,
                        ImageTransparency = transp:Tween(0.25),  
                        Size = UDim2.fromScale(1, 1),
                        Image = CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
                        Parent = previewFrame,
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 1
                            }) 
                        }
                    }))

                    transp:Set(0)
                end

                return ""
            end, catalogDisplays)
        })
    

        _maid:GiveTask(out.Destroying:Connect(function()
            print("mendem")  
            _maid:Destroy() 
        end))

        if out.Parent == nil then
            print("mendem 2")
            _maid:Destroy()
        end

    end)

    return out 
end

local function getLoadingFrame(
    maid : Maid,
    order : number,
    parent : Instance
)
    local loadingMaid = maid:GiveTask(Maid.new())

    local _fuse = ColdFusion.fuse(loadingMaid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local circles = {}

    local getCircle = function()
        local out = _new("Frame")({
            LayoutOrder = order,
            BackgroundTransparency = 0.5,
            BackgroundColor3 = SECONDARY_COLOR,
            Size = UDim2.fromScale(0.2, 1),
            Children = {
                _new("UIAspectRatioConstraint")({
                    AspectRatio = 1
                }),
                _new("UICorner")({
                    CornerRadius = UDim.new(10,0)
                })
            }
        })
        return out
    end 

    local function initiateLoadingLoop()
        local waitTime = 0.25
        local loopCompleted = true
        loadingMaid.Loop = RunService.RenderStepped:Connect(function()
            if loopCompleted then
                loopCompleted = false
                for _, circle in pairs(circles) do
                    local t = game:GetService("TweenService"):Create(circle, TweenInfo.new(waitTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, true), {Size = UDim2.fromScale(0.3, 1.1), BackgroundTransparency = 0})
                    t:Play()
                    t.Completed:Wait()
                end

                loopCompleted = true
            end
        end)
    end

    for i = 1, 4 do
        local circle  = getCircle()
        table.insert(circles, circle)
    end

    local out = _new("Frame")({
        LayoutOrder = order,
        Visible = false,
        BackgroundTransparency = 1,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.fromScale(0.5, 0.5),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE
            })
        },
        Parent = parent
    }) :: Frame

    loadingMaid:GiveTask(out:GetPropertyChangedSignal("Visible"):Connect(function()
        if out.Visible then
            initiateLoadingLoop()
        else
            loadingMaid.Loop = nil
        end
    end))
    if out.Visible then
        initiateLoadingLoop()
    end 

    for _,circle in pairs(circles) do
        circle.Parent = out
    end
    return out
end

local function getTextBox(
    maid : Maid,
    order : number,
    placeHolderText : string,
    fn : (searhedText : string) -> (),
    confirmButtonImage : string ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local content = _new("TextBox")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.7, 1),
        TextColor3 = TEXT_COLOR,
        PlaceholderText = placeHolderText,
        PlaceholderColor3 = TEXT_COLOR,
        
    }) :: TextBox

    
    local searchButton = _new("ImageButton")({
        LayoutOrder = 1,
        Size = UDim2.fromScale(0.2, 0.8),
        BackgroundTransparency = 1,
        Image = confirmButtonImage or "rbxassetid://11713338272",
        Children = {
            _new("UIAspectRatioConstraint")({})
        },
        Events = {
            Activated = function()
                fn(content.Text)
            end
        }
    })


    maid:GiveTask(content.FocusLost:Connect(function(enterPressed : boolean)
        if enterPressed then
            fn(content.Text)
        end
    end))


    local out = _new("Frame")({
        LayoutOrder = order,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            searchButton,
            content
        }
    })

    return out
end

local function getListOptions(
    maid : Maid,
    order : number,
    lists : {
        [number] : {
            Name : string, 
            Signal : Signal,
            Content : any
        }
    },
    defautList : State<string>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local isExpanded = _Value(false)

    local content = _new("Frame")({
        LayoutOrder = 2,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.fromScale(1,0),
        Position = _Computed(function(expanded : boolean)
            return if expanded then UDim2.fromScale(0, 0) else UDim2.fromScale(0, 1)
        end, isExpanded):Tween(),
        AutomaticSize = Enum.AutomaticSize.Y,
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE_SCALE,
                PaddingBottom = PADDING_SIZE_SCALE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE_SCALE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("Frame")({
                Name = "Buffer",
                LayoutOrder = #lists + 1,
                Size = UDim2.fromScale(1, 0.3),
                BackgroundTransparency = 1,
            })
        }
    })
    for k,v in pairs(lists) do
        local button = _bind(getButton(maid, k, v.Name, function()
            v.Signal:Fire(v.Content)
        end))({
            TextTransparency = _Computed(function(expanded : boolean)
                return if expanded then 0 else 1
            end, isExpanded):Tween(),
            Size = UDim2.fromScale(1, 0.3)
        })
        button.Parent = content
    end

    local out = _bind(getButton(
        maid, 
        order,
        defautList or lists[1].Name,
        function()
            isExpanded:Set(not isExpanded:Get())
        end
    ))({
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("Frame")({
                Name = "Buffer",
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Children = {
                   
                    _new("TextLabel")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.25, 1),
                        Font = Enum.Font.ArialBold,
                        Text = ">",
                        TextScaled = true,
                        TextColor3 = PRIMARY_COLOR,
                        Rotation = _Computed(function(expanded : boolean)
                            return if expanded then 90 else 0 
                        end, isExpanded):Tween(),
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 1
                            })
                        }
                    })
                }
            }),
            content
        }
    })


    --[[local out = _new("TextButton")({
        LayoutOrder = order,
        BackgroundColor3 = BACKGROUND_COLOR,
        AutoButtonColor = true,
        Size = UDim2.fromScale(1, 1),
        Text = defautList or lists[1].Name,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UICorner")({}),
            content
        },
        Events = {
            Activated = function()
                
            end
        }
    })]]
   
    return out
end


--class
return function(
    maid : Maid,
    onCatalogTry : Signal,
    onCatalogDelete : Signal,

    onRPNameChange : Signal,
    onDescChange : Signal,

    getSubCategoryList : (categoryName : string) -> {[number] : string},
    getCatalogPages : (
        categoryName : string, 
        subCategory : string, 
        keyWord : string,

        catalogSortType : Enum.CatalogSortType ?, 
        catalogSortAggregation : Enum.CatalogSortAggregation ?, 
        creatorType : Enum.CreatorType ?,

        minPrice : number ?,
        maxPrice : number ?
    ) -> CatalogPages,

    isVisible : ValueState<boolean>
)
    
    --test 1
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local onSearch = maid:GiveTask(Signal.new())

    local char : ValueState<Model> = _Value(getCharacter()) :: any

    local settingsState : {[any] : any} = {
        [Enum.CatalogSortType] = Enum.CatalogSortType.Relevance :: Enum.CatalogSortType,
        [Enum.CatalogSortAggregation] = Enum.CatalogSortAggregation.AllTime :: Enum.CatalogSortAggregation,
        MinPrice = nil :: number ?,
        MaxPrice = nil :: number ?,
        Creator = nil :: string ?,
        [Enum.CreatorType] = nil :: Enum.CreatorType ?,
        OffSaleItems = true,
        PersonalizedResults = true
    }
   
    local CurrentCategory : ValueState<Category?> = _Value(nil) :: any
 
    local onSettingsVisible = _Value(false) 


    local mainMenuPage =  _new("Frame")({
        Size = UDim2.fromScale(0.68, 1),
        BackgroundTransparency = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("Frame")({
                Size = UDim2.fromScale(0.6,0.95),
                BackgroundTransparency = 1,
                Children = {
                    _new("UICorner")({}),

                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),

                    _new("Frame")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.75),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = PADDING_SIZE,
                                FillDirection = Enum.FillDirection.Horizontal
                            }),
                            _bind(getCategoryButton(maid, 1, "featured", function()
                                local lists = getSubCategoryList("featured")
                                CurrentCategory:Set({
                                    CategoryName = "Featured",
                                    SubCategories = lists
                                })
                                return 
                            end, isVisible, getCatalogPages))({
                                Size = UDim2.new(0.45,0,1,0),                                        
                            }),
                            _new("Frame")({
                                LayoutOrder = 2,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(0.42,0,1,0),
                                Children = {
                                    _new("UIListLayout")({
                                        Padding = PADDING_SIZE,
                                        FillDirection = Enum.FillDirection.Vertical,
                                        SortOrder = Enum.SortOrder.LayoutOrder
                                    }),
                                    _bind(getCategoryButton(maid, 1, "hair", function()
                                        local lists = getSubCategoryList("hair")
                                        CurrentCategory:Set({
                                            CategoryName = "Hair",
                                            SubCategories = lists
                                        }) 
                                        return
                                    end, isVisible, getCatalogPages))({
                                        Size = UDim2.new(1,0,0.5,0),                                                
                                    }),
                                    _bind(getCategoryButton(maid, 2,"Packs", function()
                                        local lists = getSubCategoryList("Packs")
                                        CurrentCategory:Set({
                                            CategoryName = "Packs",
                                            SubCategories = lists
                                        })
                                        return
                                    end, isVisible, getCatalogPages))({
                                        Size = UDim2.new(1,0,0.47,0)                                               
                                    }),
                                }
                            })
                        }
                    }), 

                    _bind(getCategoryButton(maid, 1, "accessories", function()
                        local lists = getSubCategoryList("accessories")
                        CurrentCategory:Set({
                            CategoryName = "Accessories",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages, 3))({
                        Size = UDim2.fromScale(0.95, 0.27)
                    }),

                }
            }),
            _new("Frame")({
                Size = UDim2.fromScale(0.4,1),
                BackgroundTransparency = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _bind(getCategoryButton(maid, 1, "Clothing", function()
                        local lists = getSubCategoryList("clothing")
                        CurrentCategory:Set({
                            CategoryName = "Clothing",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages))({
                        Size = UDim2.new(1,0,0.485,0),
                    }),
                    _bind(getCategoryButton(maid, 2, "faces", function()
                        local lists = getSubCategoryList("faces")
                        CurrentCategory:Set({
                            CategoryName = "Faces",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages))({
                        Size = UDim2.new(1,0,0.48,0),
                    }),
                }
            }),
        }
    }) :: Frame

    local categoryPageHeader = _new("Frame")({
        Name = "Header",
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _bind(getButton(maid, 1, "<", function()
                CurrentCategory:Set(nil)
            end))({
                Size = UDim2.fromScale(0.1, 1),
                TextScaled = true 
            }),
            _new("Frame")({
                LayoutOrder = 2,
                Size = UDim2.fromScale(0.4, 1),
                BackgroundTransparency = 1,
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.2),
                        TextScaled = true,
                        Font = Enum.Font.ArialBold,
                        Text = _Computed(function(currentCategory : Category ?)
                            return if currentCategory then currentCategory.CategoryName else ""
                        end, CurrentCategory),
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    _bind(getTextBox(maid, 2,"Search...", function(text : string)
                       
                        onSearch:Fire(text)
                    end))({
                        Size = UDim2.fromScale(1, 0.7)
                    })
                }
            })
            ,
            _new("ScrollingFrame")({
                Name = "SubCategory",
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                ScrollBarThickness = 4,
                ScrollBarImageTransparency = 0.6,
                CanvasSize = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 3,
                Size = UDim2.fromScale(0.45, 1),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    })

                }
            })
        }
    })

    local categoryContent = _new("ScrollingFrame")({
        Name = "Content",
        BackgroundColor3 = BACKGROUND_COLOR,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Size = UDim2.fromScale(1, 0.75),
        -- BackgroundColor3 = TEST_COLOR,
        Children = {
            _new("UIGridLayout")({
                CellSize = UDim2.fromOffset(150, 150),
                CellPadding = UDim2.fromOffset(10, 10)
            })
        }
    }) :: ScrollingFrame

    
    local categoryPageFooter = _new("Frame")({
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.09),
        --BackgroundColor3 = TEST_COLOR,
        Children = {
            _new("UIListLayout"){
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            },
            _bind(getTextBox(
                maid, 
                1, 
                "Enter Item Link...",
                function()
                    
                end
            ))({
                Size = UDim2.fromScale(0.3, 1),
            }),
            _bind(getImageButton(
                maid,
                2,
                "rbxassetid://7059346373",
                nil,
                function()
                    onSettingsVisible:Set(not onSettingsVisible:Get())
                end
            ))({
                Name = "Settings",
                BackgroundTransparency = 1,
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            })
           
        }
    }) 
 
    local categoryPage = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            categoryPageHeader,
            categoryContent,
            categoryPageFooter,
        }
    }) :: Frame

    local degreeX = -90
    local degreeY = 0

    local cf = _Value(CFrame.lookAt(Vector3.new(math.cos(math.rad(degreeX))*6,math.sin(math.rad(degreeY))*6,math.sin(math.rad(degreeX))*6), Vector3.new()))
    local camera = _new("Camera")({
        CFrame = cf
    })
    local spinningConn

    local roleplayName = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                RichText = true,
                Text = "<b>" .. (if RunService:IsRunning() then Players.LocalPlayer.Name else "Player Name") .. "</b>",
                TextStrokeColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                TextWrapped = true,
                TextScaled = true
            }),
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                Text = if RunService:IsRunning() then Players.LocalPlayer.Name else "Player Name",
                TextSize = 15, 
                TextWrapped = true,
            }),
        }
    })

    local avatarViewportFrame = _new("ViewportFrame")({
        LayoutOrder = 2,
        CurrentCamera = camera,
        Size = UDim2.fromScale(1, 0.45),
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            camera,
            _new("WorldModel")({
                Children = {
                    char 
                }
            }),
            _new("ImageButton")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Events = {
                    MouseButton1Down = function()
                        local mouse : Mouse ? = if RunService:IsRunning() then Players.LocalPlayer:GetMouse() else nil
                        local intX, intY 
                        if mouse then intX = mouse.X; intY = mouse.Y end

                        spinningConn = RunService.RenderStepped:Connect(function()
                            
                            if mouse then
                                local x,y = mouse.X - intX, mouse.Y - intY -- UserInputService:GetMouseDelta().X, UserInputService:GetMouseDelta().Y
                                degreeX += x
                                degreeY += y
                                cf:Set( CFrame.lookAt(Vector3.new(math.cos(math.rad(degreeX))*6,math.sin(math.rad(degreeY))*6,math.sin(math.rad(degreeX))*6), Vector3.new())) 
                                intX = mouse.X; intY = mouse.Y
                            end 
                        end)
                    end,
                    MouseButton1Up = function()
                        spinningConn:Disconnect()
                    end
                }
            })
        }
    })

    local avatarOptions = _new("Frame")({
        LayoutOrder = 4,
        BackgroundTransparency = 1,
        BackgroundColor3 = TEST_COLOR,
        Size = UDim2.fromScale(1, 0.16),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0.1, 0)
            }),
            _bind( getButton(maid, 1, "Reset Character", nil, RED_COLOR))({
                Size = UDim2.fromScale(0.4, 0.4)
            }),
            _bind( getTextBox(maid, 2, "Enter Roleplay Name ...", function(inputted : string)
                onRPNameChange:Fire(inputted)
            end, "rbxassetid://1264515756"))({
                Size = UDim2.fromScale(1, 0.25)
            }),
            _bind(getTextBox(maid, 2, "Enter Desc ...", function(inputted : string)
                onDescChange:Fire(inputted)
            end, "rbxassetid://1264515756"))({
                Size = UDim2.fromScale(1, 0.25)
            }),
        }
    })

    local currentOutfitsFrame =_new("ScrollingFrame")({
        LayoutOrder = 3,
        BackgroundColor3 = BACKGROUND_COLOR,
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 0.23),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE
            })
        }
    })
    
    local out = _new("Frame")({
        Visible = _Computed(function(visible : boolean)
            if visible then
                local charModel : Model = getCharacter()
                charModel:PivotTo(CFrame.new())

                char:Set(charModel) 
            end
            
            return visible
        end, isVisible),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("Frame")({
                Name = "Avatar Frame",
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(0.3, 1),
                Children = {
                    _new("UIPadding")({
                        PaddingTop = PADDING_SIZE,
                        PaddingBottom = PADDING_SIZE,
                        PaddingLeft = PADDING_SIZE,
                        PaddingRight = PADDING_SIZE
                    }),
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = PADDING_SIZE,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    roleplayName,
                    avatarViewportFrame,
                    avatarOptions,
                    currentOutfitsFrame
                }
            }),
            mainMenuPage,
            categoryPage
        }
    })

        --sub-categories
    local function getSubCategoryListFrame(categPage : Instance)
        local header = categPage:FindFirstChild("Header")
        local subCategoryListFrame = if header then header:FindFirstChild("SubCategory") else nil
        return subCategoryListFrame
    end
   
    do
        local currentCatalogPage
        local currentSubCategory 

        local pageMaid = maid:GiveTask(Maid.new())
        local catalogPageMaid = pageMaid:GiveTask(Maid.new())

        local currentSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any
        
        local currentCreatorType : ValueState<Enum.CreatorType ?> = _Value(nil) :: any
        local currentCatalogSortAggregation : ValueState<Enum.CatalogSortAggregation> = _Value(Enum.CatalogSortAggregation.AllTime) :: any
        local currentCatalogSortType : ValueState<Enum.CatalogSortType> = _Value(Enum.CatalogSortType.Relevance) :: any    
        local currentCreatorName : ValueState<string ?> = _Value(nil) :: any
        local currentMinPrice : ValueState<number?> = _Value(nil) :: any
        local currentMaxPrice : ValueState<number?> = _Value(nil) :: any

        local function loopThroughCatalogPage(
            catalogPage : CatalogPages,
            creatorType : Enum.CreatorType ?,
            creatorName : string ?
        )
            for k,v : CatalogInfo in pairs(catalogPage:GetCurrentPage()) do
                if ((creatorType == nil) or (v.CreatorType == creatorType.Name)) and ((creatorName == nil) or (v.CreatorName:lower():find(creatorName:lower()))) then
                    local buttonMaid = Maid.new()

                    local _fuse = ColdFusion.fuse(buttonMaid)
                    local _new = _fuse.new

                    local _Value = _fuse.Value 
                    local _Computed = _fuse.Computed

                    local selectedButton = _Value(false)

                    local catalogButton = catalogPageMaid:GiveTask(getCatalogButton(buttonMaid, k,  v, {
                        [1] = {
                            Name = "Try",
                            Signal = onCatalogTry
                        }
                    }, selectedButton))
                    catalogButton.Parent = categoryContent
                    
                    buttonMaid:GiveTask(catalogButton.Activated:Connect(function()
                        if currentSelectedButton:Get() ~= catalogButton then
                            currentSelectedButton:Set(catalogButton)
                        else
                            currentSelectedButton:Set(nil)
                        end
                    end))

                    _new("StringValue")({
                        Value = _Computed(function(button : GuiButton ?)
                            if button == catalogButton then
                                selectedButton:Set(true)
                            else
                                selectedButton:Set(false)
                            end
                            return ""
                        end, currentSelectedButton)
                    })

                    buttonMaid:GiveTask(catalogButton.Destroying:Connect(function()
                        buttonMaid:Destroy()
                        return
                    end))
                end
            end
        end

        local function updateContent(
            category : string, 
            subCategory : string ?, 
            keyWord : string,

            catalogSortType : Enum.CatalogSortType ?, 
            catalogSortAggregation : Enum.CatalogSortAggregation ?, 
            creatorType : Enum.CreatorType ?,
            creatorName : string ?,

            minPrice : number ?, 
            maxPrice : number ?
        )
            catalogPageMaid:DoCleaning()

            currentCatalogPage = getCatalogPages(category, subCategory or "All", keyWord,  catalogSortType, catalogSortAggregation, creatorType, minPrice, maxPrice)
            currentSubCategory = subCategory

            if currentCatalogPage then
                loopThroughCatalogPage(currentCatalogPage, creatorType, creatorName)
            end
        end

        local loadingFooter =  getLoadingFrame(maid, 3, categoryPageFooter)
        
        local selectFrameParent : ValueState<TextButton ?> = _Value(nil) :: any
        local function getSelectFrame()
            local  out = _new("Frame")({
                Name = "SelectFrame",
                LayoutOrder = 2,
                BackgroundColor3 = SELECT_COLOR,
                Size = _Computed(function(instance)
                    return if instance then UDim2.fromScale(0.8, 0.2) else UDim2.fromScale(0, 0.2)
                end, selectFrameParent):Tween(0.1),
                Children = {
                    _new("UICorner")({})
                },
            }) :: Frame
            return out
        end        

        pageMaid.SelectFrame = getSelectFrame()

        local strVal = _new("StringValue")({
            Name = _Computed(function(parent : TextButton ?) -- FX
                
                if parent then
                    local selectFrame = getSelectFrame()
                    pageMaid.SelectFrame = selectFrame
                    
                    selectFrame.Size = UDim2.fromScale(0, 0.2)
                    local t= game:GetService("TweenService"):Create(selectFrame, TweenInfo.new(0.1), {
                        Size = UDim2.fromScale(0.8, 0.2)
                    })
                    selectFrame.Parent = parent
                    t:Play()
                else

                end
                return ""
            end, selectFrameParent),
            Value = _Computed(function(
                category : Category ?, 
                catalogSortType : Enum.CatalogSortType, 
                catalogSortAggregation : Enum.CatalogSortAggregation, 
                creatorType : Enum.CreatorType ?,
                creatorName : string ?,
                minPrice : number ?,
                maxPrice : number ?
            )
                
                selectFrameParent:Set()

                if category then
                    pageMaid:DoCleaning() 
                    local selectedSubCategory = category.SubCategories[1]
                    
                    local subCategoryListFrame = getSubCategoryListFrame(categoryPage)

                    categoryPage.Visible = true
                    mainMenuPage.Visible = false

                    loadingFooter.Visible = true

                    updateContent(category.CategoryName, selectedSubCategory, "", catalogSortType, catalogSortAggregation, creatorType, creatorName, minPrice, maxPrice)
                
                    for i, v in pairs(category.SubCategories) do
                        local listButton 
                        listButton =  pageMaid:GiveTask( _bind(getButton(maid, i, v, function()
                            loadingFooter.Visible = true
                            --selectFrame.Size = UDim2.new(1, 0, 0.2, 0) 
                            selectFrameParent:Set(listButton)
                           
                            updateContent(category.CategoryName, v, "", catalogSortType, catalogSortAggregation, creatorType, creatorName, minPrice, maxPrice)
                            loadingFooter.Visible = false
                        end))({
                            Size = UDim2.fromScale(0.25, 1),
                            Parent = subCategoryListFrame,
                            Children = {
                                _new("Frame")({
                                    LayoutOrder = 1,
                                    Transparency = 1,
                                    Size = UDim2.fromScale(1, 0.85)
                                })
                            }
                        })) :: TextButton
                        if v == currentSubCategory then
                            selectFrameParent:Set(listButton)
                        end
                    end 

                    loadingFooter.Visible = false 
                else

                    categoryPage.Visible = false
                    mainMenuPage.Visible = true
                end

                return ""
            end, CurrentCategory, currentCatalogSortType, currentCatalogSortAggregation, currentCreatorType, currentCreatorName, currentMinPrice, currentMaxPrice)
        })

        maid:GiveTask(categoryContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            local uiGridLayout = categoryContent:FindFirstChild("UIGridLayout") :: UIGridLayout ?
            if uiGridLayout and (categoryContent.CanvasPosition.Y == uiGridLayout.AbsoluteContentSize.Y - categoryContent.AbsoluteSize.Y) then
                loadingFooter.Visible = true

                local s,e = pcall(function() currentCatalogPage:AdvanceToNextPageAsync() end)
                if not s and e then
                    warn("error: " .. e)
                    loadingFooter.Visible = false
                    return
                end 
                
                local category = CurrentCategory:Get()
                if category then
                    loopThroughCatalogPage(currentCatalogPage)
                end
                loadingFooter.Visible = false
            end
        end))

        maid:GiveTask(onSearch:Connect(function(keyWord : string)
            local currentCat = CurrentCategory:Get()
            if currentCat then
                loadingFooter.Visible = true
                local subCategoryFrame = selectFrameParent:Get()
                local subCategory = if subCategoryFrame then subCategoryFrame.Text else currentCat.SubCategories[1]
                updateContent(currentCat.CategoryName, subCategory, keyWord, currentCatalogSortType:Get(), currentCatalogSortAggregation:Get(), currentCreatorType:Get(), currentCreatorName:Get(), currentMinPrice:Get(), currentMaxPrice:Get())
                loadingFooter.Visible = false
            end
        end))

        
        local function getFilterOptions(
            maid : Maid,
            filterType : Enum, --Enum.CreatorType | Enum.CatalogSortAggregation | Enum.CatalogSortType
            order : number,
            onButtonSelected : Signal,
            currentOption : State<EnumItem ?>
        )
            
            local function spacifyStr(str : string)
                return str:gsub("%u", " %1"):gsub("%d+", " %1")
            end

            local _fuse = ColdFusion.fuse(maid)
            local _new = _fuse.new

            local _Value = _fuse.Value
            
            local lists = {}
        
            if filterType == Enum.CreatorType then
                table.insert(lists, {
                    Name = spacifyStr("All"),
                    Signal = onButtonSelected,
                    Content = nil :: any,
                })
            end

            for _,v : EnumItem in pairs(filterType:GetEnumItems()) do
                table.insert(lists, {
                    Name = spacifyStr(v.Name),
                    Signal = onButtonSelected,
                    Content = v,
                })
            end 
        
            local out =  _bind(getListOptions(
                maid,
                order,
                lists,
                _Computed(function(opt : EnumItem ?)
                    local text = if opt then (spacifyStr(opt.Name)) else "All"
                    return  text
                end, currentOption)
            ))({
                Size = UDim2.fromScale(0.65, 1)
            })

            return out
        end

        local onCatalogSortTypeSelected = getSignal(maid, function(passedContent)
            currentCatalogSortType:Set(passedContent)
        end)
        local onCatalogSortAggregationSelected = getSignal(maid, function(passedContent)
            currentCatalogSortAggregation:Set(passedContent)
        end)
        local onCreatorTypeSelected = getSignal(maid, function(passedContent)
            currentCreatorType:Set(passedContent)
        end)


        local settingsFrame = _new("Frame")({
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundColor3 = BACKGROUND_COLOR,
            Visible = onSettingsVisible,
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = 10,
            Children = {
                _new("UICorner")({}),
                _new("UIStroke")({
                    Thickness = 2,
                    Color = PRIMARY_COLOR
                }),
                _new("UIListLayout")({
                    Padding = PADDING_SIZE,
                    SortOrder = Enum.SortOrder.LayoutOrder
                }),
                _new("TextLabel")({
                    Name = "Title",
                    LayoutOrder = 1,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0.2),
                    RichText = true,
                    Text = "<b>SETTINGS</b>",
                    TextSize = TEXT_SIZE*1.5,
                    TextColor3 = PRIMARY_COLOR,
                    TextStrokeTransparency = 0.5,
                    --[[Children = {
                        _new("UIListLayout")({
                            Padding = PADDING_SIZE,
                        }),
                        _new("TextLabel")({
                            BackgroundTransparency = 1,
                            Text = "Settings",
                            BackgroundColor3 = TEST_COLOR,
                            Size = UDim2.fromScale(1, 0.2),
                            
                        })
                    }]]
                }),
                _new("Frame")({
                    Name = "Contents",
                    LayoutOrder = 2,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0.8),
                    Children = {
                        _new("UIListLayout")({
                            Padding = PADDING_SIZE,
                            SortOrder = Enum.SortOrder.LayoutOrder
                        }),
                    
                        _new("UIPadding")({
                            PaddingTop = PADDING_SIZE,
                            PaddingBottom = PADDING_SIZE,
                            PaddingLeft = PADDING_SIZE,
                            PaddingRight = PADDING_SIZE
                        }),
                        _new("Frame")({
                            Name = "Setting1",
                            LayoutOrder = 1,
                            ZIndex = 2,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Sort by</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),

                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CatalogSortType,
                                    2,
                                    onCatalogSortTypeSelected,
                                    currentCatalogSortType ::  any
                                ))({
                                    Size = UDim2.fromScale(0.5, 1)
                                }),
                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CatalogSortAggregation,
                                    3,
                                    onCatalogSortAggregationSelected,
                                    currentCatalogSortAggregation  ::  any
                                ))({
                                    Size = UDim2.fromScale(0.3, 1)
                                })
                                --[[_bind(getListOptions(
                                    maid,
                                    2,
                                    {
                                        {
                                            Name = "Filter1", 
                                            Signal = maid:GiveTask(Signal.new())
                                        },
                                        {
                                            Name = "Filter2", 
                                            Signal = maid:GiveTask(Signal.new())
                                        },
                                    }
                                ))({
                                    Size = UDim2.fromScale(0.65, 1)
                                })]]

                            }
                        }),
                        _new("Frame")({
                            LayoutOrder = 2,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Price</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(maid, 2, "Min Price", function(input : string)
                                    currentMinPrice:Set(tonumber(input))
                                end, ""))({
                                    Size = UDim2.fromScale(0.4, 1)
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 3,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = " to ",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(maid, 4, "Max Price", function(input : string)
                                    currentMaxPrice:Set(tonumber(input))
                                end, ""))({
                                    Size = UDim2.fromScale(0.4, 1)
                                }),
                            }
                        }),
                        _new("Frame")({
                            LayoutOrder = 3,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Creator</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(
                                    maid, 
                                    1, 
                                    "Creator Name...", 
                                        function(input : string)
                                            currentCreatorName:Set(input)
                                        return
                                    end
                                ))({
                                    Size = UDim2.fromScale(0.45, 1)
                                }),
                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CreatorType,
                                    2,
                                    onCreatorTypeSelected,
                                    currentCreatorType ::  any
                                ))({
                                    Size = UDim2.fromScale(0.3, 1)
                                }),
                            }
                        })
                    }
                })
            },
            Parent = _Computed(function()
                return out.Parent
            end, onSettingsVisible)
        }) :: Frame


        local exitButton =  maid:GiveTask(ExitButton.new(
            settingsFrame, 
            onSettingsVisible,
            function()
                onSettingsVisible:Set(false)
                return 
            end
        ))

        _new("StringValue")({
            Value = _Computed(function(isVisible : boolean)
                exitButton.Instance.Parent = settingsFrame            
                return ""
            end, onSettingsVisible)
        })

        --settings
        _new("StringValue")({
            Value = _Computed(function(catalogSortType : Enum.CatalogSortType)
                
                return ""
            end, currentCatalogSortType)
        })
    end

    --fxs
    --task.spawn(function()
    --    task.wait(1)
    --    loadingFooter.Parent = categoryPageFooter
    --end)
  

    do
        local charMaid = maid:GiveTask(Maid.new())
        local currentSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any

        local str = _new("StringValue")({
            Value = _Computed(function(charModel : Model)             
                charMaid:DoCleaning()
                local humanoid = if charModel then charModel:FindFirstChild("Humanoid") :: Humanoid else nil
                local humanoidDesc = if humanoid then humanoid:FindFirstChild("HumanoidDescription") :: HumanoidDescription else nil
                local humanoidRigType = if humanoid then humanoid.RigType else nil

                if humanoidDesc and humanoidRigType then
                    local accessories = {}
                    for _,v in pairs(humanoidDesc:GetAccessories(true)) do
                        table.insert(accessories, v)
                    end

                    if humanoidDesc.Shirt ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Shirt, Enum.AccessoryType.Shirt, false))
                    end
                    if humanoidDesc.Pants ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Pants, Enum.AccessoryType.Pants, false))
                    end

                    if humanoidDesc.RunAnimation ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.RunAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.FallAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.FallAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.IdleAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.IdleAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.JumpAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.JumpAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.MoodAnimation ~= 0  then
                        print(humanoidDesc.MoodAnimation)
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.MoodAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.SwimAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.SwimAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.WalkAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.WalkAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.ClimbAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.ClimbAnimation, Enum.AccessoryType.Unknown, false))
                    end

                    for k,humanoidDescription in pairs(accessories) do
                        local catalogInfo = convertAccessoryToSimplifiedCatalogInfo(humanoidDescription)
                        
                        local buttonMaid = charMaid:GiveTask(Maid.new())

                        local __fuse = ColdFusion.fuse(buttonMaid)
                        local __new = __fuse.new
        
                        local __Value = __fuse.Value
                        local __Computed = __fuse.Computed
        
                        local selectedButton = __Value(false)
                        local button = getCatalogButton(
                            buttonMaid, k, catalogInfo,{
                                [1] = {
                                    Name = "Delete",
                                    Signal = onCatalogTry, 
                                },
                                
                            },
                            selectedButton
                        ) :: GuiButton
        
                        button.Parent = currentOutfitsFrame
                        buttonMaid:GiveTask(button.Activated:Connect(function()
                            if currentSelectedButton:Get() ~= button then
                                currentSelectedButton:Set(button)
                            else
                                currentSelectedButton:Set(nil)
                            end
                        end))
                        buttonMaid:GiveTask(button.Destroying:Connect(function()
                            buttonMaid:Destroy()
                        end))
        
                        _new("StringValue")({
                            Value = __Computed(function(catalogButton : GuiButton ?)
                                if button == catalogButton then
                                    selectedButton:Set(true)
                                else
                                    selectedButton:Set(false)
                                end
                                return ""
                            end, currentSelectedButton)
                        })
    
                    end
                    
                end
                return ""
            end, char),
        })
    end

    --[[for i = 1, 10 do
        local button = getAccessoryButton(maid, i, {
            [1] = {
                Name = "Try",
                Signal = onCatalogTry
            }
        })
        button.Parent = categoryContent
    end]] 
      --testing

        --outfits
    --[[do
        local currentSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any
        for i = 1, 10 do
            local buttonMaid = Maid.new()

            local __fuse = ColdFusion.fuse(buttonMaid)
            local __new = __fuse.new

            local __Value = __fuse.Value
            local __Computed = __fuse.Computed

            local selectedButton = __Value(false)
            local button = getCatalogButton(
                buttonMaid, 1, {
                    ItemType = Enum.AvatarItemType.Asset.Name,
                    Id = 11584239464
                },{
                    [1] = {
                        Name = "Delete",
                        Signal = onCatalogTry,
                    },
                    
                },
                selectedButton
            ) :: GuiButton

            button.Parent = currentOutfitsFrame
            buttonMaid:GiveTask(button.Activated:Connect(function()
                if currentSelectedButton:Get() ~= button then
                    currentSelectedButton:Set(button)
                else
                    currentSelectedButton:Set(nil)
                end
            end))
            buttonMaid:GiveTask(button.Destroying:Connect(function()
                buttonMaid:Destroy()
            end))

            _new("StringValue")({
                Value = __Computed(function(catalogButton : GuiButton ?)
                    if button == catalogButton then
                        selectedButton:Set(true)
                    else
                        selectedButton:Set(false)
                    end
                    return ""
                end, currentSelectedButton)
            })
        end

        
        local charModel = char:Get()
        local humanoid = if charModel then charModel:FindFirstChild("Humanoid") :: Humanoid else nil
        local humanoidDesc = if humanoid then humanoid:FindFirstChild("HumanoidDescription") :: HumanoidDescription else nil
        local humanoidRigType = if humanoid then humanoid.RigType else nil

        if humanoidDesc and humanoidRigType then
            print("eeh?")
            print(humanoidDesc.Shirt, humanoidDesc.Pants, humanoidDesc:GetAccessories(false))
            print(typeof(humanoidDesc:GetAccessories(false)[1]))
        end
    end]]
    return out
end
