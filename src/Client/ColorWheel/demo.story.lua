--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local ColorWheel = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ColorWheel"))

return function(target : CoreGui)
    local _maid = Maid.new()

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind 
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local selectedColor = _Value(Color3.fromRGB(100,100,100))

    local onColorConfirm = _maid:GiveTask(Signal.new())
    local onBack = _maid:GiveTask(Signal.new())

    local out = ColorWheel(
        _maid,
        false,
        selectedColor,

        onColorConfirm,
        onBack,
        "Test Color Wheel",
        function()
            return "Mengulang kisah", "seperti doeloe"
        end
    )
    out.Parent = target

    _maid:GiveTask(onColorConfirm:Connect(function(t1, t2)
        print("Confem!  ", t1, t2)

    end))
    _maid:GiveTask(onBack:Connect(function()
        print("on back")
    end))

    return function()
        _maid:Destroy()
    end
end