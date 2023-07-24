--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
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

    local out = InteractUI(maid, _Value(Enum.UserInputType.MouseButton1))
    out.Parent = target

    return function() 
        maid:Destroy()
    end
end
