for _,v in pairs (game:GetService("CollectionService"):GetTagged("EnvironmentSwitch")) do 
    if v:IsA("Model") then 
        if v:FindFirstChild("SwitchButton") then
            v.SwitchButton:Destroy()
        end
        cf, s = v:GetBoundingBox() 
        local p = Instance.new("Part") 
        p.CFrame = cf 
        p.Size = s 
        p.Anchored = true 
        p.Name = "SwitchButton" 
        p:SetAttribute("noIcon", true)
        p:SetAttribute("Assignment", "Switch")

        p.Transparency = 1 
        p.Parent = v 
        game:GetService("CollectionService"):AddTag(p, "ClickButton")  
    end  
end