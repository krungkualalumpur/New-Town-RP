--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

local HUD = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MapUI"))

--types
return function(target)
    local maid = Maid.new()

    local fuse = ColdFusion.fuse(maid)

    local _new = fuse.new
    local _import = fuse.import
    local _bind = fuse.bind

    local _Value = fuse.Value
    local _Computed = fuse.Computed

    local Cf = _Value(CFrame.new(-748.194, -79.566, -1683.347)*CFrame.Angles(0, 1, 0) + Vector3.new(0,25,60))
    local out =  maid:GiveTask(HUD.new(maid, Cf, _Value(true), Vector3.new(-61.094, -81.905, -1759.019) :: any))
    out.Instance.Parent = target 
    Cf:Set(CFrame.new(392.223, 50.068, -514.346)*CFrame.Angles(0, 1, 0) + Vector3.new(10,25,20)) 
 
    return function()
        maid:Destroy()  
    end
end