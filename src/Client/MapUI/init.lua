--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local LineUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LineUtil"))
--local Pathfind = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Pathfind"))

local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>  

export type MapHUD = {
    __index : MapHUD,
    _Maid : Maid,
    Destination : ValueState<Vector3 ?>,
    Instance : GuiObject,
    Text : ValueState<string ?>,
    new : ( 
        maid : Maid,
        PlayerCFrame : ValueState<CFrame>,
        isVisible : State<boolean>,
        IntDest : Vector3 ?,
        intText : string ?
    ) -> MapHUD,
    Destroy : (MapHUD) -> nil
}

--constants
local PADDING_SIZE = UDim.new(0, 10)

local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)

local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(101,101,101)

local SCALE = 20

local DESTINATION_ARRIVE_DISTANCE = 16
--remotes
local GET_AB_VALUE = "GetABValue"
--variables

--references

--local function
--[[local function createPathPts(maid : Maid, fuse : Fuse, roadsModel : Model)
    local _new = fuse.new
    local pathPoints = maid:GiveTask(_new("Folder")({
    })) :: Folder

    local rawPts = maid:GiveTask(_new("Folder")({})) :: Folder
    for _,v : BasePart in pairs(roadsModel:GetChildren() :: any) do
        _new("Folder")({
            Parent = rawPts,
            Children = {
                _new("Part")({
                    Name = "1",
                    CFrame = v.CFrame + v.CFrame.LookVector*v.Size.Z*0.5,
                    Anchored = true
                }),
                _new("Part")({
                    Name = "2",
                    CFrame = v.CFrame - v.CFrame.LookVector*v.Size.Z*0.5,
                    Anchored = true
                }) 
            }
        })
    end
    Pathfind.CreatePathSys(rawPts, pathPoints)
    return pathPoints
end]]

--[[local function generatePathToDestination(pathPoints, start : Vector3, destination : Vector3)
    local startN, endN 

    local minPlrDist = math.huge
    local minDestDist = math.huge 

    for _,v : Part in pairs(pathPoints:GetChildren() :: any) do
        local plrdist = (v.Position - start).Magnitude
        local destdist = (v.Position - destination).Magnitude
        --finding minimum distance of player
        if plrdist < minPlrDist then 
            minPlrDist = plrdist 
            startN = tonumber(v.Name)
        end
        --finding minimum distance of dest
        if destdist < minDestDist then
            minDestDist = destdist
            endN = tonumber(v.Name)
        end
    end
    
   -- task.wait()
    if startN and endN then 
        return Pathfind(pathPoints, startN, endN)
    end
end

local function generateVisualPath(pathFindResult : {[number] : {Cost : number, N : number}}, pathPoints : Instance, startPoint : Vector3 ?, endPoint : Vector3 ?)
    local visualPathFolder = Instance.new("Folder")
    for k,v in pairs(pathFindResult) do
        local point = pathPoints:FindFirstChild(tostring(v.N)) :: BasePart
        local prevPoint = pathPoints:FindFirstChild(tostring(if pathFindResult[k - 1] then pathFindResult[k - 1].N else nil)) :: BasePart
        if point and prevPoint then
            local part = Instance.new("Part")
            part.Size = Vector3.new(100,10,10) 
            part.Color = Color3.fromRGB(250,250,50)
            part.Anchored = true
            part.Parent = visualPathFolder
            local lineInst = LineUtil.getLineFromTwoPoints(point.Position, prevPoint.Position, part)
            if lineInst then lineInst.Parent = visualPathFolder end
            if lineInst then
                if (k - 1) == 1 then
                    if startPoint then
                        local getIntersectPoint = LineUtil.getPerpendicularPointToALine(point.Position, prevPoint.Position, startPoint)
                        lineInst:Destroy()

                        lineInst = LineUtil.getLineFromTwoPoints(getIntersectPoint, point.Position, part)
                        lineInst.Parent = visualPathFolder
                    end
                elseif (k - 1) == #pathFindResult then
                    if endPoint then
                        local getIntersectPoint = LineUtil.getPerpendicularPointToALine(point.Position, prevPoint.Position, endPoint)
                        lineInst:Destroy()

                        lineInst = LineUtil.getLineFromTwoPoints(getIntersectPoint, point.Position, part)
                        lineInst.Parent = visualPathFolder
                    end
                end
            end

        end
    end 
 
    return visualPathFolder
end ]]
--
local currentMapHUD : MapHUD

local mapHUD = {} :: MapHUD
mapHUD.__index = mapHUD

function mapHUD.new(
    maid : Maid,
    PlayerCFrame : ValueState<CFrame>,
    isVisible : State<boolean>,
    IntDest : Vector3 ?,
    intText : string ?
)
  
    local buildings = workspace:WaitForChild("Assets"):WaitForChild("Buildings"):GetChildren()
    for _,v in pairs(workspace:WaitForChild("Assets"):WaitForChild("Shops"):GetChildren()) do
        if v:IsA("Model") then
            table.insert(buildings, v)
        end
    end
    for _,v in pairs(workspace:WaitForChild("Assets"):WaitForChild("Houses"):GetChildren()) do
        if v:IsA("Model") then
            table.insert(buildings, v)
        end
    end


    local fuse = ColdFusion.fuse(maid)

    local _new = fuse.new
    local _import = fuse.import
    local _bind = fuse.bind

    local _Value = fuse.Value
    local _Computed = fuse.Computed

    local Destination : ValueState<Vector3 ?> = _Value(IntDest)
    local IntText : ValueState<string ?> = _Value(nil :: string ?)
    --roads
    local roadsModel = maid:GiveTask(workspace:WaitForChild("Assets"):WaitForChild("Roads"):Clone())
    for _,v in pairs(roadsModel:GetChildren()) do
        if v:IsA("BasePart") then
            v.Color = PRIMARY_COLOR
            v.Material = Enum.Material.SmoothPlastic
            v.Transparency = 0.8
        end
        if #v:GetChildren() > 0 or not v:IsA("Part") then
            v:Destroy()
        end
    end

    local camera = _new("Camera")({
        CFrame = _Computed(function(cf : CFrame)
            local camCFrame = if workspace.CurrentCamera then workspace.CurrentCamera.CFrame else nil
            local posDir = (camCFrame.Position - cf.Position).Unit
            return if posDir then CFrame.lookAt(cf.Position + Vector3.new(posDir.X*15,10,posDir.Z*15)*SCALE, cf.Position) else CFrame.lookAt(cf.Position - cf.LookVector*10*SCALE + cf.UpVector*10*SCALE, cf.Position) 
        end, PlayerCFrame)
    }) :: Camera

    --buildings
    local buildingsModel = _new("Model")({}) --maid:GiveTask(workspace:WaitForChild("Assets"):WaitForChild("Buildings"):Clone())
    for _,v in pairs(buildings) do
        if v:IsA("Model") then
            local columnsModel = v:FindFirstChild("Columns") :: Model?
            local cf, size = nil, nil 
            if columnsModel then cf, size = columnsModel:GetBoundingBox() else cf, size = v:GetBoundingBox() end
            
            _new("Part")({
                CFrame = cf,
                Size = size,
                Color = Color3.fromRGB(10,10,10),
                Transparency = 0.85,
                Parent = buildingsModel
            })
        elseif v:IsA("Folder") then
            for _,model in pairs(v:GetChildren()) do
                if model:IsA("Model") then 
                    local cf, size = model:GetBoundingBox()
                    _new("Part")({
                        CFrame = cf, 
                        Size = size,
                        Color = Color3.fromRGB(10,10,10),
                        Transparency = 0.1,
                        Parent = buildingsModel 
                    })
                end
            end  
        end
    end

   -- local pathPoints = createPathPts(maid, fuse, roadsModel)   

    local arrow = _new("Part")({
        CFrame = _Computed(function(cf : CFrame)
            return cf*CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0))
        end, PlayerCFrame), 
        Color = Color3.fromRGB(50,255,0),
        Transparency = 0.2,
        Children = {
            _new("SpecialMesh")({
                MeshId = "rbxassetid://4752170935",
                Scale = Vector3.new(1.25*SCALE,0.5*SCALE,2*SCALE)
            }) 
        }
    }) :: BasePart


    local visualFolder = _new("Folder")({})
    local worldModel = _new("WorldModel")({
        Children = {
            roadsModel,
            buildingsModel,
            arrow,
            --pathPoints,
            visualFolder
        }
    })

    local out = _new("Frame")({
        Visible = isVisible,
        Position = UDim2.fromScale(0.01, 0.78),
        Size = UDim2.fromScale(0.21, 0.21),
        BackgroundTransparency = 0.75,
        BackgroundColor3 = SECONDARY_COLOR,
        Children = {
            _new("UIAspectRatioConstraint")({}),
            _new("ViewportFrame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                CurrentCamera = camera,
                Children = {
                    worldModel
                }
            }),
            _new("UIStroke")({
                Thickness = 1.5,
                Color = PRIMARY_COLOR
            })            
        }
    }) :: Frame

    --pathfinding demonstration

    local destIconImage = _Value("rbxassetid://6309764044")
    local destIconDynamicSize = _Value(UDim2.new())

    local destIcon = maid:GiveTask(_new("ImageLabel")({
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromScale(0.2, 0.2),
        Image = destIconImage, 
        BackgroundTransparency = 1,
        Parent = out,
        Children = { 
            _new("TextLabel")({
                Name = "DistanceText",
                AnchorPoint = Vector2.new(0,0.5),
                BackgroundColor3 = SECONDARY_COLOR,
                TextColor3 = PRIMARY_COLOR,
                BackgroundTransparency = 0.5,
                Size = UDim2.fromScale(1.2, 0.5),  
                Position = UDim2.fromScale(1, 0.5),
                Text = _Computed(function(cf : CFrame, destination : Vector3 ?)
                    local dist = if destination then ((destination - cf.Position).Magnitude/3.571)/1000 else 0
                    return if dist and dist >= 1 then string.format("%.2f km", dist) elseif dist then string.format("%.1f m", dist*1000) else ""
                end, PlayerCFrame, Destination)
            })
        }
    })) :: ImageLabel

    for _,v in pairs(buildings) do
        local iconImage = v:GetAttribute("MapIcon")
        if v:IsA("Model") and iconImage then
            destIconDynamicSize:Set(UDim2.fromScale(0, 0))
            local pointFX = destIcon:Clone()
            pointFX:ClearAllChildren()
            _bind(pointFX)({
                Size = destIconDynamicSize:Tween(1.2),
                --Size = _Value(UDim2.fromScale(0.08, 0.08)):Tween(0.5),
                Image = "rbxassetid://" .. tostring(iconImage),
            })
            local cf, _ = v:GetBoundingBox()
            maid:GiveTask(RunService.Stepped:Connect(function()
                local intViewportPos, isOnSight = camera:WorldToViewportPoint(cf.Position)

                pointFX.Visible = isOnSight

                if pointFX.Visible then
                    local x = intViewportPos.X*out.AbsoluteSize.X  
                    local y =  intViewportPos.Y*out.AbsoluteSize.Y   
                    pointFX.Position = UDim2.fromOffset( 
                        math.clamp(x, 0, out.AbsoluteSize.X), 
                        math.clamp(y, 0, out.AbsoluteSize.Y)   
                    )      
                end
            end))
            pointFX.Parent = out
            destIconDynamicSize:Set(UDim2.fromScale(0.08, 0.08))
        end 
    end


    _Computed(function(cf : CFrame, destination : Vector3 ?)
        visualFolder:ClearAllChildren()
        destIcon.Parent = nil
        if destination then
            --local pathFindResult = generatePathToDestination(pathPoints, cf.Position, destination )
        -- print(pathFindResult) 
            --if pathFindResult then
                --local visuals = generateVisualPath(pathFindResult, pathPoints, arrow.Position, destination)
                --visuals.Parent = visualFolder 

            
        --[[ else
                pathPoints:Destroy()
                pathPoints = createPathPts(maid, fuse, roadsModel)   
                pathPoints.Parent = worldModel
                print("recreating path points")]]
            --end    

            --making waypoint
            local outParent = out.Parent :: GuiObject

            local intViewportPos, isOnSight = camera:WorldToViewportPoint(destination)
        -- destIcon.Position = UDim2.fromOffset(math.clamp(intViewportPos.X*out.AbsoluteSize.X, out.AbsolutePosition.X - out.AbsoluteSize.X*0.5, out.AbsolutePosition.X + out.AbsoluteSize.X*0.5), math.clamp(intViewportPos.Y*out.AbsoluteSize.Y, out.AbsolutePosition.Y - out.AbsoluteSize.Y*0.5, out.AbsolutePosition.Y + out.AbsoluteSize.Y*0.5))
            if not outParent then return nil end
            
            local x = intViewportPos.X*out.AbsoluteSize.X  
            local y =  intViewportPos.Y*out.AbsoluteSize.Y   
            destIcon.Parent = out

            destIcon.Position = UDim2.fromOffset( 
                math.clamp(x, 0, out.AbsoluteSize.X), 
                math.clamp(y, 0, out.AbsoluteSize.Y)   
            )      
            
            if not isOnSight then
                destIconImage:Set("rbxassetid://6677276258")
                destIcon.ImageColor3 = Color3.fromRGB(255,0,0)
                destIcon.Size = UDim2.fromScale(0.1, 0.1)
            else
                destIconImage:Set("rbxassetid://6309764044")
                destIcon.ImageColor3 = Color3.fromRGB(255,255,255)
                destIcon.Size = UDim2.fromScale(0.2, 0.2)
            end

            if (destination - cf.Position).Magnitude <= DESTINATION_ARRIVE_DISTANCE then
                Destination:Set(nil)
            end
        end
        return nil          
    end, PlayerCFrame :: ValueState<CFrame>, Destination :: ValueState<Vector3 ?>)

    local textMaid = maid:GiveTask(Maid.new())
    _Computed(function(str : string ?)
        textMaid:DoCleaning()
        local textPos = textMaid:GiveTask(_Value(UDim2.fromScale(0, -1.5)))
        local transp = textMaid:GiveTask(_Value(1))

        if str then
            textMaid:GiveTask(_new("Frame")({
               
                BackgroundTransparency = transp:Tween(),
                BackgroundColor3 = SECONDARY_COLOR,
                Size = UDim2.fromScale(1, 0.2),
                Position = textPos:Tween(),
                Parent = out,
                Children = {
                    _new("UIGradient")({
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,0))
                        },
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        }),
                        Rotation = 90
                    }),
                    _new("TextLabel")({
                        BackgroundTransparency = 1,
                        TextTransparency = transp:Tween(),
                        TextStrokeTransparency = 0.85,
                        Size = UDim2.fromScale(1, 1),
                        Text = str,
                        TextColor3 = PRIMARY_COLOR,
                    })
                }
            }))
        end 
        textPos:Set(UDim2.fromScale(0, -0.35))
        transp:Set(0)
        print(str) 
        return nil
    end, IntText)

    --getting other plrs
    local function onPlrAdded(plr : Player)
        if (plr ~= Players.LocalPlayer) then
            local plrMaid = Maid.new()
            --making waypoint
            local plrFuse = ColdFusion.fuse(plrMaid)
            local _new = plrFuse.new
            local _Value = plrFuse.Value
            
            --local outParent = out.Parent :: GuiObject
            local plrIconImage = _Value("rbxassetid://6677276258")


            local plrLabel = _new("TextLabel")({
                Name = "PlayerName",
                AnchorPoint = Vector2.new(0,0.5),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = SECONDARY_COLOR,
                TextSize = 12,
                TextColor3 = PRIMARY_COLOR,
                BackgroundTransparency = 0.5,
                Position = UDim2.fromScale(1, 0.5),
                Text = plr.Name
            }) :: TextLabel

            local plrIcon = _new("ImageLabel")({
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1, 
                Size = UDim2.fromScale(0.075, 0.075),
                Image = plrIconImage, 
                ImageColor3 = Color3.fromRGB(77, 180, 74),
                Parent = out,
                Children = { 
                    plrLabel
                }
            }) :: ImageLabel

            plrMaid:GiveTask(plr.AncestryChanged:Connect(function()
                if plr.Parent == nil then
                    plrMaid:Destroy()
                end
            end))
            
            local t = tick()
            plrMaid:GiveTask(RunService.Stepped:Connect(function()
                local dt = tick() - t
                if dt >= 0.1 then
                    t = tick()

                    local char = plr.Character 

                    if (char ~= nil) and (char.PrimaryPart ~= nil) then
                        local intViewportPos, isOnSight = camera:WorldToViewportPoint(char.PrimaryPart.Position)
                        --destIcon.Position = UDim2.fromOffset(math.clamp(intViewportPos.X*out.AbsoluteSize.X, out.AbsolutePosition.X - out.AbsoluteSize.X*0.5, out.AbsolutePosition.X + out.AbsoluteSize.X*0.5), math.clamp(intViewportPos.Y*out.AbsoluteSize.Y, out.AbsolutePosition.Y - out.AbsoluteSize.Y*0.5, out.AbsolutePosition.Y + out.AbsoluteSize.Y*0.5))
                            
                        local x = intViewportPos.X*out.AbsoluteSize.X  
                        local y =  intViewportPos.Y*out.AbsoluteSize.Y   
                        plrIcon.Parent = out

                        plrIcon.Position = UDim2.fromOffset( 
                            math.clamp(x, 0, out.AbsoluteSize.X), 
                            math.clamp(y, 0, out.AbsoluteSize.Y)    
                        )      
            
                        if not isOnSight then
                            plrIcon.AnchorPoint = Vector2.new(0.5, 1)
                            plrIcon.ImageColor3 = Color3.fromRGB(255,255,255)
                            plrIcon.Size = UDim2.fromScale(0.05, 0.05)
                            plrLabel.Visible = false
                        else
                            plrIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                            plrIcon.ImageColor3 = Color3.fromRGB(77, 180, 74)
                            plrIcon.Size = UDim2.fromScale(0.075, 0.075)
                            plrLabel.Visible = true
                        end
                    end
                end
                
            end))
        end
    end
    
    if RunService:IsRunning() then
        local ABValue : "A"|"B" = NetworkUtil.invokeServer(GET_AB_VALUE)
        --print(ABValue, " abvalue ?")
        if ABValue == "A" then
            for _,plr in pairs(Players:GetPlayers()) do
                onPlrAdded(plr)
            end       
            
            maid:GiveTask(Players.PlayerAdded:Connect(function(plr : Player)
                onPlrAdded(plr)
            end))        
        end
    end

    local self : MapHUD = setmetatable({}, mapHUD) :: any
    self._Maid = maid
    self.Destination = Destination
    self.Instance = maid:GiveTask(out)
    self.Text = IntText
    
    currentMapHUD = self

    return self
end

function mapHUD:Destroy()
    self._Maid:Destroy()

    for k,v in pairs(self) do
        self[k] = nil
    end

    setmetatable(self, nil)
    return nil
end

return ServiceProxy(function()
    return currentMapHUD or mapHUD 
end)