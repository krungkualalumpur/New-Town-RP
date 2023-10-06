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
type PlayerSaveData = {
    LastTimeStamp : number,
    GameVersion : string,

	PlayerData : ManagerTypes.PlayerData
}
--constants
local DATA_ATTEMPT_COUNT = 10
local CURRENT_GAME_VERSION = "v1.0"
--variables
local gameData1 = DataStoreService:GetDataStore("GameData1")
--module
local DatastoreManager = {}
function DatastoreManager.save(player: Player, plrInfo : ManagerTypes.PlayerManager)
	assert(plrInfo, "Incomplete argument!")
	--print("save attempt", player)
	if not plrInfo.isLoaded then warn("Plot has not loaded yet!"); return end
	if
		not RunService:IsStudio()
		or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == true)
	then
		print("T1")
		--saving
		local data : PlayerSaveData = {
            PlayerData = plrInfo:GetData(),
			LastTimeStamp = DateTime.now().UnixTimestamp,
			GameVersion = CURRENT_GAME_VERSION
		}
		print("T2")
		local JSONdata = HttpService:JSONEncode(data)
		local s, e = pcall(function()
			print("T3")
			gameData1:SetAsync("k" .. player.UserId, JSONdata)
			print("saving: ", JSONdata)
		end)
		print("T4")
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

function DatastoreManager.get(player: Player)
	local s, data = pcall(function()
		return gameData1:GetAsync("k" .. player.UserId)
	end)
	if not s and data then
		local count = 0
		repeat 
			warn("Game datasave error: ", data, " attempting to reload...")
			count += 1; 
			s, data = pcall(function()
				return gameData1:GetAsync("k" .. player.UserId)
			end)
			task.wait(0.25); 
		until (s or (count > DATA_ATTEMPT_COUNT))
		return (if s then data else nil)
	end
	return data 
end

function DatastoreManager.load(player: Player, plrInfo: ManagerTypes.PlayerManager)
	local data = DatastoreManager.get(player)
	if not data then
		--loadVanilla(player, plrData, sysData)
		plrInfo.onLoadingComplete:Fire()
		return
	end

	local convertedData :  PlayerSaveData = HttpService:JSONDecode(data) 
	print("Loading: " , data, "Current Game Version : ", CURRENT_GAME_VERSION)
	if convertedData and convertedData.PlayerData then
		local s, e = pcall(function() plrInfo:SetData(convertedData.PlayerData) end)
		if not s and e then
			warn("Error upon loading player data: " .. tostring(e))
			plrInfo.onLoadingComplete:Fire()
		end
	end
end
--[[function dataStore.load(player : Player, )

end]]

return DatastoreManager