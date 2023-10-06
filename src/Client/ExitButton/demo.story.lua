--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

return function(target : CoreGui)
    local _maid = Maid.new()

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind 
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    --
    local exampleFrame = _maid:GiveTask(_new("Frame")({
        Size = UDim2.fromScale(0.1, 0.4),
        Position = UDim2.fromScale(0.1, 0.2),
        Parent = target
    })) :: GuiObject
    --[[local exampleFrame2 = _maid:GiveTask(_new("Frame")({
        Size = UDim2.fromScale(0.1, 0.4),
        Position = UDim2.fromScale(0.5, 0.2),
        Parent = target
    })) :: GuiObject]]
    local isExitButtonVisible = _Value(true)

    local frame = ExitButton.new(exampleFrame, isExitButtonVisible)
    frame.Instance.Parent = target
    
    return function()
        _maid:Destroy()
    end
end