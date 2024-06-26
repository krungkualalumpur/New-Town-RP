--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService") :: UserInputService
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Midas = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Midas"))
--modules
local Jobs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Jobs"))

local ManagerTypes = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ManagerTypes"))
local DatastoreManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DatastoreManager"))
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
    local populationDataTable = serverDataSet:CreateDataTable("Population", "population") 
    populationDataTable:AddColumn("server_id", "String", false)
    populationDataTable:AddColumn("user_id", "Int64", false)
    populationDataTable:AddColumn("session_id", "String", false)
    populationDataTable:AddColumn("timestamp", "Date", false)
    populationDataTable:AddColumn("in_game_time", "Int32", false)
    populationDataTable:AddColumn("player_nearby", "Int32", false)
    populationDataTable:AddColumn("population_in_game", "Int32", true)
    populationDataTable:AddColumn("friends_in_game", "Int32", true)
    local performanceDataTable = serverDataSet:CreateDataTable("Performance", "performance") 
    performanceDataTable:AddColumn("server_id", "String", false)
    performanceDataTable:AddColumn("user_id", "Int64", false)
    performanceDataTable:AddColumn("session_id", "String", false)
    performanceDataTable:AddColumn("timestamp", "Date", false)
    performanceDataTable:AddColumn("frame_rate", "Int32", true)
    performanceDataTable:AddColumn("ping", "Int64", true)
    performanceDataTable:AddColumn("pos_x", "Double", true)
    performanceDataTable:AddColumn("pos_z", "Double", true)

    -- level of organization for datatables
    local userDataSet = Midas:CreateDataSet("User", "user")

    -- a table with rows and columns
    local mapDataTable = userDataSet:CreateDataTable("Map", "map") 
    mapDataTable:AddColumn("server_id", "String", false)
    mapDataTable:AddColumn("user_id", "Int64", false)
    mapDataTable:AddColumn("session_id", "String", false)
    mapDataTable:AddColumn("timestamp", "Date", false)
    mapDataTable:AddColumn("pos_x", "Double", true)
    mapDataTable:AddColumn("pos_z", "Double", true)
    mapDataTable:AddColumn("height", "Double", true)
    local sessionDataTable = userDataSet:CreateDataTable("Session", "session") 
    sessionDataTable:AddColumn("server_id", "String", false)
    sessionDataTable:AddColumn("session_id", "String", false)
    sessionDataTable:AddColumn("timestamp", "Date", false)
    sessionDataTable:AddColumn("user_id", "Int64", false)
    sessionDataTable:AddColumn("is_retained_on_d0", "Boolean", true)
    sessionDataTable:AddColumn("is_retained_on_d1", "Boolean", true)
    sessionDataTable:AddColumn("is_retained_on_d7", "Boolean", true)
    sessionDataTable:AddColumn("is_retained_on_d14", "Boolean", true)
    sessionDataTable:AddColumn("is_retained_on_d28", "Boolean", true)
    sessionDataTable:AddColumn("play_duration", "Int64", true)
    sessionDataTable:AddColumn("duration_after_joined", "Int64", true)
    sessionDataTable:AddColumn("event_name", "String", true)
    sessionDataTable:AddColumn("ab_value", "String", false)
    local demographyDataTable = userDataSet:CreateDataTable("Demography", "demography")
    demographyDataTable:AddColumn("server_id", "String", false)
    demographyDataTable:AddColumn("session_id", "String", false)
    demographyDataTable:AddColumn("timestamp", "Date", false)
    demographyDataTable:AddColumn("user_id", "Int64", false)
    demographyDataTable:AddColumn("device", "String", true)
    demographyDataTable:AddColumn("language", "String", true)
    demographyDataTable:AddColumn("account_age", "Int32", true)
    demographyDataTable:AddColumn("screen_size", "String", true)
    demographyDataTable:AddColumn("is_premium", "Boolean", false)
    --[[local gameplayDataTable = userDataSet:CreateDataTable("Gameplay", "gameplay")
    gameplayDataTable:AddColumn("server_id", "String", false)
    gameplayDataTable:AddColumn("user_id", "Int64", false)
    gameplayDataTable:AddColumn("session_id", "String", false)
    gameplayDataTable:AddColumn("timestamp", "Date", false)
    gameplayDataTable:AddColumn("backpack", "Array", true)
    gameplayDataTable:AddColumn("vehicles", "Array", true)
    gameplayDataTable:AddColumn("pos_x", "Double", true)
    gameplayDataTable:AddColumn("pos_z", "Double", true)
    local customizationDataTable = userDataSet:CreateDataTable("Customization", "customization") 
    customizationDataTable:AddColumn("server_id", "String", false)
    customizationDataTable:AddColumn("user_id", "Int64", false)
    customizationDataTable:AddColumn("session_id", "String", false)
    customizationDataTable:AddColumn("timestamp", "Date", false)
    customizationDataTable:AddColumn("character", "Array", true)
    customizationDataTable:AddColumn("pos_x", "Double", true)]]

    -- level of organization for datatables
    local eventsDataSet = Midas:CreateDataSet("Events", "events")

     -- a table with rows and columns
    local backpackDataTable = eventsDataSet:CreateDataTable("Backpack", "backpack") 
    backpackDataTable:AddColumn("server_id", "String", false)
    backpackDataTable:AddColumn("user_id", "Int64", false)
    backpackDataTable:AddColumn("session_id", "String", false)
    backpackDataTable:AddColumn("timestamp", "Date", false)
    backpackDataTable:AddColumn("pos_x", "Double", true)
    backpackDataTable:AddColumn("pos_z", "Double", true)
    backpackDataTable:AddColumn("event_name", "String", false)
    backpackDataTable:AddColumn("backpack", "Array", true)
    backpackDataTable:AddColumn("item_name", "String", true)
    local customizationDataTable = eventsDataSet:CreateDataTable("Customization", "customization")
    customizationDataTable:AddColumn("server_id", "String", false)
    customizationDataTable:AddColumn("user_id", "Int64", false)
    customizationDataTable:AddColumn("session_id", "String", false)
    customizationDataTable:AddColumn("timestamp", "Date", false)
    customizationDataTable:AddColumn("pos_x", "Double", true)
    customizationDataTable:AddColumn("pos_z", "Double", true)
    customizationDataTable:AddColumn("event_name", "String", false)
    customizationDataTable:AddColumn("item_type", "String", true)
    customizationDataTable:AddColumn("character_customization", "Array", true)
    customizationDataTable:AddColumn("job_customization", "String", true)
    local vehiclesDataTable = eventsDataSet:CreateDataTable("Vehicles", "vehicles")
    vehiclesDataTable:AddColumn("server_id", "String", false)
    vehiclesDataTable:AddColumn("user_id", "Int64", false)
    vehiclesDataTable:AddColumn("session_id", "String", false)
    vehiclesDataTable:AddColumn("timestamp", "Date", false)
    vehiclesDataTable:AddColumn("pos_x", "Double", true)
    vehiclesDataTable:AddColumn("pos_z", "Double", true)
    vehiclesDataTable:AddColumn("event_name", "String", false)
    vehiclesDataTable:AddColumn("vehicles", "Array", true)
    vehiclesDataTable:AddColumn("item_name", "String", true)
    local housesDataTable = eventsDataSet:CreateDataTable("Houses", "houses")
    housesDataTable:AddColumn("server_id", "String", false)
    housesDataTable:AddColumn("user_id", "Int64", false)
    housesDataTable:AddColumn("session_id", "String", false)
    housesDataTable:AddColumn("timestamp", "Date", false)
    housesDataTable:AddColumn("pos_x", "Double", true)
    housesDataTable:AddColumn("pos_z", "Double", true)
    housesDataTable:AddColumn("event_name", "String", true)
    housesDataTable:AddColumn("house_name", "String", true)
    local miscsDataTable = eventsDataSet:CreateDataTable("Miscs", "miscs")
    miscsDataTable:AddColumn("server_id", "String", false)
    miscsDataTable:AddColumn("user_id", "Int64", false)
    miscsDataTable:AddColumn("session_id", "String", false)
    miscsDataTable:AddColumn("timestamp", "Date", false)
    miscsDataTable:AddColumn("pos_x", "Double", true)
    miscsDataTable:AddColumn("pos_z", "Double", true)
    miscsDataTable:AddColumn("event_name", "String", false)
    miscsDataTable:AddColumn("content", "String", true)
    local interfaceDataTable = eventsDataSet:CreateDataTable("Interface", "interface")
    interfaceDataTable:AddColumn("server_id", "String", false)
    interfaceDataTable:AddColumn("user_id", "Int64", false)
    interfaceDataTable:AddColumn("session_id", "String", false)
    interfaceDataTable:AddColumn("timestamp", "Date", false)
    interfaceDataTable:AddColumn("pos_x", "Double", true)
    interfaceDataTable:AddColumn("pos_z", "Double", true)
    interfaceDataTable:AddColumn("event_name", "String", false)
    interfaceDataTable:AddColumn("content", "String", true)

    local debugsDataSet = Midas:CreateDataSet("Debugs", "debugs")
    local errorDataTable = debugsDataSet:CreateDataTable("Error", "error")
    errorDataTable:AddColumn("server_id", "String", false)
    errorDataTable:AddColumn("user_id", "Int64", false)
    errorDataTable:AddColumn("session_id", "String", false)
    errorDataTable:AddColumn("timestamp", "Date", false)
    errorDataTable:AddColumn("error_content", "String", false)

    Midas:Automate(RunService:IsStudio())   
end

function Analytics.updateDataTable(plr : Player, dataSetName : string, dataTableName : string, plrInfo : PlayerManager ?, addParamsFn : (() -> ... any )?)
    assert((dataSetName ~= "Events") or (dataSetName == "Events" and addParamsFn), "Events must have event params passed within it!")
  
    local currentTimeStamp = plr:GetAttribute("JoinedTimestamp") or DateTime.now().UnixTimestamp
    plr:SetAttribute("JoinedTimestamp", currentTimeStamp)

    local dataSet = Midas:GetDataSet(dataSetName)
    assert(dataSet)
    local dataTable : Midas.DataTable<{any}> = dataSet:GetDataTable(dataTableName)
    assert(dataTable)
    if dataSetName == "Server" then
        if dataTableName == "Population" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart

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
            })
        elseif dataTableName == "Performance" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            assert(plrInfo, "Player info not found!")

            local ping = addParamsFn()
            
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                user_id = plr.UserId,
                timestamp = DateTime.now(),
                frame_rate = if plrInfo then plrInfo.Framerate else nil,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
                ping = ping
            })
        end
    elseif dataSetName == "User" then
        if dataTableName == "Map" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
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
            local dataStoreManager = DatastoreManager.get(plr)
            local firstSession = dataStoreManager.SessionIds[1]
            local firstSessionQuitTime = firstSession.JoinTime 
            local currentSession = dataStoreManager.CurrentSessionData

            local duration_after_joined = DateTime.now().UnixTimestamp - currentSession.JoinTime
            local play_duration = if currentSession.QuitTime then (currentSession.QuitTime - currentSession.JoinTime) else nil
            --print(firstSessionQuitTime, firstSession)
            --print(firstSession ~= currentSession, currentTimeStamp, firstSessionQuitTime, " debug") 
            local event_name, ab_value = addParamsFn()

            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,

                is_retained_on_d0 = if plrInfo and firstSessionQuitTime then  (if (firstSession ~= currentSession) and (currentTimeStamp) and (firstSessionQuitTime) and (currentTimeStamp - firstSessionQuitTime) <= 60*60*24*1 then true elseif (currentTimeStamp - firstSessionQuitTime) > 60*60*24*1 then false else nil) else nil,
                is_retained_on_d1 = if plrInfo and firstSessionQuitTime then (if firstSession ~= currentSession and (currentTimeStamp)  and (firstSessionQuitTime) and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*1) and  (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(1 + 1))) then true elseif (currentTimeStamp - firstSessionQuitTime) > 60*60*24*(1 + 1) then false else nil) else nil,
                is_retained_on_d7 = if plrInfo and firstSessionQuitTime then (if firstSession ~= currentSession and (currentTimeStamp)  and (firstSessionQuitTime) and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*7) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(7 + 1))) then true elseif (currentTimeStamp - firstSessionQuitTime) > 60*60*24*(7 + 1) then false else nil) else nil,
                is_retained_on_d14 = if plrInfo and firstSessionQuitTime then (if firstSession ~= currentSession and (currentTimeStamp)  and (firstSessionQuitTime) and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*14) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(14 + 1))) then true elseif (currentTimeStamp - firstSessionQuitTime) > 60*60*24*(14 + 1) then false else nil) else nil,
                is_retained_on_d28 = if plrInfo and firstSessionQuitTime then (if firstSession ~= currentSession and (currentTimeStamp)  and (firstSessionQuitTime) and (((currentTimeStamp - firstSessionQuitTime) >= 60*60*24*28) and (currentTimeStamp - firstSessionQuitTime <= 60*60*24*(28 + 1))) then true elseif (currentTimeStamp - firstSessionQuitTime) > 60*60*24*(28 + 1) then false else nil) else nil,
            
                play_duration = play_duration,
                duration_after_joined = duration_after_joined,
                event_name = event_name,
                ab_value = ab_value
            })
            --print(duration_after_joined, " : after joined dur", play_duration, " : play dur")
        elseif dataTableName == "Demography" then
            local device, language, screen_size : Vector2 = addParamsFn()

            if RunService:IsStudio() then print(device, language, screen_size, " : device debug") end

            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,

                device = device,
                language = language,
                account_age = plr.AccountAge,
                screen_size = if screen_size then string.format("%dX%d", math.floor(screen_size.X/200)*200, math.floor(screen_size.Y/200)*200) else nil,
                is_premium = (plr.MembershipType == Enum.MembershipType.Premium)
            })
        end
    elseif dataSetName == "Events" then
        local plrData = if plrInfo then plrInfo:GetData() else nil

        if dataTableName == "Backpack" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName, itemAddedName = addParamsFn()

            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,

                event_name = eventName,
                backpack = if plrData then plrData.Backpack else {},
                item_name = itemAddedName
            })
        elseif dataTableName == "Customization" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName, itemType = addParamsFn()
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
                
                event_name = eventName,
                item_type = itemType,
                character_customization = if plrData then plrData.Character else {},
                job_customization = Jobs.getJob(plr),
            })
        elseif dataTableName == "Vehicles" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName, itemAddedName = addParamsFn()
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,

                event_name = eventName,
                vehicles = if plrData then plrData.Vehicles else {},
                item_name = itemAddedName
            })
        elseif dataTableName == "Houses" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName, houseName = addParamsFn()

            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,
                
                event_name = eventName,
                house_name = houseName
            })
        elseif dataTableName == "Miscs" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName, content = addParamsFn()
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,

                event_name = eventName,
                content = content
            })
        elseif dataTableName == "Interface" then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local charPrimaryPart = char:WaitForChild("HumanoidRootPart") :: BasePart
            
            local eventName = addParamsFn()
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
                pos_x = charPrimaryPart.Position.X,
                pos_z = charPrimaryPart.Position.Z,

                event_name = eventName,
            })
        end
    elseif dataSetName == "Debugs" then
        if dataTableName == "Error" then
            local content = addParamsFn()
            dataTable:AddRow({
                server_id = game.JobId,
                session_id = tostring(math.round(currentTimeStamp)) .. tostring(plr.UserId),
                timestamp = DateTime.now(),
                user_id = plr.UserId,
               
                error_content = content
            })
        end
    end
    --print(Midas:GetDataSets(), " datasets!")
end

return Analytics