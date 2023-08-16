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
type Signal = Signal.Signal
--constants
--variables
--references
--local functions
local function getButtonInfo(
    signal : Signal,
    buttonName : string
)
    return 
        {
            Signal = signal,
            ButtonName = buttonName
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

    local stateList = _Value(list)

    local pos = _Value(UDim2.fromScale(0.5, 0.5))

    local isVisible = _Value(true)

    local options = {
        getButtonInfo(maid:GiveTask(Signal.new()), "Delete"),
        getButtonInfo(maid:GiveTask(Signal.new()), "Utilize")
    }

    local listUI = ListUI(
        maid,
        "Wisnu", 
        stateList,
        pos,
        isVisible,
        options
    )
    listUI.Parent = target

    return function()
        maid:Destroy()
    end
end
