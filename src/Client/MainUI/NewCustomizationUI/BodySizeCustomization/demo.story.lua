--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BodySizeCustomization = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"):WaitForChild("BodySizeCustomization"))
--types
type Signal = Signal.Signal
--constants
--variables
--references
--local functions
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local onSignalChange = maid:GiveTask(Signal.new())
    local onScaleConfirmChange = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local bodySizeCustomization  = BodySizeCustomization(
        maid,
        
        onSignalChange,
        onScaleConfirmChange,

        onBack
    )
    bodySizeCustomization.Parent = target
    
    return function() 
        maid:Destroy()
    end
end
