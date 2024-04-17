--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
--types
export type UIStatus = "Backpack" | "Roleplay" | "Customization" | "House" | "Vehicle" | nil

type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>
--constants
--variables
local _maid = Maid.new()
local _fuse = ColdFusion.fuse(_maid)
local _new = _fuse.new
local _import = _fuse.import
local _bind = _fuse.bind
local _clone = _fuse.clone

local _Computed = _fuse.Computed
local _Value = _fuse.Value

local status = {
    Ui = _Value(nil),
    Notif = _Value(nil)
}
--references
--local functions
--class
local StatusUtil = {}

function StatusUtil.getStatusFromName(statusName : "Ui" | "Notif") : ValueState<any>
    return status[statusName]
end

return StatusUtil