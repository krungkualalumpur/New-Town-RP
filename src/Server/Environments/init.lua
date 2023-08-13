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
    
    local sunriseStart = 5
    local sunriseEnd = 8

    local sunsetStart = 17 
    local sunsetEnd = 20

    local function getBrightnessFromClockTime(clockTime : number)
        local brightness = math.clamp(clockTime, 0, math.huge) 
        
        if clockTime > sunriseStart and clockTime < sunriseEnd then
            brightness = (sunriseEnd - sunriseStart) - (sunriseEnd - clockTime) 
        elseif clockTime > sunsetStart and clockTime < sunsetEnd then
            brightness = (sunsetEnd - clockTime)
        end

        if clockTime >= sunriseEnd and clockTime <= sunsetStart then
            brightness = 3
        end
        if clockTime >= sunsetEnd or  clockTime <= sunriseStart then
            brightness = 0
        end

        return brightness
    end

    local function getAmbientFromClockTime(clockTime : number)
        local ambient = Color3.fromRGB(
            math.clamp(getBrightnessFromClockTime(clockTime)*(60/3), 25, math.huge), 
            math.clamp(getBrightnessFromClockTime(clockTime)*(60/3), 25, math.huge), 
            math.clamp(((getBrightnessFromClockTime(clockTime) - 2)*(60)), 25, 60)
        )


        return ambient
    end

    
    maid:GiveTask(RunService.Stepped:Connect(function()
        Lighting.ClockTime += 0.0005
        Lighting.Brightness = getBrightnessFromClockTime(Lighting.ClockTime)
        Lighting.Ambient = getAmbientFromClockTime(Lighting.ClockTime)
        Lighting.OutdoorAmbient = getAmbientFromClockTime(Lighting.ClockTime)
    end))
end
--class
return {
    init = function(maid : Maid)
        initDayNightCycle(maid)

        Artificial.init(maid)
        Nature.init(maid)
    end
}