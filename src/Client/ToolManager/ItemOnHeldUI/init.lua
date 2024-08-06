--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Sintesa = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Sintesa"))
--modules
--local MainUI = require(script.Parent)
--local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("BackpackUI"))

local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local AnimationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))

local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))

local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))

local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
--types
type Signal = Signal.Signal

type Maid = Maid.Maid
type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
--remotes
--variables
--references
--local functions
return function(
    maid : Maid,
    isDark : CanBeState<boolean>,
    
    onInteract : Signal,
    onThrow : Signal)

    --backpack : ValueState<{BackpackUtil.ToolData<boolean>}>)
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local isDarkState = _import(isDark, isDark)
    -- local function onInteract()
    --     if not RunService:IsRunning() then
    --         return
    --     end
    --     for _,v in pairs(backpack:Get()) do
    --         if v.IsEquipped then
    --             local toolModel = BackpackUtil.getToolFromName(v.Name)
    --             if toolModel then
    --                 local toolData = BackpackUtil.getData(toolModel, false)
    --                 ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
    --             end
    --             break
    --         end
    --     end  
    -- end

    -- local function onThrow()
    --     if not RunService:IsRunning() then
    --         return
    --     end
    --     for _,v in pairs(backpack:Get()) do
    --         if v.IsEquipped then
    --             local toolModel = BackpackUtil.getToolFromName(v.Name)
    --             if toolModel then
    --                 --local toolData = BackpackUtil.getData(toolModel, false)
    --                 --ToolActions.onToolActivated(toolData.Class, game.Players.LocalPlayer, BackpackUtil.getData(toolModel, true))
    --                 local toolData = BackpackUtil.getData(toolModel, false)
    --                 NetworkUtil.fireServer(ON_ITEM_THROW, toolData)
    --             end
    --             break
    --         end
    --     end  
    -- end
    local function onInteractFn()
        onInteract:Fire()
    end
    local function onThrowFn()
        onThrow:Fire()
    end

    local interactButton = Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, "Interact", onInteractFn, isDark)
    local throwButton = Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, "Throw", onThrowFn, isDark)

    -- local out = _new("Frame")({
    --     Size = UDim2.new(0,100,0,100),
    --     Children = {
    --         _new("UIListLayout")({
    --             SortOrder = Enum.SortOrder.LayoutOrder,
    --             HorizontalAlignment = Enum.HorizontalAlignment.Center,
    --             VerticalAlignment = Enum.VerticalAlignment.Center
    --         }),
    --         Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
    --             maid, 
    --             1, 
    --             "Item Name Here", 
    --             _Computed(function(dark  : boolean)
    --                 return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
    --             end, isDarkState),
    --             Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.LabelLarge)), 
    --             25
    --         ),
    --         _bind(interactButton)({
    --             LayoutOrder = 2
    --         }),
    --         _bind(throwButton)({
    --             LayoutOrder = 3
    --         })
    --     }
    -- })
    local out = _bind(Sintesa.Molecules.ElevatedCard.ColdFusion.new(
        maid, 
        isDark, 
        {
            Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
                maid, 
                1, 
                "Item Name Here", 
                _Computed(function(dark  : boolean)
                    return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
                end, isDarkState),
                Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.TitleMedium)), 
                25
            ),
            _new("Frame")({
                LayoutOrder = 2,
                Name = "Buttons",
                BackgroundTransparency = 1,
                Size = UDim2.new(0,100,0,30),
                Children = {
                    _new("UIListLayout")({
                        Padding = UDim.new(0,10),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    _bind(interactButton)({
                        LayoutOrder = 2
                    }),
                    _bind(throwButton)({
                        LayoutOrder = 3
                    })
                }
            })
           
        }, 
        function(buttonData)
            print(buttonData.Name)
        end
    ))({
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0,200,0,50)
    })

    return out
end