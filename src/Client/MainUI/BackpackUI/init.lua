--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
--types
type Maid = Maid.Maid
type ItemInfo = {
    Name : string,
    Class : string
}

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local BACKGROUND_COLOR = Color3.fromRGB(190,190,190)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(25,25,25)
local PADDING_SIZE = UDim.new(0,15)
--variables
--references
--local functions
local function getItemButton(maid : Maid, itemName : string)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _new("ImageButton")({
        BackgroundTransparency = 0.5,
        BackgroundColor3 = SECONDARY_COLOR,
        AutoButtonColor = true,
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
                Text = itemName
            }),
            _new("ViewportFrame")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.75),
            })
        }
    })

    return out
end

local function getItemTypeFrame(
    maid : Maid, 
    typeName : string,
    Items : State<{
        [number] : string
    }>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local itemFrameList = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0),
        Children = {
            _new("UIGridLayout")({
                CellPadding = UDim2.fromOffset(5, 5),
                CellSize = UDim2.fromOffset(100, 100)
            }),
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

        }
    })

    local out = _new("Frame")({
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                Name = "Title",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                LayoutOrder = 1,
                TextSize = 25,
                RichText = true,
                Text = typeName,
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5,
            }),
            itemFrameList
        }
    })

 
    Items:ForValues(function(v, pairMaid : Maid)
        local itemButton = getItemButton(pairMaid, v)
        itemButton.Parent = itemFrameList
        return v
    end)

    return out
end
--class
return function(
    maid : Maid,
    itemTypes : {[number] : string},
    itemsOwned : ValueState<{[number] : ItemInfo}>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local contentFrame = _new("ScrollingFrame")({
        Name = "ContentFrame",
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        BackgroundColor3 = SECONDARY_COLOR,
        BackgroundTransparency = 0.74,
        Position = UDim2.fromScale(0,0),
        Size = UDim2.fromScale(0.3,1),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1,0)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE
            }),
            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.06),
                RichText = true,
                TextScaled = true,
                Text = "<b>Backpack</b>",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.5
            }) 
        }
    }) :: GuiObject

    for k,typeName in pairs(itemTypes) do
        local itemsFiltered = _Computed(function(items : {[number] : ItemInfo})
            local filteredItemsByTypes = {}
            for _,itemInfo : ItemInfo in pairs(items) do
                if itemInfo.Class == typeName then
                    table.insert(filteredItemsByTypes, itemInfo.Name)
                end
            end

            return filteredItemsByTypes
        end, itemsOwned)
        local itemTypeFrame = getItemTypeFrame(maid, typeName, itemsFiltered)
        itemTypeFrame.Parent = contentFrame

       --[[ task.spawn(function()
            task.wait(1) 
            items:Set({"Indonesia", " deaaw"})
        end)]]

        
    end

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
                FillDirection = Enum.FillDirection.Horizontal
            }),
            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.3, 1)
            }),
            contentFrame
        }
    }) :: Frame

    return out
end