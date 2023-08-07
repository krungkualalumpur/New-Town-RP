--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local AnimationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("AnimationUI"))
--types
--constants
--variables
--references
--local functions
local function getAnimInfo(
    animName : string,
    animId : number
)
    return {
        Name = animName,
        AnimationId = "rbxassetid://" .. tostring(animId)
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

    local animationUI = AnimationUI(
        maid,
        {
            getAnimInfo("Hepi", 1223131),
            getAnimInfo("Sed", 1223131)
        }
    )
    animationUI.Parent = target

    return function() 
        maid:Destroy()
    end
end
