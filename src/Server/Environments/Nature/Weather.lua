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
local WEATHER_INTERVAL = 120*3
--remotes
local GET_WEATHER = "GetWeather"
local CLIENT_WEATHER_UPDATE = "ClientWeatherUpdate"
--variables
local WeatherList = {
    [1] = "Cloudy" :: Weather,
    [2] = "Sunny" :: Weather,
    [3] = "Rain" :: Weather
}
local rand = Random.new()
--references
local clouds = workspace.Terrain:WaitForChild("Clouds") :: Clouds
--local functions
local function playSound(soundId : number, target : Instance ?)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Parent = target
	sound.RollOffMaxDistance = 180
	sound:Play()
	sound.Volume = 1.5
	sound.Ended:Wait()
	sound:Destroy()
	return sound 
end

local function lightning()
    local originalPosition = Vector3.new(411.175, 62.476, -370.967)
    local lightingRadius = 2500
	local heightRange = 100
    local pos =  originalPosition + rand:NextUnitVector()*lightingRadius*Vector3.new(1,0,1) 
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = workspace:WaitForChild("Assets"):GetChildren()
	local raycast = workspace:Raycast(pos + Vector3.new(0, heightRange,0), Vector3.new(0, -heightRange*2,0), params)
	
    if raycast then
		
		
		local lightingPart = Instance.new("Part")
		lightingPart.CanCollide = false
        lightingPart.Anchored = true
		lightingPart.Transparency = 1
		lightingPart.Position =raycast.Position
		lightingPart.Parent = workspace

        local randNum1 = math.random(1, 2)
		local beam = Instance.new("Beam")
		beam.Texture = if randNum1 == 1 then "rbxassetid://7151778302" else "rbxassetid://13830135344" 
		beam.Parent = lightingPart
		beam.Width0 = 150
		beam.Width1 = 150
		beam.FaceCamera = true
		beam.TextureSpeed = 0
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
		beam.LightInfluence = 0
		beam.Brightness = 105
		beam.LightEmission = 1
		
		local lighting = Instance.new("PointLight")
		lighting.Shadows = true
		lighting.Brightness = math.huge
		lighting.Range = math.huge
		lighting.Parent = lightingPart
		

		local at1 = Instance.new("Attachment")
		at1.CFrame = CFrame.new()

		at1.Parent = lightingPart

		local at2 = Instance.new("Attachment")
		at2.CFrame = CFrame.new(0, rand:NextInteger(250, 500), 0)
		at2.Parent = lightingPart

		beam.Attachment0 = at1
		beam.Attachment1 = at2
		
		local randNum = math.random(1, 3)
		local soundId = if randNum == 1 then 1079408535 elseif randNum == 2 then 133426162 else 1843131597

		task.wait(0.1)
		beam.Enabled = false
		lighting.Enabled = false
		
		local fire = Instance.new("Fire")
		fire.Parent = lightingPart
        fire.Size = 0.1
    
        local sound = playSound(soundId, lightingPart)
        lightingPart:Destroy()
	end
end

local function getRandomWeather() : Weather
    return WeatherList[math.random(1,3)]
end

--class
local Weather = {}

function Weather.WeatherProcess(weather : Weather, weatherMaid : Maid)
    weatherMaid:DoCleaning()
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
        
        --lighting!
        local randNum = math.random(0, 1)
        local isThunder = if randNum == 1 then true else false
        if isThunder then
            weatherMaid:GiveTask(RunService.Stepped:Connect(function()
               
                lightning()
            end))
        end
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
    local weatherMaid = maid:GiveTask(Maid.new())
    
    local currentWeather= getRandomWeather()
    local nextWeather = getRandomWeather()
    local nextWeather2 = getRandomWeather()
        
    Weather.WeatherProcess(currentWeather :: Weather, weatherMaid)

    local intTick = tick()
    maid:GiveTask(RunService.Stepped:Connect(function()
        if tick() - intTick >= WEATHER_INTERVAL then
            intTick = tick()

            currentWeather = nextWeather 
            nextWeather = nextWeather2
            nextWeather2 = getRandomWeather() 

            Weather.WeatherProcess(currentWeather :: Weather, weatherMaid)
            
        end
    end))

    NetworkUtil.onServerInvoke(GET_WEATHER, function(plr: Player)
        return currentWeather
    end)

    NetworkUtil.getRemoteEvent(CLIENT_WEATHER_UPDATE)
    NetworkUtil.getRemoteFunction(GET_WEATHER)
end

return Weather