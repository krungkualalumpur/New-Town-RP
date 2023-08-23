--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
--variables
--references
--local functions
local function getIntValue()
    local intValue = Instance.new("IntValue")
    intValue.Value = 1
    return intValue
end
--class
local TVchannel = {}

TVchannel.Channels = {
    [1] = {
        Id = 1,
        Name = "Channel 1",
        TextState = getIntValue(),
        Texts = { 
            [1] = '<b>GLOBAL NEWS</b> \nWe are only a few weeks away from the 2023 <font color="rgb(3, 94,180)">#Roblox Developers Conference!</font>',
            [2] = "<b>LOCAL NEWS</b> \"Another MRT incident in Hanoman city, 5 injured, no casualties.",
            [3] = "<b>BAHASA NEWS</b> \"Datuak Parpatiah nan Sabatang akan berkunjung ke Kota Kampung Bandar bulan ini.",
            [4] = "<b>WEATHER FORECAST</b> \n TODAY : SUNNY 30 C\n TOMMOROW : CLOUDY 26 C\n Source: Badan Meteorologi Pluteous"
        }
    },
}

function TVchannel.getChannelById(Id : number)
    for _,v in pairs(TVchannel.Channels) do
        if v.Id == Id then
            return v
        end
    end
    error("No channel available!")
end
function TVchannel.getCurrentTextStateByChannelId(Id : number)
    return TVchannel.getChannelById(Id).TextState
end

function TVchannel.getTextByTextState(Id : number, textState : number)
    return TVchannel.getChannelById(Id).Texts[textState]
end

function TVchannel.init(maid : Maid)
    if RunService:IsServer() then
        local intTick = tick()

        maid:GiveTask(RunService.Stepped:Connect(function()
            if tick() - intTick >= 4 then
                intTick = tick() 
                for _,v in pairs(TVchannel.Channels) do
                    local textState = if v.Texts[v.TextState.Value + 1] then (v.TextState.Value + 1) else 1
                    v.TextState.Value = textState
                end
            end
        end))
       
    end
end
return TVchannel