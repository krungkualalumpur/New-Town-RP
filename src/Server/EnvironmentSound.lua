--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))
--types
type Maid = Maid.Maid
--constants
local SOUND_VOLUME_ATTRIBUTE = "Volume"
--variables
--references
--local functions
--class
local EnvironmentSound = {}

function EnvironmentSound.init(maid : Maid)
    
    --setting all sound volume te 0
    for _,sound in pairs(SoundService:GetChildren()) do
        --setting up sounds
        if sound:IsA("Folder") or sound:IsA("Model") then
            for _,v in pairs(sound:GetChildren()) do
                if v:IsA("Sound") then
                    v:SetAttribute(SOUND_VOLUME_ATTRIBUTE, v.Volume)
                    v.Volume = 0
                end
            end
        elseif sound:IsA("Sound") then
            sound:SetAttribute(SOUND_VOLUME_ATTRIBUTE, sound.Volume)
            sound.Volume = 0
        end
    end
    
    
    for _,sound in pairs(SoundService:GetChildren()) do
        if sound:IsA("Folder") or sound:IsA("Model") then
            local songs = {}

            for _,indivSound in pairs(sound:GetChildren()) do
                if indivSound:IsA("Sound") then
                    indivSound.Looped = false
                    table.insert(songs, indivSound)
                end
            end

            local currentIndex = 1
                
            local function playQueue()
                local soundQueue = songs[currentIndex]
                if not soundQueue then
                    currentIndex = 1
                    soundQueue = songs[currentIndex]
                end

                soundQueue:Play()

                soundQueue.Ended:Wait()

                currentIndex += 1
                playQueue()
                return
            end

            task.spawn(playQueue)
        elseif sound:IsA("Sound") then
            sound.Looped = true
            sound:Play()
        end
    end
end

return EnvironmentSound