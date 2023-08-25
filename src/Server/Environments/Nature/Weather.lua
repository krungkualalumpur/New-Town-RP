--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
export type Weather = "Cloudy" | "Sunny" | "Rain"

type Maid = Maid.Maid

--constants
local WEATHER_INTERVAL = 120
--remotes
local GET_WEATHER = "GetWeather"
local CLIENT_WEATHER_UPDATE = "ClientWeatherUpdate"
--variables
local WeatherList = {
    [1] = "Cloudy" :: Weather,
    [2] = "Sunny" :: Weather,
    [3] = "Rain" :: Weather
}

--references
local clouds = workspace.Terrain:WaitForChild("Clouds") :: Clouds
--local functions
local function getRandomWeather() : Weather
    return WeatherList[math.random(1,3)]
end

--class
local Weather = {}

function Weather.WeatherProcess(weather : Weather)
    if weather == "Cloudy" then
        local t = TweenService:Create(clouds, TweenInfo.new(WEATHER_INTERVAL - (WEATHER_INTERVAL*0.95)), {
            Density = 0.73, 
            Cover = 0.596,
            Color = Color3.fromRGB(244, 244, 244)
        })
        t:Play()
        t:Destroy()
    elseif weather == "Rain" then
        local t = TweenService:Create(clouds, TweenInfo.new(WEATHER_INTERVAL - (WEATHER_INTERVAL*0.95)), {
            Density = 0.85, 
            Cover = 0.95,
            Color = Color3.fromRGB(235, 235, 235)
        })
        t:Play()
        t:Destroy()
        
    elseif weather == "Sunny" then
        local t = TweenService:Create(clouds, TweenInfo.new(WEATHER_INTERVAL - (WEATHER_INTERVAL*0.95)), {
            Density = 0.1, 
            Cover = 0.2
        })
        t:Play()
        t:Destroy()
    end

    NetworkUtil.fireAllClients(CLIENT_WEATHER_UPDATE, weather)
end

function Weather.init(maid : Maid)
    local currentWeather= getRandomWeather()
    local nextWeather = getRandomWeather()
    local nextWeather2 = getRandomWeather()
        
    Weather.WeatherProcess(currentWeather :: Weather)

    local intTick = tick()
    maid:GiveTask(RunService.Stepped:Connect(function()
        if tick() - intTick >= WEATHER_INTERVAL then
            intTick = tick()

            currentWeather = nextWeather 
            nextWeather = nextWeather2
            nextWeather2 = getRandomWeather() 

            Weather.WeatherProcess(currentWeather :: Weather)
            
        end
    end))

    NetworkUtil.onServerInvoke(GET_WEATHER, function(plr: Player)
        return currentWeather
    end)

    NetworkUtil.getRemoteEvent(CLIENT_WEATHER_UPDATE)
end

return Weather