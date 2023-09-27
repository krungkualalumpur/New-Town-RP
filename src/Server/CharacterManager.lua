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
local CATALOG_FOLDER_NAME = "CatalogFolder"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"

local GET_AVATAR_FROM_CATALOG_INFO = "GetAvatarFromCatalogInfo"

--variables
--references
--local functions
local function getCatalogFolder()
    local catalogFolder = ReplicatedStorage:FindFirstChild(CATALOG_FOLDER_NAME) :: Folder or Instance.new("Folder")
    catalogFolder.Name = CATALOG_FOLDER_NAME
    catalogFolder.Parent = ReplicatedStorage
    return catalogFolder
end

local function paralyzeCharacter(char : Model)
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("Motor6D") then
            local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
            a0.CFrame = v.C0
            a1.CFrame = v.C1
            a0.Parent = v.Part0
            a1.Parent = v.Part1

            local ballSocketConstraint = Instance.new("BallSocketConstraint")
            ballSocketConstraint.Attachment0 = a0
            ballSocketConstraint.Attachment1 = a1
            ballSocketConstraint.Parent = v.Parent

            v:Destroy()
        end
    end

    if char.PrimaryPart then
        char.PrimaryPart.CanCollide = false
    end

    local head = char:FindFirstChild("Head") :: BasePart
    if head then
        head.CanCollide = true
    end

    return
end

local function characterAdded(char : Model)
    local charMaid = Maid.new()
    
    local humanoid = char:WaitForChild("Humanoid") :: Humanoid
    if humanoid then
        humanoid.WalkSpeed = WALK_SPEED
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.BreakJointsOnDeath = false

        charMaid:GiveTask(humanoid.Died:Connect(function()
            charMaid:Destroy()
            paralyzeCharacter(char)
        end))
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
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))


    maid:GiveTask(NetworkUtil.onServerEvent(ON_CHARACTER_APPEARANCE_RESET, function(plr : Player, isClear : boolean)
        local character = plr.Character or plr.CharacterAdded:Wait()

        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local hum_desc = game.Players:GetHumanoidDescriptionFromUserId(plr.UserId)

        if hum_desc then
            humanoid:ApplyDescription(Instance.new("HumanoidDescription"))
            humanoid:RemoveAccessories()
            humanoid:ApplyDescription(hum_desc)

            if isClear then
                for _,v in pairs(character:GetChildren()) do
                    if v:IsA("Accessory") then
                        v:Destroy()
                    elseif v:IsA("Shirt") then
                        v.ShirtTemplate = ""
                    elseif v:IsA("Pants") then
                        v.PantsTemplate = ""
                    end
                end
            end
        end
    end))

    NetworkUtil.onServerInvoke(GET_AVATAR_FROM_CATALOG_INFO, function(plr : Player, catalogId : number)
        local catalogFolder = getCatalogFolder()
        local asset = catalogFolder:FindFirstChild(tostring(catalogId)) or game:GetService("InsertService"):LoadAsset(catalogId)
        asset.Name = tostring(catalogId)
        asset.Parent = catalogFolder
        task.spawn(function()
            task.wait(5)
            asset:Destroy()
        end)
        return asset
    end)
end

return CharacterManager