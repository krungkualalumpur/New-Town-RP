--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))

--local MidasEventTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasEventTree"))
--local MidasStateTree = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MidasStateTree"))
--modules
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local ChoiceActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChoiceActions"))
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local DatastoreManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DatastoreManager"))
local MarketplaceManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MarketplaceManager"))
local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
local Analytics = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Analytics"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type VehicleData = ManagerTypes.VehicleData

export type PlayerManager = ManagerTypes.PlayerManager

export type ABType = ManagerTypes.ABType
--constants
local MAX_TOOLS_COUNT = 10
local MAX_VEHICLES_COUNT = 25
local MAX_CHARACTER_SLOT = 3

local SAVE_DATA_INTERVAL = 60


local CHAT_COUNT_VALUE_NAME = "Chat Count"
local KEY_VALUE_NAME = "KeyValue"
local KEY_VALUE_ATTRIBUTE = "KeyValue"

local SOUND_NAME = "SFX"
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

local ON_CUSTOMIZE_CHAR = "OnCustomizeCharacter"
local ON_CUSTOMIZE_CHAR_COLOR = "OnCustomizeCharColor"
local ON_DELETE_CATALOG = "OnDeleteCatalog"

local GET_CHARACTER_SLOT = "GetCharacterSlot"
local SAVE_CHARACTER_SLOT = "SaveCharacterSlot"
local LOAD_CHARACTER_SLOT = "LoadCharacterSlot"
local DELETE_CHARACTER_SLOT = "DeleteCharacterSlot"

local GET_ITEM_CART = "GetItemCart"
local ON_ITEM_CART_SPAWN = "OnItemCartSpawn"

local ON_ROLEPLAY_BIO_CHANGE = "OnRoleplayBioChange"

local ON_CAMERA_SHAKE = "OnCameraShake"

local ON_NOTIF_CHOICE_INIT = "OnNotifChoiceInit"

local ON_JOB_CHANGE = "OnJobChange"

local ON_ITEM_THROW = "OnItemThrow"

local USER_INTERVAL_UPDATE = "UserIntervalUpdate"

local ON_VEHICLE_LOCKED = "OnVehicleLocked"

local SEND_FEEDBACK = "SendFeedback"

local ON_GAME_LOADING_COMPLETE = "OnGameLoadingComplete"
--variables
local Registry = {}
--references
local CharacterSpawnLocations = workspace:WaitForChild("SpawnLocations") 
local SpawnedVehiclesParent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries"):WaitForChild("Vehicles")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = workspace:WaitForChild("Assets"):GetChildren()
--local functions
local function generateSessionId(userId : number)
    local currentTimeStamp = DateTime.now().UnixTimestamp
    return tostring(math.round(currentTimeStamp)) .. tostring(userId)
end

local function playSound(soundId : number, onLoop : boolean, parent : Instance ?, volume : number ?, maxDistance : number ?)
    local sound = Instance.new("Sound")
    sound.Name = SOUND_NAME
    sound.RollOffMaxDistance = maxDistance or 30
    sound.Volume = volume or 1
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Parent = parent or (if RunService:IsClient() then Players.LocalPlayer else nil)
    sound.Looped = onLoop
    if sound.Parent then
        sound:Play()
    end
    task.spawn(function()
        sound.Ended:Wait()
        sound:Destroy()
    end)
    return sound
end

local function newVehicleData(
    itemType : ItemUtil.ItemType,
    class : string,
    isSpawned : boolean,
    name : string,
    ownerId : number,
    destroyLocked : boolean
) : VehicleData
    
    return {
        Type = itemType,
        Class = class,
        IsSpawned = isSpawned,
        Name = name,
        OwnerId = ownerId,
        Key = HttpService:GenerateGUID(false),
        DestroyLocked = destroyLocked
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
        OwnerId = model:GetAttribute("OwnerId"),
        DestroyLocked = model:GetAttribute("DestroyLocked")
    }
end

local function getVehicleModelByKey(player : Player, key : string)
    for _,vehicleModel in pairs(SpawnedVehiclesParent:GetChildren()) do
        local vehicleData = getVehicleData(vehicleModel)
        --print(vehicleData.Key, " : " ,key)
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
           -- print(isEmpty)
            if isEmpty then
                emptySpawnZone = v
                break
            end
        end
    end

    return emptySpawnZone
end

local function lockVehicle(vehicleModel : Model, lock : boolean)
    local vehicleData = getVehicleData(vehicleModel)
    vehicleModel:SetAttribute("isLocked", lock)

    playSound(138111999, false, vehicleModel.PrimaryPart, nil, 75)
end

local function setToolEquip(inst : Tool, char : Model)
    
    --set collision
    for _,v in pairs(inst:GetDescendants()) do
        if v:IsA("BasePart") and char.PrimaryPart then
            v.CollisionGroup = char.PrimaryPart.CollisionGroup
        end
    end
end

local function getRandomAB() : ABType
    local rand = math.random(0, 1)
    return if rand == 0 then "A" else "B" 
end

local function backpackRefresh(char : Model, backpack : {[number] : BackpackUtil.ToolData<any>}, plrInfo : ManagerTypes.PlayerManager)
    local plr = Players:GetPlayerFromCharacter(char)
    assert(plr, " Player not found upon refreshing tool!")
    for _,v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then
            v:Destroy()
        end
    end
    for _,v in pairs(plr:WaitForChild("Backpack"):GetChildren()) do
        if v:IsA("Tool") then
            v:Destroy()
        end
    end

    for key,toolData in pairs(backpack) do
        local toolVanilla = BackpackUtil.getToolFromName(toolData.Name)
        assert(toolVanilla, "Tool not found!")
        local clonedTool = BackpackUtil.createTool(toolVanilla) :: Tool
        clonedTool:SetAttribute("ToolKey", key)
        clonedTool.Parent = if toolData.IsEquipped then char else plr.Backpack

        setToolEquip(clonedTool, char)

        local _maid = Maid.new()
        _maid:GiveTask(clonedTool.Activated:Connect(function()
            local character = plr.Character or plr.CharacterAdded:Wait()
            if character then    
                ToolActions.onToolActivated(toolData.Class, plr, BackpackUtil.getData(toolVanilla, true), plrInfo)
            end
        end))
    end
end

--class
local PlayerManager : PlayerManager = {} :: any
PlayerManager.__index = PlayerManager

function PlayerManager.new(player : Player, maid : Maid ?)
    local currentSessionId = generateSessionId(player.UserId)

    local self : PlayerManager = setmetatable({}, PlayerManager) :: any
    self.Player = player
    self._Maid = maid or Maid.new()
    self.RoleplayBios = {
        Name = player.Name,
        Bio = ""
    }
    self.Backpack = {}
    self.Vehicles = {}
    self.ChatCount = 0
    self.CharacterSaves = {}
    self.Framerate = nil

    self.isLoaded = false

    self.onLoadingComplete = self._Maid:GiveTask(Signal.new())

    self.ABValue = "B"

    Registry[player] = self
    
    local dataStoreManager = DatastoreManager.new(self.Player, self)

    MarketplaceManager.newPlayer(self._Maid, player)

    self._Maid:GiveTask(self.onLoadingComplete:Connect(function(characterLoadSuccess : boolean)
        self.isLoaded = true
        if not characterLoadSuccess then
            --loads vanilla
            self:AddVehicle("Motorcycle", true)
            self:AddVehicle("Bajaj", true)
            self:AddVehicle("Taxi", true)
            self:AddVehicle("Muntjac", true)
            self:AddVehicle("Avalon", true)
            self:AddVehicle("Rav", true)
            self:AddVehicle("Mersi", true)
            self:AddVehicle("Pickup", true)
            self:AddVehicle("Ambulance", true)
            self:AddVehicle("SWAT Car", true)
            self:AddVehicle("Police", true)
            self:AddVehicle("Firetruck", true)

            --character loading
            self:SetData(self:GetData(), false)
        end
    end)) 

    dataStoreManager:LoadSave()
    

    --saving
    local intTick = tick()
    self._Maid:GiveTask(RunService.Stepped:Connect(function()
        if (tick() - intTick) >= SAVE_DATA_INTERVAL then
            intTick = tick()
            dataStoreManager:Save()            
        end
    end))

    --testing only
    if RunService:IsStudio() then
        local testTick = tick()
        self._Maid:GiveTask(RunService.Stepped:Connect(function()
            if (tick() - testTick) >= 1 then
                local firstSession = dataStoreManager.SessionIds[1]
                local firstSessionQuitTime = firstSession.QuitTime
                local currentSession = dataStoreManager.CurrentSessionData
                testTick = tick()
                local currentTimeStamp = DateTime.now().UnixTimestamp
                local is_retained_on_d0 = if self then (if firstSession ~= currentSession and firstSessionQuitTime and (currentTimeStamp - firstSessionQuitTime) <= 60*60*24*1 then true else false) else false
                local is_retained_on_d1 = if self then (if firstSession ~= currentSession and firstSessionQuitTime and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*1) and  (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(1 + 1))) then true else false) else false
                local is_retained_on_d7 = if self then (if firstSession ~= currentSession and firstSessionQuitTime and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*7) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(7 + 1))) then true else false) else false
                local is_retained_on_d14 = if self then (if firstSession ~= currentSession and firstSessionQuitTime and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*14) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(14 + 1))) then true else false) else false
                local is_retained_on_d28 = if self then (if firstSession ~= currentSession and firstSessionQuitTime and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*28) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(28 + 1))) then true else false) else false
            
                
                print(firstSessionQuitTime, " : first visit time stapmp\n", "d0: ", tostring(is_retained_on_d0) .. "\n", "d1: " .. tostring(is_retained_on_d1) .. "\n", "d7: " .. tostring(is_retained_on_d7))
                print("Session ID: ", dataStoreManager.SessionIds)
            end
        end))
    end

    --self:SetData(self:GetData(), false)
    --hacky way to store character info
    self._Maid.CharacterModel = player.Character

    self._Maid:GiveTask(self.Player.CharacterAdded:Connect(function(char : Model)
        self._Maid.CharacterModel = char

       -- local humanoid = char:WaitForChild("Humanoid") :: Humanoid
        --print(humanoid, humanoid:IsDescendantOf(game), humanoid:IsDescendantOf(workspace))
        --humanoid:ApplyDescription(Instance.new("HumanoidDescription"))
        --self:SetData(self:GetData(), false) -- refreshing the character (overriden by the other refershing char one)
    end))

    player:SetAttribute("SessionId", currentSessionId)

    --setting leaderstats
    local leaderstats = Instance.new"Folder"
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = self.Player

    --[[local chatCountVal = Instance.new"IntValue"
    chatCountVal.Name = CHAT_COUNT_VALUE_NAME
    chatCountVal.Value = self.ChatCount
    chatCountVal.Parent = leaderstats]]

    self._Maid:GiveTask(self.Player.Chatted:Connect(function(str : string)
        self:SetChatCount(self.ChatCount + 1)

        Analytics.updateDataTable(self.Player, "Events", "Miscs", self, function()
            return "Player_Chatted", str
        end)
    end))

    --analytics
    --[[MidasStateTree.Gameplay.BackpackAdded.Value(player, function()
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

    MidasStateTree.Gameplay.AvatarSaved.Value(player, function()
        return #self.CharacterSaves 
    end)]]

   --[[ MidasStateTree.Others.ABValue(player, function()
        return string.byte("B")
    end)]]
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

    Analytics.updateDataTable(
        self.Player, 
        "Events", 
        "Backpack", 
        self,  
        function() return "Backpack_Insertion", toolData.Name end
    )

    local char = self.Player.Character
    if char then
        backpackRefresh(char, self.Backpack, self)
    end
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
    if toolData == nil then
        return
    end
    assert(toolData, "Tool data not found in player's backpack!")
 
    toolData.IsEquipped = isEquip

    if isEquip == true then
        for k,v in pairs(self.Backpack) do
            if k ~= toolKey then
                self:SetBackpackEquip(false, k)
            end
        end

        --[[local tool = BackpackUtil.getToolFromName(toolData.Name)
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

                if character.PrimaryPart then
                    equippedTool:PivotTo(character.PrimaryPart.CFrame)
                end
                --and then set the parent
                equippedTool.Parent = character
               
                _maid:GiveTask(equippedTool.Destroying:Connect(function()
                    _maid:Destroy()
                end))
            end 
        end ]]
    else
        
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == toolData.Name) and (tool:GetAttribute("ToolKey") == toolKey) then
                tool:Destroy()
            end
        end
    end

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, self.Player, self:GetBackpack(true, true))

    Analytics.updateDataTable(
        self.Player, 
        "Events", 
        "Backpack", 
        self,  
        function() return "Backpack_Equip", toolData.Name end
    )
    return
end

function PlayerManager:DeleteBackpack(toolKey : number)
    local toolName = self.Backpack[toolKey].Name
    
    local plr = self.Player    
    self:SetBackpackEquip(false, toolKey)

    table.remove(self.Backpack, toolKey)

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plr, self:GetBackpack(true, true))

    Analytics.updateDataTable(
        self.Player, 
        "Events", 
        "Backpack", 
        self,  
        function() return "Backpack_Delete", toolName end
    )

    local char = self.Player.Character
    if char then
        backpackRefresh(char, self.Backpack, self)
    end
    return
end

function PlayerManager:AddVehicle(vehicleName : string, isLocked : boolean)
    --print(#self.Vehicles, " eh?")
    --print("debug: ", debug.traceback("when vehicle spawn"))
    if #self.Vehicles >= MAX_VEHICLES_COUNT then
        --notif
        --print("debug: ", debug.traceback("when vehicle spawn"))
        
        NotificationUtil.Notify(self.Player, "Already has max amount of vehicles to have")
        return false
    end
    
    local vehicleClass = ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), false).Class
    local vehicleData : VehicleData = newVehicleData("Vehicle", vehicleClass, false, vehicleName, self.Player.UserId, isLocked) -- ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), true) :: any
   -- print(vehicleData.DestroyLocked, vehicleData.Name, " Why u not lock ah/?!?!", isLocked)
    table.insert(self.Vehicles, vehicleData)
    
    if not isLocked then
        Analytics.updateDataTable(
            self.Player, 
            "Events", 
            "Vehicles", 
            self,  
            function() return "Vehicle_Added", vehicleData.Name end
        )
    end
    return true
end

function PlayerManager:SpawnVehicle(key : number, isSpawned : boolean, vehicleName : string ?, vehicleZones : Instance ?)
    local vehicleInfo : VehicleData = self.Vehicles[key] 

    assert(vehicleInfo and (vehicleName == nil or (vehicleInfo.Name == vehicleName)), "Vehicle info not found!")
    
    local spawnPart = if vehicleZones then getVehicleSpawnPlot(vehicleZones) else nil
    if vehicleZones then
        if not spawnPart then
            NotificationUtil.Notify(self.Player, "Plot already full here!")
        end
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
        local char = self.Player.Character or self.Player.CharacterAdded:Wait()
        local cf = if spawnPart then spawnPart.CFrame elseif char.PrimaryPart then (char.PrimaryPart.CFrame + char.PrimaryPart.CFrame.LookVector*5) else nil
        assert(cf)
        local vehicleModel = createVehicleModel(vehicleInfo, cf)

        applyVehicleData(vehicleModel, vehicleInfo)
        
        self._Maid.CurrentSpawnedVehicle = vehicleModel

        local vehicleMaid = Maid.new()
        
        local vehicleSeat = vehicleModel:FindFirstChildWhichIsA("VehicleSeat") :: VehicleSeat
        local currentOccupant
        if vehicleSeat then
            vehicleMaid:GiveTask(vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                currentOccupant = vehicleSeat.Occupant 
            end))
        end

        vehicleMaid:GiveTask(vehicleModel.Destroying:Connect(function()
            if currentOccupant then
                currentOccupant.Sit = false
            end
            vehicleMaid:Destroy()
        end))

         --check if it overlaps
         local overlapParams = OverlapParams.new()
         overlapParams.FilterType = Enum.RaycastFilterType.Include
         overlapParams.FilterDescendantsInstances = {
            workspace:WaitForChild("Assets"):WaitForChild("Buildings"):GetChildren(), 
            workspace:WaitForChild("Assets"):WaitForChild("Environment"):GetChildren(),
            workspace:WaitForChild("Assets"):WaitForChild("Houses"):GetChildren(),
            workspace:WaitForChild("Assets"):WaitForChild("Shops"):GetChildren()
        }

         local parts = workspace:GetPartBoundsInBox(cf, vehicleModel:GetExtentsSize(), overlapParams)
         if #parts > 0 then
            --self:SpawnVehicle(key, false)
            --NotificationUtil.Notify(self.Player, "Can not spawn vehicles inside a building!")
            --return
         end

        lockVehicle(vehicleModel, false)
    else
        self._Maid.CurrentSpawnedVehicle = nil
    end

    Analytics.updateDataTable(
        self.Player, 
        "Events", 
        "Vehicles", 
        self,  
        function() return "Vehicle_Spawned", vehicleInfo.Name end
    )
    return 
end

function PlayerManager:DeleteVehicle(key : number)
    local vehicleName = self.Vehicles[key].Name

    self:SpawnVehicle(key, false)

    table.remove(self.Vehicles, key)

    Analytics.updateDataTable(
        self.Player, 
        "Events", 
        "Vehicles", 
        self,  
        function() return "Vehicle_Delete", vehicleName end
    )
    return
end

function PlayerManager:SetChatCount(count : number)
    self.ChatCount = count

    --local leaderstats = self.Player:WaitForChild("leaderstats")
    --local chatCountVal = leaderstats:WaitForChild(CHAT_COUNT_VALUE_NAME) :: IntValue
    --chatCountVal.Value = count
end

function PlayerManager:GetData()
    local char =(self._Maid.CharacterModel or Players:CreateHumanoidModelFromUserId(self.Player.UserId)) :: Model
    assert(char, "Unable to load character")
    local characterData = CustomizationUtil.GetInfoFromCharacter(char)

    local plrData : ManagerTypes.PlayerData = {} :: any
    
    local currentTimeStamp = DateTime.now().UnixTimestamp

    plrData.RoleplayBios = {} :: any
    plrData.RoleplayBios.Name = self.RoleplayBios.Name
    plrData.RoleplayBios.Bio = self.RoleplayBios.Bio
    --print(self, " banyak buanget", self.CharacterSaves)
    plrData.Backpack = {};
    plrData.Character = characterData;
    plrData.CharacterSaves = table.clone(self.CharacterSaves)
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
        table.insert(plrData.Vehicles, v)
    end
   -- plrData.Character.AvatarType = CustomizationUtil.getCharacterInfo(char).AvatarType :: any

    return plrData
end

function PlayerManager:SetData(plrData : ManagerTypes.PlayerData, isYield : boolean)
    --(debug.traceback("Debugging setdata method"))
    table.clear(self.Backpack)
    for _,v in pairs(plrData.Backpack) do
        local tool = BackpackUtil.getToolFromName(v)
        if tool then
            self:InsertToBackpack(tool)
        end
    end

    table.clear(self.Vehicles)
    for k,v in pairs(plrData.Vehicles) do
        self:AddVehicle(v.Name, v.DestroyLocked) 
    end
    --print(self.Vehicles)

    --[[if not plrData.Character.hasDefaultAccessories then
        for _,v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") then    
                v:Destroy()
            end
        end
    end]]
    self.CharacterSaves = plrData.CharacterSaves

    local char = self.Player.Character or self.Player.CharacterAdded:Wait() :: Model
    if char then
        if isYield then
            if not char:IsDescendantOf(workspace) then
                char.AncestryChanged:Wait()
            end
            CustomizationUtil.SetInfoFromCharacter(char, plrData.Character)
        else
            task.spawn(function() 
                if not char:IsDescendantOf(workspace) then
                    char.AncestryChanged:Wait()
                end
                CustomizationUtil.SetInfoFromCharacter(char, plrData.Character) 
            end)
        end
    end

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
    --self:SetChatCount(plrData.ChatCount or 0)
    --bios
    self.RoleplayBios.Name = plrData.RoleplayBios.Name
    self.RoleplayBios.Bio = plrData.RoleplayBios.Bio
    --desc
    CustomizationUtil.setDesc(self.Player, "PlayerName", self.RoleplayBios.Name)
    CustomizationUtil.setDesc(self.Player, "PlayerBio", self.RoleplayBios.Bio)
    if not self.isLoaded then
        self.onLoadingComplete:Fire(true)
    end

    return true
end

function PlayerManager:SaveCharacterSlot(characterData : CustomizationUtil.CharacterData ?)
    if #self.CharacterSaves >= MAX_CHARACTER_SLOT then
        NotificationUtil.Notify(self.Player, "You reached maximum amount of character saves!")
        return self.CharacterSaves
    end
    
    local char = self._Maid.CharacterModel
    if char then
        table.insert(self.CharacterSaves,  characterData or table.clone(CustomizationUtil.GetInfoFromCharacter(char)))
    end

   -- MidasEventTree.Gameplay.AvatarSaved.Value(self.Player)
    return self.CharacterSaves
end

function PlayerManager:LoadCharacterSlot(characterDataKey : number)
    local data = self:GetData()
    data.Character = self.CharacterSaves[characterDataKey]
    self:SetData(data, true)
    return self.CharacterSaves
end

function PlayerManager:DeleteCharacterSlot(characterDataKey : number)
    table.remove(self.CharacterSaves, characterDataKey)
    return self.CharacterSaves
end

function PlayerManager:ThrowItem(toolData : ToolData<nil>)
    local rawTool = BackpackUtil.getToolFromName(toolData.Name)
    local plr = self.Player
    local char =  plr.Character

    if rawTool and char and char.PrimaryPart then
        local pos = char.PrimaryPart.Position + char.PrimaryPart.CFrame.LookVector*5 -- temporary
        local raycastResult = workspace:Raycast(pos, Vector3.new(0,-100,0), raycastParams)
    
        if not raycastResult then NotificationUtil.Notify(self.Player, "Place not suitable to throw the item"); return end
    
        local tool = rawTool:Clone() :: Tool
        if self._Maid.ThrownTool1 == nil then
            self._Maid.ThrownTool1 = tool
        elseif self._Maid.ThrownTool2 == nil then
            self._Maid.ThrownTool2 = tool
        elseif self._Maid.ThrownTool3 == nil then
            self._Maid.ThrownTool3 = tool
        elseif self._Maid.ThrownTool4 == nil then
            self._Maid.ThrownTool4 = tool
        else
            NotificationUtil.Notify(self.Player, "Cooling down, please wait!")
            tool:Destroy()
        end
 
        tool:PivotTo(CFrame.new(raycastResult.Position + Vector3.new(0, (if tool:IsA("Model") then tool:GetExtentsSize().Y elseif tool:IsA("BasePart") then tool.Size.Y else 0)*0.5, 0))*(char.PrimaryPart.CFrame - char.PrimaryPart.CFrame.Position))
        tool.Parent = workspace:WaitForChild("Assets")
        tool:SetAttribute("DeleteAfterInteract", true)
    
        for _,v in pairs(tool:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = true
            end
        end

        for k,v in pairs(self.Backpack) do
            if (v.Name == toolData.Name) and (v.IsEquipped) then
                self:DeleteBackpack(k)
                break
            end
        end

        local toolCoolDownTime = 25
        local coolDownTime = 0
        local t = tick() 
        local conn
        conn = RunService.Stepped:Connect(function()
            if self._Maid == nil then
                conn:Disconnect()
                return
            end
            if tick() - t >= 1 then
                t = tick()
                coolDownTime += 1

                if coolDownTime >= toolCoolDownTime then
                    conn:Disconnect()

                    if self._Maid.ThrownTool1 == tool then
                        self._Maid.ThrownTool1 = nil
                    elseif self._Maid.ThrownTool2 == tool then
                        self._Maid.ThrownTool2 = nil
                    elseif self._Maid.ThrownTool3 == tool then
                        self._Maid.ThrownTool3 = nil
                    elseif self._Maid.ThrownTool4 == tool then
                        self._Maid.ThrownTool4 = nil
                    end
                end
            end 
        end)

    end
    return
end

function PlayerManager:GetItemsCart(selectedItems : {[number] : BackpackUtil.ToolData<boolean>}, cf : CFrame)
    if #selectedItems > 5 then
        NotificationUtil.Notify(self.Player, "You an only have maximum 5 amount of items in the cart!")
        return 
    end
    
    local char = self.Player.Character or self.Player.CharacterAdded:Wait()
    assert(char.PrimaryPart)
    local cart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("RoleplayTools"):WaitForChild("Cart"):Clone() :: Model
    local zone = cart:FindFirstChild("Zone") :: BasePart ?
    local itemsDisplayParent = cart:FindFirstChild("Items") :: Folder ?
  
    self._Maid.ItemsCart = cart
    --raycast
    local pos = char.PrimaryPart.Position + char.PrimaryPart.CFrame.LookVector*5 -- temporary
    local raycastResult = workspace:Raycast(pos, Vector3.new(0,-100,0), raycastParams)

    if not raycastResult then NotificationUtil.Notify(self.Player, "Place not suitable to put the cart"); return end

    cart:PivotTo(CFrame.new(raycastResult.Position + Vector3.new(0, cart:GetExtentsSize().Y*0.5, 0))*(char.PrimaryPart.CFrame - char.PrimaryPart.CFrame.Position))
    cart.Parent = workspace:WaitForChild("Assets")
    
    for _,v in pairs(selectedItems) do
        
        local oriTool = BackpackUtil.getToolFromName(v.Name)
        local tool = if oriTool then oriTool:Clone() else nil

        if tool then
            local toolAsset = tool:GetChildren()[1]

            if zone and itemsDisplayParent then
                assert(toolAsset, "Tool model not found")
                --manipulate the cframe to make it look like it is stacked 
                local height = 0
                for _,v in pairs(itemsDisplayParent:GetChildren()) do
                    if v:IsA("Model") then
                        height += v:GetExtentsSize().Y 
                    elseif v:IsA("BasePart") then
                        height += v.Size.Y  
                    end
                end

                height += (if toolAsset:IsA("Model") then toolAsset:GetExtentsSize().Y*0.5 elseif toolAsset:IsA("BasePart") then toolAsset.Size.Y*0.5 else 0)

                local modelCf = zone.CFrame + Vector3.new(0, height - zone.Size.Y*0.5, 0) 

                if toolAsset:IsA("BasePart") or toolAsset:IsA("Model") then
                    toolAsset:PivotTo(modelCf) 
                    if toolAsset:IsA("BasePart") then
                        toolAsset.Anchored = true
                        toolAsset.Parent = itemsDisplayParent
                    elseif toolAsset:IsA("Model") then
                        toolAsset.Parent = itemsDisplayParent
                        for _,v in pairs(toolAsset:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Anchored = true
                            end
                        end
                    end
                end
            end

            tool:Destroy()
        end
    end

    local itemList = Instance.new("Folder")
    itemList.Name = "ItemList"
    itemList:SetAttribute("ListName", self.Player.Name .. "'s cart")
    itemList.Parent = cart

    for _,v in pairs(selectedItems) do
        local strValue = Instance.new("StringValue")
        strValue.Name = v.Name
        strValue.Value = ""
        strValue.Parent = itemList
    end

    CollectionService:AddTag(cart, "Interactable")
    cart:SetAttribute("Class", "ItemOptionsUI")

    return 
end

function PlayerManager:RemoveExistingItemsCart()
    self._Maid.ItemsCart = nil
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
   
    NetworkUtil.getRemoteFunction(GET_PLAYER_BACKPACK)
    NetworkUtil.getRemoteFunction(ON_NOTIF_CHOICE_INIT)
    NetworkUtil.getRemoteEvent(UPDATE_PLAYER_BACKPACK)
    NetworkUtil.getRemoteEvent(ON_CAMERA_SHAKE) 

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
                
                plrInfo:SetData(plrData, false)
            end
        end))


        --spawn area
        local plrInfo = PlayerManager.get(player)
        local spawnPart = CharacterSpawnLocations:WaitForChild("Spawn2") :: BasePart
        
        if spawnPart and not RunService:IsStudio() then
            char:PivotTo(spawnPart.CFrame + Vector3.new(0,5,0))
        end

        --character added
        charMaid:GiveTask(char.ChildAdded:Connect(function(inst : Instance)
            --print(inst:IsA("BasePart"), inst.Name == "Head", inst)
            if inst:IsA("BasePart") and inst.Name == "Head" then
                CustomizationUtil.setDesc(player, "PlayerName", player:GetAttribute("PlayerName") or player.Name)
                CustomizationUtil.setDesc(player, "PlayerBio", player:GetAttribute("PlayerBio") or "")
                Jobs.setJob(player, Jobs.getJob(player))
            end
        end))

       
        --tool update
        charMaid:GiveTask(char.ChildAdded:Connect(function(inst : Instance)
            local toolKey = inst:GetAttribute("ToolKey")
            if inst:GetAttribute("ToolKey") and plrInfo.Backpack[toolKey] and inst:IsA("Tool") then
                --print(plrInfo.Backpack, inst:GetAttribute("ToolKey"), " kok bisa not found yo.?")
                plrInfo:SetBackpackEquip(true, toolKey)
                NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, player, plrInfo:GetBackpack(true, true))
                setToolEquip(inst :: Tool, char)
            elseif inst:IsA("Tool") then
                inst:Destroy()
            end
        end))


        charMaid:GiveTask(char.ChildRemoved:Connect(function(inst : Instance)
            if char.Parent then
                local toolKey = inst:GetAttribute("ToolKey")
                if inst:IsA("Tool") and toolKey then
                    plrInfo:SetBackpackEquip(false, toolKey)
                    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, player, plrInfo:GetBackpack(true, true))
                end
            end
        end))

       
        
        backpackRefresh(char, plrInfo.Backpack, plrInfo)

   
    end 
    
    local function onPlayerAdded(plr : Player)
        local _maid = Maid.new()

        local plrInfo = PlayerManager.new(plr, _maid)
        print("Successfully loaded player") 
        
        local char = plr.Character or plr.CharacterAdded:Wait()
        onCharAdded(char)

        _maid:GiveTask(plr.CharacterAdded:Connect(onCharAdded))

        Analytics.updateDataTable(plr, "User", "Session", plrInfo)

        ChoiceActions.requestEvent(plr, "Default", "Welcome to the New Town", "Try our new outfit catalog feature and immerse yourself in this tropical city. The playground is yours.", true)            
       --NetworkUtil.invokeClient(ON_NOTIF_CHOICE_INIT, plr, "msg : string", true, "Test")
    end

    local function onPlayerRemove(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        if plrInfo and not plr:GetAttribute("IsSaving") then
            plr:SetAttribute("IsSaving", true) 

            local datastoreManager = DatastoreManager.get(plr)

            datastoreManager.CurrentSessionData.QuitTime = DateTime.now().UnixTimestamp

            Analytics.updateDataTable(plr, "User", "Session", plrInfo)

            local s, e = pcall(function()
                local session = Midas:GetDataSet("User")
                session:Post(50, 400, 1, false)    
            end)

            if not s and e then
                warn(e)
                Analytics.updateDataTable(plr, "Debugs", "Error", plrInfo, function()
                    return e
                end)
            end

            --datastoreManager:Save()
 
            print("Saving & Destroying" , plr.Name , "'s data")
            datastoreManager:Save()
            datastoreManager:Destroy()
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
       -- MidasEventTree.Gameplay.EquipTool.Value(plr)

        return nil
    end)
    NetworkUtil.onServerInvoke(DELETE_BACKPACK, function(plr : Player, toolKey : number, toolName : string)
        local plrInfo = PlayerManager.get(plr)
        plrInfo:DeleteBackpack(toolKey)

        NotificationUtil.Notify(plr, "You deleted " .. toolName)

       -- MidasEventTree.Gameplay.BackpackDeleted.Value(plr)
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

        --MidasEventTree.Gameplay.BackpackAdded.Value(plr)
        
        return nil
    end)

    NetworkUtil.onServerInvoke(ADD_VEHICLE, function(plr : Player, vehicleName : string)
        local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature") )

        if not plrIsVIP then 
            MarketplaceService:PromptGamePassPurchase(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            return nil 
        end

        local plrInfo = PlayerManager.get(plr)

        local success = plrInfo:AddVehicle(vehicleName, false)

        if success then
            NotificationUtil.Notify(plr, "You got " .. vehicleName ..", you can spawn it at the parking lot at the nearest vehicle spawner.")
        end
        --MidasEventTree.Gameplay.VehiclesAdded.Value(plr)
        return nil
    end)
    
    NetworkUtil.onServerInvoke(DELETE_VEHICLE, function(plr : Player, key : number)
        local plrInfo = PlayerManager.get(plr)

        plrInfo:DeleteVehicle(key)

        --MidasEventTree.Gameplay.VehiclesDeleted.Value(plr) 
        return nil
    end)

    NetworkUtil.onServerInvoke(GET_PLAYER_VEHICLES, function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        local vehicleListName = {}

        for k,v in pairs(plrInfo.Vehicles) do
            vehicleListName[k] = v.Name
        end

        return plrInfo.Vehicles
    end)


    NetworkUtil.onServerInvoke(ON_CUSTOMIZE_CHAR, function(plr : Player, customizationId : number, itemType : Enum.AvatarItemType)
        local plrInfo = PlayerManager.get(plr)
        assert(plrInfo)

        local info , infoType = nil, Enum.InfoType.Asset

        local s,e = pcall(function() info = MarketplaceService:GetProductInfo(customizationId, infoType) end)
        if not s and e then
            infoType = Enum.InfoType.Bundle
            s, e = pcall(function() info = MarketplaceService:GetProductInfo(customizationId, infoType) end)
            --print(infoType)
        end
        if not s and e then
            warn ("unable to load the catalog info by the given id: " .. tostring(e))
            return nil
        end
        --print(customizationId, " bandel nehh ", info)

        if infoType == Enum.InfoType.Bundle then
            local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))

            --if not plrIsVIP then
                --MarketplaceService:PromptGamePassPurchase(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                --return nil
            --end
            
            print(plr.Name, plrIsVIP, " vip test")
        end

        CustomizationUtil.Customize(plr, customizationId, itemType) 

        Analytics.updateDataTable(
            plr, 
            "Events", 
            "Customization", 
            plrInfo,  
            function() return "Character_Customize", itemType.Name end
        )

        --MidasEventTree.Gameplay.CustomizeAvatar.Value(plr)
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

    NetworkUtil.onServerInvoke(GET_CHARACTER_SLOT, function(plr : Player)
        local plrManager = PlayerManager.get(plr)
        return plrManager.CharacterSaves
    end)

    NetworkUtil.onServerInvoke(SAVE_CHARACTER_SLOT, function(plr : Player)
        local plrManager = PlayerManager.get(plr)
        return plrManager:SaveCharacterSlot()
    end)

    NetworkUtil.onServerInvoke(LOAD_CHARACTER_SLOT, function(plr : Player, k, content)
        local plrManager = PlayerManager.get(plr)
        return plrManager:LoadCharacterSlot(k)
    end)

    NetworkUtil.onServerInvoke(DELETE_CHARACTER_SLOT, function(plr : Player, k, content)
        local plrManager = PlayerManager.get(plr)
        return plrManager:DeleteCharacterSlot(k)
    end)

    NetworkUtil.onServerInvoke(ON_ITEM_CART_SPAWN, function(plr : Player, selectedItems : {[number] : BackpackUtil.ToolData<boolean>}, cf : CFrame)
        local plrManager = PlayerManager.get(plr)
        if not plrManager._Maid.ItemsCart then
            plrManager:GetItemsCart(selectedItems, cf)
        else
            plrManager:RemoveExistingItemsCart()
        end
        --print(plrManager._Maid.ItemsCart)
        local plrInfo = PlayerManager.get(plr)
        Analytics.updateDataTable(plr, "Events", "Backpack", plrInfo, function()
            return "Spawn_Item_Cart"
        end)
        return plrManager._Maid.ItemsCart
    end)

    NetworkUtil.onServerInvoke(GET_ITEM_CART, function(plr : Player)
        local plrManager = PlayerManager.get(plr)
        return plrManager._Maid.ItemsCart
    end)

    --maid:GiveTask(NetworkUtil.onServerEvent(ON_TOOL_ACTIVATED, function(plr : Player, toolClass : string, foodInst : Instance, toolData : BackpackUtil.ToolData<nil>)
    maid:GiveTask(NetworkUtil.onServerEvent(ON_TOOL_ACTIVATED, function(plr : Player, toolClass : string, player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, isReleased : boolean?)
       -- print(toolData, toolData.OnRelease)
        local plrInfo = PlayerManager.get(player)
        ToolActions.onToolActivated(toolClass, player, toolData, plrInfo, isReleased)
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(ON_ROLEPLAY_BIO_CHANGE, function(plr : Player, descType : CustomizationUtil.DescType, descName : string)
        local plrManager = PlayerManager.get(plr)
        assert(plrManager)
        local plrData = plrManager:GetData()
        if descType == "PlayerName" then
            plrData.RoleplayBios.Name = descName
        elseif descType == "PlayerBio" then
            plrData.RoleplayBios.Bio = descName
        end
        plrManager:SetData(plrData, false)

        --MidasEventTree.Gameplay.CustomizeAvatar.Value(plr)
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(ON_JOB_CHANGE, function(plr : Player, jobData : Jobs.JobData ?)
        if jobData then
            if Jobs.getJob(plr) ~= jobData.Name then
                Jobs.setJob(plr, jobData.Name)
            else
                Jobs.setJob(plr, nil)
            end
            local plrInfo = PlayerManager.get(plr)
            Analytics.updateDataTable(plr, "Events", "Customization", plrInfo, function()
                return "Job_Customize", jobData.Name
            end)
        else
            Jobs.setJob(plr)
        end
        
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(ON_ITEM_THROW, function(plr : Player, toolData : ToolData<nil>)
        local plrManager = PlayerManager.get(plr)
        assert(plrManager)
        plrManager:ThrowItem(toolData)
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(USER_INTERVAL_UPDATE, function(plr : Player, fps : number)
        local plrManager = PlayerManager.get(plr)
        assert(plrManager)
        plrManager.Framerate = fps
        Analytics.updateDataTable(plr, "Server", "Population", plrManager)
        Analytics.updateDataTable(plr, "Server", "Performance", plrManager)
        Analytics.updateDataTable(plr, "User", "Map", plrManager)
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(SEND_FEEDBACK, function(plr : Player, feedback : string)
        local feedbackSentKey = "SentFeedback"
        local alreadySentFeedback = plr:GetAttribute(feedbackSentKey)

        if not alreadySentFeedback then
            plr:SetAttribute(feedbackSentKey, true)

            local plrManager = PlayerManager.get(plr)

            Analytics.updateDataTable(plr, "Events", "Miscs", plrManager, function()
                return "Player_Feedback", feedback
            end)
        else
            NotificationUtil.Notify(plr, "Fail to send: you already sent a feedback!")
        end

        return
    end))

    maid:GiveTask(NetworkUtil.onServerEvent(ON_GAME_LOADING_COMPLETE, function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        Analytics.updateDataTable(plr, "Events", "Miscs", plrInfo, function()
            return "Client_Loaded_Success"
        end)
        return
    end))

    NetworkUtil.onServerInvoke(ON_VEHICLE_LOCKED, function(plr : Player, lock : boolean)
        local plrInfo = PlayerManager.get(plr)
        local spawnedVehicleData : VehicleData ? 

        for _,vehicleData in pairs(plrInfo.Vehicles) do
            if vehicleData.IsSpawned then
                spawnedVehicleData = vehicleData
                break
            end
        end
        
        assert(spawnedVehicleData, "No vehicle data detected!")
        local vehicleModel = getVehicleModelByKey(plr, spawnedVehicleData.Key)
        
        lockVehicle(vehicleModel, lock)

        return vehicleModel:GetAttribute("isLocked")
    end)

    NetworkUtil.getRemoteFunction(GET_PLAYER_VEHICLES)
    NetworkUtil.getRemoteEvent(ON_INTERACT)
    NetworkUtil.getRemoteEvent(ON_GAME_LOADING_COMPLETE)
    NetworkUtil.getRemoteEvent(ON_JOB_CHANGE)

end

return PlayerManager