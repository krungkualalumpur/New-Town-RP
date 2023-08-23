--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService('RunService')
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local HashUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild('HashUtil'))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
--types
type Maid = Maid.Maid
--constants
local SOUND_ZONE_TAG = "SoundZone"
local SOUND_POINTER_ATTRIBUTE = "Sound"
local SOUND_VOLUME_ATTRIBUTE = "Volume"
--variables
--references
local Player = Players.LocalPlayer
--local functions
local function adjustSound(inst : Instance, on : boolean) 
    local function changeSound(sound)
        local soundTween = game:GetService("TweenService"):Create(sound, TweenInfo.new(1), {Volume = if on then sound:GetAttribute(SOUND_VOLUME_ATTRIBUTE) else 0})
        soundTween:Play()

        task.spawn(function()
            soundTween.Completed:Wait()
            soundTween:Destroy()
        end)
    end
    if inst:IsA("Folder") or inst:IsA("Model") then
        for _,v in pairs(inst:GetChildren()) do
            if v:IsA("Sound") then
                changeSound(v)
                --local soundTween = game:GetService("TweenService"):Create(v, tweenInfo, propertyTable)
                --v.Volume = if on then v:GetAttribute(SOUND_VOLUME_ATTRIBUTE) else 0
            end
        end
    elseif inst:IsA("Sound") then
        changeSound(inst)
        --inst.Volume = if on then inst:GetAttribute(SOUND_VOLUME_ATTRIBUTE) else 0
    end
end
--class
local environmentSound = {}

function environmentSound.init(maid : Maid)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind 
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

   
    for _,sound in pairs(SoundService:GetChildren()) do
        --setting up sounds
        if sound:IsA("Folder") or sound:IsA("Model") then
            for _,v in pairs(sound:GetChildren()) do
                if v:IsA("Sound") then
                    v:SetAttribute(SOUND_VOLUME_ATTRIBUTE, v.Volume)
                end
            end
        elseif sound:IsA("Sound") then
            sound:SetAttribute(SOUND_VOLUME_ATTRIBUTE, sound.Volume)
        end
        
         --clear up all sounds
        adjustSound(sound, false)
    end

    local cam = workspace.CurrentCamera

    local getCamPosPart = function()
       
        local out = _new("Part")({
            Name = "CamFollower",
            Anchored = false,
            CanCollide = false,
            Transparency = 1, --0.5,
            Parent = workspace,
            Children = {
            }
        }) :: Part
        
        return out
    end

    local camPosPart = _Value(getCamPosPart()) 
    
    local isInSound = _Value({})

    maid:GiveTask(RunService.Stepped:Connect(function()
        local part = camPosPart:Get()
        if part then
            part.CFrame = cam.CFrame

            local isInSoundVal = {}
            for _,zonePart in pairs(CollectionService:GetTagged(SOUND_ZONE_TAG)) do
                if Zone.ItemIsInside(zonePart, part) then
                    local zoneSound = zonePart:GetAttribute(SOUND_POINTER_ATTRIBUTE) :: string
                    local sound = SoundService:FindFirstChild(zoneSound)
                    table.insert(isInSoundVal, sound)
                end
            end

            --updating table if it's different
            local prev = HashUtil.md5(HttpService:JSONEncode(isInSound:Get()))
            local next = HashUtil.md5(HttpService:JSONEncode(isInSoundVal))
            if prev ~= next then
                isInSound:Set(isInSoundVal)
            end
        end
    end))

    local strVal = _new("StringValue")({
        Value = _Computed(function(isinSound)
           
            for _,v in pairs(SoundService:GetChildren()) do
                if table.find(isinSound, v) then
                    adjustSound(v, true)
                else
                    adjustSound(v, false)
                end
            end
            return ""
        end, isInSound)
    })
    --[[local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind 
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local cam = workspace.CurrentCamera

    local getCamPosPart = function()
       
        local out = _new("Part")({
            Name = "CamFollower",
            Anchored = false,
            CanCollide = false,
            Transparency = 1,
            Parent = workspace,
            Children = {
              
            }
        }) :: Part
        
        return out
    end

    local camPosPart = _Value(getCamPosPart()) 
    
    local intTick = tick()
    
    maid:GiveTask(RunService.Stepped:Connect(function()
        
        local part = camPosPart:Get()

        if (tick() - intTick) >= 1 then
            intTick = tick()
            if part and part.Parent then
                part.CFrame = cam.CFrame
            end
        end

        if part and part.Parent == nil then
            camPosPart:Set(getCamPosPart())
        end
    end))
    --sound zones
    local zone = maid:GiveTask(Zone.new(CollectionService:GetTagged(SOUND_ZONE_TAG), nil))
    
    --clear up zone sounds
    for _,sound in pairs(SoundService:GetChildren()) do
        adjustSound(sound, 0)
    end

    --ignites sound when the player spawns insoide the zone
    for _,zonePart in pairs(CollectionService:GetTagged(SOUND_ZONE_TAG)) do
        if Zone.ItemIsInside(zonePart, camPosPart:Get() :: Part) then
            local zoneSound = zonePart:GetAttribute(SOUND_POINTER_ATTRIBUTE) :: string
            local sound = SoundService:FindFirstChild(zoneSound)
            adjustSound(sound, 1)
        end
    end

    maid:GiveTask(zone.itemEntered:Connect(function(inst : Instance, zonePart : BasePart)
        print(inst, " tempoe1")
        if inst == camPosPart:Get() then
            print("He1")
            local zoneSound = zonePart:GetAttribute(SOUND_POINTER_ATTRIBUTE) :: string
            local sound = SoundService:FindFirstChild(zoneSound)
            adjustSound(sound, 1)
        end
        return
    end))

    maid:GiveTask(zone.itemExited:Connect(function(inst : Instance, zonePart : BasePart) 
        print(inst, " tempoe1")
        if inst == camPosPart:Get() then 
            print("He2")
            local zoneSound = zonePart:GetAttribute(SOUND_POINTER_ATTRIBUTE) :: string
            local sound = SoundService:FindFirstChild(zoneSound)
            adjustSound(sound, 0)
        end
        return
    end))]]

end

return environmentSound