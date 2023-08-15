--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))
--types
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

    local list = {
        "Test1",
        "Test2",
        "I dont like mondays i wanna shoot",
        "Rahayu",
        "Wisnu",
        "Niko",
        'AAa',
        "Roman bellic",
        "GG"
    }

    local pos = _Value(UDim2.fromScale(0.5, 0.5))

    local isVisible = _Value(true)

    local onClickSignal = maid:GiveTask(Signal.new())

    local listUI = ListUI(
        maid,
        "Wisnu",
        list,
        pos,
        isVisible,
        onClickSignal
    )
    listUI.Parent = target

    maid:GiveTask(onClickSignal:Connect(function(k, v)

    end))

    return function()
        maid:Destroy()
    end
end
