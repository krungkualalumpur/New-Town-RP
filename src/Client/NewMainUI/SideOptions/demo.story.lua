--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local SideOptions = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NewMainUI"):WaitForChild("SideOptions"))
--types
type Signal = Signal.Signal
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
 
    local onSprintClick = maid:GiveTask(Signal.new())

    local out = SideOptions(
       maid,
       onSprintClick,

       _Value(true)
    )

    maid:GiveTask(onSprintClick:Connect(function()
        print("miksue")
    end))

    out.Parent = target

    task.spawn(function()
        task.wait(1)
        textStatus:Set("Test only")
    end)
    return function() 
        maid:Destroy()
    end
end
