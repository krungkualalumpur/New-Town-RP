--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local CustomEnum = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
local BezierUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BezierUtil"))
local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
--types
type Maid = Maid.Maid
--constants
local DOCKING_TIME = 30
--variables
--references
local harbour = workspace:WaitForChild("Assets"):WaitForChild("Infrastructures"):WaitForChild("Harbour")
--local functions
local function make3DArray(x : number, y : number, z : number, fn : (x : number, y : number, z : number) -> any)
	local array = {}
	for x = 1, math.floor(x) do
		array[x] = {}
		for y = 1, math.ceil(y) do
			array[x][y] = {}
			for z = 1, math.floor(z) do
				array[x][y][z] = fn(x, y, z)
			end	
		end
	end
	return array
end

function PlaySound(id, parent, volumeOptional: number ?, maxDist : number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = maxDist or 150
    s.Looped = false
    s.Parent = parent
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end
    
local function declareDockedShip(dockSlot : BasePart, ship : Model ?)
    for _,v in pairs(dockSlot:GetChildren()) do
        if v:IsA("ObjectValue") then
            local crane = v.Value
            if crane then
                local dockedShipPointer = crane:FindFirstChild("DockedShip")
                assert(dockedShipPointer and dockedShipPointer:IsA("ObjectValue"), 'Docked ship value not found in the crane!')
                dockedShipPointer.Value = ship
            end
        end
    end
end

local function getShipContainerCount(ship : Model)
    return #ship:WaitForChild("Cargo"):GetChildren()
end

local function updateShipContainers(ship : Model, cargoCount : number)
	local cargoZone = ship:WaitForChild("CargoZone") :: BasePart
	local cargos = ship:WaitForChild("Cargo") :: Folder
	local cargoPart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Artificial"):WaitForChild("CargoPart") :: BasePart

	local cargoLength, cargoHeight, cargoWidth = cargoZone.Size.X/cargoPart.Size.X, cargoZone.Size.Y/cargoPart.Size.Y, cargoZone.Size.Z/cargoPart.Size.Z

	local array = make3DArray(cargoLength, cargoHeight, cargoWidth, function(x, y, z)
		return Vector3.new(x, y, z)
	end)
	
	local realCargoCount = 0
	
	cargos:ClearAllChildren()
	for x,xTbl in pairs(array) do
		for y,yTbl in pairs(xTbl) do
			for z, v3 in pairs(yTbl) do
				realCargoCount += 1
				if realCargoCount <= cargoCount then
					local newCargoPart = cargoPart:Clone()
					newCargoPart.Color = Color3.fromRGB(math.random(25,155), math.random(25,155), math.random(25,155))
					--newCargoPart.CFrame = (cargoZone.CFrame - Vector3.new(cargoZone.Size.X*0.5 + cargoPart.Size.X*0.5, cargoZone.Size.Y*0.5 + cargoPart.Size.Y*0.5, cargoZone.Size.Z*0.5 + cargoPart.Size.Z*0.5)) + Vector3.new(v3.X*newCargoPart.Size.X, v3.Y*newCargoPart.Size.Y, v3.Z*newCargoPart.Size.Z)
					local baseCf = (cargoZone.CFrame):ToWorldSpace(CFrame.new(v3*cargoPart.Size) - (
						Vector3.new(cargoZone.Size.X*0.5 + newCargoPart.Size.X*0.5, cargoZone.Size.Y*0.5 + newCargoPart.Size.Y*0.5, cargoZone.Size.Z*0.5 + newCargoPart.Size.Z*0.5)
					))
					
					newCargoPart.CFrame = baseCf	
                    newCargoPart.Parent = cargos
					for _,v in pairs(newCargoPart:GetChildren()) do
						if v:IsA("Texture") then
							v.Color3 = newCargoPart.Color
						end
					end
				else
					break
				end
			end

		end
	end
end


local function spawnShip()
    --print("Trigerreddeeh!")
    local rawApproachingPoints = {}
    local rawLeavingPoints = {}
    
    local paths = harbour:WaitForChild("ShipPaths"):GetChildren()
    local path = paths[math.random(1, #paths)]

    local startNumAfterDock : number 
   
    for _,v in pairs(path:GetChildren()) do
        local k = v:GetAttribute("Order")
        if v:GetAttribute("IsDock") == true then
            startNumAfterDock = k
            break
        end
    end
    if startNumAfterDock then
        for _,v in pairs(path:GetChildren()) do
            local k = v:GetAttribute("Order")
            if k and k > startNumAfterDock then
                rawLeavingPoints[(k + 1) - startNumAfterDock] = v.CFrame
            elseif k and k < startNumAfterDock then
                rawApproachingPoints[k] = v.CFrame
            elseif k and k == startNumAfterDock then
                rawApproachingPoints[k] = v.CFrame
                rawLeavingPoints[(k + 1) - startNumAfterDock] = v.CFrame
            end
        end

    end
    local ship = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Artificial"):WaitForChild("CargoShip"):Clone()
    ship.Parent = workspace:WaitForChild("Assets"):WaitForChild("Temporaries")

    --testig
    updateShipContainers(ship, math.random(5,10))
    
    local approachingBezierPoints : {CFrame} = {}  
    pcall(function() 
        approachingBezierPoints = BezierUtil.bezierify(rawApproachingPoints, CustomEnum.BezierQuality.High)
        table.insert(approachingBezierPoints, rawApproachingPoints[#rawApproachingPoints])
    end)
    local leavingBezierPoints : {CFrame} = {}
    pcall(function() 
        leavingBezierPoints = BezierUtil.bezierify(rawLeavingPoints, CustomEnum.BezierQuality.High) 
        table.insert(leavingBezierPoints, 1, rawLeavingPoints[1])
    end)

    do
        local i = 0
        for k,v in pairs(approachingBezierPoints) do

            local currentPoint = approachingBezierPoints[k]
            local nextPoint = approachingBezierPoints[k + 1]
            if currentPoint and nextPoint then
                repeat task.wait() 
                    i += 0.008
                    ship:PivotTo(currentPoint:Lerp(nextPoint, i))
                until i > 1; i = 0
                
            --[[local conn 
                conn = RunService.Stepped:Connect(function()
                    i += 0.005
                    if i < 1 then
                        ship:PivotTo()
                    else
                        conn:Disconnect()
                    end
                end)
            ]]
            end
        end
    end
    --notifying the cranes that the ship is docked
    local dockPoint
    for _,v in pairs(path:GetChildren()) do
        local k = v:GetAttribute("Order")
        if k == startNumAfterDock then
            dockPoint = v
            break
        end
    end
    if dockPoint then
        declareDockedShip(dockPoint, ship)
        task.wait(DOCKING_TIME)
        declareDockedShip(dockPoint, nil)
    end
    do
        PlaySound(1059214449, ship.PrimaryPart, 10, 160)

        local i = 0
        --repeat task.wait() 
         --   i += 0.008
         --   ship:PivotTo(dockCf:Lerp(startPoint, i))
        --until i > 1; i = 0
        for k,v in pairs(leavingBezierPoints) do

            local currentPoint = leavingBezierPoints[k]
            local nextPoint = leavingBezierPoints[k + 1]
            if currentPoint and nextPoint then
                repeat task.wait() 
                    i += 0.008
                    ship:PivotTo(currentPoint:Lerp(nextPoint, i))
                until i > 1; i = 0
                
            --[[local conn 
                conn = RunService.Stepped:Connect(function()
                    i += 0.005
                    if i < 1 then
                        ship:PivotTo()
                    else
                        conn:Disconnect()
                    end
                end)
            ]]
            end
        end
    end
    ship:Destroy()
end


local function initHarbourCrane(maid : Maid, crane : Model)
    local triggeredInteractableKey = InteractableUtil.getTriggeredAttributeKey()

    local dockedShipPointer = Instance.new("ObjectValue")
    dockedShipPointer.Name = "DockedShip"
    dockedShipPointer.Parent = crane

    local horizontalMover = crane:FindFirstChild("HorizontalMover") :: RodConstraint
    local verticalMover = crane:FindFirstChild("VerticalMover") :: RodConstraint
    local containerDisplay = crane:FindFirstChild("ContainerDisplay") :: BasePart
    local triggers = crane:WaitForChild("Triggers")

    containerDisplay.CanCollide = false
    containerDisplay.Transparency = 1

    local craneIsSendingContainer = false
    for _,v in pairs(triggers:GetChildren()) do
        maid:GiveTask(v:GetAttributeChangedSignal(triggeredInteractableKey):Connect(function()
            local userId : number = v:GetAttribute(triggeredInteractableKey)
            if userId then
                local plrTriggering = Players:GetPlayerByUserId(userId)
                local dockedShip = dockedShipPointer.Value
                if plrTriggering then
                    if dockedShip ~= nil then
                        if craneIsSendingContainer == false then
                            craneIsSendingContainer = true

                            containerDisplay.Transparency = 0
                            verticalMover.Length = 25
                            task.wait(0.8)
                            horizontalMover.Length = 75
                            task.wait(0.8)
                            verticalMover.Length = 42
                            task.wait(0.1)

                            local count = getShipContainerCount(dockedShip)
                            updateShipContainers(dockedShip, count + 1)
                            containerDisplay.Transparency = 1

                            verticalMover.Length = 43
                            horizontalMover.Length = 31

                            task.wait(0.15)
                            craneIsSendingContainer = false
                        elseif craneIsSendingContainer == true then
                            NotificationUtil.Notify(plrTriggering, "Crane is sending the container, please wait.") -- eh
                        end
                    else
                        NotificationUtil.Notify(plrTriggering, "Cargo ship has not arrived yet, please wait.") -- eh
                    end
                end
            end
            return
        end))
    end

end


--class 
local Harbour = {}

function Harbour.init(maid : Maid)
    local cranes = harbour:FindFirstChild("Cranes")
    for _, harbourCrane in pairs(cranes:GetChildren()) do
        initHarbourCrane(maid, harbourCrane)
    end

    local isBuffer = false

    maid:GiveTask(RunService.Stepped:Connect(function()
        if isBuffer == false then
            isBuffer = true
            spawnShip()
            isBuffer = false
        end
    end))
    return
end

return Harbour