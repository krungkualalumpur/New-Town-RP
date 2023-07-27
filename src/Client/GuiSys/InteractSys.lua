--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))

--modules
local InputHandler = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("InputHandler"))

local InteractableUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InteractableUtil"))

--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.State<T>

--constants
local INTERACTABLE_TAG = "Interactable"
local MAXIMUM_INTERACT_DISTANCE = 20

local ON_INTERACT = "On_Interact"
--variables
local Interactables = {} :: {[number] : Model}
--references
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
--local functions
local function createInteract(maid : Maid, interactFrame : Frame, interactNameTag : string, interactInputKey : string, interactCode : Enum.KeyCode | Enum.UserInputType, currentInputKeyCodeState : ValueState<Enum.KeyCode | Enum.UserInputType>)
    local instancePointer = interactFrame:FindFirstChild("InstancePointer") :: ObjectValue    

    InputHandler:Map(
        interactInputKey, 
        "Keyboard", 
        {interactCode},
        "Press" ,
        function(inputObject : InputObject) 
            local inst = instancePointer.Value
            if (inst) then
                if  (inst:HasTag(interactNameTag)) then
                    if (interactCode == inputObject.KeyCode) then 
                        InteractableUtil.Interact(inst :: Model, Player)                        
                    end
                   -- NetworkUtil.fireServer(ON_INTERACT, inst)
                end
            end
            return 
        end, 
        function() 
            return 
        end
    )

    maid:GiveTask(instancePointer.Changed:Connect(function()
        local newInst = instancePointer.Value
        if newInst and newInst:HasTag(interactNameTag) then
            print(interactCode.Name)
            currentInputKeyCodeState:Set(interactCode)
        end
    end))

    if interactCode.EnumType == Enum.KeyCode then
        for _,v: Model in pairs(CollectionService:GetTagged(interactNameTag)) do
            if v:IsA("Model") then
                table.insert(Interactables, v)
            end
        end
        CollectionService:GetInstanceAddedSignal(interactNameTag):Connect(function(inst)
            table.insert(Interactables, inst)
        end)

        CollectionService:GetInstanceRemovedSignal(interactNameTag):Connect(function(inst)
            table.remove(Interactables, table.find(Interactables, inst))
        end)
    elseif interactCode.EnumType == Enum.UserInputType then
        local _fuse = ColdFusion.fuse(maid)
        local _new = _fuse.new
        local _import = _fuse.import
        local _bind = _fuse.bind
        local _clone = _fuse.clone
        
        local _Computed = _fuse.Computed
        local _Value = _fuse.Value

        for _,inst in pairs(CollectionService:GetTagged(interactNameTag)) do
            local _maid = Maid.new()

            _maid:GiveTask(_new("BillboardGui")({
                AlwaysOnTop = true,
                MaxDistance = MAXIMUM_INTERACT_DISTANCE*0.5,
                Size = UDim2.fromScale(0.6, 0.6),
                Parent = inst,
                Children = {
                    _new("ImageLabel")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Image = "rbxassetid://12804017021"
                    })
                }
            }))

            local clickDetector = Instance.new("ClickDetector")
            clickDetector.MaxActivationDistance = 18
            clickDetector.Parent = inst
            
            _maid:GiveTask(clickDetector.MouseClick:Connect(function()
                InteractableUtil.Interact(inst :: Model, Player)                        
            end))

            _maid:GiveTask(clickDetector.Destroying:Connect(function()
                _maid:Destroy()
            end))
        end
    end
end

--class
local interactSys = {}

function interactSys.init(maid : Maid, interactFrame : Frame, interactKeyCode : ValueState<Enum.KeyCode | Enum.UserInputType>)   
    local instancePointer = interactFrame:FindFirstChild("InstancePointer") :: ObjectValue


    createInteract(maid, interactFrame, "Interactable", "Interact", Enum.KeyCode.E, interactKeyCode)
    createInteract(maid, interactFrame, "ClickInteractable", "ClickToInteract", Enum.UserInputType.MouseButton1, interactKeyCode)
    createInteract(maid, interactFrame, "Tool", "F", Enum.KeyCode.F, interactKeyCode)

    --loop to find the nearest
    do
        maid:GiveTask(RunService.Stepped:Connect(function()
            local character = Player.Character
            local camera = workspace.CurrentCamera
            if character then
                local minDist = math.huge
                local nearestInst 
                for _,v in pairs(Interactables) do
                    if v:IsA("Model") then
                        local pos = if v.PrimaryPart then v.PrimaryPart.Position else v:GetBoundingBox().Position
                        local _, isWithinRange = camera:WorldToScreenPoint(pos)
                        local dist = (camera.CFrame.Position - pos).Magnitude
                        if (dist <= MAXIMUM_INTERACT_DISTANCE) and (dist < minDist) and (isWithinRange) then
                            minDist = dist
                            nearestInst = v        
                        end
                    end
                end
                if nearestInst and not nearestInst:GetAttribute("IsClick") then
                    local pos = if nearestInst.PrimaryPart then nearestInst.PrimaryPart.Position else nearestInst:GetBoundingBox().Position
                    local v3,isWithinRange = camera:WorldToScreenPoint(pos)
                    interactFrame.Visible = isWithinRange
                    interactFrame.Position = UDim2.fromOffset(v3.X - interactFrame.AbsoluteSize.X*0.5, v3.Y - interactFrame.AbsoluteSize.Y*0.5)
                    instancePointer.Value = nearestInst
                else
                    interactFrame.Visible = false
                    instancePointer.Value = nil
                end
            end
            
        end))
    end    

    return 
end

return interactSys