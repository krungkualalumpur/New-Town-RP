--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local CustomizationList = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"):WaitForChild("CustomizationList"))
--types
type Maid = Maid.Maid
--constants
local WALK_SPEED = 6

--remotes
local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"
--variables
--references
--local functions
local function characterAdded(char : Model)
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid
    if humanoid then
        humanoid.WalkSpeed = WALK_SPEED
    end
end

local function onPlayerAdded(plr : Player)
    local char = plr.Character or plr.CharacterAdded:Wait()
    characterAdded(char)
    
    local _maid = Maid.new()
    _maid:GiveTask(plr.CharacterAdded:Connect(characterAdded))

    _maid:GiveTask(plr.Destroying:Connect(function()
        _maid:Destroy()
    end))

    CustomizationUtil.setDesc(plr, "PlayerName", plr.Name)
    CustomizationUtil.setDesc(plr, "PlayerBio", "")

    --testing char only
    --[[local testacc
    for _,v in pairs(CustomizationList) do
        if v.Class == "Accessory" then
            testacc = v
        end
    end
    
    CustomizationUtil.Customize(plr, testacc.TemplateId)]]
end

--class
local CharacterManager = {}

function CharacterManager.init(maid : Maid)
   

    for _, plr : Player in pairs(Players:GetPlayers()) do
        print("Setup char oi!")
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))


    maid:GiveTask(NetworkUtil.onServerEvent(ON_CHARACTER_APPEARANCE_RESET, function(plr : Player)
        local character = plr.Character or plr.CharacterAdded:Wait()

        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local hum_desc = game.Players:GetHumanoidDescriptionFromUserId(plr.UserId)

        if hum_desc then
            humanoid:ApplyDescription(Instance.new("HumanoidDescription"))
            humanoid:RemoveAccessories()
            humanoid:ApplyDescription(hum_desc)
        end
    end))
end

return CharacterManager