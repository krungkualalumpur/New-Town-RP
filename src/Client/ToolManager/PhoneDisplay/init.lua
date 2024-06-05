--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local CustomEnum = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
local BackpackUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BackpackUtil"))
local ToolActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolActions"))
local NotificationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NotificationUtil"))
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

type PhoneUIStatus = "Message" | "Info" | "Settings" | nil
--constants
local CHAT_LIMIT = 8

local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(150,150,150)

local BUTTON_COLOR = Color3.fromRGB(82, 131, 160)
local GREEN_COLOR =  Color3.fromRGB(15,155,15)
local WHITE_COLOR = Color3.fromRGB(255,255,255)
local GREY_COLOR = Color3.fromRGB(70,70,70)
local RED_COLOR = Color3.fromRGB(141, 72, 72)
local BLACK_COLOR = Color3.fromRGB(15,15,15)

local PADDING_SIZE =  UDim.new(0.025, 0)
local TOP_PADDING_SIZE =  UDim.new(0.07, 0)

local DAY_VALUE_KEY = "DayValue"
--remotes
local ON_PHONE_MESSAGE_START = "OnPhoneMessageStart"
local IS_PLAYER_TYPING_CHECK = "IsPlayerTypingCheck"
local ON_SILENT_SWITCH = "OnSilentSwitch"
--variables
--references
local Player = Players.LocalPlayer
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
local function getDayEnumFromNum(num : number) : CustomEnum.Day
    for _,v in pairs(CustomEnum.Day:GetEnumItems()) do
        if v.Value == num then
            return v
        end
    end
    error("Unable to find the enum")
end

local function getCurrentDay() : CustomEnum.Day
    return getDayEnumFromNum(workspace:WaitForChild(DAY_VALUE_KEY).Value)
end

local function getImageButton(
    maid : Maid,
    imageId : number, 
    onClick : Signal,
    buttonName : string?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    return _new("ImageButton")({
        AutoButtonColor = true,
        BackgroundColor3 = BUTTON_COLOR,
        Image = `rbxassetid://{imageId}`,
        Children = {
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({}),        
            _new("TextLabel")({
                AnchorPoint = Vector2.new(0.5,0.5),
                Size = UDim2.fromScale(1, 0.4),
                Position = UDim2.fromScale(0.5, 1.2),
                BackgroundTransparency = 1,
                TextColor3 = GREY_COLOR,
                Text = buttonName or "",
                TextScaled = true
            })
        },
        Events = {
            MouseButton1Click = function()
                onClick:Fire()
            end
        }
    })
end

local function getButton(
    maid : Maid,
    text : string, 
    onClick : Signal,
    bgColor : Color3 ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    return _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = bgColor or BUTTON_COLOR,
        Size = UDim2.fromScale(0.3, 1),
        Text = text,
        TextColor3 = WHITE_COLOR,
        TextScaled = true,
        Children = {
            _new("UICorner")({}),
        },
        Events = {
            MouseButton1Click = function()
                PlaySound(6052548458)
                onClick:Fire()
            end
        }
    })
end

local function getPlayerList(maid : Maid, player : Player, onMessagePlayerClickSignal : Signal, notifCount : number)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local notificationText =  _new("TextLabel")({
        Name = "Notification",
        LayoutOrder = 2,
        BackgroundColor3 = RED_COLOR,
        Visible = false,
        Size = UDim2.fromScale(0.05, 0.35),
        Text = notifCount,
        TextColor3 = WHITE_COLOR,
        Children = {
            _new("UICorner")({})
        }
    }) :: TextLabel

    local msgPreviewText = _new("TextLabel")({ 
        LayoutOrder = 1,
        Name = "MessagePreviewText",
        Size = UDim2.fromScale(1, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = GREY_COLOR,
        Text = "",
        TextScaled = true
    })

    local onMessageClick = maid:GiveTask(Signal.new())
    maid:GiveTask(onMessageClick:Connect(function()
        onMessagePlayerClickSignal:Fire(player)

        notificationText.Visible = false 
    end))

    local out = _new("Frame")({
        LayoutOrder = notifCount,
        Name = player.Name,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 0.15),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("ImageLabel")({
                Name = "AvatarImage",
                LayoutOrder = 0,
                BackgroundColor3 = PRIMARY_COLOR, 
                Size = UDim2.fromScale(0.15, 1),
                Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
                Children = {
                    _new("UICorner"){
                        CornerRadius = UDim.new(1,0)
                    },
                    _new("UIAspectRatioConstraint")({})
                } 
            }),

            _new("Frame")({
                Name = "PlayerInfoFrame",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.5, 1),
                LayoutOrder = 1,
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                    _new("TextLabel")({ 
                        LayoutOrder = 1,
                        Name = "PlayerName",
                        Size = UDim2.fromScale(1, 0.5),
                        BackgroundTransparency = 1,
                        RichText = true,
                        TextColor3 = BLACK_COLOR,
                        Text = "<b>" .. player.Name .. "</b>",
                        TextScaled = true
                    }),
                    msgPreviewText
                }
            }),

          

            notificationText,

            _bind(getButton(maid, "Message", onMessageClick, BUTTON_COLOR))({
                LayoutOrder = 3,
            }),
            
        }
    })
    return out
end
--scripts
return function(
    maid : Maid,

    onMessageSend : Signal,
    onMessageRecieve : Signal
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone
    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local playersChatHistory : {[string] : {[number] : {Sender : "Local" | "Other", MessageText : string, Instance : Instance ?}}} = {}

    local UIStatus : ValueState<PhoneUIStatus> = _Value(nil) :: any
    local MessageUIStatus : ValueState<"Chat" | nil> = _Value(nil) :: any

    local chatWithPlayerStatus : ValueState<Player ?> = _Value(nil) :: any

    local onMessageClick = maid:GiveTask(Signal.new())
    local onSettingsClick = maid:GiveTask(Signal.new())
    local onInfoClick = maid:GiveTask(Signal.new())

    local onMessagePlayerClick = maid:GiveTask(Signal.new())

    local onMessageSendAttempt = maid:GiveTask(Signal.new())

    local onBack = maid:GiveTask(Signal.new())

    local isTypingText = _new("TextLabel")({
        LayoutOrder = 3,
        Name = "IsTypingStatus",
        Visible = false,
        Size = UDim2.fromScale(1, 0.07),
        Text = "is typing...",
        TextColor3 = GREY_COLOR,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = true,
    }) :: TextLabel

    local chatContent =  _new("ScrollingFrame")({ 
        LayoutOrder = 2,
        Name = "ChatContent",
        Size = UDim2.fromScale(1, 0.65),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Vertical,
                Padding = PADDING_SIZE,
            })
        }
    }) :: ScrollingFrame
    
    local chatInsertionTextBox =  _new("TextBox")({
        LayoutOrder = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        PlaceholderText = "Message",
        Size = UDim2.fromScale(0.65, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Events = {
            Focused = function()
                if RunService:IsRunning() then
                    local reciever = chatWithPlayerStatus:Get() 
                    assert(reciever)
                    NetworkUtil.fireServer(IS_PLAYER_TYPING_CHECK, reciever.Name, true)
                end
            end,
            FocusLost = function(enterPressed : boolean)
                if RunService:IsRunning() then
                    local reciever = chatWithPlayerStatus:Get() 
                    assert(reciever)
                    NetworkUtil.fireServer(IS_PLAYER_TYPING_CHECK, reciever.Name, false)
                end
                if enterPressed then
                    onMessageSendAttempt:Fire()
                end
            end :: any
        }
    }) :: TextBox


    local function removeChatData(chatData, plrName : string ?)
        for plrNameIndex : string,v in pairs(playersChatHistory) do
            if plrNameIndex == nil or (plrNameIndex == plrName) then
                for k, chat in pairs(v) do
                    if chatData == chat then
                        if chat.Instance then chat.Instance:Destroy(); chat.Instance = nil; end
                        for prop, val in pairs(chatData) do
                            chatData[prop] = nil
                        end

                        table.remove(v, k)
                    end
                end
            end
        end
    end
    local removeOtherPlayerChatHistory = function (otherPlr : Player)
        for plrName : string,v in pairs(playersChatHistory) do
            for k, chat in pairs(v) do
                removeChatData(chat, otherPlr.Name)
            end
            playersChatHistory[plrName] = nil
        end
    end

    local function onChatCreateUI(sender : "Local" | "Other", plr : Player, msgText : string)
        local playerChatHistory = playersChatHistory[plr.Name]
        assert(playerChatHistory, "Player does not exist!")
          --mengolahkan msgText
        local new_msgText = ""
        local customindex = 0
        msgText:gsub(".", function(c)
            if c:match("%S") == nil then
            customindex += 1
            end

            if customindex > 12 then
                c = "\n"..c 
                customindex = 0
            end 
            new_msgText = new_msgText .. c 
            return c 
        end)

        --
        local senderData: { Instance: any, MessageText: string, Sender: "Local" | "Other" } 

        senderData = { 
            Sender = sender,
            MessageText = new_msgText,
            Instance = nil :: any
        }
        if not playersChatHistory[plr.Name] then playersChatHistory[plr.Name] = {} end
        table.insert(playerChatHistory, senderData)
        if #playerChatHistory > CHAT_LIMIT then
            local obseleteSenderData = playerChatHistory[1]
            removeChatData(obseleteSenderData, plr.Name)
           
        end

        assert(senderData, "no sender data!")

        local chatTextFrame = _new("Frame")({ 
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0.25*(math.ceil(senderData.MessageText:len()/15))),
            Parent = chatContent,
            Children = {
                _new("UIListLayout")({
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = if senderData.Sender == "Local" then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left
                }),
                _new("ImageLabel")({
                    Name = "AvatarImage",
                    LayoutOrder = if senderData.Sender == "Local" then 2 else 0,
                    BackgroundColor3 =  BACKGROUND_COLOR, 
                    Size = UDim2.fromScale(0.15, 1),
                    Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
                    Children = {
                        _new("UICorner"){
                            CornerRadius = UDim.new(1,0) 
                        },
                        _new("UIAspectRatioConstraint")({})
                    } 
                }),
                _new("Frame")({
                    LayoutOrder = 1, 
                    BackgroundColor3 = if senderData.Sender == "Local" then GREEN_COLOR else GREY_COLOR,
                    Size = UDim2.fromScale(0.85, 1),
                    Children = {
                        _new("UIListLayout")({
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder
                        }),
                        _new("UICorner")({}),
                        _new("UIPadding")({
                            PaddingTop = TOP_PADDING_SIZE,
                            PaddingBottom = PADDING_SIZE,
                            PaddingRight = PADDING_SIZE,
                            PaddingLeft = PADDING_SIZE
                        }),
                        _new("TextLabel")({
                            LayoutOrder = 1,
                            Name = "ChatText",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(0.65, 1),
                            Text = senderData.MessageText,
                            TextScaled = true,
                            TextWrapped = true,
                            TextColor3 = WHITE_COLOR,
                            TextXAlignment = if senderData.Sender == "Local" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
                            
                        }),
                        _new("TextLabel"){
                            LayoutOrder = 2,
                            Name = "Timestamp",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(0.3, 0.8),
                            Text = Lighting.TimeOfDay:match("^%d%d:%d%d"),
                            TextSize = 10,
                            TextColor3 = WHITE_COLOR,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Children = {
                             
                            }
                        }

                    }
                }),
            }
        })
         
        senderData.Instance = chatTextFrame
        chatContent.CanvasPosition = Vector2.new(0, chatContent.AbsoluteCanvasSize.Y)

        return chatTextFrame 
    end
  
    local function onChatFrameOpened(otherPlr : Player)
        for plrName : string,v in pairs(playersChatHistory) do
            for _, chat in pairs(v) do
                if (plrName == otherPlr.Name) and chat.Instance then
                    chat.Instance.Visible = true
                elseif chat.Instance then
                    chat.Instance.Visible = false
                end
            end
        end
    end
 
    local chatFrame = _new("Frame")({
        Name = "ChatFrame",
        ZIndex = 2,
        Size = UDim2.fromScale(1, 1),
        Visible = _Computed(function(uiStatus : "Chat" | nil)
            return uiStatus == "Chat"
        end, MessageUIStatus),
        Children = {
            _new("UICorner")({}),

            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = TOP_PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                Name = "PlayerName", 
                Size = UDim2.fromScale(1, 0.1), 
                BackgroundColor3 = PRIMARY_COLOR,
                RichText = true,
                Text = _Computed(function(plr : Player ?)
                    if plr then onChatFrameOpened(plr) end
                    return if plr then ("<b>" .. plr.Name .. "</b>") else ""
                end, chatWithPlayerStatus), 
                TextColor3 = WHITE_COLOR,
            }),
            chatContent,
            isTypingText,
            _new("Frame")({
                LayoutOrder = 4, 
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1 ),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal
                    }),
                    chatInsertionTextBox,
                    _bind(getButton(maid, "Send", onMessageSendAttempt, BUTTON_COLOR))({
                        
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(0.35, 1),
                        TextColor3 = WHITE_COLOR,
                    }) 
                }
            }),
        }
    })
    local playersMessageListFrame = _new("Frame")({
        BackgroundTransparency = 0.6,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 0.88),
        Children = {    
            _new("UIPadding")({
                PaddingBottom = PADDING_SIZE,
                PaddingTop = TOP_PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE, 
            }), 
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE,
                FillDirection = Enum.FillDirection.Vertical
            }),
           
        }
    })
    local messageFrame = _new("Frame")({
        Name = "MessageFrame", 
        Size = UDim2.fromScale(1, 1),
        Visible = _Computed(function(uiStatus : PhoneUIStatus)
            return uiStatus == "Message"
        end, UIStatus),
        ClipsDescendants = true,
        Children = {
            _new("UICorner")({}),

            _new("Frame")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _new("TextLabel")({
                        LayoutOrder = -1,
                        Name = "MsgTitle",
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.1),
                        RichText = true,
                        Text = "<b>Messages</b>",
                        TextScaled = true,
                        TextColor3 = GREY_COLOR, 
                    }),
                    playersMessageListFrame
                }
            }),
            chatFrame,

        }
    })

    local InfoFrame = _new("Frame")({
        Visible = _Computed(function(uiStatus : PhoneUIStatus)
            return uiStatus == "Info"
        end, UIStatus),
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                
            }),
            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                Text = "Phone Info: Lumina L20 Series\n Made in: Bread City \n Manufactured in: New Town City",
                TextColor3 = GREY_COLOR,
                TextScaled = true,
            }),
            _new("TextLabel")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                Text = "Made in: Bread city",
                TextColor3 = GREY_COLOR,
                TextScaled = true,
            }),
        }
    })

    local function getSettingsFrameList(layoutOrder : number, optName : string, onButtonSignal : Signal, switchState : ValueState<boolean>)
        local out = _new("Frame")({
            Name = "StyleModeOptFrame",
            LayoutOrder = layoutOrder,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0.15),
            Children = {
                _new("UIListLayout")({
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder
                }),
                _new("TextLabel")({
                    LayoutOrder = 1,
                    Size = UDim2.fromScale(0.7, 1),
                    Text = optName,
                }),
                _bind(getButton(maid, "Off", onButtonSignal))({
                    LayoutOrder = 2,
                    BackgroundColor3 = _Computed(function(switch : boolean)
                        return if switch == true then GREEN_COLOR else RED_COLOR
                    end, switchState),
                    Size = UDim2.fromScale(0.3, 1),
                    Text = _Computed(function(switch : boolean)
                        return if switch == true then "On" else "Off"
                    end, switchState)
                })
            }
        })
        return out
    end

    local silentModeSignal = maid:GiveTask(Signal.new())
    local silentMode = maid:GiveTask(_Value(false))

    local SettingFrame = _new("Frame"){
        Visible = _Computed(function(uiStatus : PhoneUIStatus)
            return uiStatus == "Settings"
        end, UIStatus),
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("TextLabel")({
                LayoutOrder = 0,
                Size = UDim2.fromScale(1, 0.1),
                RichText = _Computed(function(isSilent : boolean) 
                    if RunService:IsRunning() then
                        NetworkUtil.fireServer(ON_SILENT_SWITCH, isSilent)
                    end
                    return true 
                end, silentMode),
                Text = "<b>Settings</b>",
                TextColor3 = BLACK_COLOR,
            }),
            getSettingsFrameList(1, "Silent Mode", silentModeSignal, silentMode),
        }
    }

    maid:GiveTask(silentModeSignal:Connect(function()
        silentMode:Set(not silentMode:Get())
    end))

    local backButton = _bind(getButton(maid, "<", onBack, RED_COLOR))({
        ZIndex = 2,
        Size = UDim2.fromScale(0.15, 0.13), 
        Position = UDim2.fromScale(-0.15, 0.5), 
        Visible = _Computed(function(uiStatus : PhoneUIStatus)
            return uiStatus ~= nil 
        end, UIStatus),  
    })

    local currentTime = _Value(`{Lighting.TimeOfDay:match("^%d%d:%d%d")}\nSunday`)
    if RunService:IsStudio() then
        maid:GiveTask(Lighting.Changed:Connect(function()
            currentTime:Set(`{Lighting.TimeOfDay:match("^%d%d:%d%d")}\n{getCurrentDay().Name}`)
        end))
    end
    local clockFrame = _new("Frame"){
        LayoutOrder = 0,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.85, 0.25),
        Children = {
            _new("TextLabel")({
                Size = UDim2.fromScale(1, 1),
                TextScaled = true,
                RichText = true,
                Text = currentTime,
                TextColor3 = BLACK_COLOR,
            })
        }
    }

    local totalMsgNotifText = _new("TextLabel")({
        BackgroundColor3 = RED_COLOR,
        Visible = false,
        Size = UDim2.fromScale(0.25, 0.25),
        Position = UDim2.fromScale(0.75, 0),
        TextColor3 = WHITE_COLOR,
        Text = "0",
    }) ::TextLabel
    local out = _new("Frame"){
        BackgroundColor3 = GREY_COLOR,
        Size = UDim2.fromScale(0.15, 0.3),
        Position = UDim2.fromScale(0.42, 0.55), 
        Children = {
            backButton,
            _new("UIAspectRatioConstraint")({
                AspectRatio = 0.62,
            }),
            _new("UICorner")({}),
            _new("UIPadding")({ 
                PaddingBottom = PADDING_SIZE, 
                PaddingTop = TOP_PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE,
            }),
            _new("Frame")({
                Name = "MainFrame",
                Visible = _Computed(function(uiStatus : PhoneUIStatus)
                    return uiStatus == nil 
                end, UIStatus),  
                Size = UDim2.fromScale(1, 1),
                Children = {
                    _new("UICorner")({}),
                   
                    _new("UIListLayout"){
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    },
                    clockFrame,
                    _new("ScrollingFrame")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.85),
                        CanvasSize = UDim2.new(),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        Children = {
                            _new("UIGridLayout")({
                                CellPadding = UDim2.fromScale(0.05, 0.05),
                                CellSize = UDim2.fromScale(0.3, 0.28)
                            }),
                            _new("UIPadding")({
                                PaddingBottom = PADDING_SIZE,
                                PaddingTop = TOP_PADDING_SIZE,
                                PaddingLeft = PADDING_SIZE,
                                PaddingRight = PADDING_SIZE,
                            }),
                            _bind(getImageButton(maid, 11702915127, onMessageClick, "Messages"))({
                                Children = {
                                    totalMsgNotifText :: any
                                }
                            }),
                            getImageButton(maid, 13568966069, onSettingsClick, "Settings"),
                            getImageButton(maid, 9405926389, onInfoClick, "Info"),
                        } 
                    }),
                }
            }),
          
            messageFrame,
            InfoFrame,
            SettingFrame
        }
    }

    maid:GiveTask(onMessageClick:Connect(function()
        UIStatus:Set("Message")
    end))
    maid:GiveTask(onInfoClick:Connect(function()
        UIStatus:Set("Info") 
    end))
    maid:GiveTask(onSettingsClick:Connect(function()
        UIStatus:Set("Settings") 
    end))
 
    local function updateNotif(plr : Player)
        --update notif
        local totalChatCount = 0
        for _,v in pairs(playersMessageListFrame:GetChildren()) do
            local notifText = v:FindFirstChild("Notification") :: TextLabel ?
            local chatHistoryData = playersChatHistory[plr.Name]
            local chatCount = #chatHistoryData

            if v:IsA("Frame") then
                if v.Name == plr.Name then
                    if chatWithPlayerStatus:Get() ~= plr then
                        if notifText then
                            notifText.Text = tostring(chatCount)
                            notifText.Visible = true
                        end
                    end
                    local playerInfoFrame = v:FindFirstChild("PlayerInfoFrame")
                    local previewText = if playerInfoFrame then playerInfoFrame:FindFirstChild("MessagePreviewText") :: TextLabel else nil
                    if previewText and chatHistoryData then
                        local chatData = chatHistoryData[chatCount]
                        if chatData then 
                            local msgText = chatData.MessageText 
                            local previewMsgText = ""
                            local index = 0
                            local indexLimit = 9
                            msgText:gsub(".", function(s)
                                index += 1

                                if index < indexLimit then
                                    previewMsgText = previewMsgText .. s
                                elseif index == indexLimit then
                                    previewMsgText = previewMsgText .. "..."
                                end

                                return s
                            end)
                            previewText.Text = previewMsgText
                        end
                    end
                end
            end
        end

        for _,v in pairs(playersMessageListFrame:GetChildren()) do
            local notifText = v:FindFirstChild("Notification") :: TextLabel ?
            if notifText and notifText.Visible then
                local notifCount  = tonumber(notifText.Text)
                if notifCount then
                    totalChatCount += notifCount
                end
            end
        end

        totalMsgNotifText.Text = tostring(totalChatCount)
        if totalChatCount > 0 then
            totalMsgNotifText.Visible = true
        else
            totalMsgNotifText.Visible = false
        end
    end

    
    maid:GiveTask(onMessagePlayerClick:Connect(function(player : Player)
        MessageUIStatus:Set("Chat")
        chatWithPlayerStatus:Set(player)

        updateNotif(player)
    end))

    maid:GiveTask(onMessageSendAttempt:Connect(function()
        local plr = chatWithPlayerStatus:Get()
        assert(plr)
        local msgText = chatInsertionTextBox.Text

        chatInsertionTextBox.Text = ""

        if string.match(msgText, "%S") == nil then return end -- if space only 
 
        onMessageSend:Fire(plr, msgText)
        if RunService:IsRunning() then
            msgText = NetworkUtil.invokeServer(ON_PHONE_MESSAGE_START, plr.Name, msgText)
        end
 
        onChatCreateUI("Local", plr, msgText)

        updateNotif(plr)
    end))

    maid:GiveTask(onMessageRecieve:Connect(function(plr : Player, msgText : string)
        onChatCreateUI("Other", plr, msgText)

        updateNotif(plr)
    end)) 

    maid:GiveTask(onBack:Connect(function()
        if UIStatus:Get() == "Message" then
            if MessageUIStatus:Get() =="Chat" then
                MessageUIStatus:Set(nil)
            else
                UIStatus:Set(nil)
            end
        elseif UIStatus:Get() == "Info" then
            UIStatus:Set(nil)
        elseif UIStatus:Get() == "Settings" then
            UIStatus:Set(nil)
        end
    end))

    local onPlayerChatHistoryAdded = function(plr:Player)
        playersChatHistory[plr.Name] = {}
        getPlayerList(maid, plr, onMessagePlayerClick, 0).Parent = playersMessageListFrame
    end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            onPlayerChatHistoryAdded(plr)
        end
    end

    maid:GiveTask(Players.PlayerAdded:Connect(function(plr : Player) 
        onPlayerChatHistoryAdded(plr)
    end))
    maid:GiveTask(Players.PlayerRemoving:Connect(function(plr : Player) 
        removeOtherPlayerChatHistory(plr)
        for _,v in pairs(playersMessageListFrame:GetChildren()) do
            if v:IsA("Frame") and v.Name == plr.Name and v:FindFirstChild("PlayerInfoFrame") then
                v:Destroy()
            end
        end
    end))

    if not RunService:IsRunning() then
        --onPlayerChatHistoryAdded(workspace.Part1)
        --onPlayerChatHistoryAdded(workspace.Part2)
        --onPlayerChatHistoryAdded(workspace.Part3)
    else
        NetworkUtil.onClientEvent(IS_PLAYER_TYPING_CHECK, function(senderName : string, isTyping : boolean)
            local plrtochat = chatWithPlayerStatus:Get()
            if plrtochat and (senderName == plrtochat.Name) then
                isTypingText.Visible = isTyping 
            end
        end)
    end 

    return out
end
