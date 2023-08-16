--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))

--types
type Maid = Maid.Maid

type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type VehicleData = ItemUtil.ItemInfo & {
    Key : string,
    IsSpawned : boolean,
    OwnerId : number
}

export type PlayerManager = {
    __index : PlayerManager,

    Player : Player,
    Backpack : {[number] : ToolData<boolean>},
    Vehicles : {[number] : VehicleData},

    new : (player : Player) -> PlayerManager,
    
    InsertToBackpack : (PlayerManager, tool : Instance) -> (),
    DeleteBackpack : (PlayerManager, toolKey : number) -> (),

    GetBackpack : (PlayerManager, hasDisplayType : boolean, hasEquipInfo : boolean) -> {[number] : BackpackUtil.ToolData<boolean ?>},
    SetBackpackEquip : (PlayerManager, isEquip : boolean, toolKey : number) -> (),

    AddVehicle : (PlayerManager, vehicleName : string) -> (),
    SpawnVehicle : (PlayerManager, key : number, isEquip : boolean, vehicleName : string ?, vehicleZones : Instance ?) -> (),
    DeleteVehicle : (PlayerManager, key : number) -> (),

    Destroy : (PlayerManager) -> (),

    get : (plr : Player) -> PlayerManager,
    init : (maid : Maid) -> ()
}
--constants
local MAX_TOOLS_COUNT = 10
local MAX_VEHICLES_COUNT = 5
--remotes
local ON_INTERACT = "On_Interact"
local ON_TOOL_INTERACT = "On_Tool_Interact"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"
local ADD_BACKPACK = "AddBackpack" 

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"
local ADD_VEHICLE = "AddVehicle"

local KEY_VALUE_NAME = "KeyValue"

local KEY_VALUE_ATTRIBUTE = "KeyValue"
--variables
local Registry = {}
--references
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

--class
local PlayerManager : PlayerManager = {} :: any
PlayerManager.__index = PlayerManager

function PlayerManager.new(player : Player)
    local self : PlayerManager = setmetatable({}, PlayerManager) :: any
    self.Player = player
    self.Backpack = {}
    self.Vehicles = {}

    Registry[player] = self
    return self
end

function PlayerManager:InsertToBackpack(tool : Instance)
    if #self.Backpack >= MAX_TOOLS_COUNT then
        --notif
        NotificationUtil.Notify(self.Player, "Already has max amount of tools to have")
        print("Already has max amount of tools to have")
        return
    end
    
    local toolData : BackpackUtil.ToolData<boolean> = BackpackUtil.getData(tool, false) :: any
    toolData.IsEquipped = false
    table.insert(self.Backpack, toolData)
    print(self.Backpack)
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
            print(toolData.Name, tool.Name, toolData.IsEquipped)
            if toolData.IsEquipped then
                local equippedTool = BackpackUtil.createTool(tool)
                    --func for the tool upon it being activated
                --maid:GiveTask(equippedTool.Activated:Connect(function()
                --    local character = plr.Character or plr.CharacterAdded:Wait()
                --    if character then    
                --        ToolActions.onToolActivated(toolData.Class, plr, BackpackUtil.getData(tool, true))
                --    end
                --end))
                
                equippedTool.Parent = character
               
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
        return
    end
    
    local vehicleClass = ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), false).Class
    local vehicleData : VehicleData = newVehicleData("Vehicle", vehicleClass, false, vehicleName, self.Player.UserId) -- ItemUtil.getData(ItemUtil.getItemFromName(vehicleName), true) :: any

    table.insert(self.Vehicles, vehicleData)
    return
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
            print(vehicleModel, v)
        end
    end
    
    vehicleInfo.IsSpawned = isSpawned
    if isSpawned == true then
        local vehicleModel = createVehicleModel(vehicleInfo, spawnPart.CFrame)
        applyVehicleData(vehicleModel, vehicleInfo)
    end

    return 
end

function PlayerManager:DeleteVehicle(key : number)
    self:SpawnVehicle(key, false)

    self.Vehicles[key] = nil
    return
end

function PlayerManager:Destroy()
    Registry[self.Player] = nil
    
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
    local function onPlayerAdded(plr : Player)
        local plrInfo = PlayerManager.new(plr)
        print("plr info madee!") 
    end


    for _, plr : Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(plr)
    end

    maid:GiveTask(Players.PlayerAdded:Connect(onPlayerAdded))

    maid:GiveTask(Players.PlayerRemoving:Connect(function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        plrInfo:Destroy()
    end))

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

        return nil
    end)
    NetworkUtil.onServerInvoke(DELETE_BACKPACK, function(plr : Player, toolKey : number, toolName : string)
        local plrInfo = PlayerManager.get(plr)
        plrInfo:DeleteBackpack(toolKey)
        return nil
    end)

    NetworkUtil.onServerInvoke(ADD_BACKPACK, function(plr : Player, toolName)
        local plrInfo = PlayerManager.get(plr)

        
        local toolModel = BackpackUtil.getToolFromName(toolName)

        if toolModel then plrInfo:InsertToBackpack(toolModel) end

        NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plr, plrInfo:GetBackpack(true, true))
        return nil
    end)

    NetworkUtil.onServerInvoke(ADD_VEHICLE, function(plr : Player, vehicleName : string)
        local plrInfo = PlayerManager.get(plr)

        plrInfo:AddVehicle(vehicleName)
        print(plrInfo.Vehicles)
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

    NetworkUtil.getRemoteEvent(UPDATE_PLAYER_BACKPACK)
end

return PlayerManager