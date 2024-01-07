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
--remotes
local ON_TEXT_INPUT = "OnTextInput"
--variables
--references
local Player = Players.LocalPlayer
--local functions
--class
local Artificial = {}

function Artificial.init(maid : Maid)
    local backgroundColor = Color3.fromRGB(80,80,80)
    local primaryColor = Color3.fromRGB(255,255,255)
    --text display
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