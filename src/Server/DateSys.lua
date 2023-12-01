--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local CustomEnum = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomEnum"))
--types
type Maid = Maid.Maid
export type DataSys = {
    __index : DataSys,
    _Maid : Maid,
   
    CurrentDay : CustomEnum.Day,

    new : () -> (DataSys),
    SetCurrentDay : (DataSys, day : CustomEnum.Day) -> (),
    Destroy : (DataSys) -> (),
    init : (maid : Maid) -> ()
}
--constants
local DAY_VALUE_KEY = "DayValue"
--variables
--references
--local functions
--class
local DataSys : DataSys = {} :: any
DataSys.__index = DataSys

function DataSys.new()
    local self : DataSys = setmetatable({}, DataSys) :: any
    self._Maid = Maid.new()

    --initialize
    local dayValue = Instance.new("IntValue")
    dayValue.Name = DAY_VALUE_KEY
    dayValue.Parent = workspace

    self:SetCurrentDay(CustomEnum.Day.Sunday)

    local function getDayByDayCount(dayCount : number)
        for _,v in pairs(CustomEnum.Day:GetEnumItems()) do
            if v.Value == dayCount then
                return v
            end
        end
        return CustomEnum.Day.Sunday
    end

    local isDayBuffering = false
    local dayCount = self.CurrentDay.Value

  
    self._Maid:GiveTask(Lighting.Changed:Connect(function()
        if (math.floor(Lighting.ClockTime) == 0) and not isDayBuffering then
            isDayBuffering = true
            dayCount += 1

            self:SetCurrentDay(getDayByDayCount(dayCount))
            
            dayCount = self.CurrentDay.Value
           
            print("Today is ", self.CurrentDay.Name)
        elseif (math.floor(Lighting.ClockTime) > 0) and  isDayBuffering then
            isDayBuffering = false
        end
    end))

    return self
end

function DataSys:SetCurrentDay(day : CustomEnum.Day)
    local dayValue = workspace:WaitForChild(DAY_VALUE_KEY) :: IntValue
    assert(dayValue:IsA("IntValue"))

    self.CurrentDay = day
    dayValue.Value = day.Value
end

function DataSys:Destroy()
    local t : any = self  
    self._Maid:Destroy()
    for k, v in pairs(t) do
        t[k] = nil
    end
    return
end

function DataSys.init(maid : Maid)
    maid:GiveTask(DataSys.new())
end

return DataSys