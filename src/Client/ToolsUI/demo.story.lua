--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local ToolsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ToolsUI"))
--types
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

    local out = ToolsUI(
        maid,
        'ade tipi',
        {
            getOptInfo("Satay", "A delicious one yay"),
            getOptInfo("Pempek", "A delicious one yay")

        }
    )
    out.Parent = target

    return function() 
        maid:Destroy()
    end
end
