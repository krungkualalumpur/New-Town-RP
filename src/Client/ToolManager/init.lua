--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))
local Fishes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Fishing"))

local PhoneDisplay = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ToolManager"):WaitForChild("PhoneDisplay")) 
--types
type Maid = Maid.Maid
type Signal = Signal.Signal
--constants
local WRITING_MAX_DISTANCE = 20
local TOOL_IS_WRITING_KEY = "IsWriting"
local WRITING_MAX_PTS = 50
--remotes
local ADD_BACKPACK = "AddBackpack" 
local ON_TOOL_ACTIVATED = "OnToolActivated"

local ON_WRITING_FINISHED = "OnWritingFinished"

local ON_PHONE_MESSAGE_START = "OnPhoneMessageStart"
--variables
--references
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ToolsAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools")
local target = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") :: ScreenGui

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("Assets"):GetChildren()}
--local functions


function PlaySound(id, parent, volumeOptional: number ?, maxDistance : number ?)
    local s = Instance.new("Sound")

    s.Name = "Sound"
    s.SoundId = `rbxassetid://{id}`
    s.Volume = volumeOptional or 1
    s.RollOffMaxDistance = maxDistance or 35
    s.Looped = false
    s.Parent = parent or Player:FindFirstChild("PlayerGui")
    s:Play()
    task.spawn(function() 
        s.Ended:Wait()
        s:Destroy()
    end)
    return s
end
 

--class
local ToolManager = {}

function ToolManager.init(maid : Maid)
    local onMessageSend = maid:GiveTask(Signal.new())
    local onMessageRecieve = maid:GiveTask(Signal.new())
   
    local phoneUI = PhoneDisplay(maid, onMessageSend, onMessageRecieve)

    local function onToolOnBackpack(toolHeld : Tool, char : Model)
        local tool = BackpackUtil.getToolFromName(toolHeld.Name)
        if tool then
            local _maid = Maid.new()
    
            local toolData = BackpackUtil.getData(tool ,false)
            if toolData.Name == "Pencil" then
                local pencilMaid = _maid:GiveTask(Maid.new())
                local pts = {}
                _maid:GiveTask(toolHeld:GetAttributeChangedSignal(TOOL_IS_WRITING_KEY):Connect(function()
                    --print(toolHeld, toolHeld:GetAttribute(TOOL_IS_WRITING_KEY))
                    if toolHeld:GetAttribute(TOOL_IS_WRITING_KEY) then
                        pencilMaid.Conn = RunService.RenderStepped:Connect(function()
                            if #pts <= WRITING_MAX_PTS then
                                local camera = workspace.CurrentCamera
                                local origin, direction = camera.CFrame.Position, (Mouse.Hit.Position - camera.CFrame.Position).Unit*WRITING_MAX_DISTANCE 
                                local ray = workspace:Raycast(origin, direction, raycastParams)
    
                                if ray then
                                    local part = pencilMaid:GiveTask(Instance.new("Part"))
                                    part.Color = Color3.fromRGB(0,0,0)
                                    part.Size = Vector3.new(0.25,0.25,0.25)
                                    part.Anchored = true
                                    part.Position = ray.Position
                                    part.Parent = toolHeld
                                    table.insert(pts, ray.Position)
                                else
                                    NotificationUtil.Notify(Player, "Surface too far for writing!")
                                end
                            else
                                NotificationUtil.Notify(Player, "Already reached max writing amount!")
                                pencilMaid.Conn = nil
                            end
                        end)
                    else
                        NetworkUtil.fireServer(ON_WRITING_FINISHED, pts)
    
                        table.clear(pts)
                        pencilMaid:DoCleaning() 
                    end
                end))  
            elseif toolData.Class == "Phone" then
                
                phoneUI.Parent = target
    
            end
    
            _maid:GiveTask(toolHeld.AncestryChanged:Connect(function()
                if not toolHeld:IsDescendantOf(char) then
                    _maid:Destroy()

                    if toolData.Class == "Phone" then
                        phoneUI.Parent = nil
                    end
                end
            end))
        end
    end
   
   
    local function onCharAdded(char : Model)
        local _maid = Maid.new()

        _maid:GiveTask(char.ChildAdded:Connect(function(toolHeld : Instance)
            if toolHeld:IsA("Tool") then
                onToolOnBackpack(toolHeld, char)
            end
        end))

        _maid:GiveTask(char.AncestryChanged:Connect(function()
            if char.Parent == nil then
                _maid:Destroy()
            end
        end))
    end

    local function onPlayerAdded(plr : Player)
        local _maid = Maid.new()
        local char =  plr.Character or plr.CharacterAdded:Wait()
        onCharAdded(char)
        _maid:GiveTask(plr.CharacterAdded:Connect(onCharAdded))
        _maid:GiveTask(plr.AncestryChanged:Connect(function()
            if plr.Parent == nil then
                _maid:Destroy()
            end
        end))
    end

    local function onPlayerRemoving(plr : Player)
        
    end

    onPlayerAdded(Player)

    local toolMaid = maid:GiveTask(Maid.new())

    maid:GiveTask(NetworkUtil.onClientEvent(ON_TOOL_ACTIVATED, function(toolClass : string, player : Player, toolData : BackpackUtil.ToolData<nil>, plrInfo : any, isReleased : boolean?)
        local character = player.Character or player.CharacterAdded:Wait()
        if toolClass == "Fishing Rod" then
            local toolInst : Tool 
            for _,v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and toolData.Name == v.Name then
                    toolInst = v
                    break
                end
            end
            assert(toolInst)
            --local mouse = Player:GetMouse() :: Mouse
            local camera = workspace.CurrentCamera
            local mouseLocation = UserInputService:GetMouseLocation()
            local viewportPointRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
            local ray = Ray.new(viewportPointRay.Origin, viewportPointRay.Direction * 1000)
            
            local hit, position, normal, material = workspace:FindPartOnRay(ray)

            if hit then
                if material ~= Enum.Material.Water then
                    NotificationUtil.Notify(Player, "You can only do fishing on water!")
                    return 
                end
                
                --local camera = workspace.CurrentCamera
                local toolModel = toolInst:FindFirstChild(toolInst.Name)
                local baitHolder = if toolModel then toolModel:FindFirstChild("BaitHolder") :: BasePart ? else nil
                if baitHolder then

                    if (baitHolder.Position - position).Magnitude >= 80 then
                        NotificationUtil.Notify(Player, "Bait is too far!")
                        return
                    end

                    toolMaid:DoCleaning()

                    local localMaid = toolMaid:GiveTask(Maid.new())
                    local startCf = baitHolder.CFrame
                    local endCf = CFrame.new(position)
                    local p = toolMaid:GiveTask(Instance.new("Part"))
                    p.Shape = Enum.PartType.Ball
                    p.CFrame = baitHolder.CFrame
                    p.Size = Vector3.new(1,1,1)
                    --p.Anchored = true 
                    p.Massless = true
                    p.CanCollide = true
                    p.Parent = workspace

                    local attachment0 = toolMaid:GiveTask(Instance.new("Attachment")) :: Attachment
                    local attachment1 = toolMaid:GiveTask(Instance.new("Attachment")) :: Attachment

                    attachment0.Parent = baitHolder
                    attachment1.Parent = p

                    local rope = toolMaid:GiveTask(Instance.new("RopeConstraint")) :: RopeConstraint
                    rope.Attachment0 = attachment0
                    rope.Attachment1 = attachment1
                    rope.Visible = true
                    rope.Thickness = 0.1
                    rope.Parent = toolModel

                    for x = 0, 1, 0.05 do
                        local v3 = Vector3.new(0,startCf.Position.Y,0):Lerp(Vector3.new(0,endCf.Position.Y*2,0), x):Lerp(Vector3.new(0,endCf.Position.Y,0), x)
                        
                        local v32 = Vector3.new(startCf.Position.X, 0, startCf.Position.Z):Lerp(Vector3.new(endCf.Position.X, 0, endCf.Position.Z), x)
                        local pos = v32 + v3
                        p.Position = pos

                        rope.Length = (baitHolder.Position - pos).Magnitude*1
                        task.wait()
                    end
                    PlaySound(9120584671, p, 100, 350)

                    p.Transparency = 1

                    local _fuse = ColdFusion.fuse(toolMaid)
                    local _new = _fuse.new
                    
                    local _Value = _fuse.Value

                    local waterSplashFX = _new("ParticleEmitter")({
                        Enabled = true,
                        Rate = 15,
                        Lifetime = NumberRange.new(0.6,2),
                        Size = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 7),
                            NumberSequenceKeypoint.new(1, 10)
                        }),
                        Acceleration = Vector3.new(0,1,0),
                        Texture = "rbxassetid://341774729",
                        SpreadAngle = Vector2.new(-180,180),
                        Speed = NumberRange.new(2),
                        Parent = p
                    }) :: ParticleEmitter
                    print(waterSplashFX)
                    task.wait(0.1)
                    waterSplashFX.Enabled = false

                    local t1 = tick()
                    local t2 = tick()
                    local bufferTime = 3

                    local dynamicIconSize = _Value(UDim2.fromScale(1, 0.8))
                    local smaller = true
                    --size anim
                    toolMaid:GiveTask(RunService.RenderStepped:Connect(function()
                       -- print(tick() - intTick)
                        if tick() - t1 > 0.5 then
                            t1 = tick()
                            smaller = not smaller
                            --print("soize wut?", dynamicIconSize:Get())
                            if not smaller then
                                --print("1")
                                dynamicIconSize:Set(UDim2.fromScale(1, 0.8))
                            else
                                --print('3')
                                dynamicIconSize:Set(UDim2.fromScale(0.6, 0.6))
                            end
                        end
                    end))

                    toolMaid:GiveTask(RunService.RenderStepped:Connect(function()
                        if tick() - t2 > bufferTime then 
                            local luckNum = 3
                            local randNum = math.random(1,3)

                            --print(randNum, luckNum, randNum == luckNum)
                            t2 = tick()
                            localMaid:DoCleaning()

                            if randNum == luckNum then
                               

                                local billboardPart = localMaid:GiveTask(_new("Part")({
                                    Position = endCf.Position,
                                    CanCollide = false,
                                    Anchored = true,
                                    Transparency = 1,
                                    Parent = workspace,
                                    Children = {
                                       
                                        _new("BillboardGui")({
                                            ExtentsOffsetWorldSpace = Vector3.new(0,8,0),
                                            Size = UDim2.fromScale(10, 10),
                                            Children = {
                                                _new("Frame")({
                                                    BackgroundTransparency = 1,
                                                    Size = UDim2.fromScale(1, 1),
                                                    Children = {
                                                        _new("UIListLayout")({
                                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                                            HorizontalAlignment = Enum.HorizontalAlignment.Center
                                                        }),
                                                        _new("TextLabel")({
                                                            BackgroundTransparency = 1,
                                                            Size = dynamicIconSize:Tween(0.5),
                                                            Font = Enum.Font.GothamBold,
                                                            Text = "!",
                                                            TextColor3 = Color3.new(0.737255, 0.811765, 0.039216),
                                                            TextStrokeTransparency = 0.6,
                                                            TextScaled = true,
                                                            Children = {
                                                                _new("UICorner")({
                                                                    CornerRadius = UDim.new(20,0),
                                                                }),
                                                                _new("UIStroke")({
                                                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                                                    Color = Color3.new(0.737255, 0.811765, 0.039216),
                                                                })
                                                            }
                                                        }),
                                                        _new("TextLabel")({
                                                            BackgroundTransparency = 1,
                                                            Size = UDim2.fromScale(1, 0.2),
                                                            Font = Enum.Font.Gotham,
                                                            Text = if UserInputService.KeyboardEnabled then "Right-click to catch the fish" else "Touch to catch the fish",
                                                            TextColor3 = Color3.fromRGB(255,255,255),
                                                            TextStrokeTransparency = 0.6,
                                                            TextScaled = true
                                                        })
                                                    }
                                                })
                                            }
                                        })
                                    }
                                }))
                                PlaySound(1584394759)
                                
                                --right click to interacto!
                                localMaid:GiveTask(UserInputService.InputEnded:Connect(function(input, gpe)
                                    if ((input.UserInputType == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Touch)) and not gpe then
                                        
                                        local fishesRarity = Fishes.FishesDataToRarityArray()
                                        local fishData = RarityUtil(fishesRarity)

                                        NetworkUtil.invokeServer(ADD_BACKPACK, fishData.Name)
 
                                        toolMaid:DoCleaning()
                                    end
                                end))
                            end
                        end
                        
                    end))

                    toolMaid:GiveTask(toolInst.AncestryChanged:Connect(function()
                        if toolInst.Parent == nil then
                            toolMaid:DoCleaning()
                        end
                    end))
                    --[[local tween = game:GetService("TweenService"):Create(p, TweenInfo.new(0.1), { --parablola formula stuff
                        CFrame = mouse.Hit
                    })
                    tween:Play()
                    tween.Completed:Wait()]]
                end
            end
            --[[local p = Instance.new("Part")
            p.CFrame = mouse.Hit
            p.Size = Vector3.new(25,25,25)
            p.Anchored = true
            p.CanCollide = true
            p.Parent = workspace]]
        else
            print(toolClass, Player, toolData, nil, isReleased)
            ToolActions.onToolActivated(toolClass, Player, toolData, nil, isReleased)
        end
        return
    end))

    
    maid:GiveTask(onMessageSend:Connect(function(reciever : Player, msgText : string)
        --print("Sendos !, ", type(reciever.Name), type(msgText))
        return 
    end))

    NetworkUtil.onClientInvoke(ON_PHONE_MESSAGE_START, function(senderName : string, msgText : string)
        local sender = Players:FindFirstChild(senderName)
        assert(sender, "Cannot find the sender")
        --print(sender.Name, " sent a message to yah!, ", msgText)
        onMessageRecieve:Fire(sender, msgText)
        return nil
    end)
    
    --maid:GiveTask(Players.PlayerRemoving:Connect(onPlayerRemoving))
end

return ToolManager