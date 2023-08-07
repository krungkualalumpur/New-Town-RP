--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
type ToolData = BackpackUtil.ToolData

export type PlayerManager = {
    __index : PlayerManager,

    Player : Player,
    Backpack : {[number] : ToolData},

    new : (player : Player) -> PlayerManager,
    InsertToBackpack : (PlayerManager, toolModel : Model) -> (),
    Destroy : (PlayerManager) -> ()
}
--constants
--variables
--references
--local functions
--class
local PlayerManager : PlayerManager = {} :: any
PlayerManager.__index = PlayerManager

function PlayerManager.new(player : Player)
    local self : PlayerManager = setmetatable({}, PlayerManager) :: any
    self.Player = player
    self.Backpack = {}
    return self
end

function PlayerManager:InsertToBackpack(toolModel : Model)
    table.insert(self.Backpack, BackpackUtil.getData(toolModel))
end

function PlayerManager:Destroy()
    local t = self :: any
    
    for k,v in pairs(t) do
        t[k] = nil
    end

    setmetatable(self, nil)
    return nil
end

return PlayerManager