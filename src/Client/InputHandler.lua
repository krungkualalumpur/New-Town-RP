--[=[

    @class InputHandler
    Author: 
    Aryo (@aryoseno11)
    Hex (@hexadecagons)

    Class for handling player input and providing an interface to map keys.
]=]
--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
--modules
--types
type Maid = Maid.Maid
type PlatformType = "Keyboard" | "Mobile" | "Console"
type InputEventType = "Toggle" | "Press" | "Hold" | "Release"


type KeyMap = 
    {
        Key : {[number] : Enum.KeyCode | Enum.UserInputType},
    }


type Map = {
    [PlatformType] : KeyMap,
    OnBegin : (... any) -> any,
    OnEnded : (... any) -> any,
    isActive : boolean,
    InputEventType : InputEventType
}

export type InputHandler = {
    __index : InputHandler,
    _Maid : Maid,
    Enabled : boolean,
    _InputMap : { 
        [string] : Map
    },
    _InputState : { -- buttons that are being pressed (isPressing)
        [number] : Enum.KeyCode | Enum.UserInputType
    },
    
    new : (isStart : boolean) -> InputHandler,
    Map : (InputHandler, inputName : string, platformType : PlatformType,  inputs : {Enum.KeyCode | Enum.UserInputType}, inputEventType : InputEventType, OnBegin : (... any) -> any, OnEnded : (... any) -> any) -> nil,
    Unmap : (InputHandler, inputName : string) -> nil,
    SetActive : (InputHandler, InputName : string, isActive : boolean) -> nil,
    IsActive : (InputHandler, InputName : string) -> boolean,
    OnInputEvent : (InputHandler, InputObject : InputObject, began : boolean, detectMouseMovement : boolean ?) -> nil,
    HandleEventType : (InputHandler, InputName: string, InputEventType: InputEventType, InputBegan: boolean) -> nil,
    Destroy : (InputHandler) -> nil,
}
--constants
--references
--- local functions
local function getClientPlatform() : PlatformType

    local TouchEnabled      = UserInputService.TouchEnabled
    local KeyboardEnabled   = UserInputService.KeyboardEnabled
    local MouseEnabled      = UserInputService.MouseEnabled
    local GamepadEnabled    = UserInputService.GamepadEnabled

    -- Prioritize console first, this means we will also treat PCs with gamepads plugged in as 'Console'
    if GamepadEnabled then return "Console" end

    -- If touch is enabled and there is no mouse or keyboard present, we can confidently assume this is a mobile device.
    if TouchEnabled and not (KeyboardEnabled or MouseEnabled) then return "Mobile" end

    -- Otherwise, default to PC.
    return "Keyboard"
end


--module
local currentInputHandler

local inputHandler = {} :: InputHandler
inputHandler.__index = inputHandler

function inputHandler.new(isBoot : boolean)
    local self : InputHandler = setmetatable({}, inputHandler) :: any
    self._Maid = Maid.new()
    self.Enabled = true
    self._InputMap = {}
    self._InputState = {}

    self._Maid:GiveTask(UserInputService.InputBegan:Connect(function(InputObject : InputObject, gpe : boolean)
        if not gpe then
            self:OnInputEvent(InputObject, true)
        end
    end))

    self._Maid:GiveTask(UserInputService.InputEnded:Connect(function(InputObject : InputObject, gpe : boolean)
        if not gpe then
            self:OnInputEvent(InputObject, false)
        end
    end))

    if isBoot then
        currentInputHandler = self
    end
    return self
end


function inputHandler:OnInputEvent(InputObject : InputObject, began : boolean, filter : boolean?)
    if began then --managing inputs
        if InputObject.KeyCode == Enum.KeyCode.Unknown then
            if not table.find(self._InputState, InputObject.UserInputType) and ((filter == false) or ((filter == nil) and (InputObject.UserInputType ~= (Enum.UserInputType.MouseMovement)) and (InputObject.UserInputType ~= Enum.UserInputType.Focus))) then
                table.insert(self._InputState, InputObject.UserInputType)
            end
        else
            if not table.find(self._InputState, InputObject.KeyCode) then
                table.insert(self._InputState, InputObject.KeyCode)
            end
        end
    
    end

    local isInput : boolean ?
    for inputName : string, map : Map in pairs(self._InputMap) do
        for platform : PlatformType, keyMapping : KeyMap in pairs(map :: any) do
            --cannot proceed if player is not in the same platform
            if getClientPlatform() ~= platform then continue end

            --then get from input state the keycodes and initiate the function (wip)
            for _, key : Enum.KeyCode | Enum.UserInputType in pairs(keyMapping.Key) do
                local inputFound : boolean ?
                for _, pressedInput : Enum.KeyCode | Enum.UserInputType in pairs(self._InputState) do
                    if (pressedInput == key) then
                        inputFound = true
                    else
                        if (pressedInput == InputObject.KeyCode or pressedInput == InputObject.UserInputType) and #keyMapping.Key == 1 then
                            inputFound = false
                            break
                        end
                    end
                end
                if inputFound then
                    isInput = true
                else
                    isInput = false
                    break
                end
            end

            if isInput then
                self:HandleEventType(inputName, map.InputEventType, began)
            end
            --self._InputState
        end
        
    end

    if not began then
        if table.find(self._InputState, InputObject.UserInputType) then
            table.remove(self._InputState, table.find(self._InputState, InputObject.UserInputType)) 
        elseif table.find(self._InputState, InputObject.KeyCode) then
            table.remove(self._InputState, table.find(self._InputState, InputObject.KeyCode))
        end
    end
    
    return nil
end

function inputHandler:Map(
    inputName : string, 
    platformType : PlatformType, 
    inputs : {Enum.KeyCode | Enum.UserInputType}, 
    inputEventType : InputEventType, 
    OnBegin : (... any) -> any, 
    OnEnded :(...any) -> any
)

    local _map : Map = {
        [platformType] = {Key = inputs},
        OnBegin = OnBegin,
        OnEnded = OnEnded,
        isActive = false,
        InputEventType = inputEventType
    }
    self._InputMap[inputName] = _map
    return nil
end

function inputHandler:Unmap(inputName : string)
    self._InputMap[inputName] = nil
    return nil
end

function inputHandler:SetActive(InputName : string, isActive : boolean)
    local currentPlatformType : PlatformType = getClientPlatform()

    assert(currentPlatformType, "Unable to detect current platform type!")

    for inputName : string , map : Map in pairs(self._InputMap) do
        --local keyMap : KeyMap =  map[currentPlatformType]
        --if not keyMap then continue end
        if inputName == InputName then
            map.isActive = isActive
            if isActive then
                map.OnBegin()
            else
                map.OnEnded()
            end
        end
    end
    return nil
end

function inputHandler:IsActive(InputName : string)
    for inputName : string ,Map : Map in pairs(self._InputMap) do
        if (inputName == InputName) and (Map.isActive == true) then
            return Map.isActive
        end
    end
    return false
end

function inputHandler:HandleEventType(InputName: string, InputEventType: InputEventType, InputBegan: boolean)

    -- Handle input began event.
    if InputBegan then

        -- 'TOGGLE' case: we flip the activation state.
        if InputEventType == "Toggle" then 
            self:SetActive(InputName, not self:IsActive(InputName)) 
            return 
        end

        -- 'PRESS' case: we activate the event, then immediately de-activate it manually.
        if InputEventType == "Press" then 
            self:SetActive(InputName, true)
            self:SetActive(InputName, false)
            return 
        end --active = toggle... 

        -- 'HOLD' case: input is now being held, activate.
        if InputEventType == "Hold" and not self:IsActive(InputName) then 
            self:SetActive(InputName, true) 
            return 
        end
    else

        -- Handle input ended event.
        -- 'HOLD' case: we de-activate as the input is no longer held.
        if InputEventType == "Hold" and self:IsActive(InputName) then 
            self:SetActive(InputName, false)
            return 
        end

        -- 'RELEASE' case: same logic as press, but for when the input is released.
        if InputEventType == "Release" then 
            self:SetActive(InputName, true)
            self:SetActive(InputName, false)
            return 
        end
    end

    return nil
end

function inputHandler:Destroy()
    self._Maid:Destroy()
    
    local t = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end
    setmetatable(self, nil)
    return nil
end

return ServiceProxy(function()
    return currentInputHandler or inputHandler
end)