--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
--remotes
--variables
local physicsObjectUniqueModels = {};
--references
--local functions
--class
local Objects = {}
function Objects.init(maid : Maid)
    for _,object in pairs(CollectionService:GetTagged("Object")) do
        if object:GetAttribute("Class") == "Physics" then
            if object:IsA("Model") then
                if object.PrimaryPart == nil then 
                    local minMagn = 0
                    local pripart;
                    for _,v in pairs(object:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v:SetAttribute("Transparency", v.Transparency);
                            v.CanCollide = false;
                            if v.Size.Magnitude > minMagn then
                                minMagn = v.Size.Magnitude;
                                pripart = v;
                            end
                        end
                    end
                    object.PrimaryPart = pripart;
                end
                assert(object.PrimaryPart, "Unable to set primary part");
                local oriCf = object.PrimaryPart.CFrame;
    
                if physicsObjectUniqueModels[object.Name] == nil then
                    physicsObjectUniqueModels[object.Name] = object:Clone();
                end
    
                maid:GiveTask(object.PrimaryPart.Touched:Connect(function(hit : BasePart)
                    
                    local forceN = hit.AssemblyAngularVelocity.Magnitude*hit.Mass*4
                    print(`Force: {math.round(forceN)} Netwons`)
                    if forceN >= 2 and not object:GetAttribute("OnHit") then
                        object:SetAttribute("OnHit", true)
                        local model = physicsObjectUniqueModels[object.Name]:Clone()
                        for _,v in pairs(model:GetDescendants()) do
                            if v:IsA("BasePart") then v.Massless = true; v.Anchored = false; v.CanCollide = true; end
                        end
                        model:PivotTo(oriCf);
                        model.Parent = object.Parent;
    
                        for _,v in pairs(object:GetDescendants()) do
                            if v:IsA("BasePart") then v.Transparency = 1; end
                        end
                        task.wait(10)
                        model:Destroy();
                        object:SetAttribute("OnHit", false)
    
                        for _,v in pairs(object:GetDescendants()) do
                            if v:IsA("BasePart") then v.Transparency = v:GetAttribute("Transparency") or 0; end
                        end
                    end
                end))
            end
        end 
    end
end

return Objects
