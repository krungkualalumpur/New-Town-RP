--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local NotificationChoiceTop = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoiceTop"))
--types
type Maid = Maid.Maid
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
   
    local onConfirm = maid:GiveTask(Signal.new())

    local notifChoice = NotificationChoiceTop(
        maid,
        "Test Onleh",

        onConfirm,
        "Teleport"
    )
    notifChoice.Parent = target

    maid:GiveTask(onConfirm:Connect(function()
        print("on Confirm")
    end))

    return function()
        maid:Destroy()
    end
end
