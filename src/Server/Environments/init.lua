--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Artificial = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"))
local Nature = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Nature"))

local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
--types
type Maid = Maid.Maid
--constants
--local ON_INTERACT = "On_Interact"
--local ON_TOOL_INTERACT = "On_Tool_Interact"

--variables
--references
--local functions 
local function initDayNightCycle(maid : Maid)
    
    local sunriseStart = 4.5
    local sunriseEnd = 8

    local sunsetStart = 17 
    local sunsetEnd = 20

    local function getBrightnessFromClockTime(clockTime : number)
        local brightness = math.clamp(clockTime, 0, math.huge) 
        
        if clockTime > sunriseStart and clockTime < sunriseEnd then
            brightness = (sunriseEnd - sunriseStart) - (sunriseEnd - clockTime) 
        elseif clockTime > sunsetStart and clockTime < sunsetEnd then
            brightness = math.clamp((sunsetEnd - clockTime), 0.5, math.huge)
        end

        if clockTime >= sunriseEnd and clockTime <= sunsetStart then
            brightness = sunriseEnd - sunriseStart
        end
        if clockTime >= sunsetEnd or  clockTime <= sunriseStart then
            brightness = 0.5
        end

        return brightness*1.25
    end

    local function getAmbientFromClockTime(clockTime : number)
        local ambient = Color3.fromRGB(
            math.clamp(getBrightnessFromClockTime(clockTime)*(70/3), 25, math.huge), 
            math.clamp(getBrightnessFromClockTime(clockTime)*(70/3), 25, math.huge), 
            math.clamp(((getBrightnessFromClockTime(clockTime) - 2)*(70)), 25, 70)
        )


        return ambient
    end

    
    maid:GiveTask(RunService.Stepped:Connect(function()
        Lighting.ClockTime += 0.0005
        Lighting.Brightness = getBrightnessFromClockTime(Lighting.ClockTime)
        Lighting.Ambient = getAmbientFromClockTime(Lighting.ClockTime)
        Lighting.OutdoorAmbient = getAmbientFromClockTime(Lighting.ClockTime)
    end))

     --density parts
     --[[local oriPos = workspace:WaitForChild("SpawnLocations"):WaitForChild("Spawn2").Position
     local overlapParams = OverlapParams.new()

     local folder = Instance.new("Folder")
     folder.Name = "AssetsDensityTest"
     folder.Parent = workspace

     local gap = 50
     for x = -50000/gap, 50000/gap, gap do
         for z = -50000/gap, 50000/gap, gap do
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(x, -250, z) + oriPos
            p.CanCollide = false
            p.Size = Vector3.new(gap, 500, gap)
            p.Parent = folder
            
            local parts = workspace:GetPartsInPart(p, overlapParams)
            local height = 150               p.Color = Color3.fromHSV(0, math.clamp(#parts/1000, 0, 1), 1)
            p.Transparency = 0.9    p.Locked = true     p.Size = Vector3.new(gap, height, gap)
            p.Position = Vector3.new(p.Position.X, 0 + height*0.5 ,p.Position.Z)
         end
     end]]
     local assetsDensityParts = workspace:FindFirstChild("AssetsDensityTest") 
     if assetsDensityParts then
         assetsDensityParts:Destroy()
     end
end
--class
return {
    init = function(maid : Maid)
        initDayNightCycle(maid)

        Artificial.init(maid)
        Nature.init(maid)
    end
}