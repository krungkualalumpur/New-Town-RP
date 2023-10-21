--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
--constants
local ON_NOTIF_CHOICE_INIT = "OnNotifChoiceInit"
--variables
--references
--local functions
local actions = {
    StartUp = function()
        print("Test onleh laa")
    end
} 
--class
local ChoiceActions = {} 

ChoiceActions.requestEvent = function(plr : Player, actionName : string, eventTitle : string, eventDesc : string, isConfirm : boolean)
    assert(RunService:IsServer(), "This function only runs on server!")
    task.spawn(function()
        NetworkUtil.invokeClient(ON_NOTIF_CHOICE_INIT, plr, actionName, eventTitle, eventDesc, isConfirm)
    end) --actions[eventName]()
end

ChoiceActions.triggerEvent = function(eventName : string)
    local eventFn = actions[eventName]
    if eventFn then 
        eventFn() 
    else 
        warn("Unable to find the event")
    end
end


return ChoiceActions