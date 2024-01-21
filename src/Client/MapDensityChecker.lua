--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
local Player = Players.LocalPlayer
--local functions
--class
local MapDensityChecker = {}
function MapDensityChecker.init(maid : Maid)
    if false --[[RunService:IsStudio()]] then
        local checkerMaid = Maid.new()
        local t = tick()
        maid:GiveTask(RunService.Heartbeat:Connect(function()
            if tick() - t > 10 then
                t = tick()
                
                checkerMaid:DoCleaning()
        
                local oriPos = workspace:WaitForChild("SpawnLocations"):WaitForChild("Spawn2").Position
                local overlapParams = OverlapParams.new()

                local folder = checkerMaid:GiveTask(Instance.new("Folder"))
                folder.Name = "AssetsDensityTest"
                folder.Parent = workspace

                local gap = 50
                for x = -25000/gap, 25000/gap, gap do
                    for z = -25000/gap, 25000/gap, gap do
                        local p = Instance.new("Part")
                        p.Anchored = true
                        p.Position = Vector3.new(x, if Player.Character and Player.Character.PrimaryPart then Player.Character.PrimaryPart.Position.Y else 0, z) + oriPos
                        p.CanCollide = false
                        p.Size = Vector3.new(gap, 1000, gap)
                        p.Parent = folder

                        local parts = workspace:GetPartsInPart(p, overlapParams)
                        local height = if Player.Character and Player.Character.PrimaryPart then Player.Character.PrimaryPart.Position.Y else 10              
                        p.Color = Color3.fromHSV(0, math.clamp(#parts/1000, 0, 1), 1)
                        p.Transparency = 0.5    p.Locked = true     p.Size = Vector3.new(gap, height, gap)
                        p.Position = Vector3.new(p.Position.X, (0) + height*0.5 ,p.Position.Z)
                    end
                end
            end
        end))
        
    end
    return 
end

return MapDensityChecker