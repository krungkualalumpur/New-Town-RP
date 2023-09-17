--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
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

type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local TEXT_SIZE = 15

local PADDING_SIZE = UDim.new(0,10)

local BACKGROUND_COLOR = Color3.fromRGB(120,120,120)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(175,175,175)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local TEST_COLOR = Color3.fromRGB(255,0,0)
--variables
--references
--local functions
local function getButton( 
    maid : Maid,
    order : number,
    text : string ?,
    fn : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out  = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 1),
        LayoutOrder = order,
        Text = text,
        TextColor3 = PRIMARY_COLOR,
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    })
    return out
end

local function getCatalogButton(
    maid : Maid,
    order : number,
    catalogInfo : CatalogInfo,
    buttons : {
        [number] : {
            Name : string,
            Signal : Signal
        }
    }
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
 

    local content = _new("ImageButton")({
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
            Size = UDim2.fromScale(0.75, 0.2),
            Text = v.Name,
            TextScaled = true,
            Children = {
                _new("UICorner")({}),
            }
        })
        button.Parent = content    
    end 

    local out = _new("Frame")({
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
                Text = "<b>" .. catalogInfo.Name .. "</b>",
                TextColor3 = TEXT_COLOR,
                TextStrokeTransparency = 0.5
            })
        }
    })

    return out
end

local function getImageButton(
    maid : Maid,
    order : number,
    image : string,
    text : string ?,
    fn : ((... any) -> (any)) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out = _new("ImageButton")({
        Name = text or "",
        LayoutOrder = order,
        AutoButtonColor = true,
        Image = image,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            })
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
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
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
    placeHolderText : string
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out = _new("TextBox")({
        LayoutOrder = order,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        TextColor3 = TEXT_COLOR,
        PlaceholderText = placeHolderText,
        PlaceholderColor3 = TEXT_COLOR
    })

    return out
end

--class
return function(
    maid : Maid,
    onCatalogTry : Signal,
    onCatalogDelete : Signal,

    getSubCategoryList : (categoryName : string) -> {[number] : string},
    getCatalogPages : (categoryName : string, subCategory : string) -> CatalogPages
)
    --test 1
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local CurrentCategory : ValueState<Category?> = _Value(nil) :: any

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
                            _bind(getImageButton(maid, 1, "", "featured", function()
                                local lists = getSubCategoryList("featured")
                                CurrentCategory:Set({
                                    CategoryName = "Featured",
                                    SubCategories = lists
                                })
                                return 
                            end))({
                                LayoutOrder = 1,
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
                                    _bind(getImageButton(maid, 1, "", "hair", function()
                                        local lists = getSubCategoryList("hair")
                                        CurrentCategory:Set({
                                            CategoryName = "Hair",
                                            SubCategories = lists
                                        })
                                        return
                                    end))({
                                        Size = UDim2.new(1,0,0.5,0),                                                
                                    }),
                                    _bind(getImageButton(maid, 2, "","Animation Packs", function()
                                        local lists = getSubCategoryList("Animation Packs")
                                        CurrentCategory:Set({
                                            CategoryName = "Animation Packs",
                                            SubCategories = lists
                                        })
                                        return
                                    end))({
                                        Size = UDim2.new(1,0,0.47,0)                                               
                                    }),
                                }
                            })
                        }
                    }), 

                    _bind(getImageButton(maid, 1, "", "accessories", function()
                        local lists = getSubCategoryList("accessories")
                        CurrentCategory:Set({
                            CategoryName = "Accessories",
                            SubCategories = lists
                        })
                        return
                    end))({
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
                    _bind(getImageButton(maid, 1, "", "Clothing", function()
                        local lists = getSubCategoryList("clothing")
                        CurrentCategory:Set({
                            CategoryName = "Clothing",
                            SubCategories = lists
                        })
                        return
                    end))({
                        Size = UDim2.new(1,0,0.485,0),
                    }),
                    _bind(getImageButton(maid, 2, "", "faces", function()
                        local lists = getSubCategoryList("faces")
                        CurrentCategory:Set({
                            CategoryName = "Faces",
                            SubCategories = lists
                        })
                        return
                    end))({
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
                    _bind(getTextBox(maid, 2,"Search..."))({
                        Size = UDim2.fromScale(1, 0.7)
                    })
                }
            })
            ,
            _new("ScrollingFrame")({
                Name = "SubCategory",
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                ScrollBarThickness = 5,
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
                "Enter Item Link..."
            ))({
                Size = UDim2.fromScale(0.3, 1)
            }),
           
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

    local out = _new("Frame")({
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
                    _new("ViewportFrame")({
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(1, 0.77),
                        BackgroundColor3 = BACKGROUND_COLOR
                    }),
                    _new("ScrollingFrame")({
                        LayoutOrder = 2,
                        ScrollBarThickness = 2,
                        AutomaticCanvasSize = Enum.AutomaticSize.X,
                        CanvasSize = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(1, 0.20),
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
                            }),
                            --[[getAccessoryButton(maid, 1, {
                                [1] = {
                                    Name = "Buy",
                                    Signal = onCatalogTry,
                                },
                                [2] = {
                                    Name = "Delete",
                                    Signal = onCatalogTry,
                                },
                            }),
                            getAccessoryButton(maid, 1, {
                                [1] = {
                                    Name = "Buy",
                                    Signal = onCatalogTry,
                                },
                                [2] = {
                                    Name = "Delete",
                                    Signal = onCatalogTry,
                                },
                            }),
                            getAccessoryButton(maid, 1, {
                                [1] = {
                                    Name = "Buy", 
                                    Signal = onCatalogTry,
                                },
                                [2] = {
                                    Name = "Delete",
                                    Signal = onCatalogTry,
                                },
                            }),
                            getAccessoryButton(maid, 1, {
                                [1] = {
                                    Name = "Buy", 
                                    Signal = onCatalogTry,
                                },
                                [2] = {
                                    Name = "Delete",
                                    Signal = onCatalogTry,
                                },
                            }),]]
                        }
                    }),
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

        local function loopThroughCatalogPage(catalogPage : CatalogPages)
            for k,v in pairs(catalogPage:GetCurrentPage()) do

                local button = catalogPageMaid:GiveTask(getCatalogButton(maid, k,  v, {
                    [1] = {
                        Name = "Try",
                        Signal = onCatalogTry
                    }
                }))
                button.Parent = categoryContent
                
            end
        end

        local function updateContent(category : string, subCategory : string ?)
            catalogPageMaid:DoCleaning()

            currentCatalogPage = getCatalogPages(category, subCategory or "All")
            currentSubCategory = subCategory

            loopThroughCatalogPage(currentCatalogPage)
            
        end

        local loadingFooter =  getLoadingFrame(maid, 2, categoryPageFooter)

        local strVal = _new("StringValue")({
            Value = _Computed(function(category : Category ?)
                pageMaid:DoCleaning()

                if category then
                    categoryPage.Visible = true
                    mainMenuPage.Visible = false

                    loadingFooter.Visible = true

                    updateContent(category.CategoryName, category.SubCategories[1])
                    local subCategoryListFrame = getSubCategoryListFrame(categoryPage)
                
                    for i, v in pairs(category.SubCategories) do
                        pageMaid:GiveTask( _bind(getButton(maid, i, v, function()
                            updateContent(category.CategoryName, v)
                        end))({
                            Size = UDim2.fromScale(0.25, 1),
                            Parent = subCategoryListFrame
                        }))
                    end 

                    loadingFooter.Visible = false
                   
                else
                    categoryPage.Visible = false
                    mainMenuPage.Visible = true
                end

                return ""
            end, CurrentCategory)
        })

        maid:GiveTask(categoryContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if (categoryContent.CanvasPosition.Y == categoryContent:FindFirstChild("UIGridLayout").AbsoluteContentSize.Y - categoryContent.AbsoluteSize.Y) then
                loadingFooter.Visible = true

                local s,e = pcall(function() currentCatalogPage:AdvanceToNextPageAsync() end)
                if not s and e then
                    warn("error: " .. e)
                end 
                
                local category = CurrentCategory:Get()
                if category then
                    loopThroughCatalogPage(currentCatalogPage)
                end
                loadingFooter.Visible = false
            end
        end))
    end

    --fxs
    --task.spawn(function()
    --    task.wait(1)
    --    loadingFooter.Parent = categoryPageFooter
    --end)
    --testing

        --outfits
    --[[for i = 1, 10 do
        local button = getAccessoryButton(maid, i, {
            [1] = {
                Name = "Try",
                Signal = onCatalogTry
            }
        })
        button.Parent = categoryContent
    end]] 
    return out
end
