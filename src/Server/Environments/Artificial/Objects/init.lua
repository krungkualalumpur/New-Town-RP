--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local functions
--class
local Objects = {}
function Objects.init(maid : Maid)
    for _,object in pairs(CollectionService:GetTagged("Object")) do
        if object:GetAttribute("Class") == "Fan" then
            local fan = object

            local fanModel = fan:FindFirstChild("Fan")
            local fanPart = fanModel:GetChildren()[1]

            local static = fan:FindFirstChild("Static") :: Model ?

            if static and fanPart and fanModel then
                local pivot = static.PrimaryPart

                if pivot then
                    local attachment0 = Instance.new("Attachment")
                    attachment0.CFrame = CFrame.new(pivot.Size.X*0.5, 0,0)
                    attachment0.Parent = pivot

                    local attachment1 = Instance.new("Attachment")
                    attachment1.Parent = fanPart
                    attachment1.WorldCFrame = attachment0.WorldCFrame

                    for _,v in pairs(fanModel:GetChildren()) do
                        if v ~= fanPart then
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = fanPart
                            weld.Part1 = v
                            weld.Parent = v
                        end
                    end

                    local hingeConstraint = Instance.new("HingeConstraint")
                    hingeConstraint.Attachment0 = attachment0
                    hingeConstraint.Attachment1 = attachment1
                    hingeConstraint.ActuatorType = Enum.ActuatorType.Motor
                    hingeConstraint.MotorMaxTorque = 50
                    hingeConstraint.AngularVelocity = 4
                    hingeConstraint.Parent = pivot

                    for _,v in pairs(fanModel:GetChildren()) do
                        v.Anchored = false 
                    end
                end
            end
        elseif object:GetAttribute("Class") == "Vault" then
            local function setVisible(part : BasePart, visible : boolean)
                part.Transparency = if visible then 0 else 1
                part.CanCollide = visible
            end

            local function setVault(part : BasePart, warningPart : BasePart ?)
                maid:GiveTask(part:GetAttributeChangedSignal("IsExplosionHit"):Connect(function()
                    if part:GetAttribute("IsExplosionHit") == true then        
                        local sound : Sound 
                        if warningPart then    
                            sound = Instance.new("Sound")
                            sound.Volume = 0.2
                            sound.RollOffMaxDistance = 22
                            sound.SoundId = "rbxassetid://5533428105"
                            sound:Play()
                            
                            sound.Parent = warningPart
                        end

                        local fakePart = part:Clone()
                        fakePart.Parent = workspace
                        for _, tag in pairs(CollectionService:GetTags(fakePart)) do
                            CollectionService:RemoveTag(fakePart, tag)
                        end
                        fakePart.CanCollide = true

                        setVisible(part, false)

                        local smoke = Instance.new("Smoke")
                        smoke.Size = 10
                        smoke.Parent = fakePart

                        fakePart.Anchored = false

                        task.wait(50)

                        smoke.Enabled = false
                        task.wait(5)
                        
                        fakePart:Destroy()
                        setVisible(part, true)
                        
                        if sound then
                            sound:Destroy()
                        end
                    end
                end))
            end

            if not object:IsA("BasePart") then
                local dynamic = object:FindFirstChild("Dynamic")
                local warningPart = object:FindFirstChild("WarningPart")
                
                for _,v in pairs((dynamic or object):GetDescendants()) do
                    setVault(v, warningPart)
                end

                
            else
                setVault(object)
            end
        elseif object:GetAttribute("Class") == "Balance" then
            local detector = object:FindFirstChild("Detector")
            assert(detector, "No scale detector added!")
            
            maid:GiveTask(detector.Touched:Connect(function(hit : BasePart)
                local character = hit.Parent    
                local humanoid = if character then character:FindFirstChild("Humanoid") else nil
                local totalMass = 0

                if character and humanoid then
                    for _,v in pairs(character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            totalMass += v.Mass
                        end
                    end
                end

                for _,v in pairs(object:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        v.Text = string.format("%.4d", totalMass)
                    end
                end
            end))

            maid:GiveTask(detector.TouchEnded:Connect(function(hit : BasePart)
        
                for _,v in pairs(object:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        v.Text = string.format("%.4d", 0)
                    end
                end
                
            end))
        elseif object:GetAttribute("Class") == "BlinkingNeon" then
            if object:IsA("BasePart") then
                object.Material = Enum.Material.Metal
                local blinkingTime = object:GetAttribute("BlinkingTime") :: number or 0.1
                local blinkColor = object:GetAttribute("BlinkColor") :: boolean

                local colorOrder = 1

                local t = tick()
                maid:GiveTask(RunService.Stepped:Connect(function()
                    if tick() - t > blinkingTime then
                        t = tick()
                        if not blinkColor then
                            if object.Material == Enum.Material.Neon then
                                object.Material = Enum.Material.Metal 
                            else
                                object.Material = Enum.Material.Neon
                            end
                        else
                            local color = if colorOrder == 1 then 
                                BrickColor.White() elseif  colorOrder == 2 then 
                                BrickColor.Green() elseif colorOrder == 3 then
                                BrickColor.Blue() else nil

                            if color == nil then
                                colorOrder = 0
                                color = BrickColor.Red()
                            end
                            object.Material = Enum.Material.Neon
                            object.BrickColor = color
                            colorOrder += 1
                        end
                    end
                end))
            end
        elseif object:GetAttribute("Class") == "TextDisplay" then
            if object:GetAttribute("DisplayType") == "Slide" then
                for _,v in pairs(object:GetDescendants()) do
                    if v:IsA("GuiObject") then
                        local i = v.Size.X.Scale
                        maid:GiveTask(RunService.Stepped:Connect(function()
                            v.Position = UDim2.new(i, 0, 0,0)
                            i -= 0.015
                            if i <= -v.Size.X.Scale then
                                i = v.Size.X.Scale
                            end
                        end))
                    end
                end
            end
        elseif object:GetAttribute("Class") == "Elevator" then
            if object:IsA("BasePart") and object.Anchored == true then
                object.AssemblyLinearVelocity = Vector3.new(0,0,5*(if object:GetAttribute("DirectionUp") == true then 1 else -1))
            end
        end
    end
end
return Objects