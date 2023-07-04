--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--references
--variables
--local function
--class
local Seat = {}

function Seat.init(maid : Maid)
    for k, v in pairs(CollectionService:GetTagged("Seat")) do
        local seat = v :: Seat
       
        maid:GiveTask(seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local humanoid : Humanoid = seat.Occupant
            if humanoid then
                local animator = humanoid:WaitForChild("Animator") :: Animator
            
                local animationsPlaying = {}

                --print(plr.Name, " is sitting")
                local function removed()
                    for k,v in pairs(animationsPlaying) do
                        v:Stop()
                        animationsPlaying[k] = nil
                    end
                end

                for _,v in pairs(seat:GetChildren()) do
                    if v:IsA("Animation") then
                        local animation = animator:LoadAnimation(v)
                        table.insert(animationsPlaying, animation)
                        animation:Play()
                    end
                end

                if seat.Occupant ~= humanoid then
                    removed()
                end
                seat:GetPropertyChangedSignal("Occupant"):Wait()
                removed()
            end
        end))
    end
end

return Seat