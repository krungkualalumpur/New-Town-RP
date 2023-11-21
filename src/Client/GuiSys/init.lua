--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
--modules
local InteractSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiSys"):WaitForChild("InteractSys"))
local InteractUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InteractUI"))
local MainUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"))
local SideOptions = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("SideOptions"))
local NotificationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"))
local MapUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MapUI"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local NewCustomizationUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"))
local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))

local ItemUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtil"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))
local Fishes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Fishing"))
local ChoiceActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChoiceActions"))

local ItemOptionsUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ItemOptionsUI"))
local ListUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ListUI"))
local NotificationChoice = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("NotificationUI"):WaitForChild("NotificationChoice"))

--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type OptInfo = ItemOptionsUI.OptInfo

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

export type VehicleData = ItemUtil.ItemInfo & {
    IsSpawned : string,
    Key : number ?
}

type GuiSys = {
    __index : GuiSys,
    _Maid : Maid,
    MainUI : GuiObject,
    NotificationUI : GuiObject,
    MapUI : MapUI.MapHUD,

    NotificationStatus : ValueState<string ?>,

    new : () -> GuiSys,
    Notify : (GuiSys, text : string) -> nil,
    Destroy : (GuiSys) -> nil,
    init : (maid : Maid) -> ()
}
--constants
local MAX_DISTANCE = 18

local LIST_TYPE_ATTRIBUTE = 'ListType'
--remotes
local ON_OPTIONS_OPENED = "OnOptionsOpened"
local ON_ITEM_OPTIONS_OPENED = "OnItemOptionsOpened"

local ON_ITEM_CART_SPAWN = "OnItemCartSpawn"

local GET_PLAYER_BACKPACK = "GetPlayerBackpack"
local UPDATE_PLAYER_BACKPACK = "UpdatePlayerBackpack"

local ADD_BACKPACK = "AddBackpack" 

local EQUIP_BACKPACK = "EquipBackpack"
local DELETE_BACKPACK = "DeleteBackpack"

local GET_PLAYER_VEHICLES = "GetPlayerVehicles"

local SPAWN_VEHICLE = "SpawnVehicle"
local ADD_VEHICLE = "AddVehicle"
local DELETE_VEHICLE = "DeleteVehicle"

local ON_CHARACTER_APPEARANCE_RESET = "OnCharacterAppearanceReset"
local ON_NOTIF_CHOICE_INIT = "OnNotifChoiceInit"

local ON_TOOL_ACTIVATED = "OnToolActivated"

local ON_JOB_CHANGE = "OnJobChange"
--variables
local Player = Players.LocalPlayer
--references
--local functions
function PlaySound(id, parent, volumeOptional: number ?)
	task.spawn(function()
		local s = Instance.new("Sound")

		s.Name = "Sound"
		s.SoundId = id
		s.Volume = volumeOptional or 1
        s.RollOffMaxDistance = 350
		s.Looped = false
		s.Parent = parent or Player:FindFirstChild("PlayerGui")
		s:Play()
		task.spawn(function() 
            s.Ended:Wait()
		    s:Destroy()
        end)
	end)
end

local function getCharacter(fromWorkspace : boolean, plr : Player ?)
    local char 
    if RunService:IsRunning() then 
        if not fromWorkspace then
            char = Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) 
        else
            for _,charModel in pairs(workspace:GetChildren()) do
                local humanoid = charModel:FindFirstChild("Humanoid")
                print(charModel:IsA("Model"), humanoid, humanoid and humanoid:IsA("Humanoid"), charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name))
                if charModel:IsA("Model") and humanoid and humanoid:IsA("Humanoid") and charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name) then
                    charModel.Archivable = true
                    char = charModel:Clone()
                    charModel.Archivable = false
                    break
                end
            end
        end
        
    else 
        char = game.ServerStorage.aryoseno11:Clone() 
    end
    
    return char
end

local function getListButtonInfo(
    signal : Signal,
    buttonName : string
)
    return 
        {
            Signal = signal,
            ButtonName = buttonName
        }
    
end

local function getEnumItemFromName(enum : Enum, enumItemName : string) 
    local enumItem 
    for _, item : EnumItem in pairs(enum:GetEnumItems()) do
        if item.Name == enumItemName then
            enumItem = item
            break
        end
    end
    return enumItem
end

--class
local currentGuiSys : GuiSys

local guiSys : GuiSys = {} :: any
guiSys.__index = guiSys

function guiSys.new()
    local maid = Maid.new()
    
    local target = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value
    
    local notificationUItarget = _new("ScreenGui")({
        Name = "NotificationScreenGui",
        Parent = Player:WaitForChild("PlayerGui"),
        IgnoreGuiInset = true,
        DisplayOrder = 10
    })

    local interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType> = _Value(Enum.KeyCode.E) :: any
    
    local self : GuiSys = setmetatable({}, guiSys) :: any
    self._Maid = maid
    self.NotificationStatus = _Value(nil :: string ?)

    local backpack = _Value(NetworkUtil.invokeServer(GET_PLAYER_BACKPACK))

    local backpackOnEquip = maid:GiveTask(Signal.new())
    local backpackOnDelete = maid:GiveTask(Signal.new())
    local onNotify = maid:GiveTask(Signal.new())
    
    local nameCustomizationOnClick = maid:GiveTask(Signal.new()) 

    local onItemCartSpawn = maid:GiveTask(Signal.new())
    local onJobChange = maid:GiveTask(Signal.new())

    local onCharacterReset = maid:GiveTask(Signal.new())

    local MainUIStatus : ValueState<MainUI.UIStatus> = _Value(nil) :: any

    self.MainUI = MainUI(
        maid,
        backpack,
        
        MainUIStatus,

        backpackOnEquip,
        backpackOnDelete,
        onNotify,

        onItemCartSpawn,
        onJobChange,
        
        onCharacterReset,

        target
    )

    maid:GiveTask(nameCustomizationOnClick:Connect(function(descType, text)
        CustomizationUtil.setDesc(Player, descType, text)
    end))

    maid:GiveTask(backpackOnEquip:Connect(function(toolKey : number, toolName : string ?)
        NetworkUtil.invokeServer(
            EQUIP_BACKPACK,
            toolKey,
            toolName
        )
    end))
    maid:GiveTask(backpackOnDelete:Connect(function(toolKey : number, toolName : string)
        NetworkUtil.invokeServer(
            DELETE_BACKPACK,
            toolKey,
            toolName
        )
    end))

    maid:GiveTask(onNotify:Connect(function(msg : string)
        self:Notify(msg)
    end))

    
    maid:GiveTask(onItemCartSpawn:Connect(function(selectedItems : {[number] : BackpackUtil.ToolData<boolean>})
        MainUIStatus:Set(nil)

        NetworkUtil.invokeServer(ON_ITEM_CART_SPAWN, selectedItems)
        print("test 123")
    end))
    
    maid:GiveTask(onJobChange:Connect(function(job)
        NetworkUtil.fireServer(ON_JOB_CHANGE, job)
    end))

    self.NotificationUI = NotificationUI(
        maid,
        self.NotificationStatus
    )


    do
        local charMaid = maid:GiveTask(Maid.new()) 

        local onSprintClick = maid:GiveTask(Signal.new())
        local sprintState = _Value(false)
        local function onCharAdded(char : Model)
            charMaid:DoCleaning()
            charMaid:GiveTask(char:GetAttributeChangedSignal("IsSprinting"):Connect(function()
                if char:GetAttribute("IsSprinting") == true then
                    sprintState:Set(true)
                else
                    sprintState:Set(false)
                end
            end))
        end
        local sideOptionsUI = SideOptions(
            maid, 
            onSprintClick,

            sprintState
        )
        sideOptionsUI.Parent = target
        
        onCharAdded(Player.Character or Player.CharacterAdded:Wait())

        maid:GiveTask(onSprintClick:Connect(function()
            local char = Player.Character
            if char then
                char:SetAttribute("IsSprinting", not char:GetAttribute("IsSprinting"))
            end
        end))

        maid:GiveTask(Player.CharacterAdded:Connect(onCharAdded))
    end


    --map ui
    local plrCf = _Value(CFrame.new())
    local mapUI = MapUI.new(maid, plrCf, _Value(true))
    mapUI.Instance.Parent = target

    local charMaid = maid:GiveTask(Maid.new())

    local function cfSetup(char : Model)
        charMaid:DoCleaning()
 
        charMaid:GiveTask(RunService.Stepped:Connect(function()
            if char.PrimaryPart then
                plrCf:Set(char.PrimaryPart.CFrame)
            end
        end))
    end

    cfSetup(Player.Character or Player.CharacterAdded:Wait())
    maid:GiveTask(Player.CharacterAdded:Connect(function(char : Model)
        cfSetup(char)
    end))
 
    self.MainUI.Parent = target
    self.NotificationUI.Parent = notificationUItarget
    self.MapUI = mapUI

    currentGuiSys = self

    local proxPrompt = _new("ProximityPrompt")({
        RequiresLineOfSight = false
    }) :: ProximityPrompt
    InteractSys.init(maid, proxPrompt, interactKeyCode)

    maid:GiveTask(NetworkUtil.onClientEvent(UPDATE_PLAYER_BACKPACK, function(newbackpackval : {BackpackUtil.ToolData<boolean>})
        backpack:Set(newbackpackval)
    end))

    local currentOptInfo : ValueState<OptInfo ?> = _Value(nil) :: any   
    local onItemGet = maid:GiveTask(Signal.new())

    local isExitButtonVisible = _Value(true)

    NetworkUtil.onClientInvoke(ON_OPTIONS_OPENED, function(
        listName : string,
        inst : Instance
    )
        local _maid = Maid.new()
        local _fuse = ColdFusion.fuse(_maid)
        local _new = _fuse.new
        local _import = _fuse.import
        local _bind = _fuse.bind
        local _clone = _fuse.clone
    
        local _Computed = _fuse.Computed
        local _Value = _fuse.Value
        
        local cam = workspace.CurrentCamera

        local position = _Value(UDim2.new())
        local isVisible = _Value(true)

        local list = _Value({}) 
        
        local buttonlistsInfo = {}

        if inst:GetAttribute(LIST_TYPE_ATTRIBUTE) == "Vehicle" then
            local plrIsVIP = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
            if not plrIsVIP then 
                MarketplaceService:PromptGamePassPurchase(Player, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
                _maid:Destroy()
                return nil 
            end
            
            list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            
            local onVehicleSpawn = maid:GiveTask(Signal.new())
            local onVehicleDelete = maid:GiveTask(Signal.new())

            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleSpawn, "Spawn"))
            table.insert(buttonlistsInfo, getListButtonInfo(onVehicleDelete, "Delete"))

            maid:GiveTask(onVehicleSpawn:Connect(function(key, val : string)
                local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                local spawnerZones = spawnerZonesPointer.Value

                NetworkUtil.invokeServer(
                    SPAWN_VEHICLE, 
                    key,
                    val,
                    spawnerZones
                )
            end))

            maid:GiveTask(onVehicleDelete:Connect(function(key, val)
                NetworkUtil.invokeServer(
                    DELETE_VEHICLE,
                    key
                )

                list:Set(NetworkUtil.invokeServer(GET_PLAYER_VEHICLES))
            end))
        end

        local listUI =  ListUI(
            _maid, 
            listName, 
            list,
            position,
            isVisible,
            buttonlistsInfo
        ) :: GuiObject

        ExitButton.new(
            listUI, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        listUI.Parent = target

        _maid:GiveTask(RunService.Stepped:Connect(function()
            local worldPos 
            local pos, isOnRange
            if inst:IsA("Model") then
                local cf, _ = inst:GetBoundingBox()
                pos, isOnRange = cam:WorldToScreenPoint(cf.Position)
                worldPos = cf.Position
            elseif inst:IsA("BasePart") then
                pos, isOnRange = cam:WorldToScreenPoint(inst.Position)
                worldPos = inst.Position
            end
            if pos and (isOnRange ~= nil) then
                position:Set(UDim2.fromOffset(pos.X, pos.Y))
                isVisible:Set(isOnRange)

                if Player.Character and worldPos and ((worldPos - Player.Character.PrimaryPart.Position).Magnitude >= MAX_DISTANCE) then
                    maid.ItemOptionsUI = nil
                end
            end
        end))

        return nil
    end)

    NetworkUtil.onClientInvoke(ON_ITEM_OPTIONS_OPENED, function(
        listName : string,
        ToolsList : {[number] : OptInfo},
        interactedItem : Instance
    )
        local _maid = Maid.new()
        currentOptInfo:Set(nil)
        
        local itemOptionsUI: GuiObject = ItemOptionsUI(
            _maid,
            listName, 
            ToolsList,

            currentOptInfo,

            onItemGet,

            interactedItem
        ) :: GuiObject
        ExitButton.new(
            itemOptionsUI:WaitForChild("ContentFrame") :: GuiObject, 
            isExitButtonVisible,
            function()
                maid.ItemOptionsUI = nil
                return 
            end
        )

        maid.ItemOptionsUI = _maid
        itemOptionsUI.Parent = target

        --managing player list
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        maid.OnItemOptionsUIDestroy = itemOptionsUI.Destroying:Connect(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            maid.OnItemOptionsUIDestroy = nil
        end)

        return nil
    end)

    local toolMaid = maid:GiveTask(Maid.new())

    maid:GiveTask(NetworkUtil.onClientEvent(ON_TOOL_ACTIVATED, function(toolClass : string, toolInst : Tool)
        if toolClass == "Fishing Rod" then
            --local mouse = Player:GetMouse() :: Mouse
            local camera = workspace.CurrentCamera
            local mouseLocation = UserInputService:GetMouseLocation()
            local viewportPointRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
            local ray = Ray.new(viewportPointRay.Origin, viewportPointRay.Direction * 1000)
            
            local hit, position, normal, material = workspace:FindPartOnRay(ray)

            if hit then
                if material ~= Enum.Material.Water then
                    self:Notify("You can only do fishing on water!")
                    return 
                end
                
                --local camera = workspace.CurrentCamera
                local toolModel = toolInst:FindFirstChild(toolInst.Name)
                local baitHolder = if toolModel then toolModel:FindFirstChild("BaitHolder") :: BasePart ? else nil
                if baitHolder then

                    if (baitHolder.Position - position).Magnitude >= 80 then
                        self:Notify("Bait is too far!")
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
                    PlaySound("rbxassetid://9120584671", p, 100)

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
                                PlaySound("rbxassetid://1584394759")
                                
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

                    toolMaid:GiveTask(toolInst.Destroying:Connect(function()
                        toolMaid:DoCleaning()
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
        end
        return
    end))

    do
        local _maid = maid:GiveTask(Maid.new())
      
        maid:GiveTask(NetworkUtil.onClientEvent(ON_JOB_CHANGE, function(jobData)
            _maid:DoCleaning()

            local _fuse = ColdFusion.fuse(_maid)
            local _new = _fuse.new
            local _Value = _fuse.Value
                
            local dynamicPos = _Value(UDim2.fromScale(-1, 0.5))
            local dynamicTransp = _Value(1)

            local out =  _new("ImageLabel")({
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.3, 0.3),
                Position = dynamicPos:Tween(0.2),
                Image = string.format("rbxassetid://%d", jobData.ImageId),
                ImageTransparency = dynamicTransp:Tween(0.2),
                Parent = target,
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            })

            dynamicTransp:Set(0)
            dynamicPos:Set(UDim2.fromScale(0.5, 0.5))
            task.wait(2)
            dynamicTransp:Set(1)
            dynamicPos:Set(UDim2.fromScale(1, 0.5))
            task.wait(0.2)
            _maid:DoCleaning()
        end))
    end

    local notifMaid = maid:GiveTask(Maid.new())
    NetworkUtil.onClientInvoke(ON_NOTIF_CHOICE_INIT, function(actionName : string, eventTitle : string, eventDesc : string, isConfirm : boolean)
        notifMaid:DoCleaning()
      
        local notificationChoiceUI = NotificationChoice(notifMaid, eventTitle, eventDesc, isConfirm, function()
            --print("Test1") action name ..]
            ChoiceActions.triggerEvent(actionName)
            notifMaid:DoCleaning()

        end)
        notificationChoiceUI.Parent = target

        return nil
    end)


    maid:GiveTask(onItemGet:Connect(function(inst : Instance)
        local optInfo : ItemOptionsUI.OptInfo ? = currentOptInfo:Get()
        local char = Player.Character or Player.CharacterAdded:Wait()
        
        if optInfo then
            if optInfo.Type == "Tool" then
                NetworkUtil.invokeServer(
                    ADD_BACKPACK,
                    optInfo.Name
                )
            elseif optInfo.Type == "Vehicle" then
                NetworkUtil.invokeServer(
                    ADD_VEHICLE,
                    optInfo.Name
                )
                --local spawnerZonesPointer =  inst:FindFirstChild("SpawnerZones") :: ObjectValue
                --local spawnerZones = spawnerZonesPointer.Value
                
                --NetworkUtil.invokeServer(
                --    SPAWN_VEHICLE,
                --    optInfo.Name,
                --    spawnerZones
                --)
            end
        end
        currentOptInfo:Set(nil)
    end))

    maid:GiveTask(onCharacterReset:Connect(function(char : ValueState<Model>)
        notifMaid:DoCleaning()
        local notif = NotificationChoice(notifMaid, "⚠️ Warning", "Are you sure you want to reset your character? All unsaved progress will be lost.", false, function()
            notifMaid:DoCleaning()
            local loadingFrame = LoadingFrame(notifMaid, "Resetting character, please what")
            loadingFrame.Parent = target
            NetworkUtil.invokeServer(ON_CHARACTER_APPEARANCE_RESET)
            char:Set(getCharacter(true))
            notifMaid:DoCleaning()
        end, function()
            notifMaid:DoCleaning()
        end)
        notif.Parent = target
    end))

    --task.spawn(function()
        --print(AvatarEditorService:GetItemDetails(16630147, Enum.AvatarItemType.Asset))
        --local params = CatalogSearchParams.new()
        --params.SearchKeyword = "featured"
        --params.BundleTypes = {Enum.BundleType.Animations}
        
       -- local result = AvatarEditorService:SearchCatalog(params)
        --print(result:GetCurrentPage())
        --local s,e = pcall(function() result:AdvanceToNextPageAsync() end) 
        --if not s and e then warn(e) end 
        --print(result:GetCurrentPage())
   -- end)

    --setting default backpack to untrue it 
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    return self 
end

function guiSys:Notify(text : string)
   -- print("Test1")
    self.NotificationStatus:Set(nil)
   -- print(self.NotificationStatus:Get())
    task.wait(0.1)
    self.NotificationStatus:Set(text)
   -- print(self.NotificationStatus:Get())
    return
end

function guiSys:Destroy()
    self._Maid:Destroy()

    local t : GuiSys = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end
    
    setmetatable(self, nil)
    return
end

function guiSys.init(maid : Maid)
    local newGuiSys = maid:GiveTask(guiSys.new())


   
    return
end

return ServiceProxy(function()
    return currentGuiSys or guiSys
end)