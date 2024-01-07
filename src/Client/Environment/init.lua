--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local Nature = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"):WaitForChild("Nature"))
local Artificial = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environment"):WaitForChild("Artificial"))
local Rain = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Rain"))
--types
type Maid = Maid.Maid
--constants
local PART_DETECTION_TRANSPARENCY_TRESHOLD = 0.95
--remotes
local GET_WEATHER = "GetWeather"
local CLIENT_WEATHER_UPDATE = "ClientWeatherUpdate"
--variables
--references
--local functions 
local function updateWeather(weather : string)
    if weather == "Rain" then
        Rain:Enable()
    else
        Rain:Disable()
    end
end
--class
return {
    init = function(maid : Maid)
        Nature.init(maid)
        Artificial.init(maid)

        ----
        Rain:SetCollisionMode(
            Rain.CollisionMode.Function, 
            function(p)
                return (p.Transparency <= PART_DETECTION_TRANSPARENCY_TRESHOLD) and p.CanCollide
            end
        )
        ----

        do local currentWeather 
            currentWeather = NetworkUtil.invokeServer(GET_WEATHER)

            updateWeather(currentWeather)
        end


        NetworkUtil.onClientEvent(CLIENT_WEATHER_UPDATE, function(weather)
            updateWeather(weather)
        end)
       
        NetworkUtil.getRemoteFunction(GET_WEATHER)
    end
}