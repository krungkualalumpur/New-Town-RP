--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
--types
type Maid = Maid.Maid

type ToolData<isEquipped> = BackpackUtil.ToolData<isEquipped>

export type PlayerManager = {
    __index : PlayerManager,

    Player : Player,
    Backpack : {[number] : ToolData<boolean>},

    new : (player : Player) -> PlayerManager,
    InsertToBackpack : (PlayerManager, tool : Instance) -> (),
    GetBackpack : (PlayerManager, hasDisplayType : boolean, hasEquipInfo : boolean) -> {[number] : BackpackUtil.ToolData<boolean ?>},
    SetBackpackEquip : (PlayerManager, isEquip : boolean, toolKey : number) -> (),
    Destroy : (PlayerManager) -> (),

    get : (plr : Player) -> PlayerManager,
    init : (maid : Maid) -> ()
}
--constants
local MAX_TOOLS_COUNT = 10
--remotes
local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"
--variables
local Registry = {}
--references
--local functions
--class
local PlayerManager : PlayerManager = {} :: any
PlayerManager.__index = PlayerManager

function PlayerManager.new(player : Player)
    local self : PlayerManager = setmetatable({}, PlayerManager) :: any
    self.Player = player
    self.Backpack = {}

    Registry[player] = self
    return self
end

function PlayerManager:InsertToBackpack(tool : Instance)
    if #self.Backpack >= MAX_TOOLS_COUNT then
        --notif
        print("Already has max amount of tools to have")
        return
    end
    
    local toolData : BackpackUtil.ToolData<boolean> = BackpackUtil.getData(tool, false) :: any
    toolData.IsEquipped = false
    table.insert(self.Backpack, toolData)
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
    local toolInfo = self.Backpack[toolKey]
    assert(toolInfo)

    toolInfo.IsEquipped = isEquip

    NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, self.Player, self:GetBackpack(true, true))

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
    print("bermuram durja sampaiken")
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


    NetworkUtil.onServerInvoke(GET_PLAYER_BACKPACK, function(plr : Player)
        local plrInfo = PlayerManager.get(plr)
        return plrInfo:GetBackpack(true, true)
    end)


    NetworkUtil.onServerInvoke(EQUIP_BACKPACK, function(plr : Player, toolKey : number, toolName : string ?)
        local plrInfo = PlayerManager.get(plr)
        local character = plr.Character or plr.CharacterAdded:Wait()

        for _,v in pairs(character:GetChildren()) do
            if v:IsA("Tool") then
                v:Destroy()
            end
        end

        if toolName then
            local tool = BackpackUtil.getToolFromName(toolName)
            if tool then
                local toolData = plrInfo.Backpack[toolKey]

                if (toolData.Name == toolName) and not toolData.IsEquipped then
                    local equippedTool = BackpackUtil.createTool(tool)
                        --func for the tool upon it being activated
                    local maid = Maid.new()
                    maid:GiveTask(equippedTool.Activated:Connect(function()
                        local character = plr.Character or plr.CharacterAdded:Wait()
                        if character then    
                            local toolAction = ToolActions.getActionInfo(toolData.Class)
                            toolAction.Activated(equippedTool, character:WaitForChild("Humanoid") :: Humanoid)
                        end
                    end))
                    
                    equippedTool.Parent = character
                    maid:GiveTask(equippedTool.Destroying:Connect(function()
                        plrInfo:SetBackpackEquip(false, toolKey)
                        maid:Destroy()
                    end))

                    plrInfo:SetBackpackEquip(true, toolKey)
                end 
            end 
        end

        return nil
    end)
    NetworkUtil.onServerInvoke(DELETE_BACKPACK, function(plr : Player, toolKey : number, toolName : string)
        local plrInfo = PlayerManager.get(plr)
        local character = plr.Character or plr.CharacterAdded:Wait()

        local toolInfo = plrInfo.Backpack[toolKey]

        if toolInfo.Name == toolName then
            if toolInfo.IsEquipped then
                for _,v in pairs(character:GetChildren()) do
                    if v:IsA("Tool") then
                        v:Destroy()
                    end
                end
            end

            table.remove(plrInfo.Backpack, toolKey)

            NetworkUtil.fireClient(UPDATE_PLAYER_BACKPACK, plr, plrInfo:GetBackpack(true, true))
        end
        return nil
    end)

    NetworkUtil.getRemoteEvent(UPDATE_PLAYER_BACKPACK)
end

return PlayerManager