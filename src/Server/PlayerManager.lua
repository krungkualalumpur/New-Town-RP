--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
--modules
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))

local DatastoreManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DatastoreManager"))
local MarketplaceManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MarketplaceManager"))
local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type VehicleData = ManagerTypes.VehicleData

export type PlayerManager = ManagerTypes.PlayerManager

export type ABType = ManagerTypes.ABType
--constants
local MAX_TOOLS_COUNT = 10
local MAX_VEHICLES_COUNT = 5

local SAVE_DATA_INTERVAL = 60

local CHAT_COUNT_VALUE_NAME = "Chat Count"
--remotes
local ON_INTERACT = "On_Interact"
local ON_TOOL_INTERACT = "On_Tool_Interact"
local ON_TOOL_ACTIVATED = "OnToolActivated"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"
local ADD_BACKPACK = "AddBackpack" 

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"
local ADD_VEHICLE = "AddVehicle"
local DELETE_VEHICLE = "DeleteVehicle"

local ON_CUSTOMIZE_AVATAR_NAME = "OnCustomizeAvatarName"
local ON_CUSTOMIZE_CHAR = "OnCustomizeCharacter"
local ON_CUSTOMIZE_CHAR_COLOR = "OnCustomizeCharColor"
local ON_DELETE_CATALOG = "OnDeleteCatalog"
local GET_AVATAR_FROM_CHARACTER_DATA = "GetAvatarFromCharacterData"

local KEY_VALUE_NAME = "KeyValue"

local KEY_VALUE_ATTRIBUTE = "KeyValue"

local ON_CAMERA_SHAKE = "OnCameraShake"

--variables
local Registry = {}
--references
local CharacterSpawnLocations = workspace:WaitForChild("SpawnLocations") 
local SpawnedVehiclesParent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
--local functions
local function newVehicleData(
    itemType : ItemUtil.ItemType,
    class : string,
    isSpawned : boolean,
    name : string,
    ownerId : number
) : VehicleData
    
    return {
        Type = itemType,
        Class = class,
        IsSpawned = isSpawned,
        Name = name,
        OwnerId = ownerId,
        Key = HttpService:GenerateGUID(false)
    }
end


local function applyVehicleData(model : Instance, vehicleData : VehicleData)
    model:SetAttribute("Class", vehicleData.Class);
    model.Name = vehicleData.Name
    model:SetAttribute("OwnerId", vehicleData.OwnerId)
    
    if vehicleData.Key then
        local keyValue = model:FindFirstChild(KEY_VALUE_NAME) :: StringValue or Instance.new("StringValue")
        keyValue.Name = KEY_VALUE_NAME
        keyValue.Value = vehicleData.Key
        keyValue.Parent = model
    end

    if vehicleData.IsSpawned == false then
        model:Destroy()
    end
end

local function getVehicleData(model : Instance) : VehicleData
    local itemType : ItemUtil.ItemType =  ItemUtil.getItemTypeByName(model.Name) :: any

    local keyValue = model:FindFirstChild(KEY_VALUE_NAME) :: StringValue ?
    
    local key = if keyValue then keyValue.Value else nil

    return {
        Type = itemType,
        Class = model:GetAttribute("Class"),
        IsSpawned = model:IsDescendantOf(SpawnedVehiclesParent),
        Name = model.Name,
        Key = key or "",
        OwnerId = model:GetAttribute("OwnerId")
    }
end

local function getVehicleModelByKey(player : Player, key : string)
    for _,vehicleModel in pairs(SpawnedVehiclesParent:GetChildren()) do
        local vehicleData = getVehicleData(vehicleModel)
        print(vehicleData.Key, " : " ,key)
        if vehicleData.Key == key and (player.UserId == vehicleData.OwnerId) then
            return vehicleModel
        end
    end
    return 
end


local function createVehicleModel(vehicleData : VehicleData, cf : CFrame)
    local vehicleModel = ItemUtil.getItemFromName(vehicleData.Name):Clone()
    vehicleModel:PivotTo(cf)

    applyVehicleData(vehicleModel, vehicleData)

    vehicleModel.Parent = SpawnedVehiclesParent
    return vehicleModel
end

local function getVehicleSpawnPlot(partZones : Instance)
    local emptySpawnZone
    for _,v in pairs(partZones:GetDescendants()) do
        if v:IsA("BasePart") then
            local isEmpty = true
            for _,tP in pairs(v:GetTouchingParts()) do
                if tP:IsDescendantOf(SpawnedVehiclesParent) then
                    isEmpty = false
                    break
                end
            end
            print(isEmpty)
            if isEmpty then
                emptySpawnZone = v
                break
            end
        end
    end

    return emptySpawnZone
end

local function getRandomAB() : ABType
    local rand = math.random(0, 1)
    return if rand == 0 then "A" else "B" 
end

--class
local PlayerManager : PlayerManager = {} :: any
PlayerManager.__index = PlayerManager

function PlayerManager.new(player : Player, maid : Maid ?)
    local self : PlayerManager = setmetatable({}, PlayerManager) :: any
    self.Player = player
    self._Maid = maid or Maid.new()
    self.Backpack = {}
    self.Vehicles = {}
    self.ChatCount = 0

    self.isLoaded = false

    self.onLoadingComplete = self._Maid:GiveTask(Signal.new())

    self.ABValue = "B"

    Registry[player] = self
    MarketplaceManager.newPlayer(self._Maid, player)

    self._Maid:GiveTask(self.onLoadingComplete:Connect(function()
        self.isLoaded = true
    end)) 

    DatastoreManager.load(player, self)

    --saving
    local intTick = tick()
    self._Maid:GiveTask(RunService.Stepped:Connect(function()
        if (tick() - intTick) >= SAVE_DATA_INTERVAL then
            intTick = tick()
            DatastoreManager.save(player, self)

        end
    end))

    --hacky way to store character info
    self._Maid.CharacterModel = player.Character

    self._Maid:GiveTask(self.Player.CharacterAdded:Connect(function(char : Model)
        self._Maid.CharacterModel = char
    end))

    --setting leaderstats
    local leaderstats = Instance.new"Folder"
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = self.Player

    local chatCountVal = Instance.new"IntValue"
    chatCountVal.Name = CHAT_COUNT_VALUE_NAME
    chatCountVal.Value = self.ChatCount
    chatCountVal.Parent = leaderstats

    self._Maid:GiveTask(self.Player.Chatted:Connect(function(str : string)
        print(self.Player.Name, " chatted! string: ", str)
        self:SetChatCount(self.ChatCount + 1)
    end))

    --analytics
    MidasStateTree.Gameplay.BackpackAdded.Value(player, function()
        return #self.Backpack
    end)

    MidasStateTree.Gameplay.VehiclesAdded.Value(player, function()
        return #self.Vehicles
    end)

    MidasStateTree.Gameplay.CustomizeAvatar.Value(player, function()
        local count = 0
        local data = self:GetData()

        if data.Character.Face ~= 0 then 
            count += 1
        end
        if data.Character.Pants ~= 0 then
            count += 1
        end
        if data.Character.Shirt ~= 0 then
            count += 1
        end
        for _,v in pairs(data.Character.Accessories) do
            count += 1
        end
       
        return count
    end) 

    MidasStateTree.Others.ABValue(player, function()
        return string.byte("B")
    end)
        --testing only
    --task.spawn(function()
     --   while wait(1) do
     --       print(self:GetData())
     --   end
    --end)
    return self
end

function PlayerManager:InsertToBackpack(tool : Instance)
    if #self.Backpack >= MAX_TOOLS_COUNT then
        --notif
        NotificationUtil.Notify(self.Player, "Already has max amount of tools to have")
        print("Already has max amount of tools to have")
        return false
    end
    
    local toolData : BackpackUtil.ToolData<boolean> = BackpackUtil.getData(tool, false) :: any
    toolData.IsEquipped = false
    table.insert(self.Backpack, toolData)
    return true
end

function PlayerManager:GetBackpack(hasDisplayType : boolean, hasEquipInfo : boolean)
    local backpack = {}

    for _,v in pairs(self.Backpack) do
        local tool = BackpackUtil.getToolFromName(v.Name)
        if tool then
            local toolData : ToolData<boolean ?> = BackpackUtil.getData(tool, hasDisplayType)
            if hasEquipInfo then
                toolData.IsEquipped = v.IsEquipped
            end
            table.insert(backpack, toolData)
        end
    end

    return backpack
end

function PlayerManager:SetBackpackEquip(isEquip : boolean, toolKey : number)
    --[[local toolInfo = self.Backpack[toolKey]
    assert(toolInfo)

    toolInfo.IsEquipped = isEquip

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, self.Player, self:GetBackpack(true, true))]]

    local plr = self.Player
    local character = plr.Character or plr.CharacterAdded:Wait()

    local toolData = self.Backpack[toolKey] 
    assert(toolData, "Tool data not found in player's backpack!")
 
    toolData.IsEquipped = isEquip

    if isEquip == true then
        for k,v in pairs(self.Backpack) do
            if k ~= toolKey then
                self:SetBackpackEquip(false, k)
            end
        end

        local tool = BackpackUtil.getToolFromName(toolData.Name)
        if tool then
            if toolData.IsEquipped then
                local equippedTool = BackpackUtil.createTool(tool) :: Tool
                local _maid = Maid.new()
                    --func for the tool upon it being activated
                _maid:GiveTask(equippedTool.Activated:Connect(function()
                    local character = plr.Character or plr.CharacterAdded:Wait()
                    if character then    
                        ToolActions.onToolActivated(toolData.Class, plr, BackpackUtil.getData(tool, true))
                    end
                end))
                
                --set collision
                for _,v in pairs(equippedTool:GetDescendants()) do
                    if v:IsA("BasePart") and character.PrimaryPart then
                        v.CollisionGroup = character.PrimaryPart.CollisionGroup
                    end
                end

                --and then set the parent
                equippedTool.Parent = character
               
                _maid:GiveTask(equippedTool.Destroying:Connect(function()
                    _maid:Destroy()
                end))
            end 
        end 
    else
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == toolData.Name) then
                tool:Destroy()
            end
        end
    end

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, self.Player, self:GetBackpack(true, true))


    return
end

function PlayerManager:DeleteBackpack(toolKey : number)
    local plr = self.Player    
    self:SetBackpackEquip(false, toolKey)

    table.remove(self.Backpack, toolKey)

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plr, self:GetBackpack(true, true))

    return
end

function PlayerManager:AddVehicle(vehicleName : string)
    if #self.Vehicles >= MAX_VEHICLES_COUNT then
        --notif
        NotificationUtil.Notify(self.Player, "Already has max amount of vehicles to have")
        return false
    end
    
    local vehicleClass = ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), false).Class
    local vehicleData : VehicleData = newVehicleData("Vehicle", vehicleClass, false, vehicleName, self.Player.UserId) -- ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), true) :: any

    table.insert(self.Vehicles, vehicleData)
    return true
end

function PlayerManager:SpawnVehicle(key : number, isSpawned : boolean, vehicleName : string ?, vehicleZones : Instance ?)
    local vehicleInfo : VehicleData = self.Vehicles[key] 

    assert(vehicleInfo and (vehicleName == nil or (vehicleInfo.Name == vehicleName)), "Vehicle info not found!")
    
    local spawnPart = getVehicleSpawnPlot(vehicleZones or workspace:WaitForChild("Miscs"):WaitForChild("CarSpawns"))
    if not spawnPart then
        NotificationUtil.Notify(self.Player, "Plot already full here ah!")
    end
    
    for k,v in pairs(self.Vehicles) do
        self.Vehicles[k].IsSpawned = false
        local vehicleModel =  getVehicleModelByKey(self.Player, self.Vehicles[k].Key)
        if vehicleModel then
            applyVehicleData(vehicleModel, v)
        end
    end
    
    vehicleInfo.IsSpawned = isSpawned
    if isSpawned == true then
        local vehicleModel = createVehicleModel(vehicleInfo, spawnPart.CFrame)
        applyVehicleData(vehicleModel, vehicleInfo)
        
        self._Maid.CurrentSpawnedVehicle = vehicleModel
    else
        self._Maid.CurrentSpawnedVehicle = nil
    end

    return 
end

function PlayerManager:DeleteVehicle(key : number)
    self:SpawnVehicle(key, false)

    table.remove(self.Vehicles, key)
    return
end

function PlayerManager:SetChatCount(count : number)
    self.ChatCount = count

    local leaderstats = self.Player:WaitForChild("leaderstats")
    local chatCountVal = leaderstats:WaitForChild(CHAT_COUNT_VALUE_NAME) :: IntValue
    chatCountVal.Value = count
end

function PlayerManager:GetData()
    local char = self._Maid.CharacterModel :: Model ?

    local plrData : ManagerTypes.PlayerData = {} :: any
    plrData.Backpack = {};
    plrData.Character = CustomizationUtil.GetInfoFromCharacter(char or Players:CreateHumanoidModelFromUserId(self.Player));
    plrData.Vehicles = {};
    plrData.ChatCount = self.ChatCount

    for _,v in pairs(self.Backpack) do
        table.insert(plrData.Backpack, v.Name)
    end

    --[[if char then
        for _,v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") then    
                local accId = CustomizationUtil.getAccessoryId(v)
                if accId then table.insert(plrData.Character.Accessories, accId) else plrData.Character.hasDefaultAccessories = true end
            elseif v:IsA("Shirt") then
                plrData.Character.Shirt = tonumber(string.match(v.ShirtTemplate, "%d+")) or 0
            elseif v:IsA("Pants") then
                plrData.Character.Pants = tonumber(string.match(v.PantsTemplate, "%d+")) or 0
            end

            local face = CustomizationUtil.getFaceTextureFromChar(char)
            plrData.Character.Face = tonumber(string.match(face, "%d+")) or 0
        end

        local bundleId = CustomizationUtil.getBundleIdFromCharacter(char)
        plrData.Character.Bundle = bundleId
    end]]
    

    for _,v in pairs(self.Vehicles) do
        table.insert(plrData.Vehicles, v.Name)
    end
   -- plrData.Character.AvatarType = CustomizationUtil.getCharacterInfo(char).AvatarType :: any

    return plrData
end

function PlayerManager:SetData(plrData : ManagerTypes.PlayerData)
    table.clear(self.Backpack)
    for _,v in pairs(plrData.Backpack) do
        local tool = BackpackUtil.getToolFromName(v)
        if tool then
            self:InsertToBackpack(tool)
        end
    end

    table.clear(self.Vehicles)
    for _,v in pairs(plrData.Vehicles) do
        self:AddVehicle(v)
    end

    local char = self.Player.Character or self.Player.CharacterAdded:Wait()
    --[[if not plrData.Character.hasDefaultAccessories then
        for _,v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") then    
                v:Destroy()
            end
        end
    end]]
    CustomizationUtil.SetInfoFromCharacter(char, plrData.Character)

   --[[ for _,v in pairs(plrData.Character.Accessories) do
        CustomizationUtil.Customize(self.Player, v, Enum.AvatarItemType.Asset)
    end
    CustomizationUtil.Customize(self.Player, plrData.Character.Face, Enum.AvatarItemType.Asset)
    CustomizationUtil.Customize(self.Player, plrData.Character.Shirt, Enum.AvatarItemType.Asset)
    CustomizationUtil.Customize(self.Player, plrData.Character.Pants, Enum.AvatarItemType.Asset)
    CustomizationUtil.Customize(self.Player, plrData.Character.TShirt, Enum.AvatarItemType.Asset)
    --CustomizationUtil.setCustomeFromTemplateId(self.Player, "Face", plrData.Character.Face or 0)
    --CustomizationUtil.setCustomeFromTemplateId(self.Player, "Shirt", plrData.Character.Shirt or 0)
    --CustomizationUtil.setCustomeFromTemplateId(self.Player, "Pants", plrData.Character.Pants or 0)

     --set bundle
    CustomizationUtil.Customize(self.Player, plrData.Character.Bundle or 0, Enum.AvatarItemType.Bundle)]]

    --set chat count
    self.ChatCount = plrData.ChatCount or 0

    if not self.isLoaded then
        self.onLoadingComplete:Fire() 
    end
    return true
end

function PlayerManager:Destroy()
    Registry[self.Player] = nil
    
    self._Maid:Destroy()

    local t = self :: any
    
    for k,v in pairs(t) do
        t[k] = nil
    end

    setmetatable(self, nil)
    return nil
end

function PlayerManager.get(plr : Player)
    return Registry[plr]
end

function PlayerManager.init(maid : Maid)
    local function onCharAdded(char : Model)
        local charMaid = Maid.new()
        local humanoid = char:WaitForChild("Humanoid") :: Humanoid
        local player = Players:GetPlayerFromCharacter(char)
        
        charMaid:GiveTask(humanoid.Died:Connect(function()
            charMaid:Destroy()
            
            if player then
                local plrInfo = PlayerManager.get(player)
                local plrData = plrInfo:GetData()

                player.CharacterAdded:Wait()
                
                plrInfo:SetData(plrData)
            end
        end))

        --spawn area
        local plrInfo = PlayerManager.get(player)
        local spawnPart = CharacterSpawnLocations:WaitForChild("Spawn2") :: BasePart
        
        if spawnPart and not RunService:IsStudio() then
            char:PivotTo(spawnPart.CFrame + Vector3.new(0,5,0))
        end
    end 
    
    local function onPlayerAdded(plr : Player)
        local _maid = Maid.new()

        local plrInfo = PlayerManager.new(plr, _maid)
        print("Successfully loaded player") 
        
        local char = plr.Character or plr.CharacterAdded:Wait()
        onCharAdded(char)

        _maid:GiveTask(plr.CharacterAdded:Connect(onCharAdded))
    end

    local function onPlayerRemove(plr : Player)
        local plrInfo = PlayerManager.get(plr)

        if plrInfo and not plr:GetAttribute("IsSaving") then
            plr:SetAttribute("IsSaving", true) 
            DatastoreManager.save(plr, plrInfo)
 
            plrInfo:Destroy()
        end
    end

    for _, plr : Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))

    maid:GiveTask(Players.PlayerRemoving:Connect(function(plr : Player)
        onPlayerRemove(plr)
    end))
    game:BindToClose(function()
		for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
			onPlayerRemove(plr)
		end
	end)

    maid:GiveTask(NetworkUtil.onServerEvent(ON_INTERACT, function(plr : Player, inst : Instance)
        if inst:IsA("Model") then
            InteractableUtil.Interact(inst, plr)
        end
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(ON_TOOL_INTERACT, function(plr : Player, inst : Instance)
        if inst:IsA("Model") then
            local plrInfo = PlayerManager.get(plr)
            InteractableUtil.InteractToolGiver(plrInfo, inst, plr)
        end
    end))

    NetworkUtil.onServerInvoke(GET_PLAYER_BACKPACK, function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        return plrInfo:GetBackpack(true, true)
    end)


    NetworkUtil.onServerInvoke(EQUIP_BACKPACK, function(plr : Player, toolKey : number, toolName : string ?)
        local plrInfo = PlayerManager.get(plr)
        plrInfo:SetBackpackEquip(if toolName then true else false, toolKey)
        --[[local character = plr.Character or plr.CharacterAdded:Wait()

        for _,v in pairs(character:GetChildren()) do
            if v:IsA("Tool") then
                v:Destroy()
            end
        end

        if toolName then
            local tool = BackpackUtil.getToolFromName(toolName)
            if tool then
                local toolData = plrInfo.Backpack[toolKey]

                print(toolData.Name, toolName, toolData.IsEquipped)
                if (toolData.Name == toolName) and not toolData.IsEquipped then
                    local equippedTool = BackpackUtil.createTool(tool)
                        --func for the tool upon it being activated
                    local maid = Maid.new()
                    --maid:GiveTask(equippedTool.Activated:Connect(function()
                    --    local character = plr.Character or plr.CharacterAdded:Wait()
                    --    if character then    
                    --        ToolActions.onToolActivated(toolData.Class, plr, BackpackUtil.getData(tool, true))
                    --    end
                    --end))
                    
                    equippedTool.Parent = character
                    maid:GiveTask(equippedTool.Destroying:Connect(function()
                        plrInfo:SetBackpackEquip(false, toolKey)
                        maid:Destroy()
                    end))

                    plrInfo:SetBackpackEquip(true, toolKey) 
                end 
            end 
        end]]
        MidasEventTree.Gameplay.EquipTool.Value(plr)

        return nil
    end)
    NetworkUtil.onServerInvoke(DELETE_BACKPACK, function(plr : Player, toolKey : number, toolName : string)
        local plrInfo = PlayerManager.get(plr)
        plrInfo:DeleteBackpack(toolKey)

        NotificationUtil.Notify(plr, "You deleted " .. toolName)

        MidasEventTree.Gameplay.BackpackDeleted.Value(plr)
        return nil
    end)

    NetworkUtil.onServerInvoke(ADD_BACKPACK, function(plr : Player, toolName)
        local plrInfo = PlayerManager.get(plr)

        
        local toolModel = BackpackUtil.getToolFromName(toolName)

        if toolModel then 
            local success = plrInfo:InsertToBackpack(toolModel) 
            if success then
                NotificationUtil.Notify(plr, toolName .. " is added to your backpack")        
            end
        end

        NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plr, plrInfo:GetBackpack(true, true))

        MidasEventTree.Gameplay.BackpackAdded.Value(plr)
        
        return nil
    end)

    NetworkUtil.onServerInvoke(ADD_VEHICLE, function(plr : Player, vehicleName : string)
        local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature") )

        if not plrIsVIP then 
            MarketplaceService:PromptGamePassPurchase(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            return nil 
        end

        local plrInfo = PlayerManager.get(plr)

        local success = plrInfo:AddVehicle(vehicleName)

        if success then
            NotificationUtil.Notify(plr, "You got " .. vehicleName)
        end
        MidasEventTree.Gameplay.VehiclesAdded.Value(plr)
        return nil
    end)
    
    NetworkUtil.onServerInvoke(DELETE_VEHICLE, function(plr : Player, key : number)
        local plrInfo = PlayerManager.get(plr)

        print(key)
        plrInfo:DeleteVehicle(key)

        MidasEventTree.Gameplay.VehiclesDeleted.Value(plr) 
        return nil
    end)

    NetworkUtil.onServerInvoke(GET_PLAYER_VEHICLES, function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        local vehicleListName = {}

        for k,v in pairs(plrInfo.Vehicles) do
            vehicleListName[k] = v.Name
        end

        return vehicleListName
    end)


    NetworkUtil.onServerInvoke(ON_CUSTOMIZE_CHAR, function(plr : Player, customizationId : number, itemType : Enum.AvatarItemType)
        local info , infoType = nil, Enum.InfoType.Asset

        local s,e = pcall(function() info = MarketplaceService:GetProductInfo(customizationId, infoType) end)
        if not s and e then
            infoType = Enum.InfoType.Bundle
            s, e = pcall(function() info = MarketplaceService:GetProductInfo(customizationId, infoType) end)
            print(infoType)
        end
        if not s and e then
            warn ("unable to load the catalog info by the given id: " .. tostring(e))
            return nil
        end
        print(customizationId, " bandel nehh ", info)

        if infoType == Enum.InfoType.Bundle then
            local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))

            --if not plrIsVIP then
                --MarketplaceService:PromptGamePassPurchase(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                --return nil
            --end
            
            print(plr.Name, plrIsVIP, " vip test")
        end

        CustomizationUtil.Customize(plr, customizationId, itemType) 
        MidasEventTree.Gameplay.CustomizeAvatar.Value(plr)
        return nil
    end)

    NetworkUtil.onServerInvoke(ON_CUSTOMIZE_CHAR_COLOR, function(plr : Player, color : Color3)
        CustomizationUtil.CustomizeBodyColor(plr, color)
        return nil
    end)

    NetworkUtil.onServerInvoke(ON_DELETE_CATALOG, function(plr : Player, customizationId : number, itemType : Enum.AvatarItemType)
        CustomizationUtil.DeleteCatalog(plr, customizationId, itemType)
        return nil
    end)

    NetworkUtil.onServerInvoke(ON_CUSTOMIZE_AVATAR_NAME, function(plr : Player, descType : CustomizationUtil.DescType, descName : string)
        CustomizationUtil.setDesc(plr, descType, descName)

        MidasEventTree.Gameplay.CustomizeAvatar.Value(plr)
        return nil
    end)

    NetworkUtil.onServerEvent(GET_AVATAR_FROM_CHARACTER_DATA, function(characterData : CustomizationUtil.CharacterData)
        return CustomizationUtil.getAvatarPreviewByCharacterData(characterData)
    end)
    
    NetworkUtil.onServerEvent(ON_TOOL_ACTIVATED, function(plr : Player, toolClass : string, foodInst : Instance, toolData : BackpackUtil.ToolData<nil>)
        local plrInfo = PlayerManager.get(plr)
        ToolActions.onToolActivated(toolClass, plr, toolData, plrInfo)
    end)

    NetworkUtil.getRemoteEvent(UPDATE_PLAYER_BACKPACK)
    NetworkUtil.getRemoteFunction(GET_PLAYER_BACKPACK)
    NetworkUtil.getRemoteEvent(ON_CAMERA_SHAKE) 
end

return PlayerManager