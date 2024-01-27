--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--local ProfileService = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ProfileService"))
--modules
local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
--types
type SessionData = {
	JoinTime : number,
	QuitTime : number ?,
	Id : string
}

type PlayerSaveData = {
    GameVersion : string,
	SessionIds : {[number] : SessionData},
    FirstVisitTimestamp : number,

	PlayerData : ManagerTypes.PlayerData
}

export type DatastoreManager = {
	__index : DatastoreManager,

	Player : Player,
	PlayerInfo : ManagerTypes.PlayerManager,
	SessionIds : {[number] : SessionData},
	CurrentSessionData : SessionData,
	GameVersion : string,
	FirstVisitTimestamp : number,

	new : (plr : Player, plrInfo : ManagerTypes.PlayerManager) -> DatastoreManager,
	Save : (DatastoreManager) -> (),
	GetData : (DatastoreManager) -> PlayerSaveData,
	SetDatastoreManagerData : (DatastoreManager, plrSaveData : PlayerSaveData) -> (),
	LoadSave : (DatastoreManager) -> (),
	Destroy : (DatastoreManager) -> (),

	get : (plr : Player) -> DatastoreManager 
}
--constants
local DATA_ATTEMPT_COUNT = 10
local CURRENT_GAME_VERSION = "v1.98.2"
--variables
local gameData1 = DataStoreService:GetDataStore("GameData")
local Registry = {}
--references
--local functions 
local function generateSessionId(userId : number)
    local currentTimeStamp = DateTime.now().UnixTimestamp
    return tostring(math.round(currentTimeStamp)) .. tostring(userId)
end

local function createSessionData(plr : Player, joinTime : number, quitTime : number ?, sessionId : string) : SessionData
	return {
		JoinTime = joinTime,
		QuitTime = quitTime,
		Id = generateSessionId(plr.UserId)
	}
end
--module 
local DatastoreManager : DatastoreManager = {}  :: any
DatastoreManager.__index = DatastoreManager

function DatastoreManager.new(plr : Player, plrInfo : ManagerTypes.PlayerManager)
	local currentSessionData = createSessionData(
		plr, 
		DateTime.now().UnixTimestamp, 
		nil, 
		generateSessionId(plr.UserId)
	)
	
	local self : DatastoreManager = setmetatable({}, DatastoreManager) :: any 
	self.Player = plr
	self.PlayerInfo = plrInfo
	self.SessionIds = {currentSessionData}
	self.FirstVisitTimestamp = DateTime.now().UnixTimestamp
	self.GameVersion = CURRENT_GAME_VERSION
	self.CurrentSessionData = currentSessionData

	Registry[plr] = self

	return self
end

function DatastoreManager:Save()
	local plrInfo = self.PlayerInfo
	assert(plrInfo, "Incomplete argument!")
	--print("save attempt", player)
	if not plrInfo.isLoaded then warn("Plot has not loaded yet!"); return end
	if
		not RunService:IsStudio()
		or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == true)
	then
		--self.CurrentSessionData.QuitTime = DateTime.now().UnixTimestamp
		--print("T1")
		--saving
		local data : PlayerSaveData = {
            PlayerData = plrInfo:GetData(),
			SessionIds = self.SessionIds,
			FirstVisitTimestamp = self.FirstVisitTimestamp,
			GameVersion = CURRENT_GAME_VERSION
		}
		--print("T2")
		local JSONdata = HttpService:JSONEncode(data)
		local s, e = pcall(function()
			--print("T3")
			gameData1:SetAsync("k" .. self.Player.UserId, JSONdata)
			if RunService:IsStudio() then print("saving: ", JSONdata) end
		end)
		--print("T4")
		if not s then
			warn("Game datasave error: ", e)
		end
	elseif
		RunService:IsStudio()
		and (
			not ServerStorage:FindFirstChild("SaveInStudio")
			or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == false)
		)
	then
		warn("save in studio is disabled, set SaveInStudio to true, located in ServerStorage")
	end
end

function DatastoreManager:GetData()
	local s, data = pcall(function()
		return gameData1:GetAsync("k" .. self.Player.UserId)
	end)
	if not s and data then
		local count = 0
		repeat 
			warn("Game datasave error: ", data, " attempting to reload...")
			count += 1; 
			s, data = pcall(function()
				return gameData1:GetAsync("k" .. self.Player.UserId)
			end)
			task.wait(0.25); 
		until (s or (count > DATA_ATTEMPT_COUNT))
		return (if s then data else nil)
	end
	return data 
end

function DatastoreManager:SetDatastoreManagerData(plrSaveData : PlayerSaveData)
	assert(#plrSaveData.SessionIds > 0, "Session id cannot be empty!")
	local newCurrentSessionData = plrSaveData.SessionIds[#plrSaveData.SessionIds]

	self.FirstVisitTimestamp = plrSaveData.FirstVisitTimestamp	
	self.SessionIds = plrSaveData.SessionIds
	self.CurrentSessionData = newCurrentSessionData
	self.GameVersion = CURRENT_GAME_VERSION
end

function DatastoreManager:LoadSave()
	
	local plrInfo = self.PlayerInfo

	local data = self:GetData()
	if not data then
		--loadVanilla(player, plrData, sysData)
		plrInfo.onLoadingComplete:Fire(false)
		return
	end

	local convertedData :  PlayerSaveData = HttpService:JSONDecode(data) 
	print("Loading: " , data, "Current Game Version : ", CURRENT_GAME_VERSION, "Session Ids: ", self.SessionIds)
	if convertedData and convertedData.PlayerData then
		if (CURRENT_GAME_VERSION ~= convertedData.GameVersion) then
			warn("Error upon loading player data: Game version already updated!")
			plrInfo.onLoadingComplete:Fire(false)
			return
		end

		local s, e = pcall(function() plrInfo:SetData(convertedData.PlayerData, true) end)
		if (not s and e) then
			warn("Error upon loading player data: " .. tostring(e))
			plrInfo.onLoadingComplete:Fire(false)
			return
		end

			--tracking session id
		local sessionData = createSessionData(
			self.Player, 
			DateTime.now().UnixTimestamp, 
			nil, 
			generateSessionId(self.Player.UserId)
		)
		table.insert(convertedData.SessionIds, sessionData)
		print("SessionIds", convertedData.SessionIds, #convertedData.SessionIds)
		self:SetDatastoreManagerData(convertedData)
	end
	return
end

function DatastoreManager:Destroy()
	Registry[self.Player] = nil

	local t : any = self
	for k,v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)
end


function DatastoreManager.get(plr : Player)
	return Registry[plr]
end
--[[function dataStore.load(player : Player, )

end]]

return DatastoreManager