--!strict 
---author: @aryoseno11
---contributor: @CJ_Oyer 

--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid

type FunctionData = {
    Function : (t : {any}, k : any, v : any) -> any ?,
    Destroy : (FunctionData) -> nil
}
type OnEvent = {
    Connect : (OnEvent, func : (... any) -> any?) -> FunctionData,
    Destroy : (OnEvent) -> nil
}

export type Zone  = {
    __index : Zone,
    _Maid  : Maid,
    
    new : (ZoneParts : {BasePart} ?, maid : Maid ?) -> Zone,

    ZoneParts : {[number] : Maid},
    PlayersInside : {[number] : Player},
    ItemsInside : {[number] : Instance},
    
    _playerQuitted : {},
	_itemsQuitted : {},
    _zonePartsRemoved : {},

    playerEntered : OnEvent,
    playerExited : OnEvent,
    itemEntered : OnEvent, 
    itemExited : OnEvent,
    
    onZoneAdded : OnEvent,
    onZoneRemoved : OnEvent,
    
    AddZoneInstance : (Zone, zone : Part) -> nil,
    RemoveZoneInstance : (Zone, zone : Part) -> nil,

	Destroy : (Zone) -> nil
}
--constants
local COOLDOWN_TIME = 0.25
--local functions
local function getMetaIndex(haystack : any, needle : any)
	local mt = getmetatable(haystack)
	
	local index
	for k,v in pairs(mt.__index) do
		if v == needle then
			index = k
			break
		end
	end
	return index
end


local function onAddSignal(proxiedTbl, hit)
	local hitIndex = getMetaIndex(proxiedTbl, hit)
	
	local mt = getmetatable(proxiedTbl :: any)
	
	--[[local partRegistered = false-- = if mt and mt.__index then table.find(mt.__index, hit) else nil
	for k,v in pairs(mt.__index) do
		if v == hit then
			partRegistered = true
			break
		end
	end]]
	
	local sum = if mt and mt.__index then #mt.__index else 0
	if not hitIndex then
		--registring the part
		proxiedTbl[sum + 1] = hit
		return true
	end
	return false
end

local function onQuitSignal(proxiedTbl, quitProxiedTbl, hit)
	local index = getMetaIndex(proxiedTbl, hit)
	
	if index then
		proxiedTbl[index] = nil			
		
		local quitmt = getmetatable(quitProxiedTbl :: any)
		local quitIndex = if quitmt and quitmt.__index then #quitmt.__index + 1 else nil
		
		if quitIndex then
			quitProxiedTbl[quitIndex] = hit; quitProxiedTbl[quitIndex] = nil
			return true
		end
	end
	return false
end


local function equipProxy(tbl : any )
	local proxy = tbl 
	proxy._PropertiesProxy = {}
	proxy._Functions = {} 

	setmetatable(proxy, {
		__index = proxy._PropertiesProxy,
		__newindex = function(t,k,v)
			for _,funcData in pairs(proxy._Functions) do
				funcData.Function(proxy._PropertiesProxy, k, (v))
			end 
			
			proxy._PropertiesProxy[k] = v
		end
	})
	return proxy
end

local function GetEvent(proxySetTbl : any , getFilter : ((t : any, k : number | string, v : any ?) -> boolean) ?, passedArguments : ((t : any, k : number | string, v : any ?) -> ... any)? ) : OnEvent
	local OnEvent : OnEvent = {
        Connect = function(self, func : (... any) -> any?) : FunctionData
            local funcData = {
                Function = function(t, k, v)
                    if getFilter and getFilter(t, k, v) or not getFilter then
                        if passedArguments then
							task.spawn(function() 
								func(passedArguments(t,k,v))
							end)
						end
                    end
                end,
                Destroy = function(self)
                    local funcKey = table.find(proxySetTbl._Functions, self)
                    if funcKey then
                        proxySetTbl._Functions[funcKey] = nil
                    end
                end,
            }
            table.insert(proxySetTbl._Functions, funcData)
    
            return funcData
        end,

        Destroy = function(self)
           for k,v in pairs(self) do
                self[k] = nil
            end
        end
    } 

	return OnEvent
end

--module
local Zone = {} :: Zone 
Zone.__index = Zone

function Zone.new(ZoneParts : {BasePart} ?, maid : Maid ?) 
	local self : Zone = setmetatable({}, Zone) :: any
    self._Maid = maid or Maid.new()
	self.ZoneParts = equipProxy({})
	
	self.PlayersInside = equipProxy({})
	self.ItemsInside = equipProxy({})
	
	self._playerQuitted = equipProxy({})
	self._itemsQuitted = equipProxy({})
    self._zonePartsRemoved = equipProxy({})

	self.playerEntered =  self._Maid:GiveTask(GetEvent(self.PlayersInside, function(k, i, v) 
		if type(v) == "table" and v.Player and v.Maid then 
			return true 
		else 
			return false 
		end 
	end, function(k, i, v) -- passed arguments
		return v.Player, v.Zone, v.Maid
	end))
	self.playerExited =  self._Maid:GiveTask(GetEvent(self._playerQuitted, function(k, i, v) 
		if type(v) == "table" and v.Player and v.Maid then 
			return true 
		else 
			return false 
		end 
	end, function(k, i, v) -- passed arguments
		return v.Player, v.Zone, v.Maid
	end))

	self.itemEntered =  self._Maid:GiveTask(GetEvent(self.ItemsInside, function(k, i, v) 
		if v and v.hit and v.Zone then 
			return true 
		else 
			return false 
		end
	end, function(k, i, v) -- passed arguments
		return v.hit, v.Zone, v.Maid
	end))
	self.itemExited =  self._Maid:GiveTask(GetEvent(self._itemsQuitted, function(k, i, v)  --conditions
		if v and v.hit and v.Zone then
			return true 
		else 
			return false 
		end
	end, function(k, i, v) -- passed arguments
		return v.hit, v.Zone, v.Maid
	end))
	
	
	--inits zone
	self.onZoneAdded =  self._Maid:GiveTask(GetEvent(self.ZoneParts, nil, function(k, i, v) -- passed arguments
		return v
	end))
	self.onZoneRemoved =  self._Maid:GiveTask(GetEvent(self._zonePartsRemoved, nil, function(k, i, v) -- passed arguments
		return v
	end))

	local function checkIfInside(zonePart : BasePart, hit : BasePart)
		local pos = hit.Position
		--local snappedPos = NumberUtil.snapVector3(zonePart, pos, 0.1)
		local size = zonePart.Size + Vector3.new(1,1,1)*hit.Size.Magnitude
		local snappedRelativePos = zonePart.CFrame:PointToObjectSpace(pos)--local snappedRelativePos = zonePart.CFrame:PointToObjectSpace(snappedPos)
		--print("X: ", math.floor(math.abs(snappedRelativePos.X)) .. " < =" .. math.ceil(size.X*0.5))
		--print("Y: ", math.floor(math.abs(snappedRelativePos.Y)) .. " < =" .. math.ceil(size.Y*0.5))
		--print("Z: ", math.floor(math.abs(snappedRelativePos.Z)) .. " < =" .. math.ceil(size.Z*0.5))
		if (math.floor(math.abs(snappedRelativePos.X)) <= math.ceil(size.X*0.5)) and  (math.floor(math.abs(snappedRelativePos.Y)) <= math.ceil(size.Y*0.5)) and (math.floor(math.abs(snappedRelativePos.Z)) <= math.ceil(size.Z*0.5)) then 
			return true			
		end

		--if table.find(workspace:GetPartBoundsInBox(zonePart.CFrame, size), hit) then
			--return true
		--end
		return false
	end

	local function onHitEnter(zone, hit)
		--need to roundify number lah
		--if not checkIfInside(part, hit.Position) then return end
		--processing
		local mt = getmetatable(self.ItemsInside :: any)
		local hitInfo
		if mt and mt.__index then 
			for _, existingHitInfo in pairs(mt.__index) do
				if existingHitInfo.hit == hit then
					hitInfo = existingHitInfo
				end
			end
		end
		
		if not hitInfo then
			local enterMaid = Maid.new()
			local success =  onAddSignal(self.ItemsInside, {hit = hit, Zone = zone, Maid = enterMaid}) 

			if success then
				local player = if hit.Parent and hit.Parent:IsA("Model")  and (hit.Parent.PrimaryPart == hit) then game:GetService("Players"):GetPlayerFromCharacter(hit.Parent) else nil
				if player then
					local plrInfo	
					local plrMt = getmetatable(self.PlayersInside :: any)
					if plrMt and plrMt.__index then 
						for _, existingPlrInfo in pairs(plrMt.__index) do
							if existingPlrInfo.Player == player then
								plrInfo = existingPlrInfo
							end
						end
					end
					if not plrInfo then
						onAddSignal(self.PlayersInside, {Player = player, Zone = zone, Maid = Maid.new()})
					end
				end
			end
		end
	end

	local function onHitQuit(zone, hit : BasePart)
		--need to roundify number too here lah (or maybe??)
		--if not checkIfInside(part, hit.Position) then return end
		--processing
		local mt = getmetatable(self.ItemsInside :: any)
		local hitInfo
		if mt and mt.__index then 
			for _, existingHitInfo in pairs(mt.__index) do
				if existingHitInfo.hit == hit then
					hitInfo = existingHitInfo
				end
			end
		end
		
		if not hitInfo then return end
		local success = onQuitSignal(self.ItemsInside, self._itemsQuitted, hitInfo)
		if success then
			hitInfo.Maid:Destroy()  --destroying the maid
			local player = if hit.Parent and hit.Parent:IsA("Model")  and (hit.Parent.PrimaryPart == hit) then game:GetService("Players"):GetPlayerFromCharacter(hit.Parent) else nil
			if player then	
				local plrInfo	
				local plrMt = getmetatable(self.PlayersInside :: any)
				if plrMt and plrMt.__index then 
					for _, existingPlrInfo in pairs(plrMt.__index) do
						if existingPlrInfo.Player == player then
							plrInfo = existingPlrInfo
						end
					end
				end
				if plrInfo then
					onQuitSignal(self.PlayersInside, self._playerQuitted, plrInfo) 
					if plrInfo.Maid then plrInfo.Maid:Destroy(); end
				end
			end
		end
	end

	self._Maid:GiveTask(self.onZoneAdded:Connect(function(_maid : Maid)
        local part : Part = _maid.Zone :: any
		--REMEMBER MAID LATER FOR DIS!
		_maid:GiveTask(part.Touched:Connect(function(hit : BasePart)
			onHitEnter(part, hit)
		end))


		--_maid:GiveTask(part.TouchEnded:Connect(function(hit : Instance)
		--	onHitQuit(part, hit :: BasePart)
		--end))

        _maid:GiveTask(part.Destroying:Connect(function()
            _maid:Destroy()
            self:RemoveZoneInstance(part)
        end))
		
		_maid:GiveTask(RunService.Stepped:Connect(function() --checking whether the zone is destroyed or not
			if self.ZoneParts == nil then
				_maid:Destroy()
			end
		end))
		
		return nil
	end))
	self._Maid:GiveTask(self.onZoneRemoved:Connect(function(_maid : Maid)
		local success = onQuitSignal(self.ZoneParts, self._zonePartsRemoved, _maid)
		if success then
			_maid:Destroy() --destroying the maid
		end
		return nil
	end))
	
	for i,v in pairs(ZoneParts or {}) do
        local _maid = Maid.new()
        _maid.Zone = v
        print(v, _maid.Zone)
		self.ZoneParts[i] = _maid
		task.wait()
	end

	--tracking
    self._Maid:GiveTask(self.itemEntered:Connect(function(hit : BasePart, zonePart : BasePart) 
		local _maid = Maid.new()
		_maid:GiveTask(RunService.Stepped:Connect(function()
			local isInside = checkIfInside(zonePart, hit)
			if not isInside then
				_maid:Destroy()
				onHitQuit(zonePart, hit)
			end
		end))

		--detect on distroy...
		_maid:GiveTask(hit.Destroying:Connect(function()
			_maid:Destroy()
			onHitQuit(zonePart, hit)
		end))
		_maid:GiveTask(zonePart.Destroying:Connect(function()
			_maid:Destroy()
		end))

		return nil
	end))

	--test only
	--self._Maid:GiveTask(self.itemExited:Connect(function(v, zonePart)

	--	return nil
	--end))
	
	return self
end

function Zone:AddZoneInstance(zone : Part)
    local mt = getmetatable(self.ZoneParts :: any)
    local index = if mt and mt.__index then #mt.__index else nil
    if index then
        local _maid = Maid.new()
        _maid.Zone = zone
        self.ZoneParts[index + 1] = _maid
    end
    return nil
end

function Zone:RemoveZoneInstance(zone : Part)
    local mt = getmetatable(self.ZoneParts :: any)
    local index, maidInfo-- = if mt and mt.__index then table.find(mt.__index, hit) else nil
    for k,maid in pairs(mt.__index) do
        if maid.Zone :: BasePart == zone then
            index = k; maidInfo = maid
            break
        end
    end
    
    if index and maidInfo then
     	local success = onQuitSignal(self.ZoneParts, self._zonePartsRemoved, maidInfo)	
		if success then
			maidInfo:Destroy()
		end
        --self._itemsQuitted[1] = hit
        --print("Prabowo ", index)
    end
    
    return nil
end

function Zone:Destroy()
	self._Maid:Destroy()

	local t = self :: any
	for k,v in pairs(t) do
		
		local mt = getmetatable(v)
		if mt then setmetatable(v, nil) end
		
		t[k] = nil
	end

	setmetatable(self, nil)
	return nil
end

return Zone