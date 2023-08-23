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
--variables
--references
--local functions
--class
local EnvironmentSound = {}

function EnvironmentSound.init(maid : Maid)
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
            print(sound, ' eeh??')
            sound.Looped = true
            sound:Play()
        end
    end
end

return EnvironmentSound