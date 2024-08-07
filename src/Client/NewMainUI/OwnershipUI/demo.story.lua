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
type Signal = Signal.Signal
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local _fuse = ColdFusion.fuse(maid)

    local _Value = _fuse.Value
 
    local isOwnHouse = _Value(false)
    local isOwnVehicle = _Value(true)
    local isHouseLocked = _Value(false)
    local isVehicleLocked = _Value(false)
   
    local onHouseLocked = maid:GiveTask(Signal.new())
    local onVehicleLocked = maid:GiveTask(Signal.new())
    
    local onVehicleSpawned = maid:GiveTask(Signal.new())

    local out = interface(
       maid,

       false,

       _Value(Color3.new()),
       _Value(Color3.new()),

        isOwnHouse,
        isOwnVehicle,
        isHouseLocked,
        isVehicleLocked,

        onHouseLocked,
        onVehicleLocked,

        onVehicleSpawned,

        maid:GiveTask(Signal.new()),

        target
        )
    out.Parent = target

    return function() 
        maid:Destroy()
    end
end
