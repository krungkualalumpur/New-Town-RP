--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))

--modules
--types
type Maid = Maid.Maid
--constants
local ON_NOTIFICATION = "OnNotification"
--variables
--references
--local functions
--class
local NotificationUtil = {}

function NotificationUtil.Notify(
    plr : Player,
    text : string 
)

    if RunService:IsServer() then
        NetworkUtil.fireClient(ON_NOTIFICATION, plr, text)
    elseif RunService:IsClient() then
        local guiSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"))
        guiSys:Notify(text)
    end
end

function NotificationUtil.init(maid : Maid)
    if RunService:IsClient() then
        --print("test1")
        NetworkUtil.onClientEvent(ON_NOTIFICATION, function(text : string)
            NotificationUtil.Notify(game.Players.LocalPlayer, text)
        end)
    elseif RunService:IsServer() then
        --print("test2")
        NetworkUtil.getRemoteEvent(ON_NOTIFICATION)
    end
end

return NotificationUtil