--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
--types
type ToolData = BackpackUtil.ToolData<boolean>
--constants
--variables
--references
--local functions
local function getItemInfo(
    class : string,
    name : string
) : ToolData
    return {
        Class = class,
        Name = name,
        IsEquipped = false
    }
end
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local function getRandomItemInfo()
        local rand1 = math.random(1,2)
        
        local function getRandomNum()
            return math.random(1, 120)
        end
        
        return getItemInfo(
            if rand1 == 1 then "ha" else "hi", 
            string.format("%s%s%s", string.char(getRandomNum()), string.char(getRandomNum()), string.char(getRandomNum()))
        )
    end 

    local items = _Value({
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(), 
        getRandomItemInfo(),
        getRandomItemInfo(),
        getRandomItemInfo(),

    }) 

    local onEquip = maid:GiveTask(Signal.new())
    local onDelete = maid:GiveTask(Signal.new())

    local backpackUI = BackpackUI(
        maid, 
        {"ha", "hi", "hu", "he"},
        items,
        onEquip, 
        onDelete
    )
    backpackUI.Parent = target
    print(backpackUI)

    maid:GiveTask(onEquip:Connect(function(itemName : string)
        print("Onclick1 ", itemName)
    end))
    maid:GiveTask(onDelete:Connect(function(itemName : string)
        print("Onclick2 ", itemName)

    end))

    return function() 
        maid:Destroy()
    end
end
