--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))
--types
type Maid = Maid.Maid
--constants
local INTERACTABLE_TAG = "Interactable"
local MAXIMUM_INTERACT_DISTANCE = 32

local INTERACT_MAIN_INPUT_KEY = "Interact_Main"

local ON_INTERACT = "On_Interact"
--variables
--references
local Player = Players.LocalPlayer
--local functions
--class
local interactSys = {}

function interactSys.init(maid : Maid, interactFrame : Frame)
    local instancePointer = interactFrame:FindFirstChild("InstancePointer") :: ObjectValue

    local Interactables = CollectionService:GetTagged(INTERACTABLE_TAG)
    
    CollectionService:GetInstanceAddedSignal(INTERACTABLE_TAG):Connect(function(inst)
        table.insert(Interactables, inst)
    end)

    CollectionService:GetInstanceRemovedSignal(INTERACTABLE_TAG):Connect(function(inst)
        table.remove(Interactables, table.find(Interactables, inst))
    end)

    --loop to find the nearest
    do
        maid:GiveTask(RunService.Stepped:Connect(function()
            local character = Player.Character
            local camera = workspace.CurrentCamera
            if character then
                local minDist = math.huge
                local nearestInst 
                for _,v in pairs(Interactables) do
                    if v:IsA("Model") and v.PrimaryPart then
                        local _, isWithinRange = camera:WorldToScreenPoint(v.PrimaryPart.Position)
                        local dist = (camera.CFrame.Position - v.PrimaryPart.Position).Magnitude
                        if (dist <= MAXIMUM_INTERACT_DISTANCE) and (dist < minDist) and (isWithinRange) then
                            minDist = dist
                            nearestInst = v        
                        end
                    end
                end
                if nearestInst then
                    local v3,isWithinRange = camera:WorldToScreenPoint(nearestInst.PrimaryPart.Position)
                    interactFrame.Visible = isWithinRange
                    interactFrame.Position = UDim2.fromOffset(v3.X - interactFrame.AbsoluteSize.X*0.5, v3.Y - interactFrame.AbsoluteSize.Y*0.5)
                    instancePointer.Value = nearestInst
                else
                    interactFrame.Visible = false
                    instancePointer.Value = nil
                end
            end
            
        end))
    end    


    InputHandler:Map(
        INTERACT_MAIN_INPUT_KEY, 
        "Keyboard", 
        {Enum.KeyCode.E},
        "Press" ,
        function() 
            local inst = instancePointer.Value
            if inst then
                print(inst.Name, " interacted boi..")
                NetworkUtil.fireServer(ON_INTERACT, inst)
            end
            return 
        end, 
        function() 
            return 
        end
    )

    return 
end

return interactSys