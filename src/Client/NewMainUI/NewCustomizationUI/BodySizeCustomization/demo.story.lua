--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BodySizeCustomization = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"):WaitForChild("BodySizeCustomization"))
--types
type Signal = Signal.Signal
--constants
--variables
--references
--local functions
local function getCharacter(fromWorkspace : boolean, plr : Player ?)
    local char 
    if RunService:IsRunning() then 
        if not fromWorkspace then
            char = Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) 
        else
            for _,charModel in pairs(workspace:GetChildren()) do
                local humanoid = charModel:FindFirstChild("Humanoid")
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
--class
return function(target : CoreGui)
    local maid = Maid.new() 

    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local onSignalChange = maid:GiveTask(Signal.new())
    local onScaleConfirmChange = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local bodySizeCustomization  = BodySizeCustomization(
        maid,
        
        onSignalChange,
        onScaleConfirmChange,

        onBack,

        maid:GiveTask(getCharacter(false)),
    
        _Value(_new("Frame")({}) :: any),

        _new("Frame")({}) :: Frame
    )
    bodySizeCustomization.Visible = true
    bodySizeCustomization.Parent = target
    
    maid:GiveTask(onSignalChange:Connect(function()
        print("on change")
    end))

    maid:GiveTask(onScaleConfirmChange:Connect(function()
        print("on confirm")
    end))

    maid:GiveTask(onBack:Connect(function()
        print("back!")
    end))

    return function() 
        maid:Destroy()
    end
end
