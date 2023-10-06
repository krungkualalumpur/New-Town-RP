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
--modules
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type State<a> = ColdFusion.State<a>
type ValueState<a> = ColdFusion.ValueState<a>
type CanBeState<a> = ColdFusion.CanBeState<a>


export type ExitButton = {
    __index : ExitButton,
    _isAlive : boolean,
    _Maid : Maid,
    new : (GuiObject : GuiObject, isVisible : ValueState<boolean>, func : ((... any) -> any)?) -> ExitButton,
    Instance : ScreenGui,
    Destroy : (ExitButton) -> nil
}

type FrameCollectionType = "Grid" | "List"

--constants
local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(50,180,180)

local BUTTON_SIZE = 45
local TEXT_SIZE = 16

local PADDING_SIZE = UDim.new(0, 5)

--vars

--references

--local functions

--module
local ExitButton = {} :: ExitButton
ExitButton.__index = ExitButton

function ExitButton.new(guiObject : GuiObject, isVisible : ValueState<boolean>, func : ((... any) -> any) ?)
    local maid = Maid.new()
    
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _clone = _fuse.clone
    local _bind = _fuse.bind
    
    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local dynamicThickness = _Value(2)

    local exitButton = maid:GiveTask(_new("TextButton")({
        Size = UDim2.fromScale(0.04, 0.04),
        BackgroundColor3 = Color3.fromRGB(255,100,0),
        TextColor3 = PRIMARY_COLOR,
        Font = Enum.Font.ArialBold,
        TextScaled = true,
        Children = {
            _new("UIStroke")({
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 1,
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            }),
            _new("UIPadding")({
                PaddingBottom = UDim.new(0.12,0),
                PaddingTop = UDim.new(0.12,0),
                PaddingLeft = UDim.new(0.12,0),
                PaddingRight = UDim.new(0.12,0),

            }),
            _new("TextLabel")({
                Size = UDim2.fromScale(1,1),
                BackgroundColor3 = Color3.fromRGB(255,100,0),
                TextColor3 = PRIMARY_COLOR,
                Font = Enum.Font.ArialBold,
                TextScaled = true,
                Text = "X",
                Children = {
                    _new("UIStroke")({
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = dynamicThickness,
                    }),
                   -- _new("")
                },
            })
           -- _new("")
        },
        Events = {
            Activated = function()
                isVisible:Set(false)
                if func then
                    func()
                end
            end,
            MouseButton1Down = function()
                dynamicThickness:Set(4)
            end,
            MouseButton1Up = function()
                dynamicThickness:Set(2)
            end
        }
    })) :: GuiButton

    local self = setmetatable({}, ExitButton) :: any
    self._Maid = maid
    self._isAlive = true
   

    self.Instance = _new("ScreenGui")({
        Parent = if RunService:IsRunning() then Players.LocalPlayer:WaitForChild("PlayerGui") else game:GetService("CoreGui"),
        Children = {
            exitButton
        }
    })

    local inst = self.Instance :: GuiObject
    --updates position per frame
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        exitButton.ZIndex = guiObject.ZIndex + 1
        exitButton.Visible = guiObject.Visible
        exitButton.Position = UDim2.fromOffset(guiObject.AbsolutePosition.X + guiObject.AbsoluteSize.X - exitButton.AbsoluteSize.X, guiObject.AbsolutePosition.Y)
    end))

    maid:GiveTask(inst.Destroying:Connect(function()
        if self._isAlive then self:Destroy() end
    end))

    maid:GiveTask(guiObject.Destroying:Connect(function()
        if self._isAlive then self:Destroy() end
    end))

    return self
end 

function ExitButton:Destroy()
    if not self._isAlive then
        return
    end
    self._isAlive = false

    --destroying
    self._Maid:Destroy()
    local t = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end
    setmetatable(self, nil)
    return 
end

return ExitButton
--[[return ServiceProxy(function()
    return currentExitButton or ExitButton
end)]]