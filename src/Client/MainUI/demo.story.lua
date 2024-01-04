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

    local onBackpackAdd = maid:GiveTask(Signal.new())
    local onBackpackDelete = maid:GiveTask(Signal.new())
    local onVehicleSpawn = maid:GiveTask(Signal.new())
    local onVehicleDelete = maid:GiveTask(Signal.new())
    local onJobChange = maid:GiveTask(Signal.new())
    local onNotify = maid:GiveTask(Signal.new())

    local isOwnHouse = _Value(false)
    local isOwnVehicle = _Value(false)

    local houseIsLocked = _Value(true)
    local vehicleIsLocked = _Value(true)

    local nameOnCustomize = maid:GiveTask(Signal.new())

    local onItemCartSpawn = maid:GiveTask(Signal.new())

    local onCharReset = maid:GiveTask(Signal.new())

    local onHouseLocked = maid:GiveTask(Signal.new())
    local onVehicleLocked = maid:GiveTask(Signal.new())

    local onHouseClaim = maid:GiveTask(Signal.new())

    MainUI(
        maid,
        
        backpack :: any,

        MainUIStatus,

        _Value({}),
        _Value("Sundus, " .. game.Lighting.TimeOfDay),
        isOwnHouse,
        isOwnVehicle,
        houseIsLocked,
        vehicleIsLocked,

        onBackpackAdd,
        onBackpackDelete,
        onVehicleSpawn,
        onVehicleDelete,
 
        onHouseLocked,
        onVehicleLocked,

        onHouseClaim,

        onNotify,

        onItemCartSpawn,

        onJobChange,
        onCharReset,
        
        target
    )

    maid:GiveTask(onBackpackAdd:Connect(function()
        print("Add")
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

    maid:GiveTask(onItemCartSpawn:Connect(function(items)
        print("Item Cart Spawn ", items)
    end))

    maid:GiveTask(onCharReset:Connect(function()
        print("Character Reset")
    end))

    return function() 
        maid:Destroy()
    end
end
