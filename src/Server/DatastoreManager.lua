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
local CURRENT_GAME_VERSION = "v1.0"
--variables
local gameData1 = DataStoreService:GetDataStore("GameData1")
--module
local DatastoreManager = {}
function DatastoreManager.save(player: Player, plrInfo : ManagerTypes.PlayerManager)
	assert(plrInfo, "Incomplete argument!")
	--print("save attempt", player, plrSys)
	if not plrInfo.isLoaded then warn("Plot has not loaded yet!"); return end
	if
		not RunService:IsStudio()
		or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == true)
	then
		--saving
		local data : PlayerSaveData = {
            PlayerData = plrInfo:GetData(),
			LastTimeStamp = DateTime.now().UnixTimestamp,
			GameVersion = CURRENT_GAME_VERSION
		}

		local JSONdata = HttpService:JSONEncode(data)
		local s, e = pcall(function()
			gameData1:SetAsync("k" .. player.UserId, JSONdata)
			print("saving: ", JSONdata)
		end)
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
		warn("Game datasave error: ", data)
		return nil
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
		plrInfo:SetData(convertedData.PlayerData)
	end
end
--[[function dataStore.load(player : Player, )

end]]

return DatastoreManager