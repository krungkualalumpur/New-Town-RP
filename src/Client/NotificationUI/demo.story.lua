--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local NotificationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"))
--types
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local _fuse = ColdFusion.fuse(maid)

    local _Value = _fuse.Value

    local textStatus = _Value("You reached max amoutnt of tool" :: string ?)
 

    local out = NotificationUI(
        maid,
        false,
        textStatus
    )

    out.Parent = target

    task.spawn(function()
        task.wait(1)
        textStatus:Set("Test only")
    end)
    return function() 
        maid:Destroy()
    end
end
