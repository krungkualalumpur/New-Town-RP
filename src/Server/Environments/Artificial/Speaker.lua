--!strict
--services
local CollectionService = game:GetService("CollectionService")
local ReplicationStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicationStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local SOUND_PART_TAG = "SoundPart"
--variables
--references
--local functions
--class
local Speaker = {}

function Speaker.init(maid : Maid)
    for _,soundPart in pairs(CollectionService:GetTagged(SOUND_PART_TAG)) do
        local songIds = {}
     

        for _,sound in pairs(soundPart:GetChildren()) do
            if sound:IsA("Sound") then
                table.insert(songIds, sound)
            end
        end

        local currentIndex = 1
              
        local function playQueue()
            local soundQueue = songIds[currentIndex]
            if not soundQueue then
                currentIndex = 1
                soundQueue = songIds[currentIndex]
            end

            soundQueue:Play()

            soundQueue.Ended:Wait()

            currentIndex += 1
            playQueue()
            return
        end

        task.spawn(playQueue)
    end
end

return Speaker