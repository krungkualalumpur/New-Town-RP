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
local Elevator = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Elevator"))
local Seat = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Seat"))
local Minigame = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Minigame"))
local Vehicle = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Vehicle"))
local Speaker = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Speaker"))
local Objects = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Objects"))
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local function
local function initNightLight(maid : Maid)    
    local function turnOnOff(inst : Instance, on :boolean)
        task.wait()

        local function detectIsLight(inst : BasePart)
            local isLight = false
            for _,v in pairs(inst:GetChildren()) do
                if v:IsA("Light") then
                    isLight = true
                    break
                end
            end

            if isLight then
                inst.Material = if on then Enum.Material.Neon else Enum.Material.SmoothPlastic
            end
        end
        if inst:IsA("BasePart") then
            detectIsLight(inst)
        end

        for _,child in pairs(inst:GetDescendants()) do
            if child:IsA("Light") then 
                child.Enabled = on
            elseif child:IsA("BasePart") then 
                detectIsLight(child)            
            elseif child:IsA("Beam") then
                child.Enabled = on
            end
        end

    end

    local function checkTime(onTime : number, offTime : number)
        --[[if math.floor(Lighting.ClockTime) == onTime and not ison then
            for _,inst in pairs(CollectionService:GetTagged("NightLight")) do
                turnOnOff(inst, true)
            end
            ison = true
      end

        if math.floor(Lighting.ClockTime) == offTime and ison then
            for _,inst in pairs(CollectionService:GetTagged("NightLight")) do
                turnOnOff(inst, false)
            end
            ison = false
        end]]
        --print((Lighting.ClockTime > onTime), (Lighting.ClockTime < offTime), not ison)
        --[[if ((Lighting.ClockTime > onTime) or (Lighting.ClockTime < offTime)) and not ison then
            for _,inst in pairs(CollectionService:GetTagged("NightLight")) do
                turnOnOff(inst, true)
            end
            ison = true
        elseif ((Lighting.ClockTime <= onTime) and (Lighting.ClockTime >= offTime)) and ison then
            for _,inst in pairs(CollectionService:GetTagged("NightLight")) do
                turnOnOff(inst, false)
            end
            ison = false
        end]]
        for _,inst in pairs(CollectionService:GetTagged("NightLight")) do
            if ((Lighting.ClockTime > (inst:GetAttribute("OnTime") or onTime)) or (Lighting.ClockTime < (inst:GetAttribute("OffTime") or offTime))) then
                turnOnOff(inst, true)
            elseif ((Lighting.ClockTime <= (inst:GetAttribute("OnTime") or onTime)) and (Lighting.ClockTime >= (inst:GetAttribute("OffTime") or offTime))) then
                turnOnOff(inst, false)
            end 
        end

    end

    local intTick = tick()

    checkTime(0, 3)
    maid:GiveTask(Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if (tick() - intTick) > 1 then
            intTick = tick()
            checkTime(17.8, 3)
        end
    end))
end

--class
return {
    init = function(maid)
        print("oi??!!1")
        Objects.init(maid)
        Elevator.init(maid)
        Seat.init(maid)
        Minigame.init(maid)
        Vehicle.init(maid)
        Speaker.init(maid)

        initNightLight(maid)
    end
}