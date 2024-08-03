--This is an auto generated script, please do not modify this!
--!strict
--services
--packages
--modules
--types
type CustomEnum <N> = {
	Name : N,
	GetEnumItems : (self : CustomEnum<N>) -> {[number] : CustomEnumItem<CustomEnum<N>, string>}
}

type CustomEnumItem <E, N> = {
	Name : N,
	Value : number,
	EnumType : E
}
type BezierQualityEnum = CustomEnum<"BezierQuality">
export type BezierQuality = CustomEnumItem<BezierQualityEnum, "Low"|"Medium"|"High">

type DayEnum = CustomEnum<"Day">
export type Day = CustomEnumItem<DayEnum, "Sunday"|"Monday"|"Tuesday"|"Wednesday"|"Thursday"|"Friday"|"Saturday">

type AnimationActionEnum = CustomEnum<"AnimationAction">
export type AnimationAction = CustomEnumItem<AnimationActionEnum, "ShowerWithBucket"|"Rowing"|"TagAnObject"|"TypingStanding"|"TypingSitting"|"Sleeping"|"ScooterAnim"|"Reading"|"Texting"|"Eating"|"Drinking">

export type CustomEnums = {

	BezierQuality : 	{		
		Low : CustomEnumItem <BezierQualityEnum, "Low">,
		Medium : CustomEnumItem <BezierQualityEnum, "Medium">,
		High : CustomEnumItem <BezierQualityEnum, "High">,
	} & BezierQualityEnum,

	Day : 	{		
		Sunday : CustomEnumItem <DayEnum, "Sunday">,
		Monday : CustomEnumItem <DayEnum, "Monday">,
		Tuesday : CustomEnumItem <DayEnum, "Tuesday">,
		Wednesday : CustomEnumItem <DayEnum, "Wednesday">,
		Thursday : CustomEnumItem <DayEnum, "Thursday">,
		Friday : CustomEnumItem <DayEnum, "Friday">,
		Saturday : CustomEnumItem <DayEnum, "Saturday">,
	} & DayEnum,

	AnimationAction : 	{		
		ShowerWithBucket : CustomEnumItem <AnimationActionEnum, "ShowerWithBucket">,
		Rowing : CustomEnumItem <AnimationActionEnum, "Rowing">,
		TagAnObject : CustomEnumItem <AnimationActionEnum, "TagAnObject">,
		TypingStanding : CustomEnumItem <AnimationActionEnum, "TypingStanding">,
		TypingSitting : CustomEnumItem <AnimationActionEnum, "TypingSitting">,
		Sleeping : CustomEnumItem <AnimationActionEnum, "Sleeping">,
		ScooterAnim : CustomEnumItem <AnimationActionEnum, "ScooterAnim">,
		Reading : CustomEnumItem <AnimationActionEnum, "Reading">,
		Texting : CustomEnumItem <AnimationActionEnum, "Texting">,
		Eating : CustomEnumItem <AnimationActionEnum, "Eating">,
		Drinking : CustomEnumItem <AnimationActionEnum, "Drinking">,
	} & AnimationActionEnum,

}
--constants
--remotes
--local function


local BezierQuality = {
	Name = "BezierQuality",
	GetEnumItems = function(self)
		local t = {}
		for _,v in pairs(self) do
			if type(v) == "table" then 
				 table.insert(t, v)  
			end
		end
		return t
	end,
}

BezierQuality.Low = {
	Name = "Low",
	Value = 1,
	EnumType = BezierQuality
}

BezierQuality.Medium = {
	Name = "Medium",
	Value = 2,
	EnumType = BezierQuality
}

BezierQuality.High = {
	Name = "High",
	Value = 3,
	EnumType = BezierQuality
}

local Day = {
	Name = "Day",
	GetEnumItems = function(self)
		local t = {}
		for _,v in pairs(self) do
			if type(v) == "table" then 
				 table.insert(t, v)  
			end
		end
		return t
	end,
}

Day.Sunday = {
	Name = "Sunday",
	Value = 1,
	EnumType = Day
}

Day.Monday = {
	Name = "Monday",
	Value = 2,
	EnumType = Day
}

Day.Tuesday = {
	Name = "Tuesday",
	Value = 3,
	EnumType = Day
}

Day.Wednesday = {
	Name = "Wednesday",
	Value = 4,
	EnumType = Day
}

Day.Thursday = {
	Name = "Thursday",
	Value = 5,
	EnumType = Day
}

Day.Friday = {
	Name = "Friday",
	Value = 6,
	EnumType = Day
}

Day.Saturday = {
	Name = "Saturday",
	Value = 7,
	EnumType = Day
}

local AnimationAction = {
	Name = "AnimationAction",
	GetEnumItems = function(self)
		local t = {}
		for _,v in pairs(self) do
			if type(v) == "table" then 
				 table.insert(t, v)  
			end
		end
		return t
	end,
}

AnimationAction.ShowerWithBucket = {
	Name = "ShowerWithBucket",
	Value = 1,
	EnumType = AnimationAction
}

AnimationAction.Rowing = {
	Name = "Rowing",
	Value = 2,
	EnumType = AnimationAction
}

AnimationAction.TagAnObject = {
	Name = "TagAnObject",
	Value = 3,
	EnumType = AnimationAction
}

AnimationAction.TypingStanding = {
	Name = "TypingStanding",
	Value = 4,
	EnumType = AnimationAction
}

AnimationAction.TypingSitting = {
	Name = "TypingSitting",
	Value = 5,
	EnumType = AnimationAction
}

AnimationAction.Sleeping = {
	Name = "Sleeping",
	Value = 6,
	EnumType = AnimationAction
}

AnimationAction.ScooterAnim = {
	Name = "ScooterAnim",
	Value = 7,
	EnumType = AnimationAction
}

AnimationAction.Reading = {
	Name = "Reading",
	Value = 8,
	EnumType = AnimationAction
}

AnimationAction.Texting = {
	Name = "Texting",
	Value = 9,
	EnumType = AnimationAction
}

AnimationAction.Eating = {
	Name = "Eating",
	Value = 10,
	EnumType = AnimationAction
}

AnimationAction.Drinking = {
	Name = "Drinking",
	Value = 11,
	EnumType = AnimationAction
}

local CustomEnum = {	
	BezierQuality = BezierQuality :: any,
	Day = Day :: any,
	AnimationAction = AnimationAction :: any,
} :: CustomEnums

return CustomEnum