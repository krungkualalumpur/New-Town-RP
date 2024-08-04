--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local RoleplayUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("RoleplayUI"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomEnums = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))

--types
type Maid = Maid.Maid

type ValueState<T> = ColdFusion.ValueState<T>

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
    local onItemCartSpawn = maid:GiveTask(Signal.new())
    local onJobChange = maid:GiveTask(Signal.new())

    local currentJob = _Value(nil :: any)

    local backpack : ValueState<{BackpackUtil.ToolData<boolean>}> = _Value({
        BackpackUtil.newData("Jamu", "Consumption") :: any,
    })

    local animationUI = RoleplayUI(
        maid,
        {
            CustomEnums.AnimationAction.Happy,
            CustomEnums.AnimationAction.Sad,
            CustomEnums.AnimationAction.Wave,
            CustomEnums.AnimationAction.Dance1,
            CustomEnums.AnimationAction.Dance2
        },

        onAnimClick,
        onItemCartSpawn,


        onJobChange,
        backpack,
        currentJob,
        Jobs.getJobs(),
        _Value("test" :: string ?),

        false
    )

    maid:GiveTask(onAnimClick:Connect(function(animationAction : CustomEnums.AnimationAction)
        print("faiaaah ", animationAction.Name)
    end))
    animationUI.Parent = target
    maid:GiveTask(onItemCartSpawn:Connect(function(selectedItems : {[number] : BackpackUtil.ToolData<nil>})
        print("Item cart spawn! ", selectedItems)
    end))

    maid:GiveTask(onJobChange:Connect(function(jobData)
        currentJob:Set(jobData)
    end))

    return function() 
        maid:Destroy()
    end
end
