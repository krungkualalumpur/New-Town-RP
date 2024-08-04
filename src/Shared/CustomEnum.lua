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
export type AnimationAction = CustomEnumItem<AnimationActionEnum, "ShowerWithBucket"|"Rowing"|"TagAnObject"|"TypingStanding"|"TypingSitting"|"ScooterAnim"|"Reading"|"Texting"|"Eating"|"Drinking"|"Sleeping"|"Dance1"|"Dance2"|"GetOut"|"Happy"|"Laugh"|"No"|"Point"|"Sad"|"Shy"|"Standing"|"Wave"|"Yawning"|"Yes">

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
		ScooterAnim : CustomEnumItem <AnimationActionEnum, "ScooterAnim">,
		Reading : CustomEnumItem <AnimationActionEnum, "Reading">,
		Texting : CustomEnumItem <AnimationActionEnum, "Texting">,
		Eating : CustomEnumItem <AnimationActionEnum, "Eating">,
		Drinking : CustomEnumItem <AnimationActionEnum, "Drinking">,
		Sleeping : CustomEnumItem <AnimationActionEnum, "Sleeping">,
		Dance1 : CustomEnumItem <AnimationActionEnum, "Dance1">,
		Dance2 : CustomEnumItem <AnimationActionEnum, "Dance2">,
		GetOut : CustomEnumItem <AnimationActionEnum, "GetOut">,
		Happy : CustomEnumItem <AnimationActionEnum, "Happy">,
		Laugh : CustomEnumItem <AnimationActionEnum, "Laugh">,
		No : CustomEnumItem <AnimationActionEnum, "No">,
		Point : CustomEnumItem <AnimationActionEnum, "Point">,
		Sad : CustomEnumItem <AnimationActionEnum, "Sad">,
		Shy : CustomEnumItem <AnimationActionEnum, "Shy">,
		Standing : CustomEnumItem <AnimationActionEnum, "Standing">,
		Wave : CustomEnumItem <AnimationActionEnum, "Wave">,
		Yawning : CustomEnumItem <AnimationActionEnum, "Yawning">,
		Yes : CustomEnumItem <AnimationActionEnum, "Yes">,
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

AnimationAction.ScooterAnim = {
	Name = "ScooterAnim",
	Value = 6,
	EnumType = AnimationAction
}

AnimationAction.Reading = {
	Name = "Reading",
	Value = 7,
	EnumType = AnimationAction
}

AnimationAction.Texting = {
	Name = "Texting",
	Value = 8,
	EnumType = AnimationAction
}

AnimationAction.Eating = {
	Name = "Eating",
	Value = 9,
	EnumType = AnimationAction
}

AnimationAction.Drinking = {
	Name = "Drinking",
	Value = 10,
	EnumType = AnimationAction
}

AnimationAction.Sleeping = {
	Name = "Sleeping",
	Value = 11,
	EnumType = AnimationAction
}

AnimationAction.Dance1 = {
	Name = "Dance1",
	Value = 12,
	EnumType = AnimationAction
}

AnimationAction.Dance2 = {
	Name = "Dance2",
	Value = 13,
	EnumType = AnimationAction
}

AnimationAction.GetOut = {
	Name = "GetOut",
	Value = 14,
	EnumType = AnimationAction
}

AnimationAction.Happy = {
	Name = "Happy",
	Value = 15,
	EnumType = AnimationAction
}

AnimationAction.Laugh = {
	Name = "Laugh",
	Value = 16,
	EnumType = AnimationAction
}

AnimationAction.No = {
	Name = "No",
	Value = 17,
	EnumType = AnimationAction
}

AnimationAction.Point = {
	Name = "Point",
	Value = 18,
	EnumType = AnimationAction
}

AnimationAction.Sad = {
	Name = "Sad",
	Value = 19,
	EnumType = AnimationAction
}

AnimationAction.Shy = {
	Name = "Shy",
	Value = 20,
	EnumType = AnimationAction
}

AnimationAction.Standing = {
	Name = "Standing",
	Value = 21,
	EnumType = AnimationAction
}

AnimationAction.Wave = {
	Name = "Wave",
	Value = 22,
	EnumType = AnimationAction
}

AnimationAction.Yawning = {
	Name = "Yawning",
	Value = 23,
	EnumType = AnimationAction
}

AnimationAction.Yes = {
	Name = "Yes",
	Value = 24,
	EnumType = AnimationAction
}

local CustomEnum = {	
	BezierQuality = BezierQuality :: any,
	Day = Day :: any,
	AnimationAction = AnimationAction :: any,
} :: CustomEnums

return CustomEnum