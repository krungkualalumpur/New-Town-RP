--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local HouseUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("HouseUI"))
--types
type Maid = Maid.Maid

type ValueState<T> = ColdFusion.ValueState<T>

type Signal = Signal.Signal
--constants
--variables
--references
--local functions
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

    local houseIndex = _Value(1)
    local houseName = _Value("Test House")

    local onNext = maid:GiveTask(Signal.new())
    local onPrevious = maid:GiveTask(Signal.new())
    local onClaim = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local out = HouseUI(
        maid,

        houseIndex,
        houseName,

        onNext,
        onPrevious,
        onClaim,
        onBack,

        1, 
        5
    )
    out.Parent = target
   
    maid:GiveTask(onNext:Connect(function()
        houseIndex:Set(houseIndex:Get() + 1)
        houseName:Set(("House %d"):format(houseIndex:Get()))
    end))
    maid:GiveTask(onPrevious:Connect(function()
        houseIndex:Set(houseIndex:Get() - 1)
        houseName:Set(("House %d"):format(houseIndex:Get()))
    end))
    maid:GiveTask(onBack:Connect(function()
        print("on back")
    end))

    return function() 
        maid:Destroy()
    end
end
