--!strict
--service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--remotes
--types
type Maid = Maid.Maid
--constants
local EVENT_LIGHT_KEY = "EventLight"
--remotes
local ON_TOP_NOTIF_CHOICE = "OnTopNotifChoice"
--variables
--references
local shop = workspace:WaitForChild("Assets"):WaitForChild("Buildings"):WaitForChild("Modern Shop")
--local function
function PlaySound(id, parent, looped : boolean, volumeOptional: number ?, maxDistance : number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = maxDistance or 50
    s.Looped = looped
    s.Parent = parent or Player:FindFirstChild("PlayerGui")
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end

local function clubEvent(period : number, building: Instance)

    
    local _maid = Maid.new()

    local flashColor1 = BrickColor.Red()
    local flashColor2 = BrickColor.Blue()

    local totalT = 0
    local lightInterval = 0.25

    local t = tick()

    local lightT = tick()

    local function onLampReset(lamp : Instance)
        if lamp:IsDescendantOf(building) then
            for _,v in pairs(lamp:GetDescendants()) do
                if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
                    v.Color = Color3.fromRGB(100,100,100)
                elseif v:IsA("Light") then
                    v.Color = Color3.fromRGB(100,100,100)
                end
            end
        end
    end

    _maid:GiveTask(RunService.Stepped:Connect(function()
        if tick() - t >= 1 then
            t = tick()

            totalT += 1
            
            if totalT >= period then
                _maid:Destroy()

                
                for _,lamp : Instance in pairs(CollectionService:GetTagged(EVENT_LIGHT_KEY)) do
                    onLampReset(lamp)
                end

                building:WaitForChild("Furnitures"):WaitForChild("Interior"):WaitForChild("Floor 2"):WaitForChild("BarSection"):WaitForChild("Stage"):WaitForChild("Dj").PrimaryPart:WaitForChild("Smoke").Enabled = false
            end
        end

        --operate
        if tick() - lightT >= lightInterval then
            lightT = tick()
            for _,lamp in pairs(CollectionService:GetTagged(EVENT_LIGHT_KEY)) do
                if lamp:IsDescendantOf(building) then
                    for _,v in pairs(lamp:GetDescendants()) do
                        if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
                            v.BrickColor = if v.BrickColor ==  flashColor1 then flashColor2 else flashColor1
                        elseif v:IsA("Light") then
                            v.Color = if v.Color ==  flashColor1.Color then flashColor2.Color else flashColor1.Color
                        end
                    end
                end
            end
        end
     end))

     building:WaitForChild("Furnitures"):WaitForChild("Interior"):WaitForChild("Floor 2"):WaitForChild("BarSection"):WaitForChild("Stage"):WaitForChild("Dj").PrimaryPart:WaitForChild("Smoke").Enabled = true
     local rand = math.random(1, 2)
    _maid:GiveTask(PlaySound(if rand == 1 then 1842613033 else 1835378016, building:WaitForChild("Furnitures"):WaitForChild("Interior"):WaitForChild("Floor 2"):WaitForChild("BarSection"):WaitForChild("Stage"):WaitForChild("Dj").PrimaryPart, true))

     NetworkUtil.fireAllClients(ON_TOP_NOTIF_CHOICE, "Wohoo, a cafe is having a disco event!", "Waypoint", building.PrimaryPart.CFrame)
end
--class
local Buildings = {}

function Buildings.init(maid : Maid)
    local clubEventDone = false

    maid:GiveTask(Lighting.Changed:Connect(function()
        if math.floor(Lighting.ClockTime) == 23 then
            if clubEventDone == false then
                clubEvent(160, shop)
                clubEventDone = true
            end
        else
            clubEventDone = false
        end
    end))

    NetworkUtil.getRemoteEvent(ON_TOP_NOTIF_CHOICE)
    return
end

return Buildings