--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
local PHYSICS_REGENERATE_TIME = 14
--remotes
--variables
local physicsObjectUniqueModels = {};
--references
--local functions
function PlaySound(id, parent, volumeOptional: number ?, maxDist : number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = maxDist or 150
    s.Looped = false
    s.Parent = parent
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end
--class
local Objects = {}
function Objects.init(maid : Maid)
    for _,object in pairs(CollectionService:GetTagged("Object")) do
        if object:GetAttribute("Class") == "Physics" then
            local tempDestroyTime = 8

            if object:IsA("Model") then
                assert(object.PrimaryPart, "Unable to get primary part");
                local oriCf = object.PrimaryPart.CFrame;
    
                if physicsObjectUniqueModels[object.Name] == nil then
                    physicsObjectUniqueModels[object.Name] = object:Clone();
                end
    
                maid:GiveTask(object.PrimaryPart.Touched:Connect(function(hit : BasePart)
                    
                    local forceN = hit.AssemblyAngularVelocity.Magnitude*hit.Mass

                    if forceN >= 20 and not object:GetAttribute("OnHit") and not Players:GetPlayerFromCharacter(hit.Parent) then
                        object:SetAttribute("OnHit", true)
                        local model = physicsObjectUniqueModels[object.Name]:Clone()
                        for _,v in pairs(model:GetDescendants()) do
                            
                            if v:IsA("BasePart") then 
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = v
                                weld.Part1 = model.PrimaryPart
                                weld.Parent = model.PrimaryPart
                                v.Massless = true; v.Anchored = false; v.CanCollide = true;
                            end
                        end
                        model:PivotTo(oriCf);
                        model.Parent = object.Parent;
    
                        for _,v in pairs(object:GetDescendants()) do
                            if v:IsA("BasePart") then v.Transparency = 1; elseif v:IsA("SurfaceGui") then v.Enabled = false; end
                        end
                       
                        local s = PlaySound(9125671948, model.PrimaryPart, 1.2, 30)
                        s.PlaybackSpeed = math.random(95, 120)/100

                        local sfx
                        local vfx
                        if object.Name == "Hydrant" then
                            sfx = PlaySound(9114530859, object.PrimaryPart, 1.2, 30)  
                            vfx = Instance.new("ParticleEmitter")
                            vfx.Texture = "rbxassetid://243740013"
                            vfx.RotSpeed = NumberRange.new(0,4)
                            vfx.Speed = NumberRange.new(8,12)
                            vfx.EmissionDirection = Enum.NormalId.Top
                            vfx.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255));
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255));
                            }
                            vfx.SpreadAngle = Vector2.new(5, 5)
                            vfx.Size = NumberSequence.new{
                                NumberSequenceKeypoint.new(0, 1.69);
                                NumberSequenceKeypoint.new(1, 3.44)
                            }
                            vfx.Lifetime = NumberRange.new(6,8)
                            vfx.Acceleration = Vector3.new(0,-8,0)
                            vfx.Parent = object.PrimaryPart
                        end
                        task.wait(tempDestroyTime)
                        model:Destroy(); if sfx then sfx:Destroy() end; 
                        task.wait(PHYSICS_REGENERATE_TIME - tempDestroyTime)
                        if vfx then vfx:Destroy() end; 
                        object:SetAttribute("OnHit", false)
    
                        for _,v in pairs(object:GetDescendants()) do
                            if v:IsA("BasePart") then v.Transparency = v:GetAttribute("Transparency") or 0; elseif v:IsA("SurfaceGui") then v.Enabled = v:GetAttribute("Enabled") end
                        end
                    end
                end))
            end
        end 
    end
end

return Objects
