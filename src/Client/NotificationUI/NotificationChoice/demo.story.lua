--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))
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
   
    local notifChoice = maid:GiveTask(NotificationChoice(
        maid, 
        "Test",
        "Desc",
        true,
        function()
            print("On click")
        end,
        function()
            print("on cancel")
            --maid:Destroy()  
        end
    ))
    notifChoice.Parent = target

    return function()
        maid:Destroy()
    end
end
