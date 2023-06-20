--!strict
for i,v in pairs(game.ReplicatedStorage.Assets.VehicleAssets.VehicleParts:GetChildren()) do if not v:GetAttribute("KindIndex") then v:SetAttribute("KindIndex", i) end end