--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))

local Buildings = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Buildings"))
local Houses = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Houses"))
local Elevator = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Elevator"))
local Seat = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Seat"))
local Minigame = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Minigame"))
local Vehicle = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Vehicle"))
local Speaker = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Speaker"))
local Objects = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Objects"))
local Harbour = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("Harbour"))
local FishingSys = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("FishingSys"))
local NPC = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Artificial"):WaitForChild("NPC"))
--types
type Maid = Maid.Maid
--constants
local LOD_ITEM_TAG = "LODItem"
local ADAPTIVE_LOD_ITEM_TAG = "AdaptiveLODItem"
--remotes
local ON_TEXT_INPUT = "OnTextInput"
--variables
--references
--local function
local function clientOptimalization()
    for _,door in pairs(CollectionService:GetTagged("Door")) do
        if door:IsA("Model") and not CollectionService:HasTag(door, ADAPTIVE_LOD_ITEM_TAG) then
            local doorPrimaryPart
            
            local doorModel = door:FindFirstChild("Model")
            if doorModel and not doorModel.PrimaryPart then
                for _,modelChild in pairs(doorModel:GetChildren()) do
                    if modelChild:IsA("BasePart") and modelChild:FindFirstChildWhichIsA("Attachment") then
                        doorPrimaryPart = modelChild :: BasePart
                        break
                    end
                end
            elseif doorModel then
                doorPrimaryPart = doorModel.PrimaryPart
            end

            if doorPrimaryPart then
                door.PrimaryPart = doorPrimaryPart
                CollectionService:AddTag(door, ADAPTIVE_LOD_ITEM_TAG)
            end

            if doorModel then
                for _,modelChild in pairs(doorModel:GetDescendants()) do
                    if modelChild:IsA("BasePart") and modelChild ~= doorPrimaryPart then
                        local weldConstraint = Instance.new("WeldConstraint")
                        weldConstraint.Part0 = modelChild
                        weldConstraint.Part1 = doorPrimaryPart
                        weldConstraint.Parent = doorPrimaryPart
                    end
                end
                
            end
        end
    end

    for _, interact in pairs(CollectionService:GetTagged("ClickInteractable")) do
        if interact:GetAttribute("Class") == "Circuit" then
            CollectionService:AddTag(interact, LOD_ITEM_TAG)
        end
    end
end

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

local function remotesInit(maid : Maid)
    maid:GiveTask(NetworkUtil.onServerEvent(ON_TEXT_INPUT, function(plr: Player, text : string)
        local char = plr.Character 
        if char then
            for _,tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolModel = tool:WaitForChild(tool.Name)
                    if toolModel then
                        local toolData = BackpackUtil.getData(toolModel, false)
                        print(toolData.Class)
                        if toolData.Class == "TextDisplay" then
                            local filteredText  = ""
                            local filteredTextResult 
                            local s, e =  pcall(function()
                                filteredTextResult =  TextService:FilterStringAsync(text, plr.UserId)
                            end)
                            if not s then warn(e) end
                            if filteredTextResult then
                                local _s, _e = pcall(function() 
                                    filteredText = filteredTextResult:GetNonChatStringForBroadcastAsync()
                                end)
                                if not _s then warn(_e) end
                            end

                            for _,v in pairs(toolModel:GetDescendants()) do
                                if v:IsA("TextLabel") then
                                    v.Text = filteredText
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end))
end

--class
return {
    init = function(maid)
        Buildings.init(maid)
        Houses.init(maid)
        Objects.init(maid)
        Elevator.init(maid)
        Seat.init(maid)
        Minigame.init(maid)
        Vehicle.init(maid)
        Speaker.init(maid)
        Harbour.init(maid)
        FishingSys.init(maid)
        NPC.init(maid)

        clientOptimalization()
        initNightLight(maid)

        remotesInit(maid)
    end
}