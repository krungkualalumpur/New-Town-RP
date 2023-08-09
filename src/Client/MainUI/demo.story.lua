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
        Name = name
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

    local backpack = _Value({
        getItemInfo(
            "Food",
            "Oneng Oncee" 
        )
    })

    local onBackpackEquip = maid:GiveTask(Signal.new())
    local onBackpackDelete = maid:GiveTask(Signal.new())

    local frame = MainUI(
        maid,
        
        backpack :: any,

        onBackpackEquip,
        onBackpackDelete
    )
    frame.Parent = target

    maid:GiveTask(onBackpackEquip:Connect(function()
        print("Equip")
    end))

    maid:GiveTask(onBackpackDelete:Connect(function()
        print("Delete")
    end))

    return function() 
        maid:Destroy()
    end
end
