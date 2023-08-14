--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
--types
type Signal = Signal.Signal
--constants
--variables
--references
--local functions
local function getOptInfo(name : string, desc : string)
    return {
        Name = name,
        Desc = desc
    }
end
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local _fuse = ColdFusion.fuse(maid)

    local _Value = _fuse.Value

    local currentOptInfo = _Value(nil :: any)
    local onItemGet = maid:GiveTask(Signal.new())
    local out = ItemOptionsUI(
        maid,
        'ade tipi',
        {
            getOptInfo("Satay", "A delicious one yay"),
            getOptInfo("Pempek", "A delicious one yay")
        },
        currentOptInfo,
        onItemGet
    )
    out.Parent = target

    maid:GiveTask(onItemGet:Connect(function()
        print(currentOptInfo:Get(), " on get euy!")
    end))

    return function() 
        maid:Destroy()
    end
end
