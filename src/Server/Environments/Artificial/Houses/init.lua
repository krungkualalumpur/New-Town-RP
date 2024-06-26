--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local Analytics = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Analytics"))
--types
type Maid = Maid.Maid

export type InteractableData = {
    Class : string,
    IsSwitch : boolean ?
}
--constants
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.new(0.807843, 0.819608, 0.054902)

local MAXIMUM_INTERACT_DISTANCE = 20
--remotes
local ON_HOUSE_CLAIMED = "OnHouseClaimed"
local ON_HOUSE_LOCKED = "OnHouseLocked"

local ON_HOUSE_CHANGE_COLOR = "OnHouseChangeColor"
--variables
--references
local houses = workspace:WaitForChild("Assets"):WaitForChild("Houses")
--local functions

local function getHouseOfPlayer(plr : Player)
    for _,house in pairs(houses:GetChildren()) do
        local playerPointer = house:FindFirstChild("OwnerPointer")
        if playerPointer and playerPointer.Value == plr then
            return house
        end
    end
    return false
end

--scripts
local House = {}

function House.claim(house : Model, player : Player ?) : false ?
    local ownerPointer = house:FindFirstChild("OwnerPointer")
    if ownerPointer then
        print(ownerPointer.Value, " on claim fn 1", player)
        if ownerPointer.Value ~= nil and ownerPointer.Value == player then
            local claimsModel = house:FindFirstChild("Claims")
            local claimButton = if claimsModel then claimsModel:FindFirstChild("ClaimButton") :: Model ? else nil
            local claimerPointer = if claimButton then claimButton:WaitForChild("ClaimerPointer") :: ObjectValue else nil

            ownerPointer.Value = nil
            if claimerPointer then
                claimerPointer.Value = nil
            end
            NetworkUtil.fireClient(ON_HOUSE_CLAIMED, player)
            return
        elseif ownerPointer.Value ~= nil and ownerPointer.Value ~= player then
            if player then
                NotificationUtil.Notify(player, "House already claimed!")
            end
            return false
        end

        if player then
            for _,house in pairs(houses:GetChildren()) do
                local claimsModel = house:FindFirstChild("Claims")
                local claimButton = if claimsModel then claimsModel:FindFirstChild("ClaimButton") :: Model ? else nil
                local claimerPointer = if claimButton then claimButton:WaitForChild("ClaimerPointer") :: ObjectValue else nil

                local otherHouseOwnerPointer = house:FindFirstChild("OwnerPointer")

                if otherHouseOwnerPointer and otherHouseOwnerPointer.Value == player then
                    otherHouseOwnerPointer.Value = nil
                end

                if claimerPointer and claimerPointer.Value == player then
                    claimerPointer.Value = nil
                end
            end
        end
        print(ownerPointer.Value, " on claim fn 2", player)

        local prevOwner = ownerPointer.Value
        if player == nil and prevOwner then
            NetworkUtil.fireClient(ON_HOUSE_CLAIMED, prevOwner)
        elseif player ~= nil then
            NetworkUtil.fireClient(ON_HOUSE_CLAIMED, player, house)
            Analytics.updateDataTable(
                player, 
                "Events", 
                "Houses",
                nil,
                function()
                    return "house_claimed", house.Name
                end
            )
        end
        ownerPointer.Value = player

        print(ownerPointer.Value, " on claim fn 3", player)
    end
    return
end

function House.lockHouse(house : Model, lock : boolean)
    local ownerPointer = house:FindFirstChild("OwnerPointer")
    local plr = ownerPointer.Value
    
    house:SetAttribute("isLocked", lock)

    local doors = house:FindFirstChild("Doors")
    if doors then
        for _,doorModel in pairs(doors:GetChildren()) do
            if CollectionService:HasTag(doorModel, "Door") then
                doorModel:SetAttribute("OwnerId", if lock then plr.UserId else nil) 
            end
        end
    end
    return
end

function House.init(maid : Maid)    
    local houseIndex = 0
    for _,house in pairs(houses:GetChildren()) do
        
        local claimsModel = house:FindFirstChild("Claims")

        if claimsModel then
            --create pointer for players
            local playerPointer = Instance.new("ObjectValue")
            playerPointer.Name = "OwnerPointer"
            playerPointer.Parent = house

            local function updateHouseOwnership(plr : Player ?)
                house:SetAttribute("isLocked", true)

                local doors = house:FindFirstChild("Doors")
                local furnitures = house:FindFirstChild("Furnitures")
                local lamps = house:FindFirstChild("Lamps")
                local curtains = house:FindFirstChild("Curtains")
                local walls = house:FindFirstChild("Walls")
                local paints = if walls then walls:FindFirstChild("Paints") else nil

                if doors then
                    for _,doorModel in pairs(doors:GetChildren()) do
                        if CollectionService:HasTag(doorModel, "Door") then
                            doorModel:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                            local model = doorModel:FindFirstChild("Model")
                            if model and model:GetAttribute("IsOpened") then
                                task.spawn(function()
                                    InteractableUtil.InteractOpening(doorModel, false, plr)
                                end)
                            end
                        end
                    end
                end
                if furnitures then
                    local interiorFurnitures = furnitures:FindFirstChild("Interiors")
                    local exteriorFurnitures = furnitures:FindFirstChild("Exteriors")
                    for _,interactable in pairs(furnitures:GetChildren()) do
                        if CollectionService:HasTag(interactable, "Interactable") or CollectionService:HasTag(interactable, "ClickInteractable") then
                            interactable:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                        end
                    end

                    if interiorFurnitures then
                        for _,interactable in pairs(interiorFurnitures:GetChildren()) do
                            if CollectionService:HasTag(interactable, "Interactable") or CollectionService:HasTag(interactable, "ClickInteractable") then
                                interactable:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                            end
                        end
    
                    end
                    if exteriorFurnitures then
                        for _,interactable in pairs(exteriorFurnitures:GetChildren()) do
                            if CollectionService:HasTag(interactable, "Interactable") or CollectionService:HasTag(interactable, "ClickInteractable") then
                                interactable:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                            end
                        end
    
                    end
                    
                end
                if lamps then
                    for _,lampCircuit in pairs(lamps:GetDescendants()) do
                        if CollectionService:HasTag(lampCircuit, "ClickInteractable") or CollectionService:HasTag(lampCircuit, "Interactable") then
                            lampCircuit:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                        end
                    end
                end
                if curtains then
                    for _,curtain in pairs(curtains:GetDescendants()) do
                        if CollectionService:HasTag(curtain, "ClickInteractable") or CollectionService:HasTag(curtain, "Interactable") then
                            curtain:SetAttribute("OwnerId", if plr then plr.UserId else -1) 
                        end
                    end
                end
                if paints then
                    local intColorVal = Instance.new("Color3Value") :: Color3Value
                    intColorVal.Name = "IntColorVal"
                    for _,v in pairs(paints:GetDescendants()) do
                        if v:IsA("BasePart") then
                            intColorVal.Value = v.Color
                            break
                        end
                    end
                    intColorVal.Parent = house
                end
                
                task.spawn(function()
                    local claimButton = claimsModel:FindFirstChild("ClaimButton") :: Model ?
                    local claimerPointer = if claimButton then claimButton:WaitForChild("ClaimerPointer") :: ObjectValue else nil
                    if claimButton and claimButton.PrimaryPart and claimerPointer then
                        local billboardGui = claimButton.PrimaryPart:FindFirstChild("ClaimGUI") or Instance.new("BillboardGui")
                        billboardGui.Name = "ClaimGUI"
                        billboardGui.AlwaysOnTop = true
                        billboardGui.MaxDistance = MAXIMUM_INTERACT_DISTANCE*5
                        billboardGui.ExtentsOffsetWorldSpace = Vector3.new(0,2,0)
                        billboardGui.Size = UDim2.fromScale(4, 2)
                        billboardGui.Parent = claimButton.PrimaryPart
    
                        local textLabel = billboardGui:FindFirstChild("ClaimText") or Instance.new("TextLabel")
                        textLabel.Name = "ClaimText"
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextScaled = true
                        textLabel.TextColor3 = PRIMARY_COLOR
                        textLabel.Size = UDim2.fromScale(1, 0.6)
                        textLabel.Position = UDim2.fromScale(0, 0.98)
                        textLabel.Text = if plr then ("%s's house"):format(plr.Name) else "Claim this house!"
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.Parent = billboardGui

                        local imageLabel = billboardGui:FindFirstChild("PlayerIcon") or Instance.new("ImageLabel")
                        imageLabel.Name = "PlayerIcon"
                        imageLabel.Visible = if plr then true else false
                        imageLabel.BackgroundColor3 = SECONDARY_COLOR
                        imageLabel.BackgroundTransparency = 0
                        imageLabel.Size = UDim2.fromScale(1, 1.9)
                        imageLabel.Position = UDim2.fromScale(0, -0.98)
                        imageLabel.Image = if plr then Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420) else ""
                        imageLabel.Parent = billboardGui
                        local uiCorner =  imageLabel:FindFirstChild("UICorner") or Instance.new("UICorner")
                        uiCorner.CornerRadius = UDim.new(1,0)
                        uiCorner.Parent = imageLabel
                    end
                end)
                
            end
        
          
            updateHouseOwnership()

            local ownerMaid = maid:GiveTask(Maid.new())
            maid:GiveTask(playerPointer.Changed:Connect(function()
                ownerMaid:DoCleaning()
                local plr = playerPointer.Value :: Player?
                updateHouseOwnership(plr)
                if plr then
                    ownerMaid:GiveTask(plr.Changed:Connect(function()
                        if plr.Parent == nil then
                            ownerMaid:Destroy()
                            playerPointer.Value = nil
                        end
                    end))
                else
                    local intColorVal = house:FindFirstChild("IntColorVal") :: Color3Value
                    local walls = house:FindFirstChild("Walls")
                    local paints = walls:FindFirstChild("Paints")
                    if intColorVal and intColorVal.Value and paints then
                        for _,v in pairs(paints:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Color = intColorVal.Value
                            end
                        end
                    end
                end
            end))

            task.spawn(function()
                local claimButton = claimsModel:FindFirstChild("ClaimButton") :: Model ?
                local claimerPointer = if claimButton then claimButton:WaitForChild("ClaimerPointer") else nil
                if claimButton and claimButton.PrimaryPart and claimerPointer then
                    maid:GiveTask(claimerPointer.Changed:Connect(function()
                        local plr = claimerPointer.Value :: Player ?
                        House.claim(house, plr)
                    end))
                end
            end)
           
            --set index
            houseIndex += 1
            house:SetAttribute("Index", houseIndex)
        end
    end

    NetworkUtil.onServerInvoke(ON_HOUSE_LOCKED, function(plr : Player, lock : boolean) 
        local house = getHouseOfPlayer(plr)
        if house then
            House.lockHouse(house, lock)
        end
        return if house then house:GetAttribute("isLocked") else true
    end)

    NetworkUtil.onServerInvoke(ON_HOUSE_CHANGE_COLOR, function(plr : Player, color : Color3)
        local house = getHouseOfPlayer(plr)

        local walls = house:FindFirstChild("Walls") 
        local paints = if walls then walls:FindFirstChild("Paints") else nil

        if paints then
            for _,v in pairs(paints:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = color
                end
            end
        end

        return nil
    end)

    maid:GiveTask(NetworkUtil.onServerEvent(ON_HOUSE_CLAIMED, function(plr : Player, houseIndex : number)
        for _, house in pairs(houses:GetChildren()) do
            local currentHouseIndex = house:GetAttribute("Index")
            if currentHouseIndex == houseIndex then
                print("House_Claim1")
                local msg = House.claim(house, plr)
                if msg == false then
                    return
                end
                print("House_Claim2")
                local char = plr.Character or plr.CharacterAdded:Wait()
                local cf, size = house:GetBoundingBox()
                char:PivotTo(cf + cf.LookVector*size.Z*0.5)
                print("House_Claim3")
                break
            end
        end
    end))

    NetworkUtil.getRemoteEvent(ON_HOUSE_CLAIMED)
    NetworkUtil.getRemoteFunction(ON_HOUSE_LOCKED)
end

return House