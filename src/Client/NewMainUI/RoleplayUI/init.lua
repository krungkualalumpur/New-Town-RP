--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))
local CustomEnums = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
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
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)

local PADDING_SIZE = UDim.new(0,10)
--remotes
local GET_ITEM_CART = "GetItemCart"
--variables
--references
--local functions
--class
return function(
    maid : Maid,
    Animations : {[number] : CustomEnums.AnimationAction},

    OnAnimClick : Signal,
    onItemCartSpawn : Signal,
    onJobChange : Signal,
    onBack : Signal,

    backpack : ValueState<{BackpackUtil.ToolData<boolean>}>,
    currentJob : State<Jobs.JobData?>,

    jobsList : {
        [number] : Jobs.JobData
    }, 

    isDark : CanBeState<boolean>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local width = 380

    local cartSpawned : ValueState<boolean> = _Value(  if RunService:IsRunning() then if NetworkUtil.invokeServer(GET_ITEM_CART) then true else false else false)
    
    local selectedItems : ValueState<{[number] : BackpackUtil.ToolData<nil>}> = _Value({})

    local selectedCategory = _Value("Job")
    local isScrolling = _Value(false)

    local isDarkState = _import(isDark, isDark)
    
    local containerColorState = _Computed(function(isDark : boolean)
        local dynamicScheme = Sintesa.ColorUtil.getDynamicScheme(isDark)
        return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(dynamicScheme:get_surface())
    end, isDarkState)

    local tools = game:GetService("CollectionService"):GetTagged("Tool")

    local toolsMaid = maid:GiveTask(Maid.new())
     
    local cartListFrame = _bind(Sintesa.Molecules.Lists.ColdFusion.new(maid, isDark, false, _Computed(function(backpackTbl : {[number] : BackpackUtil.ToolData<boolean>}, items : {[number] : BackpackUtil.ToolData<nil>}) 
        toolsMaid:DoCleaning()
        
        local _fuse = ColdFusion.fuse(toolsMaid)
        local _new = _fuse.new
        local _import = _fuse.import
        local _bind = _fuse.bind
        local _clone = _fuse.clone
    
        local _Computed = _fuse.Computed
        local _Value = _fuse.Value

        local list = {}
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
                local modelDisplay = toolsMaid:GiveTask(v:Clone())
                modelDisplay:PivotTo(CFrame.new())
                for _,v in pairs(modelDisplay:GetDescendants()) do
                    if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                        v:Destroy()
                    end
                end

                table.insert(list, Sintesa.TypeUtil.createFusionListInstance(
                    modelDisplay.Name, 
                    "Owned item", 
                    nil, 
                    Sintesa.Molecules.Checkbox.ColdFusion.new(maid, _Computed(function(items : {[number] : BackpackUtil.ToolData<nil>})
                        local isSelected: boolean? = false
                        for _,item in pairs(items) do
                            if v.Name == item.Name then
                                isSelected = true
                                break
                            end
                        end
                        return isSelected 
                    end, selectedItems), function() 
                        local currentSelectedItems = table.clone(selectedItems:Get())
                           
                        local selectedToolData
                        for _,toolData in pairs(currentSelectedItems) do
                            if toolData.Name == modelDisplay.Name then
                                selectedToolData = toolData
                                break
                            end
                        end

                        if not selectedToolData and #currentSelectedItems >= 5 then
                            return
                        end
                    
                        if not selectedToolData then
                            table.insert(currentSelectedItems, BackpackUtil.getData(v :: Model, true))
                        else
                            table.remove(currentSelectedItems, table.find(currentSelectedItems, selectedToolData))
                        end
                        selectedItems:Set(currentSelectedItems)
                    end, false),
                    nil,
                    _new("ImageButton")({
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0,25,0,25),
                        Children = {
                            Sintesa.InterfaceUtil.ViewportFrame.ColdFusion.new(
                                toolsMaid, 
                                modelDisplay, 
                                25, 
                                true, 
                                isDarkState
                            )
                        }
                    }) :: ImageButton
                   
                ))
            end
        end

        return list
    end, backpack, selectedItems), width))({
        LayoutOrder = 3,
        Size = UDim2.new(0, width, 0.85,0)
    })

    local gerobakFrameContent = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
            
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
           
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                1, 
                _Computed(function(tbl : {})
                     return ("Select items to be put into the cart. %s"):format(if #tbl < 1 then "\n<b>(You currently do not have items in your backpack)</b>" else "")
                 end, backpack), 
                _Computed(function(dark  : boolean)
                    return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                end, isDarkState),
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
                10
            ))({
                TextYAlignment = Enum.TextYAlignment.Bottom
            }),
            cartListFrame,
            _new("Frame")({
                LayoutOrder = 3,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    }),
                    _bind(Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, _Computed(function(bool : boolean)
                        --gerobakFrameContent.Visible = not bool
                        return if bool then "Despawn cart" else "Spawn cart"
                    end, cartSpawned), function()  
                        onItemCartSpawn:Fire(selectedItems:Get(), cartSpawned)
                    end, isDarkState, 40))({
                        LayoutOrder = 3
                    })
                   
                }
            }),
        } 
    })

    local gerobakFrame = _new("Frame")({
        Name = "GerobakFrame",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Visible = _Computed(function(category : string) 
            return category == "Cart" 
        end, selectedCategory),
        Size = UDim2.fromScale(0.9,0.85), 
        Children = {
           
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                --Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
        

            gerobakFrameContent,

            
            
        }
    })

    local header = Sintesa.Molecules.SmallTopTopAppBar.ColdFusion.new(
        maid, 
        isDarkState, 
        "Roleplay Tools", 
        Sintesa.TypeUtil.createFusionButtonData("Back", Sintesa.IconLists.navigation.arrow_back), 
        {}, 
        isScrolling, 
        function(buttonData: Sintesa.ButtonData)  
            onBack:Fire()
        end
    ) :: GuiObject
    header.Size = UDim2.new(0,width- 12,0, header.Size.Y.Offset) 
    local footer = _bind(Sintesa.Molecules.NavigationBar.ColdFusion.new(maid, isDarkState, "", {
        Sintesa.TypeUtil.createFusionButtonData("Job", Sintesa.IconLists.action1.work, _Computed(function(selectedCat : string)
            return if selectedCat == "Job" then true else false
        end, selectedCategory)),
        Sintesa.TypeUtil.createFusionButtonData("Animation", Sintesa.IconLists.image.animation, _Computed(function(selectedCat : string)
            return if selectedCat == "Animation" then true else false
        end, selectedCategory)),
        Sintesa.TypeUtil.createFusionButtonData("Cart", Sintesa.IconLists.action.shopping_cart, _Computed(function(selectedCat : string)
            return if selectedCat == "Cart" then true else false
        end, selectedCategory))
    }, function(button: Sintesa.ButtonData)  
        selectedCategory:Set(button.Name :: Status)
    end))({
        LayoutOrder = 10
    }) :: GuiButton
    footer.Size = UDim2.new(0,width, 0, footer.Size.Y.Offset)
  
    local _joblists = {}
    for k,v in pairs(jobsList) do
        table.insert(_joblists, Sintesa.TypeUtil.createFusionListInstance(v.Name, nil, nil, 
            Sintesa.Molecules.Checkbox.ColdFusion.new(maid, _Computed(function(job : Jobs.JobData?)
            return (if job and job.Name == v.Name then true else false) :: boolean?
        end, currentJob), function() 
            onJobChange:Fire(v)
        end, false), 
            v.Name:match("%a"), nil, true))
    end
    local jobFrameContent = _bind(Sintesa.Molecules.Lists.ColdFusion.new(maid, isDarkState, false, _joblists, width))({
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.None,
        Size = UDim2.new(0, width, 0.9,0)
    })  

   
    local jobFrame = _new("Frame")({
        Name = "JobFrame",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        Visible = _Computed(function(category : string) 
            return category == "Job" 
        end, selectedCategory),
        Size = UDim2.fromScale(1,1), 
        Children = {
          
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                --Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                1, 
                "Choose your roleplay job", 
                _Computed(function(dark  : boolean)
                    return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                end, isDarkState),
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
                35
            ))({
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Bottom
            }),
            jobFrameContent
        }
    })

    local _animLists = {}
    for _,v in pairs(Animations) do
        table.insert(_animLists, Sintesa.TypeUtil.createFusionListInstance(v.Name, "Animation", nil, Sintesa.Molecules.FilledCommonButton.ColdFusion.new(
            maid, 
            "Play", 
            function() 
                OnAnimClick:Fire(v)
            end, 
            isDarkState
        )))
    end
    local animFrameContent = _bind(Sintesa.Molecules.Lists.ColdFusion.new(maid, isDarkState, false, _animLists, width))({
        LayoutOrder = 2,
        Visible = _Computed(function(category : string) 
            return category == "Animation" 
        end, selectedCategory),
        Size = UDim2.fromScale(1,1), 
    })

    
    local contentFrame = _new("Frame")({
        Name = "ContentFrame",
        BackgroundTransparency = 0,
        BackgroundColor3 = containerColorState,
        Size = UDim2.new(0,width,0.7,0), 
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            animFrameContent,
            jobFrame,
            gerobakFrame,
        }
    })
    
    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Children = {
           
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right
 
            }),
            header,
            -- ZIndex = 2,
            --    -- Size = UDim2.new(0, width- 12, 0,15),
               
            --     Children = {
            --         _new("UISizeConstraint")({
            --             MaxSize = Vector2.new(width - 12, header.Size.Y.Offset)
            --         })
            --     }
            -- }),
           
            contentFrame,
            footer
        }
    }) :: Frame

    local screenAbsoluteSize = _Value(workspace.CurrentCamera.ViewportSize)
    
    maid:GiveTask(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        screenAbsoluteSize:Set(workspace.CurrentCamera.ViewportSize)
    end))
    _bind(contentFrame)({
        Size = _Computed(function(absSize : Vector2)
            return UDim2.fromOffset(width, absSize.Y - footer.AbsoluteSize.Y - header.AbsoluteSize.Y)
        end, screenAbsoluteSize)
    })

    return out
end