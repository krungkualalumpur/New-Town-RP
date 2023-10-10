--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local MainUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"))
local BackpackUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("BackpackUI"))
--types
type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
--remotes
--variables
--references
--local functions
local function getItemInfo(
    class : string,
    name : string
)
    return {
        Class = class,
        Name = name,
        IsEquipped = true
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

    local MainUIStatus : ValueState<MainUI.UIStatus> = _Value(nil) :: any

    local backpack = _Value({
        getItemInfo(
            "Food",
            "Satay" 
        )
    })

    local onBackpackEquip = maid:GiveTask(Signal.new())
    local onBackpackDelete = maid:GiveTask(Signal.new())
    local onNotify = maid:GiveTask(Signal.new())

    local nameOnCustomize = maid:GiveTask(Signal.new())

    local onCharReset = maid:GiveTask(Signal.new())

    MainUI(
        maid,
        
        backpack :: any,

        MainUIStatus,

        onBackpackEquip,
        onBackpackDelete,
        onNotify,

        onCharReset,
        
        target
    )

    maid:GiveTask(onBackpackEquip:Connect(function()
        print("Equip")
    end))

    maid:GiveTask(onBackpackDelete:Connect(function()
        print("Delete")
    end))

    maid:GiveTask(onNotify:Connect(function()
        print("Notify")
    end))

    maid:GiveTask(nameOnCustomize:Connect(function()
        print("Customize Name")
    end))

    return function() 
        maid:Destroy()
    end
end
