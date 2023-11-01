--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type AnimationInfo = {
    Name : string,
    AnimationId : string
}

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(75, 210, 80)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)

local PADDING_SIZE = UDim.new(0,10)
--variables
--references
--local functions
local function getButton(
    maid : Maid,
    order : number,
    text : string,
    fn : () -> (),
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

local function getViewportFrame(
    maid : Maid,
    order : number,
    relativePos : CanBeState<Vector3>,
    contentInstance : CanBeState<Model ?>,
    fn : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed

    local importedCf : State<Vector3> = _import(relativePos, Vector3.new(5,0,0))

    local camera = _new("Camera")({
        CFrame = _Computed(function (localv3 : Vector3)
            
            return CFrame.lookAt(localv3, Vector3.new())
        end, importedCf)
    })

    local out = _new("ViewportFrame")({
        LayoutOrder = order,
        CurrentCamera = camera,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = TERTIARY_COLOR,
        Children = {
            camera,
            _new("WorldModel")({
                Children = {
                    _import(contentInstance, nil) 
                }
            }),
        }
    })
 
    if fn then
        _new("ImageButton")({
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Events = {
                Activated = function()
                    fn()
                end
            },
            Parent = out
        })
    end

    return out
end


local function getAnimationButton(maid : Maid, animationInfo : AnimationInfo, onAnimClick : Signal)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("ImageButton")({
        BackgroundColor3 = TERTIARY_COLOR,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0,0,40),
        AutoButtonColor = true,
        Children = {
            _new("UIStroke")({
                Color = SECONDARY_COLOR,
                Thickness = 1.5
            }),
            _new("UICorner")({}),
            
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                TextColor3 = TEXT_COLOR,
                TextSize = 22,
                Font = Enum.Font.Gotham,
                Text = animationInfo.Name,
            })
        },
        Events = {
            Activated = function()
                onAnimClick:Fire(animationInfo)
            end
        }
    })

    return out
end


local function getSelectButton(maid : Maid, order : number, text : string, isSelected : State<boolean>, fn : () -> (), color : Color3?)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = getButton(maid, order, text, fn, color)
    _bind(out)({
        AutoButtonColor = false,
        BackgroundColor3 = color,
        Size = UDim2.new(0.25, 0,1,0),
        Children = {
            _new("Frame")({
                BackgroundColor3 = SELECT_COLOR,
                Visible = isSelected,
                Size = _Computed(function(selected : boolean)
                    return if selected then UDim2.fromScale(0.8, 0.1) else UDim2.fromScale(0, 0.15)
                end, isSelected):Tween(0.2),
                Children = {
                    _new("UICorner")({})
                }
            })
        }
    })

    return out
end
--class
return function(
    maid : Maid,
    Animations : {[number] : AnimationInfo},

    OnAnimClick : Signal,
    onItemCartSpawn : Signal,

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,

    UIStatus : ValueState<string ?>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local selectedItems : ValueState<{[number] : BackpackUtil.ToolData<nil>}> = _Value({})

    local selectedCategory = _Value("Cart")

    local animationFrameContent = _new("ScrollingFrame")({
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        BackgroundColor3 = BACKGROUND_COLOR,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(0.88,0.8), 
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UICorner")({}),
            _new("UIGridLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                CellSize = UDim2.fromOffset(150, 150),
                CellPadding =  UDim2.fromOffset(15, 15)
            }),
        }
    })

    local animationFrame = _new("ScrollingFrame")({
        LayoutOrder = 2,
        Name = "AnimationFrame",
        Visible = _Computed(function(category : string) 
            return category == "Basic Animation" 
        end, selectedCategory),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = BACKGROUND_COLOR,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(0.9,0.85), 
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("Frame")({
                LayoutOrder = 0,
                Size = UDim2.new(1,0,0,2)
            }),
            animationFrameContent
        }
    })

    
    local gerobakItemsPut =  _new("ScrollingFrame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0.9),
        Children = {
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIGridLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                CellSize = UDim2.fromOffset(80, 80),
            }),
            --_new("")({})
        }
    })

    local tools = game:GetService("CollectionService"):GetTagged("Tool")

    local toolsMaid = maid:GiveTask(Maid.new())
     
    local strValue = _new("StringValue")({
        Value = _Computed(function(backpackTbl : {[number] : BackpackUtil.ToolData<boolean>}, items : {[number] : BackpackUtil.ToolData<nil>})
            toolsMaid:DoCleaning()
            for k,v in pairs(tools) do
                local ownsTool = false
                for _,backpackTool in pairs(backpackTbl) do
                    if backpackTool.Name == v.Name then
                        ownsTool = true
                        break
                    end
                end  
                if not v:GetAttribute("DescendantsAreTools") and ownsTool then
                    --print(v) 
                    local modelDisplay = v:Clone()
                    modelDisplay:PivotTo(CFrame.new())
                    for _,v in pairs(modelDisplay:GetDescendants()) do
                        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                            v:Destroy()
                        end
                    end
                    local button =  getViewportFrame(
                        toolsMaid,
                        k,
                        Vector3.new(1.4,1,1.4),
                        modelDisplay,
                        function()
                           
                            local currentSelectedItems = table.clone(selectedItems:Get())
                           
                            local selectedToolData
                            for _,toolData in pairs(currentSelectedItems) do
                                if toolData.Name == modelDisplay.Name then
                                    selectedToolData = toolData
                                    break
                                end
                            end
                        
                            if not selectedToolData then
                                table.insert(currentSelectedItems, BackpackUtil.getData(v :: Model, true))
                            else
                                table.remove(currentSelectedItems, table.find(currentSelectedItems, selectedToolData))
                            end
                            selectedItems:Set(currentSelectedItems)
                        end
                    )
                    _new("TextLabel")({
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0, 0.7),
                        Size = UDim2.fromScale(1, 0.3),
                        Font = Enum.Font.Gotham,
                        Text = modelDisplay.Name,
                        TextColor3 = TEXT_COLOR,
                        TextStrokeTransparency = 0.5,
                        TextScaled = true,
                        TextWrapped = true,
                        Parent = button
                    })
                    button.Parent = gerobakItemsPut

                    local isSelected = false
                    for _,item in pairs(items) do
                        if v.Name == item.Name then
                            isSelected = true
                            break
                        end
                    end

                    _new("ImageLabel")({
                        Visible = isSelected,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Image = "rbxassetid://72382658",
                        Parent = button
                    })

                    if isSelected then
                        _bind(button)({
                            LayoutOrder = -1
                        })
                        print("Schzio")
                    end
                end
            end
            
            --[[for k,v in pairs(backpackTbl) do
                local button = getButton(maid, k, v.Name, maid:GiveTask(Signal.new()), function()
                    print("testme")
                end, SELECT_COLOR)
                button.Parent = gerobakItemsPut
            end]]
            return ""
        end, backpack, selectedItems)
    })

    local gerobakFrameContent = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.85),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.05),
                Font = Enum.Font.Gotham,
                Text = "Select items to be put into the cart",
                TextScaled = true,
                TextWrapped = true,
                TextColor3 = TEXT_COLOR,
                TextStrokeTransparency = 0.8,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            
            gerobakItemsPut
        } 
    })

    local gerobakFrame = _new("Frame")({
        Name = "GerobakFrame",
        LayoutOrder = 2,
        BackgroundColor3 = BACKGROUND_COLOR,
        Visible = _Computed(function(category : string) 
            return category == "Cart" 
        end, selectedCategory),
        Size = UDim2.fromScale(0.9,0.85), 
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                --Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
        
            _new("Frame")({
                LayoutOrder = 0,
                Size = UDim2.new(1,0,0,2)
            }),

            gerobakFrameContent,

            _new("Frame")({
                LayoutOrder = 3,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.08),
                Children = {
                    _new("UIListLayout")({
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    _bind(getButton(maid, 3,"Spawn Item Cart", function()
                        onItemCartSpawn:Fire(selectedItems:Get())
                    end, SELECT_COLOR))({
                        Size = UDim2.fromScale(0.25, 1)
                    })
                }
            }),
            
        }
    })

    for _,v in pairs(Animations) do
        local animButton = getAnimationButton(
            maid, 
            v,
            OnAnimClick
        )
        animButton.Parent = animationFrameContent
    end

    local header = _new("ScrollingFrame")({
        LayoutOrder = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.9, 0.1),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.fromScale(0, 0),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            getSelectButton(maid, 1, "Cart", _Computed(function(category : string)
                return category == "Cart"
            end, selectedCategory), function()
                if selectedCategory:Get() ~= "Cart" then
                    selectedCategory:Set("Cart")   
                end
            end, BACKGROUND_COLOR),
            --[[getSelectButton(maid, 2, "Basic Animation", _Computed(function(category : string)
                return category == "Basic Animation" 
            end, selectedCategory), function()
                if selectedCategory:Get() ~= "Basic Animation" then
                    selectedCategory:Set("Basic Animation")          
                end
            end, BACKGROUND_COLOR),]]
            getSelectButton(maid, 3, "Basic Animation", _Computed(function(category : string)
                return category == "Basic Animation" 
            end, selectedCategory), function()
                if selectedCategory:Get() ~= "Basic Animation" then
                    selectedCategory:Set("Basic Animation")          
                end
            end, BACKGROUND_COLOR)
        }
    })

    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(0.5,1), 
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
            }),
            header,
            animationFrame,
            gerobakFrame
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
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("Frame")({
                Name = "Buffer",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.285, 1)
            }),
            contentFrame,
        }
    }) :: Frame

   -- game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

    local isExitButtonVisible = _Value(false)
    local exitButton = ExitButton.new(header :: Frame, isExitButtonVisible, function()
        UIStatus:Set(nil)
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        return
    end)
    return out
end