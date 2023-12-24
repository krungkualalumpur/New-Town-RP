--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
--modules
local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
--types
type Maid = Maid.Maid
type DataType = Midas.DataType
type RowData = {
    server_id: string,
    session_id: string,
    timestamp: DateTime,
    user_id: number,
    is_premium: boolean,
    friends_in_game: number?,
    pos_x: number?,
    pos_y: number?,
}
type PlayerManager = ManagerTypes.PlayerManager

--constants
local TITLE_ID = "Analytics"
    --local DEV_SECRET_KEY = "8MWPBTO9AOFZUUZUJT4EEDRGWU54D874KN33B51653U68K1SKZ"
--variables
--references
--local functions
--class
local Analytics = {}
function Analytics.init(maid : Maid)
    Midas.init(maid)
    Midas.ProjectId = TITLE_ID

    local mongoDB = Midas.StorageProviders.MongoDB.new(
        "C1uB4i5jzWAoK3jcxrHqJD8Zw8zBzSY8IoVQDgqPazE6jUgYZAqB40VDXpRxOq3g",
        "https://ap-southeast-1.aws.data.mongodb-api.com/app/data-qleae" 
    )
    mongoDB.DebugPrintEnabled = RunService:IsStudio()
    Midas:SetOnBatchSaveInvoke(
        function(
            projectId: string,
            dataSetId: string,
            dataTableId: string,
            dataList: { [number]: { [string]: unknown } },
            format: { [string]: DataType },
            onPayloadSizeKnownInvoke:(number) -> ()
        ): boolean
            return mongoDB:InsertMany(
                projectId, 
                dataSetId, 
                dataTableId, 
                dataList, 
                format, 
                onPayloadSizeKnownInvoke
            )
        end
    )

     -- level of organization for datatables
    local serverDataSet = Midas:CreateDataSet("Server", "server")

    -- a table with rows and columns
    local populationDataTable = serverDataSet:CreateDataTable("Population", "population") :: Midas.DataTable<RowData>
    populationDataTable:AddColumn("server_id", "String", false)
    populationDataTable:AddColumn("user_id", "Int64", false)
    populationDataTable:AddColumn("session_id", "String", false)
    populationDataTable:AddColumn("timestamp", "Date", false)
    populationDataTable:AddColumn("in_game_time", "Int32", false)
    populationDataTable:AddColumn("player_nearby", "Int32", false)
    populationDataTable:AddColumn("population_in_game", "Int32", true)
    populationDataTable:AddColumn("friends_in_game", "Int32", true)
    local performanceDataTable = serverDataSet:CreateDataTable("Performance", "performance") :: Midas.DataTable<RowData>
    performanceDataTable:AddColumn("server_id", "String", false)
    performanceDataTable:AddColumn("user_id", "Int64", false)
    performanceDataTable:AddColumn("session_id", "String", false)
    performanceDataTable:AddColumn("timestamp", "Date", false)
    performanceDataTable:AddColumn("frame_rate", "Int32", true)
    performanceDataTable:AddColumn("pos_x", "Double", true)
    performanceDataTable:AddColumn("pos_z", "Double", true)

-- level of organization for datatables
    local userDataSet = Midas:CreateDataSet("User", "user")

-- a table with rows and columns
    local mapDataTable = userDataSet:CreateDataTable("Map", "map") :: Midas.DataTable<RowData>
    mapDataTable:AddColumn("server_id", "String", false)
    mapDataTable:AddColumn("user_id", "Int64", false)
    mapDataTable:AddColumn("session_id", "String", false)
    mapDataTable:AddColumn("timestamp", "Date", false)
    mapDataTable:AddColumn("pos_x", "Double", true)
    mapDataTable:AddColumn("pos_z", "Double", true)
    mapDataTable:AddColumn("height", "Double", true)
    local sessionDataTable = userDataSet:CreateDataTable("Session", "session") :: Midas.DataTable<RowData>
    sessionDataTable:AddColumn("server_id", "String", false)
    sessionDataTable:AddColumn("session_id", "String", false)
    sessionDataTable:AddColumn("timestamp", "Date", false)
    sessionDataTable:AddColumn("user_id", "Int64", false)
    sessionDataTable:AddColumn("is_premium", "Boolean", false)
    sessionDataTable:AddColumn("is_retained_on_d0", "Boolean", false)
    sessionDataTable:AddColumn("is_retained_on_d1", "Boolean", false)
    sessionDataTable:AddColumn("is_retained_on_d7", "Boolean", false)
    sessionDataTable:AddColumn("is_retained_on_d14", "Boolean", false)
    sessionDataTable:AddColumn("is_retained_on_d28", "Boolean", false)
    sessionDataTable:AddColumn("play_duration", "Boolean", true)
    local gameplayDataTable = userDataSet:CreateDataTable("Gameplay", "gameplay") :: Midas.DataTable<RowData>
    gameplayDataTable:AddColumn("server_id", "String", false)
    gameplayDataTable:AddColumn("user_id", "Int64", false)
    gameplayDataTable:AddColumn("session_id", "String", false)
    gameplayDataTable:AddColumn("timestamp", "Date", false)
    gameplayDataTable:AddColumn("backpack", "Array", true)
    gameplayDataTable:AddColumn("vehicles", "Array", true)
    gameplayDataTable:AddColumn("pos_x", "Double", true)
    gameplayDataTable:AddColumn("pos_z", "Double", true)
    local customizationDataTable = userDataSet:CreateDataTable("Customization", "customization") :: Midas.DataTable<RowData>
    customizationDataTable:AddColumn("server_id", "String", false)
    customizationDataTable:AddColumn("user_id", "Int64", false)
    customizationDataTable:AddColumn("session_id", "String", false)
    customizationDataTable:AddColumn("timestamp", "Date", false)
    customizationDataTable:AddColumn("character", "Array", true)
    customizationDataTable:AddColumn("pos_x", "Double", true)
    customizationDataTable:AddColumn("pos_z", "Double", true)
    

    Midas:Automate(RunService:IsStudio())

    --player joins & exits
    maid:GiveTask(Players.PlayerAdded:Connect(function(plr : Player)
        plr:SetAttribute("JoinTime", DateTime.now().UnixTimestamp)
        Analytics.updateDataTable(plr, "User", "Session")
    end))

    maid:GiveTask(Players.PlayerRemoving:Connect(function(plr : Player)
        local plrJoinTime = plr:GetAttribute("JoinTime")
        plr:SetAttribute("PlayDuration", if plrJoinTime then DateTime.now().UnixTimestamp - plrJoinTime else nil)
        Analytics.updateDataTable(plr, "User", "Session")
    end))
end

function Analytics.updateDataTable(plr : Player, dataSetName : string, dataTableName : string, plrInfo : PlayerManager ?)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
    local currentTimeStamp = plr:GetAttribute("JoinedTimestamp") or DateTime.now().UnixTimestamp
    plr:SetAttribute("JoinedTimestamp", currentTimeStamp)

    local dataSet = Midas:GetDataSet(dataSetName)
    assert(dataSet)
    local dataTable : Midas.DataTable<{any}> = dataSet:GetDataTable(dataTableName)
    assert(dataTable)
    if dataSetName == "Server" then
        if dataTableName == "Population" then
            local plrAmount = 0
            local friendsAmount = 0
            local friendNearby = 0
            for _, exstPlr in pairs(Players:GetPlayers()) do
                plrAmount += 1
                if exstPlr:IsFriendsWith(plr.UserId) then
                    friendsAmount += 1
                end
            end
            for _, exstPlr in pairs(Players:GetPlayers()) do 
                local otherChar = exstPlr.Character
                if (exstPlr ~= plr) and (otherChar and otherChar.PrimaryPart) and (char and char.PrimaryPart) and ((char.PrimaryPart.Position - otherChar.PrimaryPart.Position).Magnitude <= 30) then
                    friendNearby += 1
                end
            end

            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                in_game_time = game.Lighting.ClockTime,
                player_nearby = friendNearby,
                population_in_game = plrAmount,
                friends_in_game = friendsAmount,
                play_duration = plr:GetAttribute("PlayDuration")
            })
        elseif dataTableName == "Performance" then
            assert(plrInfo, "Player info not found!")
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                frame_rate = if plrInfo then plrInfo.Framerate else nil,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
            })
        end
    elseif dataSetName == "User" then
        if dataTableName == "Map" then
            dataTable:AddRow({ 
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                pos_x = charPrimaryPart.Position.X,
                height = charPrimaryPart.Position.Y,
                pos_z = charPrimaryPart.Position.Z,
            })
        elseif dataTableName == "Session" then
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                is_premium = (plr.MembershipType == Enum.MembershipType.Premium),

                is_retained_on_d0 = if plrInfo then (if plrInfo.FirstVisitTimestamp and (currentTimeStamp - plrInfo.FirstVisitTimestamp) <= 60*60*24*1 then true else false) else false,
                is_retained_on_d1 = if plrInfo then (if plrInfo.FirstVisitTimestamp and (((currentTimeStamp - plrInfo.FirstVisitTimestamp) >= 60*60*24*1) and (currentTimeStamp - plrInfo.FirstVisitTimestamp <= 60*60*24*(1 + 1))) then true else false) else false,
                is_retained_on_d7 = if plrInfo then (if plrInfo.FirstVisitTimestamp and (((currentTimeStamp - plrInfo.FirstVisitTimestamp) >= 60*60*24*7) and (currentTimeStamp - plrInfo.FirstVisitTimestamp <= 60*60*24*(7 + 1))) then true else false) else false,
                is_retained_on_d14 = if plrInfo then (if plrInfo.FirstVisitTimestamp and (((currentTimeStamp - plrInfo.FirstVisitTimestamp) >= 60*60*24*14) and (currentTimeStamp - plrInfo.FirstVisitTimestamp <= 60*60*24*(14 + 1))) then true else false) else false,
                is_retained_on_d28 = if plrInfo then (if plrInfo.FirstVisitTimestamp and (((currentTimeStamp - plrInfo.FirstVisitTimestamp) >= 60*60*24*28) and (currentTimeStamp - plrInfo.FirstVisitTimestamp <= 60*60*24*(28 + 1))) then true else false) else false,
            })
        elseif dataTableName == "Gameplay" then
            local plrData = if plrInfo then plrInfo:GetData() else nil
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                backpack = if plrData then plrData.Backpack else {},
                vehicles = if plrData then plrData.Vehicles else {},
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
            })
        elseif dataTableName == "Customization" then
            local plrData = if plrInfo then plrInfo:GetData() else nil
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                character = if plrData then plrData.Character else {},
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
            })
        end
    end
    --print(Midas:GetDataSets(), " datasets!")
end

return Analytics