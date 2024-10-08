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

local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
--types
type Signal = Signal.Signal

type Maid = Maid.Maid
type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
--constants
--remotes
--variables
--references
--local functions
return function(
    maid : Maid,
    isDark : CanBeState<boolean>,
    
    itemName : CanBeState<string>,

    onThrow : Signal,
    onDelete : Signal,
    onInteract : Signal?,

    toolData : BackpackUtil.ToolData<any>)

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
        if onInteract then 
            onInteract:Fire(toolData)
        end
    end
    local function onThrowFn()
        onThrow:Fire(toolData)
    end

    local function onDeleteFn()
        onDelete:Fire(toolData)
    end

    local interactButton = if onInteract then Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, "Interact", onInteractFn, isDark) else nil
    local throwButton = Sintesa.Molecules.FilledCommonButton.ColdFusion.new(maid, "Throw", onThrowFn, isDark)
    local removeButton = Sintesa.Molecules.TextCommonButton.ColdFusion.new(maid, "Remove", onDeleteFn, isDark)

    local title = _bind(Sintesa.InterfaceUtil.TextLabel.ColdFusion.new(
        maid, 
        1, 
        itemName, 
        _Computed(function(dark  : boolean)
            return Sintesa.StyleUtil.MaterialColor.Color3FromARGB(Sintesa.ColorUtil.getDynamicScheme(dark):get_onSurfaceVariant())
        end, isDarkState),
        Sintesa.TypeUtil.createTypographyData(Sintesa.StyleUtil.Typography.get(Sintesa.SintesaEnum.TypographyStyle.TitleMedium)), 
        25
    ))({
        Size = UDim2.new(0,0,0,0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local contentFrame = _bind(Sintesa.Molecules.ElevatedCard.ColdFusion.new(
        maid, 
        isDark, 
        {
            title,
            _new("Frame")({
                LayoutOrder = 2,
                Name = "Buttons",
                BackgroundTransparency = 1,
                Size = UDim2.new(0,0,0,30),
                Children = {
                    _new("UIListLayout")({
                        Padding = UDim.new(0,10),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    if interactButton then 
                        _bind(interactButton)({
                            LayoutOrder = 2
                        }) 
                    else nil :: any,
                    _bind(throwButton)({
                        LayoutOrder = 3,
                    }),
                    _bind(removeButton)({
                        LayoutOrder = 4
                    })
                }
            })
           
        }, 
        function(buttonData)
            print(buttonData.Name)
        end
    ))({
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0,0,0,50)
    })

    local out = _new("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Children = {
            _new("UIPadding")({
                PaddingBottom = UDim.new(0,70)
            }),
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right
            }),
            contentFrame
        }
    })

    title.Size = UDim2.new(0, contentFrame.AbsoluteSize.X, 0, 0)
    return out
end