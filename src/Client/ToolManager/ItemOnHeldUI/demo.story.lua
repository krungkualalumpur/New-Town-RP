--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local interface = require(script.Parent)
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

    local nameOnCustomize = maid:GiveTask(Signal.new())

    local onInteract = maid:GiveTask(Signal.new())
    local onThrow = maid:GiveTask(Signal.new())

    local out = interface(
        maid,
        false,

        "Pencil",

        onInteract,
        onThrow,

        nil
    )
    out.Parent = target

    return function() 
        maid:Destroy()
    end
end
