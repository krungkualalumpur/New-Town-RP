--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local VehicleControl = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("VehicleControl"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new()
    local out = maid:GiveTask(VehicleControl(
        maid,

        maid:GiveTask(Signal.new()),
        maid:GiveTask(Signal.new()),
        maid:GiveTask(Signal.new()),
        maid:GiveTask(Signal.new())
    ))
    out.Parent = target

    return function()
        maid:Destroy()
    end
end
