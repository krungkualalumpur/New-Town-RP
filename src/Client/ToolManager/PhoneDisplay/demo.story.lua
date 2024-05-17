--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local PhoneDisplay = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ToolManager"):WaitForChild("PhoneDisplay"))
--types
--constants
--remotes
--variables
--references
--local functions
--class

return function(target : CoreGui)
    local maid = Maid.new()
    local _fuse = ColdFusion.fuse(maid)
    local _Value = _fuse.Value

    local onMessageSend = maid:GiveTask(Signal.new())
    local onMessageRecieve = maid:GiveTask(Signal.new())

    local out = PhoneDisplay(
        maid,
        onMessageSend,
        onMessageRecieve
    )

    maid:GiveTask(onMessageSend:Connect(function(player : Player, msgText : string)
        print("Message sent ", msgText)
    end))
    maid:GiveTask(onMessageRecieve:Connect(function(player : Player, msgText : string)
        print("Message sent ", msgText)
    end))

    out.Parent = target

   -- onMessageRecieve:Fire(workspace.Part1, "Test1212")
    return function()
        maid:Destroy()
    end
end