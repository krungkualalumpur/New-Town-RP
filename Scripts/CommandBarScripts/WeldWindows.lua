--!strict
local CollectionService = game:GetService("CollectionService")

for _,v in pairs(CollectionService:GetTagged("Window")) do
    local windowModel = v:FindFirstChild("Model")
    if windowModel then
        local mainPart = windowModel:GetChildren()[1]
        if mainPart then
            for _,v in pairs(mainPart:GetChildren()) do
                if v:IsA("WeldConstraint") then
                    v:Destroy()
                end
            end

            for _,v in pairs(windowModel:GetChildren()) do
                if v ~= mainPart and v:IsA("BasePart") then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = mainPart
                    weld.Part1 = v
                    weld.Parent = mainPart

                    for _,weld2 in pairs(v:GetChildren()) do
                        if weld2:IsA("WeldConstraint") then
                            weld2:Destroy()
                        end
                    end

                    v.Anchored = false
                end
            end
        end
    end
end
