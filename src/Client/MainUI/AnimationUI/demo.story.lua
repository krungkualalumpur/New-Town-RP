--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local AnimationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("AnimationUI"))
--types
type Maid = Maid.Maid

type AnimationInfo = {
    Name : string,
    AnimationId : string
}

type Signal = Signal.Signal
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

    local onAnimClick = maid:GiveTask(Signal.new())
    local animationUI = AnimationUI(
        maid,
        {
            getAnimInfo("Hepi", 1223131),
            getAnimInfo("Sed", 1223131)
        },
        onAnimClick
    )
    maid:GiveTask(onAnimClick:Connect(function(animInfo : AnimationInfo)
        print("faiaaah ", animInfo.Name)
    end))
    animationUI.Parent = target

    return function() 
        maid:Destroy()
    end
end
