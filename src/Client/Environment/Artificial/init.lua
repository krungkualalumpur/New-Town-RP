--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
--types
type Maid = Maid.Maid
--constants
local ADAPTIVE_LOD_ITEM_TAG = "AdaptiveLODItem"
--remotes
local ON_TEXT_INPUT = "OnTextInput"
--variables
--references
local Player = Players.LocalPlayer
--local functions
local function clientOptimalization()
    for _,door in pairs(CollectionService:GetTagged("Door")) do
        if door:IsA("Model") and not door.PrimaryPart and not CollectionService:HasTag(door, ADAPTIVE_LOD_ITEM_TAG) then
            local doorPrimaryPart
            
            local doorModel = door:FindFirstChild("Model")
            if doorModel then
                for _,modelChild in pairs(doorModel:GetChildren()) do
                    if modelChild:IsA("BasePart") and modelChild:FindFirstChildWhichIsA("WeldConstraint") and modelChild:FindFirstChildWhichIsA("Attachment") then
                        doorPrimaryPart = modelChild :: BasePart
                        break
                    end
                end
            end

            if doorPrimaryPart then
                door.PrimaryPart = doorPrimaryPart
                CollectionService:AddTag(door, ADAPTIVE_LOD_ITEM_TAG)
            end
        end
    end
end
--class
local Artificial = {}

function Artificial.init(maid : Maid)
    --performance opt
    clientOptimalization()
   
    --text display
    local backgroundColor = Color3.fromRGB(80,80,80)
    local primaryColor = Color3.fromRGB(255,255,255)
    
    local function onCharAdded(char : Model)
        local _maid = Maid.new()

        _maid:GiveTask(char.Changed:Connect(function()
            if char.Parent == nil then
                _maid:Destroy()
            end
        end))

        _maid:GiveTask(char.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then
                local toolModel = tool:WaitForChild(tool.Name)
                if toolModel then
                    local toolData = BackpackUtil.getData(toolModel, false)
                    print(toolData.Class)
                    if toolData.Class == "TextDisplay" then
                        local toolMaid = Maid.new()
                        local textBox = toolMaid:GiveTask(Instance.new("TextBox")) :: TextBox
                        textBox.BackgroundColor3 = backgroundColor
                        textBox.Transparency = 0.4
                        textBox.AnchorPoint = Vector2.new(0.5, 0.5)
                        textBox.Size = UDim2.fromScale(0.45, 0.15)
                        textBox.Position = UDim2.fromScale(0.5, 0.75)
                        textBox.Text = ""
                        textBox.TextColor3 = primaryColor
                        textBox.TextScaled = true
                        textBox.PlaceholderText = "Insert text here"
                        textBox.TextStrokeTransparency = 0.5
                        textBox.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

                        local intText = textBox.Text
                        toolMaid:GiveTask(textBox.Changed:Connect(function()
                            if textBox.Text ~= intText then
                                intText = textBox.Text:sub(1, 50)
                                NetworkUtil.fireServer(ON_TEXT_INPUT, intText)
                            end
                        end))

                        toolMaid:GiveTask(tool.Changed:Connect(function()
                            if tool.Parent ~= char then
                                toolMaid:Destroy()
                            end
                        end) )
                        print(textBox)
                    end
                end
            end
        end))
    end
    maid:GiveTask(Player.CharacterAdded:Connect(onCharAdded))

end

return Artificial