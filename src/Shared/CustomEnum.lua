--!strict
--services
--packages
--modules
--types
export type CustomEnum <N> = {
	Name : N,
	GetEnumItems : (self : CustomEnum<N>) -> {[number] : CustomEnumItem<CustomEnum<N>, string>}
}

export type CustomEnumItem <E, N> = {
	Name : string,
	Value : number,
	EnumType : E
}
type DayEnum = CustomEnum<"Day">
export type Day = CustomEnumItem<DayEnum, string>

export type CustomEnums = {

	Day : 	{		
		Sunday : CustomEnumItem <DayEnum, "Sunday">,
		Monday : CustomEnumItem <DayEnum, "Monday">,
		Tuesday : CustomEnumItem <DayEnum, "Tuesday">,
		Wednesday : CustomEnumItem <DayEnum, "Wednesday">,
		Thursday : CustomEnumItem <DayEnum, "Thursday">,
		Friday : CustomEnumItem <DayEnum, "Friday">,
		Saturday : CustomEnumItem <DayEnum, "Saturday">,
	} & DayEnum,

}
--constants
--remotes
--local function


local Day = {
	Name = "Day" :: any,
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
	Name = "Sunday" :: any,
	Value = 1,
	EnumType = Day
}

Day.Monday = {
	Name = "Monday" :: any,
	Value = 2,
	EnumType = Day
}

Day.Tuesday = {
	Name = "Tuesday" :: any,
	Value = 3,
	EnumType = Day
}

Day.Wednesday = {
	Name = "Wednesday" :: any,
	Value = 4,
	EnumType = Day
}

Day.Thursday = {
	Name = "Thursday" :: any,
	Value = 5,
	EnumType = Day
}

Day.Friday = {
	Name = "Friday" :: any,
	Value = 6,
	EnumType = Day
}

Day.Saturday = {
	Name = "Saturday" :: any,
	Value = 7,
	EnumType = Day
}

local CustomEnum = {	
	Day = Day :: any,
} :: CustomEnums

return CustomEnum