--!strict 
--services 
--packages 
--modules 
--types 
export type CustomizationClass = "Accessory" | "Face" | "Shirt" | "Pants"

export type Customization = { 
	Class : CustomizationClass,
	Name : string,
	TemplateId : number
}
--constants 
--variables 
local CustomizationList : {[number] : Customization} = {
	{
		Class = "Accessory",
		Name = "Malibu Festival Hair",
		TemplateId = 14212171129,
	},
	{
		Class = "Accessory",
		Name = "😄 Blushing Big Smile Face (3D) 😄",
		TemplateId = 12064732367,
	},
	{
		Class = "Accessory",
		Name = "❤️Cute Joy Blush Face❤️",
		TemplateId = 13253018587,
	},
	{
		Class = "Accessory",
		Name = "📀 Faceless",
		TemplateId = 12383395027,
	},
	{
		Class = "Accessory",
		Name = "💕Kawaii Cutie Blush Face",
		TemplateId = 14077508293,
	},
	{
		Class = "Accessory",
		Name = "Silver Star Cyber Sigil Crown",
		TemplateId = 12922571644,
	},
	{
		Class = "Accessory",
		Name = "Low Thin Round Glasses Black",
		TemplateId = 12014310349,
	},
	{
		Class = "Accessory",
		Name = "Roblox Baseball Cap",
		TemplateId = 607702162,
	},
	{
		Class = "Accessory",
		Name = "Elf Ears",
		TemplateId = 13452778789,
	},
	{
		Class = "Accessory",
		Name = "Cold Blushy Cute Girl",
		TemplateId = 12361516582,
	},
	{
		Class = "Accessory",
		Name = "Hungry Blob",
		TemplateId = 13916929716,
	},
	{
		Class = "Accessory",
		Name = "Anime Straw Hat on Back",
		TemplateId = 14109830077,
	},
	{
		Class = "Accessory",
		Name = "Evil Purple Shake",
		TemplateId = 13986559755,
	},
	{
		Class = "Accessory",
		Name = "Black Spiky Hair",
		TemplateId = 13832918624,
	},
	{
		Class = "Accessory",
		Name = "Dragon",
		TemplateId = 13828544064,
	},
	{
		Class = "Accessory",
		Name = "Hungry Monster",
		TemplateId = 13916906201,
	},
	{
		Class = "Accessory",
		Name = "Popular Girl Cute Mask Light Brown",
		TemplateId = 11985118745,
	},
	{
		Class = "Accessory",
		Name = "Jellyfish Y2K Black Hair",
		TemplateId = 14279853522,
	},
	{
		Class = "Accessory",
		Name = "Y2K Multiverse Boy Beanie",
		TemplateId = 13685386315,
	},
	{
		Class = "Accessory",
		Name = "White Star Hairclips",
		TemplateId = 13533155377,
	},
	{
		Class = "Accessory",
		Name = "Ninja Mask of Shadows",
		TemplateId = 1309911,
	},
	{
		Class = "Accessory",
		Name = "Rainbow X Purge Mask",
		TemplateId = 9609586595,
	},
	{
		Class = "Accessory",
		Name = "cute kawaii puppy face filter",
		TemplateId = 13989741745,
	},
	{
		Class = "Accessory",
		Name = "White Raised Sunglasses",
		TemplateId = 8213730863,
	},
	{
		Class = "Accessory",
		Name = "Roblox Visor",
		TemplateId = 2646473721,
	},
	{
		Class = "Accessory",
		Name = "(Animated) Creepy Smile Madness Mask",
		TemplateId = 11417785930,
	},
	{
		Class = "Accessory",
		Name = "Black Y2K Cyberstar Glasses",
		TemplateId = 8207724090,
	},
	{
		Class = "Accessory",
		Name = "B/W Face Head",
		TemplateId = 12291759350,
	},
	{
		Class = "Accessory",
		Name = "Cold Blushy Cute Girl",
		TemplateId = 12379445256,
	},
	{
		Class = "Accessory",
		Name = "📀 Faceless",
		TemplateId = 12377198936,
	},
	{
		Class = "Accessory",
		Name = " Y2K White Knitted Rabbit Beanie",
		TemplateId = 12337910749,
	},
	{
		Class = "Accessory",
		Name = "Cute Chibi Face Mask",
		TemplateId = 13726856309,
	},
	{
		Class = "Accessory",
		Name = "Shiny Basic Headphones",
		TemplateId = 12920022570,
	},
	{
		Class = "Accessory",
		Name = "White Spiky Hair",
		TemplateId = 13832915407,
	},
	{
		Class = "Accessory",
		Name = "White Simple Bored Face",
		TemplateId = 12162793732,
	},
	{
		Class = "Accessory",
		Name = "Black Spikey Headphones",
		TemplateId = 8091854095,
	},
	{
		Class = "Accessory",
		Name = "Faceless Cheeks Head Light ",
		TemplateId = 12724989637,
	},
	{
		Class = "Accessory",
		Name = "Medieval Hood of Mystery",
		TemplateId = 617605556,
	},
	{
		Class = "Accessory",
		Name = "Heart Glasses",
		TemplateId = 13661490863,
	},
	{
		Class = "Accessory",
		Name = "Blush",
		TemplateId = 10856411911,
	},
	{
		Class = "Accessory",
		Name = "NewSide Bangs in Black",
		TemplateId = 6134532324,
	},
	{
		Class = "Accessory",
		Name = "Dual Red Evil Sword",
		TemplateId = 13905595453,
	},
	{
		Class = "Accessory",
		Name = "Fluffy Earmuffs In White",
		TemplateId = 6744680002,
	},
	{
		Class = "Accessory",
		Name = "Rainbow Flame Aura - Top",
		TemplateId = 5634362258,
	},
	{
		Class = "Accessory",
		Name = "White Trendy Shoulder Bag",
		TemplateId = 11280888020,
	},
	{
		Class = "Accessory",
		Name = "Cold Blushy Cute Girl",
		TemplateId = 12361152003,
	},
	{
		Class = "Accessory",
		Name = "Faceless",
		TemplateId = 12994295329,
	},
	{
		Class = "Accessory",
		Name = "Wing",
		TemplateId = 13849968553,
	},
	{
		Class = "Accessory",
		Name = "Celebrity Bling",
		TemplateId = 6239323549,
	},
	{
		Class = "Accessory",
		Name = "(Animated) Black Crying Entity Mask",
		TemplateId = 11966052244,
	},
	{
		Class = "Accessory",
		Name = "Swept Bangs in Black",
		TemplateId = 6965372930,
	},
	{
		Class = "Accessory",
		Name = "Blue's Hoodie",
		TemplateId = 13655543096,
	},
	{
		Class = "Accessory",
		Name = "Soft Chibi Eyes",
		TemplateId = 13935722443,
	},
	{
		Class = "Accessory",
		Name = "y2k butterfly cross chain necklace",
		TemplateId = 12918113689,
	},
	{
		Class = "Accessory",
		Name = "Mean Girl Cute Mask Light Brown",
		TemplateId = 12355935672,
	},
	{
		Class = "Accessory",
		Name = "Pop Cat",
		TemplateId = 6380246734,
	},
	{
		Class = "Accessory",
		Name = "Y2K Heart Necklace",
		TemplateId = 9324091278,
	},
	{
		Class = "Accessory",
		Name = "Elf Ears w/ White Piercings",
		TemplateId = 6275932619,
	},
	{
		Class = "Accessory",
		Name = "Voluminous Top Eyelashes in Black",
		TemplateId = 10714469213,
	},
	{
		Class = "Accessory",
		Name = "Titan Cameraman Head Skibi",
		TemplateId = 14132709265,
	},
	{
		Class = "Accessory",
		Name = "Cold Blushy Cute Girl",
		TemplateId = 12814583904,
	},
	{
		Class = "Accessory",
		Name = "Teary-Eyed Glasses",
		TemplateId = 11610991994,
	},
	{
		Class = "Accessory",
		Name = "Roblox Logo Visor",
		TemplateId = 607700713,
	},
	{
		Class = "Accessory",
		Name = "Shadowed Head [🏆]",
		TemplateId = 4904654004,
	},
	{
		Class = "Accessory",
		Name = "♡ angelic lashes",
		TemplateId = 13841714321,
	},
	{
		Class = "Accessory",
		Name = "TanqR Bedwars Buddy",
		TemplateId = 10961358092,
	},
	{
		Class = "Accessory",
		Name = "Fancy Stylish Glasses on Head",
		TemplateId = 7246171208,
	},
	{
		Class = "Accessory",
		Name = "Designer Keffiyeh",
		TemplateId = 14157118140,
	},
	{
		Class = "Accessory",
		Name = "Black Raised Goggles",
		TemplateId = 5693879776,
	},
	{
		Class = "Accessory",
		Name = "Robox",
		TemplateId = 4819740796,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Speakerman Core",
		TemplateId = 13569339530,
	},
	{
		Class = "Accessory",
		Name = "International Fedora - Germany",
		TemplateId = 3033910400,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Speakerman",
		TemplateId = 13568760629,
	},
	{
		Class = "Accessory",
		Name = "Kitty Star Beanie w/ Cyber Heart Goggles [White]",
		TemplateId = 13958916778,
	},
	{
		Class = "Accessory",
		Name = "Gamer Wings",
		TemplateId = 5313324044,
	},
	{
		Class = "Accessory",
		Name = "💵 CHEAP Middle Part Black Messy Hair",
		TemplateId = 14315842481,
	},
	{
		Class = "Accessory",
		Name = "Black - Oversized Cat Eye Glasses",
		TemplateId = 13803148089,
	},
	{
		Class = "Accessory",
		Name = "Cute Full Bangs (Black)",
		TemplateId = 8275222163,
	},
	{
		Class = "Accessory",
		Name = "White Stylish Headband",
		TemplateId = 11690230870,
	},
	{
		Class = "Accessory",
		Name = "Cute Face",
		TemplateId = 13628182787,
	},
	{
		Class = "Accessory",
		Name = "Rainbow Fashion Hood",
		TemplateId = 5316615598,
	},
	{
		Class = "Accessory",
		Name = "Realistic Capybara Mount",
		TemplateId = 11701552350,
	},
	{
		Class = "Accessory",
		Name = "Blush Sticker Filter",
		TemplateId = 10716153814,
	},
	{
		Class = "Accessory",
		Name = "Plasma Core for Titan Cameraman (Front)",
		TemplateId = 14135100632,
	},
	{
		Class = "Accessory",
		Name = "Faceless Cheeks Head",
		TemplateId = 12724978968,
	},
	{
		Class = "Accessory",
		Name = "Cute Tired Sleepy Adorable Eyes with Dark Circle",
		TemplateId = 13476682372,
	},
	{
		Class = "Accessory",
		Name = "Ketchup Splatter",
		TemplateId = 10859062545,
	},
	{
		Class = "Accessory",
		Name = "Rainbow Cursed Chains",
		TemplateId = 9923917802,
	},
	{
		Class = "Accessory",
		Name = "Evil Dark Mummy Smile",
		TemplateId = 11437316866,
	},
	{
		Class = "Accessory",
		Name = "Black Turtle Neck",
		TemplateId = 4378579302,
	},
	{
		Class = "Accessory",
		Name = "Rainbow Twisted Bandana",
		TemplateId = 12709543148,
	},
	{
		Class = "Accessory",
		Name = "Fangs",
		TemplateId = 12900842236,
	},
	{
		Class = "Accessory",
		Name = "Black  Cute Hair",
		TemplateId = 13260332276,
	},
	{
		Class = "Accessory",
		Name = "Stickered Shiny Headphones",
		TemplateId = 14066329335,
	},
	{
		Class = "Accessory",
		Name = "Hime Cut Pigtails",
		TemplateId = 14395139004,
	},
	{
		Class = "Accessory",
		Name = "Keffiyeh Traditional ",
		TemplateId = 13519180331,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Speaker Cinemaman (No Propellers)",
		TemplateId = 13956037578,
	},
	{
		Class = "Accessory",
		Name = "Jetpack Wings for Titan Cameraman (Metallic Neon)",
		TemplateId = 14148489827,
	},
	{
		Class = "Accessory",
		Name = "💵 CHEAP Black Messy Hair V3",
		TemplateId = 14349808796,
	},
	{
		Class = "Accessory",
		Name = "Black Frame Glasses",
		TemplateId = 12931836677,
	},
	{
		Class = "Accessory",
		Name = "Snow Fuzzy Headband",
		TemplateId = 6133255800,
	},
	{
		Class = "Accessory",
		Name = "Cute Blue Shark Hood 🌊",
		TemplateId = 6346995345,
	},
	{
		Class = "Accessory",
		Name = "Silver Ninja Star of the Brilliant Light",
		TemplateId = 11377306,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Tv Man - Core",
		TemplateId = 13822410234,
	},
	{
		Class = "Accessory",
		Name = "BubbleGum Candy (1.0)",
		TemplateId = 6105519422,
	},
	{
		Class = "Accessory",
		Name = "Purple Flame Gas Mask of Insanity",
		TemplateId = 13854094986,
	},
	{
		Class = "Accessory",
		Name = "Grimacing Monster Head",
		TemplateId = 14214279939,
	},
	{
		Class = "Accessory",
		Name = "Y2K Multiverse Girl Beanie",
		TemplateId = 13685381577,
	},
	{
		Class = "Accessory",
		Name = "Black Tophead",
		TemplateId = 5231223671,
	},
	{
		Class = "Accessory",
		Name = "big poo",
		TemplateId = 9923014557,
	},
	{
		Class = "Accessory",
		Name = "Anime Gear 5 Face",
		TemplateId = 14168023993,
	},
	{
		Class = "Accessory",
		Name = "ROBLOX 'R' Baseball Cap",
		TemplateId = 417457461,
	},
	{
		Class = "Accessory",
		Name = "Staring Dog",
		TemplateId = 8144102915,
	},
	{
		Class = "Accessory",
		Name = "80s Hanging Suspenders",
		TemplateId = 5727822995,
	},
	{
		Class = "Accessory",
		Name = "Anime Smile Face",
		TemplateId = 13829542036,
	},
	{
		Class = "Accessory",
		Name = "Arachnid Villain  Cap Wolfcut Blonde",
		TemplateId = 14373393748,
	},
	{
		Class = "Accessory",
		Name = "Cute Tongue (Cheeks)",
		TemplateId = 14035280066,
	},
	{
		Class = "Accessory",
		Name = "Wing",
		TemplateId = 11706393151,
	},
	{
		Class = "Accessory",
		Name = "Blush",
		TemplateId = 12726744035,
	},
	{
		Class = "Accessory",
		Name = "3.0 Black Round Jewelled Glasses",
		TemplateId = 8970227661,
	},
	{
		Class = "Accessory",
		Name = "Blush",
		TemplateId = 12779615698,
	},
	{
		Class = "Accessory",
		Name = "Devil Straw Samurai Hat",
		TemplateId = 6869986319,
	},
	{
		Class = "Accessory",
		Name = "Jellyfish Y2K Blonde  Hair",
		TemplateId = 14275204801,
	},
	{
		Class = "Accessory",
		Name = "Super Cute Tongue",
		TemplateId = 14035273807,
	},
	{
		Class = "Accessory",
		Name = "Red Eye Glare",
		TemplateId = 10721963880,
	},
	{
		Class = "Accessory",
		Name = "Foxy from LankyBox",
		TemplateId = 5004362849,
	},
	{
		Class = "Accessory",
		Name = "Fashionista Bangs in Black",
		TemplateId = 6134536229,
	},
	{
		Class = "Accessory",
		Name = "NewSide Bangs in Blonde",
		TemplateId = 6657507028,
	},
	{
		Class = "Accessory",
		Name = "Dragon",
		TemplateId = 13828134773,
	},
	{
		Class = "Accessory",
		Name = "(Animated) Red Crying Entity Mask",
		TemplateId = 11695614585,
	},
	{
		Class = "Accessory",
		Name = "Faceless Cheeks Head Nougat Skin Tone",
		TemplateId = 12725003069,
	},
	{
		Class = "Accessory",
		Name = "Faceless Head - Skin Color",
		TemplateId = 10715284563,
	},
	{
		Class = "Accessory",
		Name = "Blonde Cute Hair",
		TemplateId = 13260296005,
	},
	{
		Class = "Accessory",
		Name = "Bloody Hand Print",
		TemplateId = 11259123293,
	},
	{
		Class = "Accessory",
		Name = "Star Kitty Crochet Beanie White",
		TemplateId = 12866052670,
	},
	{
		Class = "Accessory",
		Name = "Kawaii Cat Grey Ushanka",
		TemplateId = 13843290569,
	},
	{
		Class = "Accessory",
		Name = "Black Jewelled Horns of the Abyss",
		TemplateId = 7485912398,
	},
	{
		Class = "Accessory",
		Name = "Cartoony Rainbow Minions: Back",
		TemplateId = 6572651845,
	},
	{
		Class = "Accessory",
		Name = "cameraman",
		TemplateId = 14375506432,
	},
	{
		Class = "Accessory",
		Name = "Spider Hero Man Mask",
		TemplateId = 14303540463,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Speakerman Jetpack",
		TemplateId = 13610652604,
	},
	{
		Class = "Accessory",
		Name = "💕Kawaii Cutie Blush Face",
		TemplateId = 14072740037,
	},
	{
		Class = "Accessory",
		Name = "Blank Faceless Mask With Chubby Cheeks",
		TemplateId = 12402999642,
	},
	{
		Class = "Accessory",
		Name = "Shadow Head",
		TemplateId = 13464860482,
	},
	{
		Class = "Accessory",
		Name = "Blushing Heart Eyes [White]",
		TemplateId = 13500606103,
	},
	{
		Class = "Accessory",
		Name = "Kitty Ears",
		TemplateId = 1374269,
	},
	{
		Class = "Accessory",
		Name = "Faceless",
		TemplateId = 12994246892,
	},
	{
		Class = "Accessory",
		Name = "Lovespun Cheeks Mystic Wispy Hooded Lashes",
		TemplateId = 12342615103,
	},
	{
		Class = "Accessory",
		Name = "Headphones",
		TemplateId = 11207374535,
	},
	{
		Class = "Accessory",
		Name = "Jellyfish Y2K Hair Ginger",
		TemplateId = 14385567831,
	},
	{
		Class = "Accessory",
		Name = "Starbling Beanie",
		TemplateId = 833771553,
	},
	{
		Class = "Accessory",
		Name = "Comic Style Horned Gas Mask",
		TemplateId = 13854086766,
	},
	{
		Class = "Accessory",
		Name = "Faceless Black Head",
		TemplateId = 13538034108,
	},
	{
		Class = "Accessory",
		Name = "NewSide Bangs in Brown",
		TemplateId = 12307091817,
	},
	{
		Class = "Accessory",
		Name = "😄 Big Smile Face (3D) 😄",
		TemplateId = 12409796490,
	},
	{
		Class = "Accessory",
		Name = "Spooder-Man Shoulder Buddy",
		TemplateId = 14167252011,
	},
	{
		Class = "Accessory",
		Name = "Butterfly Hat",
		TemplateId = 4849184439,
	},
	{
		Class = "Accessory",
		Name = "Banana Suit",
		TemplateId = 4962552589,
	},
	{
		Class = "Accessory",
		Name = "Glasses",
		TemplateId = 13174859058,
	},
	{
		Class = "Accessory",
		Name = "Silver Link Chain",
		TemplateId = 5355321395,
	},
	{
		Class = "Accessory",
		Name = "Black Eyepatch",
		TemplateId = 4528880486,
	},
	{
		Class = "Accessory",
		Name = "Backwards  94",
		TemplateId = 6774189421,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Infected Titan Speakerman Upgrade",
		TemplateId = 14373989309,
	},
	{
		Class = "Accessory",
		Name = "Black Sunglasses",
		TemplateId = 7234984836,
	},
	{
		Class = "Accessory",
		Name = "Curtain Bangs in Blonde",
		TemplateId = 8230978629,
	},
	{
		Class = "Accessory",
		Name = "TanqR Shoulder Buddy",
		TemplateId = 5067271347,
	},
	{
		Class = "Accessory",
		Name = "NickEh30",
		TemplateId = 13936335370,
	},
	{
		Class = "Accessory",
		Name = "Healing Potion",
		TemplateId = 11419319,
	},
	{
		Class = "Accessory",
		Name = "Cold Blushy Cute Girl",
		TemplateId = 12849428433,
	},
	{
		Class = "Accessory",
		Name = "Dragon",
		TemplateId = 13828128546,
	},
	{
		Class = "Accessory",
		Name = "Hoodie",
		TemplateId = 12716716024,
	},
	{
		Class = "Accessory",
		Name = "Diamond Stud Earrings",
		TemplateId = 4508445398,
	},
	{
		Class = "Accessory",
		Name = "DJ Khaled",
		TemplateId = 14111924787,
	},
	{
		Class = "Accessory",
		Name = "Black Fuzzy Headband",
		TemplateId = 6133262085,
	},
	{
		Class = "Accessory",
		Name = "Swept Bangs in Blonde",
		TemplateId = 6965371510,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Speakerman's Backpack",
		TemplateId = 13569209137,
	},
	{
		Class = "Accessory",
		Name = "Popular Girl Cute Mask Nougat",
		TemplateId = 11985154624,
	},
	{
		Class = "Accessory",
		Name = "Super Super Super Happy Face Blush",
		TemplateId = 14339012244,
	},
	{
		Class = "Accessory",
		Name = "R̶$̶1̶0̶0̶ Gold Diamond Chain Bling",
		TemplateId = 13197804874,
	},
	{
		Class = "Accessory",
		Name = "Traditional Keffiyeh",
		TemplateId = 13656690113,
	},
	{
		Class = "Accessory",
		Name = "Iced Out Milestone Chain",
		TemplateId = 14107676188,
	},
	{
		Class = "Accessory",
		Name = "Y2K Face Stars ",
		TemplateId = 12625283415,
	},
	{
		Class = "Accessory",
		Name = "white connected headphones (3.0)",
		TemplateId = 10943566005,
	},
	{
		Class = "Accessory",
		Name = "Pirate King Smile Face",
		TemplateId = 11110592971,
	},
	{
		Class = "Accessory",
		Name = "Black Ushanka",
		TemplateId = 13700464410,
	},
	{
		Class = "Accessory",
		Name = "Rainbow Evil Mask",
		TemplateId = 11503993953,
	},
	{
		Class = "Accessory",
		Name = "Swept Bangs in Brown",
		TemplateId = 12307048143,
	},
	{
		Class = "Accessory",
		Name = "Red Big Eyes Head",
		TemplateId = 14068516652,
	},
	{
		Class = "Accessory",
		Name = "Rounded Cute Anime Glasses",
		TemplateId = 6934244289,
	},
	{
		Class = "Accessory",
		Name = "Queen Spiders' Cap Wolfcut Brown",
		TemplateId = 14373520453,
	},
	{
		Class = "Accessory",
		Name = "White Luxury Heart Purse (3.0)",
		TemplateId = 8715048013,
	},
	{
		Class = "Accessory",
		Name = "Joy Blush Light Skin Tone Mask",
		TemplateId = 7394713560,
	},
	{
		Class = "Accessory",
		Name = "Oversized Tied Hoodie",
		TemplateId = 11329866528,
	},
	{
		Class = "Accessory",
		Name = "Very Black Ushanka",
		TemplateId = 6341769324,
	},
	{
		Class = "Accessory",
		Name = "Curtain Bangs in Brown",
		TemplateId = 8231039071,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Titan Tv Man - Back",
		TemplateId = 13822738066,
	},
	{
		Class = "Accessory",
		Name = "Iced Out Cash Chain Bling",
		TemplateId = 13205757343,
	},
	{
		Class = "Accessory",
		Name = "Down to Earth Hair",
		TemplateId = 1772336109,
	},
	{
		Class = "Accessory",
		Name = "💵 CHEAP Black Messy Hair V4",
		TemplateId = 14361229179,
	},
	{
		Class = "Accessory",
		Name = "White Flowy Bow",
		TemplateId = 6201860992,
	},
	{
		Class = "Accessory",
		Name = "White Heart Hairclips",
		TemplateId = 8303730595,
	},
	{
		Class = "Accessory",
		Name = "Black And Red White Eyes Head",
		TemplateId = 13795327140,
	},
	{
		Class = "Accessory",
		Name = "Simple Piercing Set",
		TemplateId = 12214970207,
	},
	{
		Class = "Accessory",
		Name = "Mask of madness Red",
		TemplateId = 8528641477,
	},
	{
		Class = "Accessory",
		Name = "Stubble Beard",
		TemplateId = 4995497755,
	},
	{
		Class = "Accessory",
		Name = "Black Fashion Hood",
		TemplateId = 4932728913,
	},
	{
		Class = "Accessory",
		Name = "angry cat (profile picture)",
		TemplateId = 13812528171,
	},
	{
		Class = "Accessory",
		Name = "Red Roblox Cap",
		TemplateId = 48474313,
	},
	{
		Class = "Accessory",
		Name = "Dual Dark Evil Sword",
		TemplateId = 13905597213,
	},
	{
		Class = "Accessory",
		Name = "White Hair Flower",
		TemplateId = 6711563577,
	},
	{
		Class = "Accessory",
		Name = "Crazed Infinity Sorcerer Face",
		TemplateId = 14290242020,
	},
	{
		Class = "Accessory",
		Name = "Wing",
		TemplateId = 13849942818,
	},
	{
		Class = "Accessory",
		Name = "Low Thin Round Glasses White",
		TemplateId = 12014289631,
	},
	{
		Class = "Accessory",
		Name = "Doodle Face Mask",
		TemplateId = 12796821185,
	},
	{
		Class = "Accessory",
		Name = "Hasbulla",
		TemplateId = 14167073275,
	},
	{
		Class = "Accessory",
		Name = "Wacky Sunglasses",
		TemplateId = 6742512536,
	},
	{
		Class = "Accessory",
		Name = "Y2k Raised Wrap Shades (White)",
		TemplateId = 13151900300,
	},
	{
		Class = "Accessory",
		Name = "Y2K Silver Heart Belly Piercing",
		TemplateId = 8185216491,
	},
	{
		Class = "Accessory",
		Name = "Skibi Cameraman Head",
		TemplateId = 13510720742,
	},
	{
		Class = "Accessory",
		Name = "Brain (For headless)",
		TemplateId = 7286849695,
	},
	{
		Class = "Accessory",
		Name = "Cute Frog Circle Rimmed Glasses Frame Pastel Green",
		TemplateId = 12362183929,
	},
	{
		Class = "Accessory",
		Name = "cameraman",
		TemplateId = 14375509236,
	},
	{
		Class = "Accessory",
		Name = "Cute White Cat-Eye Glasses",
		TemplateId = 11599231787,
	},
	{
		Class = "Accessory",
		Name = "Soft Pink Ocean Eyes [Beige]",
		TemplateId = 13406249733,
	},
	{
		Class = "Accessory",
		Name = "Kitty Knit Beanie (Black)",
		TemplateId = 9876423155,
	},
	{
		Class = "Accessory",
		Name = "Black Head",
		TemplateId = 12850150835,
	},
	{
		Class = "Accessory",
		Name = "(Part) Skibi Infected TitanSpeakerman Upgrade Core",
		TemplateId = 14377575054,
	},
	{
		Class = "Accessory",
		Name = "Cute Pigtails Hair Blonde",
		TemplateId = 14327179533,
	},
	{
		Class = "Accessory",
		Name = "Aesthetic Preppy Cowgirl Hat",
		TemplateId = 8595649196,
	},
	{
		Class = "Accessory",
		Name = "Bombo's Survival Knife",
		TemplateId = 121946387,
	},
	{
		Class = "Accessory",
		Name = "Head Blush Heart ♥ V2 (White) 💗",
		TemplateId = 10858980140,
	},
	{
		Class = "Accessory",
		Name = "Kanye",
		TemplateId = 14111920973,
	},
	{
		Class = "Accessory",
		Name = "TanqR Samurai Hat",
		TemplateId = 13463662648,
	},
	{
		Class = "Accessory",
		Name = "Headphones",
		TemplateId = 11215918760,
	},
	{
		Class = "Accessory",
		Name = "Cute Full Bangs (Blonde)",
		TemplateId = 8275237326,
	},
	{
		Class = "Accessory",
		Name = "Cute Kitty Plushie Mask Hood",
		TemplateId = 13464883872,
	},
	{
		Class = "Accessory",
		Name = "Tropical City Shades",
		TemplateId = 6879004087,
	},
	{
		Class = "Accessory",
		Name = "Jellyfish Y2K Hair Brown",
		TemplateId = 14310664814,
	},
	{
		Class = "Accessory",
		Name = "Barbie Box",
		TemplateId = 14278095009,
	},
	{
		Class = "Accessory",
		Name = "(Animated) Horror Smile Madness Mask",
		TemplateId = 11641704751,
	},
	{
		Class = "Face",
		Name = "Silly Fun",
		TemplateId = 7699174,
	},
	{
		Class = "Face",
		Name = "Happy :D",
		TemplateId = 406000730,
	},
	{
		Class = "Face",
		Name = "Cutiemouse",
		TemplateId = 15885121,
	},
	{
		Class = "Face",
		Name = "Golden Eyes - 24kGoldn",
		TemplateId = 9156275069,
	},
	{
		Class = "Face",
		Name = "So Funny",
		TemplateId = 32058239,
	},
	{
		Class = "Face",
		Name = "^_^",
		TemplateId = 15366173,
	},
	{
		Class = "Face",
		Name = "Shiny Teeth",
		TemplateId = 20722130,
	},
	{
		Class = "Face",
		Name = "Drool",
		TemplateId = 7074893,
	},
	{
		Class = "Face",
		Name = "Hold It In",
		TemplateId = 2222771916,
	},
	{
		Class = "Face",
		Name = "ROAR!!!",
		TemplateId = 406001167,
	},
	{
		Class = "Face",
		Name = ">_<",
		TemplateId = 15324577,
	},
	{
		Class = "Face",
		Name = "Anime Surprise",
		TemplateId = 416846300,
	},
	{
		Class = "Face",
		Name = "Glee",
		TemplateId = 7074729,
	},
	{
		Class = "Face",
		Name = "Huh?",
		TemplateId = 150182466,
	},
	{
		Class = "Face",
		Name = ":P",
		TemplateId = 14861743,
	},
	{
		Class = "Face",
		Name = "I <3 New Site Theme",
		TemplateId = 32723404,
	},
	{
		Class = "Face",
		Name = ":3",
		TemplateId = 15432080,
	},
	{
		Class = "Face",
		Name = "Knights of Redcliff: Paladin - Face",
		TemplateId = 2493587489,
	},
	{
		Class = "Face",
		Name = "Smiling Girl",
		TemplateId = 209994875,
	},
	{
		Class = "Face",
		Name = "Joyous Surprise",
		TemplateId = 28999228,
	},
	{
		Class = "Face",
		Name = "Butterfly Wink - Lil Nas X (LNX)",
		TemplateId = 7657646351,
	},
	{
		Class = "Face",
		Name = "Good Intentioned",
		TemplateId = 7317793,
	},
	{
		Class = "Face",
		Name = "Stare",
		TemplateId = 8560971,
	},
	{
		Class = "Face",
		Name = "Puck",
		TemplateId = 20298988,
	},
	{
		Class = "Face",
		Name = "Disbelief",
		TemplateId = 20337343,
	},
	{
		Class = "Face",
		Name = "Monster Face",
		TemplateId = 49045351,
	},
	{
		Class = "Face",
		Name = "Friendly Smile",
		TemplateId = 616381207,
	},
	{
		Class = "Face",
		Name = "Finn McCool",
		TemplateId = 10907549,
	},
	{
		Class = "Face",
		Name = "Vampire",
		TemplateId = 29532363,
	},
	{
		Class = "Face",
		Name = "Glittering Eye - Zara Larsson",
		TemplateId = 7893460486,
	},
	{
		Class = "Face",
		Name = "Lazy Eye",
		TemplateId = 7075502,
	},
	{
		Class = "Face",
		Name = "Dizzy Face",
		TemplateId = 10907551,
	},
	{
		Class = "Face",
		Name = "Heeeeeey...",
		TemplateId = 21635565,
	},
	{
		Class = "Face",
		Name = "Friendly Grin",
		TemplateId = 25321961,
	},
	{
		Class = "Face",
		Name = "Winky",
		TemplateId = 7074864,
	},
	{
		Class = "Face",
		Name = "Awesome Face",
		TemplateId = 30394850,
	},
	{
		Class = "Face",
		Name = "Singing",
		TemplateId = 66330310,
	},
	{
		Class = "Face",
		Name = "Grr!",
		TemplateId = 19398554,
	},
	{
		Class = "Face",
		Name = ":-o",
		TemplateId = 7317773,
	},
	{
		Class = "Face",
		Name = "Suspicious",
		TemplateId = 209994929,
	},
	{
		Class = "Face",
		Name = "Red Lip - Tate McRae",
		TemplateId = 9650713776,
	},
	{
		Class = "Face",
		Name = "Goofball",
		TemplateId = 27134344,
	},
	{
		Class = "Face",
		Name = "O_o ",
		TemplateId = 66330265,
	},
	{
		Class = "Face",
		Name = "-_-",
		TemplateId = 15637848,
	},
	{
		Class = "Face",
		Name = "Not sure if...",
		TemplateId = 173789324,
	},
	{
		Class = "Face",
		Name = ":-/",
		TemplateId = 7075469,
	},
	{
		Class = "Face",
		Name = "I Hate Noobs",
		TemplateId = 14030577,
	},
	{
		Class = "Face",
		Name = "Sneaky Steve",
		TemplateId = 823012694,
	},
	{
		Class = "Face",
		Name = "¬_¬ 2.0",
		TemplateId = 406000958,
	},
	{
		Class = "Face",
		Name = "Anguished",
		TemplateId = 8560975,
	},
	{
		Class = "Face",
		Name = "Sigmund",
		TemplateId = 21311601,
	},
	{
		Class = "Face",
		Name = "$.$",
		TemplateId = 10831558,
	},
	{
		Class = "Face",
		Name = "Happy Wink",
		TemplateId = 236399287,
	},
	{
		Class = "Face",
		Name = "Skeptic",
		TemplateId = 31117267,
	},
	{
		Class = "Face",
		Name = "Awkward....",
		TemplateId = 23932048,
	},
	{
		Class = "Face",
		Name = "WHAAAaaa!",
		TemplateId = 14127194,
	},
	{
		Class = "Face",
		Name = "Scarecrow",
		TemplateId = 26260927,
	},
	{
		Class = "Face",
		Name = "Mr. Chuckles",
		TemplateId = 10907541,
	},
	{
		Class = "Face",
		Name = "Smug",
		TemplateId = 406001308,
	},
	{
		Class = "Face",
		Name = "Just Trouble",
		TemplateId = 244160766,
	},
	{
		Class = "Face",
		Name = "Ghostface",
		TemplateId = 12467159,
	},
	{
		Class = "Face",
		Name = "Look At My Nose",
		TemplateId = 23311761,
	},
	{
		Class = "Face",
		Name = "Hut Hut Hike!",
		TemplateId = 15470849,
	},
	{
		Class = "Face",
		Name = "And then we'll take over the world!",
		TemplateId = 12732366,
	},
	{
		Class = "Face",
		Name = "Love",
		TemplateId = 11611321,
	},
	{
		Class = "Face",
		Name = "D:",
		TemplateId = 14812981,
	},
	{
		Class = "Face",
		Name = "Smil Nas X - Lil Nas X (LNX)",
		TemplateId = 5917459717,
	},
	{
		Class = "Face",
		Name = "XD 2.0",
		TemplateId = 406001052,
	},
	{
		Class = "Face",
		Name = "Blinky",
		TemplateId = 7506135,
	},
	{
		Class = "Face",
		Name = "Yawn",
		TemplateId = 20010377,
	},
	{
		Class = "Face",
		Name = "Adorable Puppy",
		TemplateId = 11389372,
	},
	{
		Class = "Face",
		Name = "Blerg!",
		TemplateId = 12777646,
	},
	{
		Class = "Face",
		Name = "Chill McCool",
		TemplateId = 376813144,
	},
	{
		Class = "Face",
		Name = ":/",
		TemplateId = 15471035,
	},
	{
		Class = "Face",
		Name = "Sunrise Eyes - Tai Verdes",
		TemplateId = 7987201392,
	},
	{
		Class = "Face",
		Name = "Robot Smile",
		TemplateId = 30265169,
	},
	{
		Class = "Face",
		Name = "Beaming with Pride",
		TemplateId = 3267567501,
	},
	{
		Class = "Face",
		Name = "Wink-Blink",
		TemplateId = 22828351,
	},
	{
		Class = "Face",
		Name = "Retro Smiley",
		TemplateId = 10770432,
	},
	{
		Class = "Face",
		Name = "Tired Face",
		TemplateId = 141728790,
	},
	{
		Class = "Face",
		Name = "Jack Frost Face",
		TemplateId = 19396123,
	},
	{
		Class = "Face",
		Name = "Hilarious",
		TemplateId = 27861352,
	},
	{
		Class = "Face",
		Name = "Drill Sergeant",
		TemplateId = 141728899,
	},
	{
		Class = "Face",
		Name = "I Didn't Eat That Cookie",
		TemplateId = 116042990,
	},
	{
		Class = "Face",
		Name = "Furious George ",
		TemplateId = 277950647,
	},
	{
		Class = "Face",
		Name = "Concerned",
		TemplateId = 9250660,
	},
	{
		Class = "Face",
		Name = "Slickfang",
		TemplateId = 7317765,
	},
	{
		Class = "Face",
		Name = "Cute Kitty",
		TemplateId = 11389441,
	},
	{
		Class = "Face",
		Name = "Awkward Eyeroll",
		TemplateId = 150182378,
	},
	{
		Class = "Face",
		Name = "Silence",
		TemplateId = 10860397,
	},
	{
		Class = "Face",
		Name = "Up To Something",
		TemplateId = 1016186364,
	},
	{
		Class = "Face",
		Name = "Cheerful Grin",
		TemplateId = 33321848,
	},
	{
		Class = "Face",
		Name = "Fearless",
		TemplateId = 7074991,
	},
	{
		Class = "Face",
		Name = "Sick Day",
		TemplateId = 26619096,
	},
	{
		Class = "Face",
		Name = "Super Happy Joy",
		TemplateId = 280988698,
	},
	{
		Class = "Face",
		Name = "Sinister",
		TemplateId = 8329686,
	},
	{
		Class = "Face",
		Name = "I Am Not Amused",
		TemplateId = 7131886,
	},
	{
		Class = "Face",
		Name = "Cheerful Hello",
		TemplateId = 362051644,
	},
	{
		Class = "Face",
		Name = "Sniffles",
		TemplateId = 14516578,
	},
	{
		Class = "Face",
		Name = "Vans Checkerboard Blue Eyes",
		TemplateId = 8247356154,
	},
	{
		Class = "Face",
		Name = "Big Sad Eyes",
		TemplateId = 391496223,
	},
	{
		Class = "Face",
		Name = "Tango",
		TemplateId = 16101765,
	},
	{
		Class = "Face",
		Name = "Hmmm...",
		TemplateId = 7076076,
	},
	{
		Class = "Face",
		Name = "Demented Mouse",
		TemplateId = 12188176,
	},
	{
		Class = "Face",
		Name = "Serious Scar Face",
		TemplateId = 255827175,
	},
	{
		Class = "Face",
		Name = "=)",
		TemplateId = 14817393,
	},
	{
		Class = "Face",
		Name = "Devil Nas X - Lil Nas X (LNX)",
		TemplateId = 7657657626,
	},
	{
		Class = "Face",
		Name = "Devilish Smile - 24kGoldn",
		TemplateId = 9156271739,
	},
	{
		Class = "Face",
		Name = "Square Eyes",
		TemplateId = 22119034,
	},
	{
		Class = "Face",
		Name = "Uh Oh",
		TemplateId = 7074944,
	},
	{
		Class = "Face",
		Name = "It's Go Time!",
		TemplateId = 7506141,
	},
	{
		Class = "Face",
		Name = ">:3",
		TemplateId = 15177601,
	},
	{
		Class = "Face",
		Name = "Semi Colon Open Paren",
		TemplateId = 16179646,
	},
	{
		Class = "Face",
		Name = ":-[",
		TemplateId = 15470193,
	},
	{
		Class = "Face",
		Name = "Alright",
		TemplateId = 7131541,
	},
	{
		Class = "Face",
		Name = "Fang",
		TemplateId = 7075142,
	},
	{
		Class = "Face",
		Name = "Daring Beard",
		TemplateId = 110288809,
	},
	{
		Class = "Face",
		Name = "Classic Goof",
		TemplateId = 7074661,
	},
	{
		Class = "Face",
		Name = "Awkward Grin",
		TemplateId = 150182501,
	},
	{
		Class = "Face",
		Name = "Hypnoface",
		TemplateId = 10770436,
	},
	{
		Class = "Face",
		Name = "Old Timer",
		TemplateId = 27003636,
	},
	{
		Class = "Face",
		Name = "Thinking",
		TemplateId = 29716262,
	},
	{
		Class = "Face",
		Name = "Classic Vampire",
		TemplateId = 7074836,
	},
	{
		Class = "Face",
		Name = "You ated my caik!",
		TemplateId = 21635583,
	},
	{
		Class = "Face",
		Name = "O.o",
		TemplateId = 7074595,
	},
	{
		Class = "Face",
		Name = "Walk the Plank You Scurvy Dogs!",
		TemplateId = 13478124,
	},
	{
		Class = "Face",
		Name = "Stitchface",
		TemplateId = 8329679,
	},
	{
		Class = "Face",
		Name = "Crazy Happy",
		TemplateId = 45515121,
	},
	{
		Class = "Face",
		Name = "McLaren Big Grin ",
		TemplateId = 9062637857,
	},
	{
		Class = "Face",
		Name = "24kGoldn Face",
		TemplateId = 9156266858,
	},
	{
		Class = "Face",
		Name = "Commando",
		TemplateId = 10527010,
	},
	{
		Class = "Face",
		Name = "Drooling Noob",
		TemplateId = 24067718,
	},
	{
		Class = "Face",
		Name = "Starface",
		TemplateId = 32873408,
	},
	{
		Class = "Face",
		Name = "Toothless",
		TemplateId = 19399752,
	},
	{
		Class = "Face",
		Name = "Monster Smile",
		TemplateId = 398675917,
	},
	{
		Class = "Face",
		Name = "Meanie",
		TemplateId = 9250643,
	},
	{
		Class = "Face",
		Name = "Sweat It Out",
		TemplateId = 20909103,
	},
	{
		Class = "Face",
		Name = "Mysterious",
		TemplateId = 7132035,
	},
	{
		Class = "Face",
		Name = "Classic Alien Face",
		TemplateId = 159199178,
	},
	{
		Class = "Face",
		Name = "Obvious Wink",
		TemplateId = 51241537,
	},
	{
		Class = "Face",
		Name = "Zombie Face",
		TemplateId = 133360789,
	},
	{
		Class = "Face",
		Name = "Alien",
		TemplateId = 31317701,
	},
	{
		Class = "Face",
		Name = "Downcast",
		TemplateId = 21352013,
	},
	{
		Class = "Face",
		Name = "ZOMG",
		TemplateId = 8329682,
	},
	{
		Class = "Face",
		Name = "Nouveau George",
		TemplateId = 398675764,
	},
	{
		Class = "Face",
		Name = "Sly Guy Face",
		TemplateId = 238983378,
	},
	{
		Class = "Face",
		Name = "Diamond Grill - Lil Nas X (LNX)",
		TemplateId = 7657627637,
	},
	{
		Class = "Face",
		Name = "Glory on the Gridiron",
		TemplateId = 21802396,
	},
	{
		Class = "Face",
		Name = "Visual Studio Seized Up For 45 Seconds... Again",
		TemplateId = 14083380,
	},
	{
		Class = "Face",
		Name = "Stink Eye",
		TemplateId = 416846143,
	},
	{
		Class = "Face",
		Name = "Friendly Pirate",
		TemplateId = 19366445,
	},
	{
		Class = "Face",
		Name = "I wuv u",
		TemplateId = 10907545,
	},
	{
		Class = "Face",
		Name = "Nervous",
		TemplateId = 23219981,
	},
	{
		Class = "Face",
		Name = "Sunny Fun",
		TemplateId = 51241171,
	},
	{
		Class = "Face",
		Name = "NetHack Addict",
		TemplateId = 16357383,
	},
	{
		Class = "Face",
		Name = "Smith McCool",
		TemplateId = 27412825,
	},
	{
		Class = "Face",
		Name = "Lady Lashes",
		TemplateId = 29348122,
	},
	{
		Class = "Face",
		Name = "Exclamation Face",
		TemplateId = 35168581,
	},
	{
		Class = "Face",
		Name = "Disapproving Unibrow",
		TemplateId = 66330360,
	},
	{
		Class = "Face",
		Name = "D=",
		TemplateId = 17138027,
	},
	{
		Class = "Face",
		Name = "Raig Face",
		TemplateId = 209994783,
	},
	{
		Class = "Face",
		Name = "Angry Zombie",
		TemplateId = 173789114,
	},
	{
		Class = "Face",
		Name = "eXtreme",
		TemplateId = 10831454,
	},
	{
		Class = "Face",
		Name = "Bad Dog",
		TemplateId = 10678423,
	},
	{
		Class = "Face",
		Name = "Sparkle Time Sparkle Eyes",
		TemplateId = 2620507161,
	},
	{
		Class = "Face",
		Name = "Slithering Smile",
		TemplateId = 2830646491,
	},
	{
		Class = "Face",
		Name = "Daring",
		TemplateId = 8329690,
	},
	{
		Class = "Face",
		Name = "Secret Service",
		TemplateId = 20612949,
	},
	{
		Class = "Face",
		Name = "Bored",
		TemplateId = 66330106,
	},
	{
		Class = "Face",
		Name = "Bluffing",
		TemplateId = 147144673,
	},
	{
		Class = "Face",
		Name = "Chubs",
		TemplateId = 7076110,
	},
	{
		Class = "Face",
		Name = "Gigglypuff",
		TemplateId = 35397243,
	},
	{
		Class = "Face",
		Name = "Scarecrow Face",
		TemplateId = 14721869,
	},
	{
		Class = "Face",
		Name = "Too Much Candy",
		TemplateId = 295763789,
	},
	{
		Class = "Face",
		Name = "Fast Car",
		TemplateId = 22587894,
	},
	{
		Class = "Face",
		Name = "Sad",
		TemplateId = 7699177,
	},
	{
		Class = "Face",
		Name = "Overjoyed Smile",
		TemplateId = 1428416217,
	},
	{
		Class = "Face",
		Name = "Toughguy",
		TemplateId = 21439665,
	},
	{
		Class = "Face",
		Name = "Oh Deer",
		TemplateId = 12145328,
	},
	{
		Class = "Face",
		Name = "Tiger Chase Fear Face",
		TemplateId = 258198928,
	},
	{
		Class = "Face",
		Name = ":-O",
		TemplateId = 15013192,
	},
	{
		Class = "Face",
		Name = "Don't Wake Me Up",
		TemplateId = 343619993,
	},
	{
		Class = "Face",
		Name = "The Big Dog",
		TemplateId = 10860384,
	},
	{
		Class = "Face",
		Name = "Alien Ambassador",
		TemplateId = 11913700,
	},
	{
		Class = "Face",
		Name = "The Friendly Eviscerator",
		TemplateId = 22500129,
	},
	{
		Class = "Face",
		Name = "Rodeo Vampire - Lil Nas X (LNX)",
		TemplateId = 5917448278,
	},
	{
		Class = "Face",
		Name = "Pumpkin Face",
		TemplateId = 313549781,
	},
	{
		Class = "Face",
		Name = "Sharpnine's Face of Disappointment",
		TemplateId = 209994270,
	},
	{
		Class = "Face",
		Name = "Hockey Face",
		TemplateId = 142464206,
	},
	{
		Class = "Face",
		Name = "Whuut?",
		TemplateId = 274338458,
	},
	{
		Class = "Face",
		Name = "Adoration",
		TemplateId = 28878297,
	},
	{
		Class = "Face",
		Name = "Vans Checkerboard Brown Eyes",
		TemplateId = 5893869335,
	},
	{
		Class = "Face",
		Name = "Friendly Cyclops",
		TemplateId = 30394438,
	},
	{
		Class = "Face",
		Name = "Prideful Smile",
		TemplateId = 3267564334,
	},
	{
		Class = "Face",
		Name = "Pwnda Face",
		TemplateId = 28281786,
	},
	{
		Class = "Face",
		Name = "Xtreme Happy",
		TemplateId = 20644021,
	},
	{
		Class = "Face",
		Name = "Shocked",
		TemplateId = 147144644,
	},
	{
		Class = "Face",
		Name = "Sadfaic",
		TemplateId = 117522793,
	},
	{
		Class = "Face",
		Name = "Toothy Grin",
		TemplateId = 7075434,
	},
	{
		Class = "Face",
		Name = "Daydreaming",
		TemplateId = 29296146,
	},
	{
		Class = "Face",
		Name = "Aghast",
		TemplateId = 9250633,
	},
	{
		Class = "Face",
		Name = "RAWR!",
		TemplateId = 7076224,
	},
	{
		Class = "Face",
		Name = "Lightning Speaker",
		TemplateId = 22588801,
	},
	{
		Class = "Face",
		Name = "Meow?",
		TemplateId = 10907529,
	},
	{
		Class = "Face",
		Name = "Raccoon",
		TemplateId = 27052537,
	},
	{
		Class = "Face",
		Name = "Friendly Puppy",
		TemplateId = 27725434,
	},
	{
		Class = "Face",
		Name = "Toothy Drool",
		TemplateId = 8560980,
	},
	{
		Class = "Face",
		Name = "Spring Bunny ",
		TemplateId = 110207437,
	},
	{
		Class = "Face",
		Name = "Unbelievable",
		TemplateId = 419752096,
	},
	{
		Class = "Face",
		Name = "Mischievous",
		TemplateId = 9250654,
	},
	{
		Class = "Face",
		Name = "Grumpy Blox",
		TemplateId = 173789498,
	},
	{
		Class = "Face",
		Name = "Timmy McPwnage",
		TemplateId = 22023062,
	},
	{
		Class = "Face",
		Name = "Chippy McTooth",
		TemplateId = 7317769,
	},
	{
		Class = "Face",
		Name = "Warpaint Josh Dun - Twenty One Pilots",
		TemplateId = 7389923463,
	},
	{
		Class = "Face",
		Name = "Pony Face",
		TemplateId = 13656095,
	},
	{
		Class = "Face",
		Name = "NOWAI!",
		TemplateId = 51241862,
	},
	{
		Class = "Face",
		Name = "Magical Dragon",
		TemplateId = 34871168,
	},
	{
		Class = "Face",
		Name = "Frightful",
		TemplateId = 7699193,
	},
	{
		Class = "Face",
		Name = "Sharpnine's Face of Joy",
		TemplateId = 406002032,
	},
	{
		Class = "Face",
		Name = "=(",
		TemplateId = 30395097,
	},
	{
		Class = "Face",
		Name = "McLaren Smile",
		TemplateId = 9062620353,
	},
	{
		Class = "Face",
		Name = "Distaught Alien Invader",
		TemplateId = 11913668,
	},
	{
		Class = "Face",
		Name = "Not Again!",
		TemplateId = 28119051,
	},
	{
		Class = "Face",
		Name = "Lion",
		TemplateId = 11956548,
	},
	{
		Class = "Face",
		Name = "Frightening Unibrow",
		TemplateId = 8560985,
	},
	{
		Class = "Face",
		Name = "Ogre Face",
		TemplateId = 391495894,
	},
	{
		Class = "Face",
		Name = "Bad News Face",
		TemplateId = 268603331,
	},
	{
		Class = "Face",
		Name = "I Lack Personal Confidence",
		TemplateId = 7506144,
	},
	{
		Class = "Face",
		Name = "Sad Zombie",
		TemplateId = 7131361,
	},
	{
		Class = "Face",
		Name = "Sai-eye Tyler Joseph - Twenty One Pilots",
		TemplateId = 7389910081,
	},
	{
		Class = "Face",
		Name = "Old Man Jenkins",
		TemplateId = 13335647,
	},
	{
		Class = "Face",
		Name = "Woebegone",
		TemplateId = 21755022,
	},
	{
		Class = "Face",
		Name = "Emotionally Distressed Zombie",
		TemplateId = 7506136,
	},
	{
		Class = "Face",
		Name = "Skeletar",
		TemplateId = 10770395,
	},
	{
		Class = "Face",
		Name = "Absolutely Shocked",
		TemplateId = 2620506085,
	},
	{
		Class = "Face",
		Name = "Torque the Green Orc",
		TemplateId = 2830497827,
	},
	{
		Class = "Face",
		Name = "Cuckookrazybot 10000",
		TemplateId = 554663025,
	},
	{
		Class = "Face",
		Name = "Trance",
		TemplateId = 29109681,
	},
	{
		Class = "Face",
		Name = "Orange Starface",
		TemplateId = 162200666,
	},
	{
		Class = "Face",
		Name = "So Super Excited - Blue",
		TemplateId = 2569001052,
	},
	{
		Class = "Shirt",
		Name = "ROBLOX Jacket",
		TemplateId = 607785314,
	},
	{
		Class = "Shirt",
		Name = "Gangster Black Shirt w/ Tattoos and Watch",
		TemplateId = 5270451236,
	},
	{
		Class = "Shirt",
		Name = "cottage core lilac purple cardigan",
		TemplateId = 7724798674,
	},
	{
		Class = "Shirt",
		Name = "Cute White Y2k Vintage Aesthetic Girl Preppy Soft",
		TemplateId = 9625919193,
	},
	{
		Class = "Shirt",
		Name = "Denim Jacket with White Hoodie",
		TemplateId = 398633584,
	},
	{
		Class = "Shirt",
		Name = "white wrap tank",
		TemplateId = 3737269621,
	},
	{
		Class = "Shirt",
		Name = "Grey Suit w/ Black Vest [+]",
		TemplateId = 6554200369,
	},
	{
		Class = "Shirt",
		Name = "brown hockey jacket cottage core vintage tan beige",
		TemplateId = 7902675177,
	},
	{
		Class = "Shirt",
		Name = "Roblox Shirt - Simple Pattern",
		TemplateId = 3670737444,
	},
	{
		Class = "Shirt",
		Name = " Black and White Hoodie Champion Sweater",
		TemplateId = 7021249548,
	},
	{
		Class = "Shirt",
		Name = "y2k aesthetic girl vintage trendy soft gray cute",
		TemplateId = 6876555875,
	},
	{
		Class = "Shirt",
		Name = "y2k green camo grunge streetwear gothic emo",
		TemplateId = 10313548182,
	},
	{
		Class = "Shirt",
		Name = "Black flannel aesthetic y2k soft trendy emo vamp",
		TemplateId = 5134719820,
	},
	{
		Class = "Shirt",
		Name = "spiderman",
		TemplateId = 8223928164,
	},
	{
		Class = "Shirt",
		Name = "NBA Youngboy Black Amiri Red Vlone Vest chain ice",
		TemplateId = 7581342573,
	},
	{
		Class = "Shirt",
		Name = "VAMPIRE EPIC FACE BLACK TEE",
		TemplateId = 6788766332,
	},
	{
		Class = "Shirt",
		Name = "Flower spring tie front preppy pastel soft",
		TemplateId = 8918147744,
	},
	{
		Class = "Shirt",
		Name = "cute White corset fairy lace soft cottage core",
		TemplateId = 6748325601,
	},
	{
		Class = "Shirt",
		Name = "Baddie Tattoo Tank y2k aesthetic halloween preppy",
		TemplateId = 6748392322,
	},
	{
		Class = "Shirt",
		Name = "grey shirt grunge y2k vamp emo 2000s white black",
		TemplateId = 10097438498,
	},
	{
		Class = "Shirt",
		Name = "smiley preppy pink tee yay",
		TemplateId = 10930313660,
	},
	{
		Class = "Shirt",
		Name = "y2k vamp cyber doll emo baddie goth ugh gyaru yay",
		TemplateId = 8342289655,
	},
	{
		Class = "Shirt",
		Name = "st patricks vintage sweater sage green cottage ",
		TemplateId = 6905879940,
	},
	{
		Class = "Shirt",
		Name = "🌈Cartoony Rainbow Shirt",
		TemplateId = 7136156284,
	},
	{
		Class = "Shirt",
		Name = "st patricks day baby tee pastel preppy bloxburg",
		TemplateId = 8733059577,
	},
	{
		Class = "Shirt",
		Name = "shadow hoodie y2k vamp emo goth boy trendy black",
		TemplateId = 8621453261,
	},
	{
		Class = "Shirt",
		Name = "spiderman",
		TemplateId = 9283535775,
	},
	{
		Class = "Shirt",
		Name = "grunge y2k vamp Halloween emo ok shein skeleton",
		TemplateId = 8934513671,
	},
	{
		Class = "Shirt",
		Name = "Pastel Starburst Top with Gray Jacket",
		TemplateId = 398634295,
	},
	{
		Class = "Shirt",
		Name = "Blue Plaid Shirt ",
		TemplateId = 398635081,
	},
	{
		Class = "Shirt",
		Name = "cute white shirt",
		TemplateId = 11166002988,
	},
	{
		Class = "Shirt",
		Name = "halloween y2k black tube top emo black fairy swag",
		TemplateId = 4887497746,
	},
	{
		Class = "Shirt",
		Name = "Emo y2k black shirt aesthetic lol boy trendy",
		TemplateId = 7919545692,
	},
	{
		Class = "Shirt",
		Name = "White Suit w/ Black Vest [+]",
		TemplateId = 6553589977,
	},
	{
		Class = "Shirt",
		Name = "emo grunge y2k vamp baddie swag black vamp vday",
		TemplateId = 6468534886,
	},
	{
		Class = "Shirt",
		Name = "𐐪♡𐑂 raglan butterfly blue tee",
		TemplateId = 8486071599,
	},
	{
		Class = "Shirt",
		Name = "y2k lowrise 2000s snow fae soft hello kitty top",
		TemplateId = 9067279555,
	},
	{
		Class = "Shirt",
		Name = "y2k girl cute black vamp emo vintage aesthetic ok",
		TemplateId = 5748563757,
	},
	{
		Class = "Shirt",
		Name = "vamp emo cyber y2k ok lol streetwear graphic grim",
		TemplateId = 7900421413,
	},
	{
		Class = "Shirt",
		Name = "🕷️ Spiderman: No Way Home Suit - Top 🕷️",
		TemplateId = 4243503691,
	},
	{
		Class = "Shirt",
		Name = "red vamp grunge y2k Christmas emo goth skeleton",
		TemplateId = 8931371324,
	},
	{
		Class = "Shirt",
		Name = "y2k vamp emo vintage baddie cute yay aesthetic",
		TemplateId = 6768438209,
	},
	{
		Class = "Shirt",
		Name = "Bape X Bulls NBA Jersey",
		TemplateId = 6659283978,
	},
	{
		Class = "Shirt",
		Name = "★💗Preppy cute girl summer pink yellow jacket top!",
		TemplateId = 9469846049,
	},
	{
		Class = "Shirt",
		Name = "vamp twilight goth y2k bella swan witch emo envy",
		TemplateId = 7713626261,
	},
	{
		Class = "Shirt",
		Name = "los angeles cute aesthetic y2k soft vintage girl",
		TemplateId = 7265697514,
	},
	{
		Class = "Shirt",
		Name = "Rainbow🌈",
		TemplateId = 10562280883,
	},
	{
		Class = "Shirt",
		Name = "butterfly",
		TemplateId = 5554356721,
	},
	{
		Class = "Shirt",
		Name = "Argentina 2016 Kit [SS] | Messi #10",
		TemplateId = 396086549,
	},
	{
		Class = "Shirt",
		Name = "blue cyber angel y2k heavenly shirt + pearls yay",
		TemplateId = 5931151743,
	},
	{
		Class = "Shirt",
		Name = "Cute blue flower jacket",
		TemplateId = 6499746810,
	},
	{
		Class = "Shirt",
		Name = "[💎] Luxury Trendry Black T-Shirt Y2k 2023",
		TemplateId = 8449359555,
	},
	{
		Class = "Shirt",
		Name = "Black Batman Shirt",
		TemplateId = 6808801205,
	},
	{
		Class = "Shirt",
		Name = "Purple and Teal Top",
		TemplateId = 4047886060,
	},
	{
		Class = "Shirt",
		Name = "cottage core fairy vintage plaid sweater soft tan",
		TemplateId = 6862266654,
	},
	{
		Class = "Shirt",
		Name = "brown cowgirl trendy cute vintage girl aesthetic",
		TemplateId = 7152939724,
	},
	{
		Class = "Shirt",
		Name = "y2k vamp girl vintage aesthetic emo cyber cute ok",
		TemplateId = 6170187890,
	},
	{
		Class = "Shirt",
		Name = "Black And Red Gradient Bars Suit Top",
		TemplateId = 4481684165,
	},
	{
		Class = "Shirt",
		Name = "My Favorite Pizza Shirt",
		TemplateId = 4047884939,
	},
	{
		Class = "Shirt",
		Name = "Luffy",
		TemplateId = 7682597897,
	},
	{
		Class = "Shirt",
		Name = "✿preppy tank top - flower",
		TemplateId = 7027037222,
	},
	{
		Class = "Shirt",
		Name = "🐸 cute frog shirt preppy aesthetic green y2k tee",
		TemplateId = 6928894488,
	},
	{
		Class = "Shirt",
		Name = "bella swan twilight vamp y2k swag fairy grunge emo",
		TemplateId = 7338884141,
	},
	{
		Class = "Shirt",
		Name = "Spiderman 🕷",
		TemplateId = 8648606436,
	},
	{
		Class = "Shirt",
		Name = "vintage retro thrift indie fairy pixie y2k angel",
		TemplateId = 7684945576,
	},
	{
		Class = "Shirt",
		Name = "Guitar Tee with Black Jacket",
		TemplateId = 4047884046,
	},
	{
		Class = "Shirt",
		Name = "Plain Black Short Sleeve Tee",
		TemplateId = 4863226667,
	},
	{
		Class = "Shirt",
		Name = "y2k da hood girl beige star top ",
		TemplateId = 13188114627,
	},
	{
		Class = "Shirt",
		Name = "batman",
		TemplateId = 6867759152,
	},
	{
		Class = "Shirt",
		Name = "💠Blue Fade Hoodie Frost y2k Ocean Aqua stripes",
		TemplateId = 8897094086,
	},
	{
		Class = "Shirt",
		Name = "| aesthetic preppy indie softie green",
		TemplateId = 8391408885,
	},
	{
		Class = "Shirt",
		Name = "Gojo",
		TemplateId = 6518982031,
	},
	{
		Class = "Shirt",
		Name = "🔥FF Skater Nocturno🔥",
		TemplateId = 7123621018,
	},
	{
		Class = "Shirt",
		Name = "Matching duck fit - Pijama de pato camisa {🐥}",
		TemplateId = 8696625817,
	},
	{
		Class = "Shirt",
		Name = "Cute vintage aesthetic blue layer crop top shirt🤍",
		TemplateId = 6774208258,
	},
	{
		Class = "Shirt",
		Name = "Brown emo vintage fairy baddie cute y2k aesthetic",
		TemplateId = 6191602503,
	},
	{
		Class = "Shirt",
		Name = "🤎checkered brown shirt y2k ok grunge cute girl🤎",
		TemplateId = 7219405648,
	},
	{
		Class = "Shirt",
		Name = "Mr Beast Tee Shirt Blue",
		TemplateId = 14362799970,
	},
	{
		Class = "Shirt",
		Name = "y2k honey vamp emo cyber aesthetic swag baddie yay",
		TemplateId = 7241304238,
	},
	{
		Class = "Shirt",
		Name = "كخه2",
		TemplateId = 7380696466,
	},
	{
		Class = "Shirt",
		Name = "grunge y2k streetwear ok skullz qt emo yk vamp lol",
		TemplateId = 6953584858,
	},
	{
		Class = "Shirt",
		Name = "Plain White Short Sleeve",
		TemplateId = 3416308755,
	},
	{
		Class = "Shirt",
		Name = "saitama",
		TemplateId = 12216090341,
	},
	{
		Class = "Shirt",
		Name = "☆🧡⚡preppy retro summer y2k cute aesthetic tank!",
		TemplateId = 9024582278,
	},
	{
		Class = "Shirt",
		Name = "cute brandy mellville softie cardigan aesthetic",
		TemplateId = 6560709507,
	},
	{
		Class = "Shirt",
		Name = "spiderman",
		TemplateId = 7496590077,
	},
	{
		Class = "Shirt",
		Name = "Slender Black Jacket Emo Y2k Trash",
		TemplateId = 7046201897,
	},
	{
		Class = "Shirt",
		Name = "(AG) Black Shirt no Hair ext [copy n paste]",
		TemplateId = 6507772849,
	},
	{
		Class = "Shirt",
		Name = "White Tuxedo Shirt + Suspenders/Gloves [+]",
		TemplateId = 7337672541,
	},
	{
		Class = "Shirt",
		Name = "Ronaldo",
		TemplateId = 11813475271,
	},
	{
		Class = "Shirt",
		Name = "😍Abs-Six pack🔥Slender Blue muscle boy Anime",
		TemplateId = 8730085447,
	},
	{
		Class = "Shirt",
		Name = "Fresh Dark Blue Fitted Cap Boys / Men Outfit",
		TemplateId = 6743320303,
	},
	{
		Class = "Shirt",
		Name = "nova",
		TemplateId = 13915422672,
	},
	{
		Class = "Shirt",
		Name = "━☆Red GAP Devil Hoodie☆━",
		TemplateId = 5831429758,
	},
	{
		Class = "Shirt",
		Name = "★ lana thrift swan vamp mitski drain y2k ok dahood",
		TemplateId = 7666185571,
	},
	{
		Class = "Shirt",
		Name = "✨Aesthetic Bow Tied White Christmas y2k Cute Top",
		TemplateId = 5238514749,
	},
	{
		Class = "Shirt",
		Name = "Light blue Stitch crop top!",
		TemplateId = 5095204242,
	},
	{
		Class = "Shirt",
		Name = "Blue and Black Motorcycle Shirt",
		TemplateId = 144076358,
	},
	{
		Class = "Shirt",
		Name = "luffy",
		TemplateId = 12120129224,
	},
	{
		Class = "Shirt",
		Name = "Hello Kitty vamp pjs qt ok lol cute y2k emo gyaru",
		TemplateId = 9205390372,
	},
	{
		Class = "Shirt",
		Name = "cool y2k vamp emo 2000s cyber fairy bella swan hi",
		TemplateId = 7767984021,
	},
	{
		Class = "Shirt",
		Name = "black y2k core preppy 2000 white emo halloween",
		TemplateId = 10503415646,
	},
	{
		Class = "Shirt",
		Name = "red plaid crop top for copy and paste",
		TemplateId = 6780970545,
	},
	{
		Class = "Shirt",
		Name = "Cute Black Crop Top w Ruby Necklace",
		TemplateId = 7581474755,
	},
	{
		Class = "Shirt",
		Name = "Michael Jordan Blue Chicago Bulls Hoodie Black",
		TemplateId = 5003312733,
	},
	{
		Class = "Shirt",
		Name = "black flannel aesthetic y2k soft vintage vamp emo",
		TemplateId = 8737634149,
	},
	{
		Class = "Shirt",
		Name = "Black y2k aesthetic vintage cute girl vamp goth ok",
		TemplateId = 6957748331,
	},
	{
		Class = "Shirt",
		Name = "purple cool crop-top .*+",
		TemplateId = 5042211670,
	},
	{
		Class = "Shirt",
		Name = "grunge y2k vamp Halloween emo ok baddie skeleton",
		TemplateId = 6595131928,
	},
	{
		Class = "Shirt",
		Name = "White Short Sleeve Crop top Cheap!",
		TemplateId = 5510081416,
	},
	{
		Class = "Shirt",
		Name = "NBA Youngboy Black White Amiri Vlone Vest chain YB",
		TemplateId = 8832735645,
	},
	{
		Class = "Shirt",
		Name = "grunge emo vamp ok swag off shoulder",
		TemplateId = 6768837946,
	},
	{
		Class = "Shirt",
		Name = "Hello kitty bag lil peep grunge y2k black headless",
		TemplateId = 7470806575,
	},
	{
		Class = "Shirt",
		Name = "[B]Cute Pink Crop Top w Butterfly Necklace",
		TemplateId = 6935628505,
	},
	{
		Class = "Shirt",
		Name = "❄️Cute White Aesthetic Vintage Fairy Y2K Preppy",
		TemplateId = 6124931327,
	},
	{
		Class = "Shirt",
		Name = "Cute white cropped plain cami cheap aesthetic vsco",
		TemplateId = 4561478415,
	},
	{
		Class = "Shirt",
		Name = "vamp scene yay ok grunge goth baddie aesthetic",
		TemplateId = 7273460213,
	},
	{
		Class = "Shirt",
		Name = "vamp emo cyber y2k ok lol streetwear grim skull 🦇",
		TemplateId = 8133818526,
	},
	{
		Class = "Shirt",
		Name = "Aesthetic purple blouse",
		TemplateId = 5461041547,
	},
	{
		Class = "Shirt",
		Name = "y2k gyaru emo ok vamp skool doll cyber streetwear",
		TemplateId = 6572052446,
	},
	{
		Class = "Shirt",
		Name = "hello kitty grunge shirt / goth / alt / emo",
		TemplateId = 5695750220,
	},
	{
		Class = "Shirt",
		Name = "white and pink smiley preppy top!",
		TemplateId = 6886214024,
	},
	{
		Class = "Shirt",
		Name = "nike pro top y2k aesthetic gray sports tank",
		TemplateId = 6385978493,
	},
	{
		Class = "Shirt",
		Name = "🔥Half Camo Red Adidas Shirt🔥 Adiddas Addidas",
		TemplateId = 6834899777,
	},
	{
		Class = "Shirt",
		Name = "Rainbow Classic Ninja Outfit",
		TemplateId = 7211287423,
	},
	{
		Class = "Shirt",
		Name = "🔥MU Red Flannel w/ Black Tee🔥",
		TemplateId = 1431276681,
	},
	{
		Class = "Shirt",
		Name = "🌈 Cartoony Rainbow Shirt",
		TemplateId = 5531440872,
	},
	{
		Class = "Shirt",
		Name = "y2k vamp cyber doll emo baddie goth ugh gyaru yay",
		TemplateId = 7082061297,
	},
	{
		Class = "Shirt",
		Name = "y2k twilight bella swan",
		TemplateId = 7394456847,
	},
	{
		Class = "Shirt",
		Name = "goth emo punk alt scene y2k drain vamp sale blood",
		TemplateId = 6150089465,
	},
	{
		Class = "Shirt",
		Name = "━♰White Devil Gap Hoodie♰━",
		TemplateId = 6683873729,
	},
	{
		Class = "Shirt",
		Name = "Bape Half And Half Camo Hoodie",
		TemplateId = 6085950392,
	},
	{
		Class = "Shirt",
		Name = "y2k grey sweater with backpack emo goth matching",
		TemplateId = 9244423769,
	},
	{
		Class = "Shirt",
		Name = "hello kitty",
		TemplateId = 7632153559,
	},
	{
		Class = "Shirt",
		Name = "Plain Black Shirt",
		TemplateId = 11412597471,
	},
	{
		Class = "Shirt",
		Name = "☺90's Brown Beige Argyle Vest☺",
		TemplateId = 6177567055,
	},
	{
		Class = "Shirt",
		Name = "Saitama",
		TemplateId = 438640555,
	},
	{
		Class = "Shirt",
		Name = "daisy top",
		TemplateId = 5970470892,
	},
	{
		Class = "Shirt",
		Name = "Cute Blue Butterfly Aesthetic Sporty Y2K Preppy",
		TemplateId = 5930314116,
	},
	{
		Class = "Shirt",
		Name = "Drip",
		TemplateId = 6764840753,
	},
	{
		Class = "Shirt",
		Name = "Toji +",
		TemplateId = 12915339705,
	},
	{
		Class = "Shirt",
		Name = "cinnamoroll",
		TemplateId = 9478646701,
	},
	{
		Class = "Shirt",
		Name = "Tv Man (+)",
		TemplateId = 13791336997,
	},
	{
		Class = "Shirt",
		Name = "Black Turtle Neck (For UGC Item by Youri)",
		TemplateId = 4383637715,
	},
	{
		Class = "Shirt",
		Name = "plain black t-shirt plain black t-shirt plain blac",
		TemplateId = 6320379156,
	},
	{
		Class = "Shirt",
		Name = "💚🌴 ˗ˏˋ preppy sage green sport tank",
		TemplateId = 10473062678,
	},
	{
		Class = "Shirt",
		Name = "🌈CUTE FUN PASTEL UNICORN CROP TOP!!🌈",
		TemplateId = 4909936568,
	},
	{
		Class = "Shirt",
		Name = "Jordan 6 UNC DopeSkill T-Shirt BEAN Graphic Crop",
		TemplateId = 10285645943,
	},
	{
		Class = "Shirt",
		Name = "💯>Spiderman<💯",
		TemplateId = 8545817639,
	},
	{
		Class = "Shirt",
		Name = "Brown aesthetic top",
		TemplateId = 7179921254,
	},
	{
		Class = "Shirt",
		Name = "🔥 LA West Coast Dodgers Jersey",
		TemplateId = 7526350926,
	},
	{
		Class = "Shirt",
		Name = "froggy outfit",
		TemplateId = 7324400371,
	},
	{
		Class = "Shirt",
		Name = "Cute Blue Shark Hood Shirt",
		TemplateId = 6347320610,
	},
	{
		Class = "Shirt",
		Name = "Blue Galaxy Hoodie Y2k Christmas Goth Emo Vamp",
		TemplateId = 7827765699,
	},
	{
		Class = "Shirt",
		Name = "🐻Cute Bear Animal Preppy Aesthetic Soft Y2K Brown",
		TemplateId = 6713769656,
	},
	{
		Class = "Shirt",
		Name = "NBA Kobe Bryant Purple Jersey Black Hoodie Cool ok",
		TemplateId = 9517955485,
	},
	{
		Class = "Shirt",
		Name = "Gloves ",
		TemplateId = 97956332,
	},
	{
		Class = "Shirt",
		Name = "cute fairycore grunge y2k preppy brown cottagecore",
		TemplateId = 8827914016,
	},
	{
		Class = "Shirt",
		Name = "Y2K multiverse boy crop",
		TemplateId = 13793359545,
	},
	{
		Class = "Shirt",
		Name = "Blusa chaveo no drip",
		TemplateId = 7464638495,
	},
	{
		Class = "Shirt",
		Name = "💸4PF LIL BABY RYLO 'SUM TO PROVE' BLUE TEE💸",
		TemplateId = 9622908251,
	},
	{
		Class = "Shirt",
		Name = "𝒩𝒞 | Pink Barbie Bomber W Tank ",
		TemplateId = 13108549584,
	},
	{
		Class = "Shirt",
		Name = "☆⛄💗 Preppy Christmas Pink Smiley Matching Pj !☆ ",
		TemplateId = 11727558847,
	},
	{
		Class = "Shirt",
		Name = "Black Suit",
		TemplateId = 2478933288,
	},
	{
		Class = "Shirt",
		Name = "skull y2k envy grunge emo boy alt hooide graphic k",
		TemplateId = 9529318530,
	},
	{
		Class = "Shirt",
		Name = "floral cute vintage cottage core y2k green girl",
		TemplateId = 7240990843,
	},
	{
		Class = "Shirt",
		Name = "rainbow shattered",
		TemplateId = 5954657521,
	},
	{
		Class = "Shirt",
		Name = "💜Purple Hoodie💜 (Girls) [HL] |「𝘾𝙇」",
		TemplateId = 6525602599,
	},
	{
		Class = "Shirt",
		Name = "Brown Trippy Smiley Soft Preppy Girl Vamp",
		TemplateId = 11928900424,
	},
	{
		Class = "Shirt",
		Name = "zip up grey stars emo cyber vamp swag y2k baddie",
		TemplateId = 6468542769,
	},
	{
		Class = "Shirt",
		Name = "brown cottage core vintage preppy beige cute tan",
		TemplateId = 6959669630,
	},
	{
		Class = "Shirt",
		Name = "lime 🦠⭐️",
		TemplateId = 8533973473,
	},
	{
		Class = "Shirt",
		Name = "Goku",
		TemplateId = 6911298876,
	},
	{
		Class = "Shirt",
		Name = "기여운 고먐미",
		TemplateId = 5633235643,
	},
	{
		Class = "Shirt",
		Name = "Emo Black Goth girl y2k anime cute aesthetic vamp",
		TemplateId = 5510258860,
	},
	{
		Class = "Shirt",
		Name = "y2k baddie cottage core corset pink kawaii preppy",
		TemplateId = 9906218539,
	},
	{
		Class = "Shirt",
		Name = "Y2k black top aesthetic trendy girls emo cute boy",
		TemplateId = 9364920955,
	},
	{
		Class = "Shirt",
		Name = "McDonalds",
		TemplateId = 12716135279,
	},
	{
		Class = "Shirt",
		Name = "Red Suit w/ Black Vest [+]",
		TemplateId = 7152018398,
	},
	{
		Class = "Shirt",
		Name = "White T with BLUE Bulletproof Vest",
		TemplateId = 8076137357,
	},
	{
		Class = "Shirt",
		Name = "Purple Thrasher tee",
		TemplateId = 5293611398,
	},
	{
		Class = "Shirt",
		Name = "𝒩𝒞 | 1992 Short Tied Shirt",
		TemplateId = 7675980822,
	},
	{
		Class = "Shirt",
		Name = "Blue Heart Bape Shirt",
		TemplateId = 6551382861,
	},
	{
		Class = "Shirt",
		Name = "grey shirt grunge y2k vamp emo 2000s !",
		TemplateId = 10834122199,
	},
	{
		Class = "Shirt",
		Name = "Luffy Gear 5TH [Nika] V2 (One Piece) [+]",
		TemplateId = 9287093540,
	},
	{
		Class = "Shirt",
		Name = "dora",
		TemplateId = 7765255668,
	},
	{
		Class = "Shirt",
		Name = "Black Void Shirt",
		TemplateId = 5410566530,
	},
	{
		Class = "Shirt",
		Name = "McDonalds",
		TemplateId = 13361984360,
	},
	{
		Class = "Shirt",
		Name = "💙Blue Nike Tech Fleece Shirt💙 blu nik tekh",
		TemplateId = 11149259665,
	},
	{
		Class = "Shirt",
		Name = "Brown CH Y2K Plaid Jacket W Palm Angels Skeleton T",
		TemplateId = 6775310143,
	},
	{
		Class = "Shirt",
		Name = "nezuko ",
		TemplateId = 7642540419,
	},
	{
		Class = "Shirt",
		Name = "Titan Speaker Man (+)",
		TemplateId = 13711469767,
	},
	{
		Class = "Shirt",
		Name = "Goku",
		TemplateId = 5045240078,
	},
	{
		Class = "Shirt",
		Name = "<3",
		TemplateId = 10793363380,
	},
	{
		Class = "Shirt",
		Name = "Nik Tech Fleece Y2K Emo Vamp DaHood",
		TemplateId = 10505299354,
	},
	{
		Class = "Shirt",
		Name = "𝒩𝒞 | Beige Lavin Gallery Debt",
		TemplateId = 13253015143,
	},
	{
		Class = "Shirt",
		Name = "+TBK+ Plain Black & White Hoodie",
		TemplateId = 133708637,
	},
	{
		Class = "Shirt",
		Name = "Garou [+]",
		TemplateId = 5717261228,
	},
	{
		Class = "Shirt",
		Name = "😈 Red Growing Corruption Hoodie 😈",
		TemplateId = 5294490925,
	},
	{
		Class = "Shirt",
		Name = "♡ cinnamoroll",
		TemplateId = 10425074855,
	},
	{
		Class = "Shirt",
		Name = "Pink top with pink preppy smile ",
		TemplateId = 6528108095,
	},
	{
		Class = "Shirt",
		Name = "🦍OTF Long Live The Guys Red Tee OBLOCK Chains🦍",
		TemplateId = 9086054537,
	},
	{
		Class = "Shirt",
		Name = "preppy rainbow boho 🌈",
		TemplateId = 8989685942,
	},
	{
		Class = "Shirt",
		Name = "Very expensivee pt3",
		TemplateId = 7302184868,
	},
	{
		Class = "Shirt",
		Name = "Katakuri",
		TemplateId = 6895777063,
	},
	{
		Class = "Shirt",
		Name = "Rich suit",
		TemplateId = 7710284379,
	},
	{
		Class = "Shirt",
		Name = "Batman crop",
		TemplateId = 5804566780,
	},
	{
		Class = "Shirt",
		Name = "KT$®[NY]🚧LIMITED💹🎱Jacket Yellow Dark Girls",
		TemplateId = 9944380819,
	},
	{
		Class = "Shirt",
		Name = "Hello Kitty Pjamas Shirt White and Pink",
		TemplateId = 7403507415,
	},
	{
		Class = "Shirt",
		Name = "❤️Black Long Sleeves With Jordan Bulls 23 Jersey❤️",
		TemplateId = 6499116486,
	},
	{
		Class = "Shirt",
		Name = "black miles spider shirt (=^-ω-^=)",
		TemplateId = 13755584778,
	},
	{
		Class = "Shirt",
		Name = "Fresh Dark Blue Fitted Cap Jacket",
		TemplateId = 6743266272,
	},
	{
		Class = "Shirt",
		Name = "Popcat",
		TemplateId = 9549066704,
	},
	{
		Class = "Shirt",
		Name = "ribbed top",
		TemplateId = 11328910448,
	},
	{
		Class = "Shirt",
		Name = "barbie",
		TemplateId = 6837705336,
	},
	{
		Class = "Shirt",
		Name = "Burb Tattoos Rolex Chain Drip Icy Cash Money",
		TemplateId = 7233982404,
	},
	{
		Class = "Shirt",
		Name = "Black-red-champion-hoodie",
		TemplateId = 6726897383,
	},
	{
		Class = "Shirt",
		Name = "Spiderman Classic Costume Shirt",
		TemplateId = 14363914827,
	},
	{
		Class = "Shirt",
		Name = "𝒞𝒟 | Yellow Unstopable t-shirt",
		TemplateId = 8855733503,
	},
	{
		Class = "Shirt",
		Name = "Yellow Noob Shirt - Boys {ORIGINAL}",
		TemplateId = 5227483717,
	},
	{
		Class = "Shirt",
		Name = "y2k vintage brown v neck vest w white top male ver",
		TemplateId = 7208928531,
	},
	{
		Class = "Shirt",
		Name = "Grey Goth Y2k Cute Vintage Aesthetic Vamp Emo",
		TemplateId = 6518213334,
	},
	{
		Class = "Shirt",
		Name = "Tanqr",
		TemplateId = 8303839311,
	},
	{
		Class = "Shirt",
		Name = "💚🐸 frog outfit 🐸💚",
		TemplateId = 7318129653,
	},
	{
		Class = "Shirt",
		Name = "Cute aesthetic blue top 💖",
		TemplateId = 11998228866,
	},
	{
		Class = "Shirt",
		Name = "Pop Cat Shirt",
		TemplateId = 6547407176,
	},
	{
		Class = "Shirt",
		Name = "Toji [+]",
		TemplateId = 7354821687,
	},
	{
		Class = "Shirt",
		Name = "neko cat maid outfit dress top w/ gloves ",
		TemplateId = 5933990311,
	},
	{
		Class = "Shirt",
		Name = "Join #A$TRO LOCKER !",
		TemplateId = 13526021011,
	},
	{
		Class = "Shirt",
		Name = "Chat girl cutee fitt",
		TemplateId = 6998500386,
	},
	{
		Class = "Shirt",
		Name = "White Blank T-Shirt/Shirt",
		TemplateId = 3008003445,
	},
	{
		Class = "Shirt",
		Name = "Black Vest with Gray Undershirt and Gloves",
		TemplateId = 7153722654,
	},
	{
		Class = "Shirt",
		Name = "lace clouds beige ༻♥",
		TemplateId = 11766289413,
	},
	{
		Class = "Shirt",
		Name = "maid",
		TemplateId = 6467815787,
	},
	{
		Class = "Shirt",
		Name = ".☆*🐳preppy aesthetic purple shirt girl *☆.",
		TemplateId = 10724304415,
	},
	{
		Class = "Shirt",
		Name = "Cow print ",
		TemplateId = 9622989307,
	},
	{
		Class = "Shirt",
		Name = "Skibi Cameraman Suit [+]",
		TemplateId = 13555851202,
	},
	{
		Class = "Shirt",
		Name = "cinnamon toast crunch troll among us meme tophead",
		TemplateId = 7526815860,
	},
	{
		Class = "Shirt",
		Name = "كخة",
		TemplateId = 14397822231,
	},
	{
		Class = "Shirt",
		Name = "Cinnamoroll",
		TemplateId = 9474510268,
	},
	{
		Class = "Pants",
		Name = "☆ y2k star outfit",
		TemplateId = 11575783966,
	},
	{
		Class = "Pants",
		Name = "Black Slacks",
		TemplateId = 129459077,
	},
	{
		Class = "Pants",
		Name = "preppy white top & shorts boho set summer",
		TemplateId = 13744596969,
	},
	{
		Class = "Pants",
		Name = "Cute ripped Jeans Y2k aesthetic vintage girl ok",
		TemplateId = 5197702014,
	},
	{
		Class = "Pants",
		Name = "grey y2k star cargo jeans da hood emo tank top ",
		TemplateId = 13582003202,
	},
	{
		Class = "Pants",
		Name = "Black Jeans with White Shoes",
		TemplateId = 398633812,
	},
	{
		Class = "Pants",
		Name = "vamp Y2k goth grey shorts ripped aesthetic trendy",
		TemplateId = 7217204058,
	},
	{
		Class = "Pants",
		Name = "star outfit black shorts backpack socks",
		TemplateId = 13234378318,
	},
	{
		Class = "Pants",
		Name = "red star outfit ",
		TemplateId = 12931599490,
	},
	{
		Class = "Pants",
		Name = "beige emo khaki grunge y2k goth emo extreme boy",
		TemplateId = 9154749510,
	},
	{
		Class = "Pants",
		Name = "Emo chain pants",
		TemplateId = 7191535915,
	},
	{
		Class = "Pants",
		Name = "Butterfly ripped pants",
		TemplateId = 7001843110,
	},
	{
		Class = "Pants",
		Name = "☆ black star outfit",
		TemplateId = 12931713091,
	},
	{
		Class = "Pants",
		Name = "2000s y2k blue shorts",
		TemplateId = 9658689820,
	},
	{
		Class = "Pants",
		Name = "Brown Trippy Smiley Softie Preppy Emo Goth Baddie",
		TemplateId = 8739289340,
	},
	{
		Class = "Pants",
		Name = "y2k grunge emo gothic fit vamp twilight preppy",
		TemplateId = 12668603287,
	},
	{
		Class = "Pants",
		Name = "swag ok vamp hi doll skull emo schoolboy y2k blood",
		TemplateId = 6275777270,
	},
	{
		Class = "Pants",
		Name = "kawaii bear y2k preppy aesthetic outfit vamp",
		TemplateId = 12657989004,
	},
	{
		Class = "Pants",
		Name = "Jeans",
		TemplateId = 129458426,
	},
	{
		Class = "Pants",
		Name = "Black Silk Mini Dress with silver necklace",
		TemplateId = 7220612603,
	},
	{
		Class = "Pants",
		Name = "baddie y2k emo gothic vamp gayru black beige pants",
		TemplateId = 12092941280,
	},
	{
		Class = "Pants",
		Name = "Cute Denim Shorts Jeans Aesthetic Sporty Preppy",
		TemplateId = 8828281142,
	},
	{
		Class = "Pants",
		Name = "NBA Black Jeans Red Sneakers Youngboy 4KT",
		TemplateId = 9659287787,
	},
	{
		Class = "Pants",
		Name = "black y2k denim jeans envy emo steetwear da hood",
		TemplateId = 13500919306,
	},
	{
		Class = "Pants",
		Name = "Beautiful You Jeans",
		TemplateId = 398634487,
	},
	{
		Class = "Pants",
		Name = "hello pjs pajamas y2k aesthetic",
		TemplateId = 11156784176,
	},
	{
		Class = "Pants",
		Name = "cargo pants grey black",
		TemplateId = 12380638156,
	},
	{
		Class = "Pants",
		Name = "Black baddie biker shorts x black white Jordan 1s",
		TemplateId = 8383437691,
	},
	{
		Class = "Pants",
		Name = "spiderman",
		TemplateId = 8689056955,
	},
	{
		Class = "Pants",
		Name = "Cute White Flower Preppy Bloxburg Jean Vintage Y2k",
		TemplateId = 11791323358,
	},
	{
		Class = "Pants",
		Name = "barbie",
		TemplateId = 12539131263,
	},
	{
		Class = "Pants",
		Name = "Nike Pros Shorts (Black) !! ✰ ° .",
		TemplateId = 7623820327,
	},
	{
		Class = "Pants",
		Name = "y2k grey jeans ripped aesthetic vintage preppy",
		TemplateId = 8507543805,
	},
	{
		Class = "Pants",
		Name = "Spiderman [-]",
		TemplateId = 11560364493,
	},
	{
		Class = "Pants",
		Name = "baddie y2k black dh shorts emo aesthetic tattoo",
		TemplateId = 6712040000,
	},
	{
		Class = "Pants",
		Name = "cargo pants tan beige y2k core grunge emo white",
		TemplateId = 11164780591,
	},
	{
		Class = "Pants",
		Name = "💜 Cute Purple Y2K Softie Baddie Preppy Emo Goth",
		TemplateId = 10237420962,
	},
	{
		Class = "Pants",
		Name = "Bloxburg Soft Y2K New York Emo Goth Vamp Preppy",
		TemplateId = 9695657370,
	},
	{
		Class = "Pants",
		Name = "pink dress beach tropical",
		TemplateId = 12873119750,
	},
	{
		Class = "Pants",
		Name = "hello kitty",
		TemplateId = 11688810628,
	},
	{
		Class = "Pants",
		Name = "Y2K",
		TemplateId = 6413259597,
	},
	{
		Class = "Pants",
		Name = "⚫️*All Black *⚫️",
		TemplateId = 7262883976,
	},
	{
		Class = "Pants",
		Name = "NBA Youngboy Black Jeans White Jordans YB 4KT",
		TemplateId = 7549008293,
	},
	{
		Class = "Pants",
		Name = "butterfly y2k soft preppy aesthetic bloxburg vamp ",
		TemplateId = 12082357266,
	},
	{
		Class = "Pants",
		Name = "y2k school",
		TemplateId = 7210775999,
	},
	{
		Class = "Pants",
		Name = "y2k graveyard outfit grey silver star",
		TemplateId = 12974124044,
	},
	{
		Class = "Pants",
		Name = "Ripped Skater Pants",
		TemplateId = 398635338,
	},
	{
		Class = "Pants",
		Name = "da hood girl y2k cyber",
		TemplateId = 10374583189,
	},
	{
		Class = "Pants",
		Name = "preppy white skirt with shoes! softie boho",
		TemplateId = 6727549090,
	},
	{
		Class = "Pants",
		Name = "y2k star beige fit boots emo ",
		TemplateId = 13589096770,
	},
	{
		Class = "Pants",
		Name = "KT$®[FF]💖LIMITED💹🔫Original Angelical Red Boys",
		TemplateId = 8295439574,
	},
	{
		Class = "Pants",
		Name = "🌈 Cartoony Rainbow Pants",
		TemplateId = 5688213572,
	},
	{
		Class = "Pants",
		Name = "Grey✨.",
		TemplateId = 7048706977,
	},
	{
		Class = "Pants",
		Name = "st patrick y2k cottage core green sage vintage ",
		TemplateId = 6885458963,
	},
	{
		Class = "Pants",
		Name = "barbie",
		TemplateId = 10014447673,
	},
	{
		Class = "Pants",
		Name = "y2k r&b green camo grunge cargo pants ok",
		TemplateId = 10325427642,
	},
	{
		Class = "Pants",
		Name = "☁️ Cinnamoroll Overalls",
		TemplateId = 11458898753,
	},
	{
		Class = "Pants",
		Name = "nelk boys x champion black joggers",
		TemplateId = 4628693536,
	},
	{
		Class = "Pants",
		Name = "Barbie",
		TemplateId = 5331283449,
	},
	{
		Class = "Pants",
		Name = "White Suit 'n' Black Vest [-]",
		TemplateId = 6555794614,
	},
	{
		Class = "Pants",
		Name = "💚🐸 frog outfit 🐸💚",
		TemplateId = 6873157849,
	},
	{
		Class = "Pants",
		Name = "emo grunge ok y2k lol pls vamp gyaru cyber",
		TemplateId = 6960786140,
	},
	{
		Class = "Pants",
		Name = "꒰☻preppy y2k soft bloxburg emo summer boho set°｡",
		TemplateId = 10399403394,
	},
	{
		Class = "Pants",
		Name = "𝓙𝓐 ♡| blue set w shorts",
		TemplateId = 13302336533,
	},
	{
		Class = "Pants",
		Name = "y2k",
		TemplateId = 12244554292,
	},
	{
		Class = "Pants",
		Name = "2000s y2k black shorts",
		TemplateId = 9701889070,
	},
	{
		Class = "Pants",
		Name = "hello kitty pink skirt white top cute y2k vamp emo",
		TemplateId = 11946598712,
	},
	{
		Class = "Pants",
		Name = "vamp twilight goth y2k bella swan witch emo envy",
		TemplateId = 11023189766,
	},
	{
		Class = "Pants",
		Name = "Takis",
		TemplateId = 10781528818,
	},
	{
		Class = "Pants",
		Name = "🌱 green y2k cottagecore kawaii vintage dress",
		TemplateId = 7777148211,
	},
	{
		Class = "Pants",
		Name = "High waisted black cargo jeans pants trendy pocket",
		TemplateId = 6976457528,
	},
	{
		Class = "Pants",
		Name = "ok vamp swag cyber y2k gyaru fairy grunge emo envy",
		TemplateId = 6953140147,
	},
	{
		Class = "Pants",
		Name = "Preppy Brown Bear Argyle Aesthetic Set Cute Hearts",
		TemplateId = 9364608063,
	},
	{
		Class = "Pants",
		Name = "Y2K",
		TemplateId = 7121853101,
	},
	{
		Class = "Pants",
		Name = "spiderman pjs y2k da hood yuh",
		TemplateId = 11746885801,
	},
	{
		Class = "Pants",
		Name = "y2k grey da hood fit",
		TemplateId = 13334137331,
	},
	{
		Class = "Pants",
		Name = "white and grey pj's",
		TemplateId = 4879356118,
	},
	{
		Class = "Pants",
		Name = "bff set y2k bloxburg soft preppy emo baddie gothic",
		TemplateId = 8382458828,
	},
	{
		Class = "Pants",
		Name = "{£} Chanel Fur | Pink Silk Dress",
		TemplateId = 7389090172,
	},
	{
		Class = "Pants",
		Name = "🦇 Batman 🦇",
		TemplateId = 9381391368,
	},
	{
		Class = "Pants",
		Name = "black aesthetic goth y2k emo vamp ripped pants",
		TemplateId = 4737347763,
	},
	{
		Class = "Pants",
		Name = "all black pants",
		TemplateId = 7189083561,
	},
	{
		Class = "Pants",
		Name = "emo vamp grunge lol y2k 2000s cyber cute top",
		TemplateId = 10932987733,
	},
	{
		Class = "Pants",
		Name = "White Lace Black Dress + Shoes cute",
		TemplateId = 6295126852,
	},
	{
		Class = "Pants",
		Name = "[ORIG] skirt + convers boots envy y2k vamp emo",
		TemplateId = 5246950670,
	},
	{
		Class = "Pants",
		Name = "💠Black Chain Skirt Vamp Envy Grunge Aesthetic  ",
		TemplateId = 6844637856,
	},
	{
		Class = "Pants",
		Name = "Cute Ripped Denim Preppy Fairy Y2K Jeans Aesthetic",
		TemplateId = 11628423475,
	},
	{
		Class = "Pants",
		Name = "Black adidas boy shorts w tattoos",
		TemplateId = 4591622803,
	},
	{
		Class = "Pants",
		Name = "y2k da hood girl star outfit swag ok ",
		TemplateId = 13199139638,
	},
	{
		Class = "Pants",
		Name = "blue dress beach tropical",
		TemplateId = 12873121235,
	},
	{
		Class = "Pants",
		Name = "Red Squared Christmas pijamas",
		TemplateId = 6087965870,
	},
	{
		Class = "Pants",
		Name = "🍓Strawberry PJs",
		TemplateId = 6753251350,
	},
	{
		Class = "Pants",
		Name = "★☻⚡💗 Preppy cute Y2k Smiley girl aesthetic outfit",
		TemplateId = 9922856883,
	},
	{
		Class = "Pants",
		Name = "black shorts",
		TemplateId = 7012513733,
	},
	{
		Class = "Pants",
		Name = "White shorts w butterflies tats",
		TemplateId = 6554461464,
	},
	{
		Class = "Pants",
		Name = "🎀✨||Barbie",
		TemplateId = 5116003412,
	},
	{
		Class = "Pants",
		Name = "y2k da hood girl hello kitty shorts leg warmers",
		TemplateId = 9148044936,
	},
	{
		Class = "Pants",
		Name = "PINK hello kitty valentines pjs",
		TemplateId = 8568075050,
	},
	{
		Class = "Pants",
		Name = "Luffy",
		TemplateId = 6896171630,
	},
	{
		Class = "Pants",
		Name = "White Jeans Ripped Shorts Pants denim vintage soft",
		TemplateId = 7163024840,
	},
	{
		Class = "Pants",
		Name = "🖤Y2k Emo Goth Vamp🖤 Black Ripped Jeans",
		TemplateId = 6111376717,
	},
	{
		Class = "Pants",
		Name = "y2k thrift vintage outfit street wear k lol skull",
		TemplateId = 6568833981,
	},
	{
		Class = "Pants",
		Name = "🍋Cute Lemon Shorts Preppy Cottage Soft Y2K Girl",
		TemplateId = 6874622812,
	},
	{
		Class = "Pants",
		Name = "Roblox black default clothing",
		TemplateId = 6372680485,
	},
	{
		Class = "Pants",
		Name = "Red dunks",
		TemplateId = 9932304361,
	},
	{
		Class = "Pants",
		Name = "Pink Hawaii",
		TemplateId = 6848640078,
	},
	{
		Class = "Pants",
		Name = "y2k preppy aesthetic bleached jeans ",
		TemplateId = 9731859835,
	},
	{
		Class = "Pants",
		Name = "grunge y2k streetwear ok qt skullz emo yk vamp yay",
		TemplateId = 6585999399,
	},
	{
		Class = "Pants",
		Name = "Spiderman ⋆ ˚｡⋆˚",
		TemplateId = 9877445319,
	},
	{
		Class = "Pants",
		Name = "☁️Cloud Blue Shorts Jeans Cute Aesthetic Soft Y2K",
		TemplateId = 6369440433,
	},
	{
		Class = "Pants",
		Name = "COCOMELON 🍉",
		TemplateId = 8977992946,
	},
	{
		Class = "Pants",
		Name = "I feel Bricky 2",
		TemplateId = 23571257,
	},
	{
		Class = "Pants",
		Name = "y2k da hood girl school girl outfit star swag ok",
		TemplateId = 13199362024,
	},
	{
		Class = "Pants",
		Name = "spiderman",
		TemplateId = 8860468212,
	},
	{
		Class = "Pants",
		Name = "preppy tropical pink dress",
		TemplateId = 6750489358,
	},
	{
		Class = "Pants",
		Name = "cute core my melody pjs",
		TemplateId = 6209822387,
	},
	{
		Class = "Pants",
		Name = "Y2k Emo Goth Vamp Drain Alt Grunge Baggy Jeans fae",
		TemplateId = 6886232449,
	},
	{
		Class = "Pants",
		Name = "star jeans y2k",
		TemplateId = 12380652430,
	},
	{
		Class = "Pants",
		Name = "color changing preppy set",
		TemplateId = 13740218223,
	},
	{
		Class = "Pants",
		Name = "😈 Growing",
		TemplateId = 5485426368,
	},
	{
		Class = "Pants",
		Name = "bunny",
		TemplateId = 6033060763,
	},
	{
		Class = "Pants",
		Name = "🌿🌊aesthetic preppy boho light blue leaves!",
		TemplateId = 8690516179,
	},
	{
		Class = "Pants",
		Name = "y2k pajamas da hood girl hello kitty ",
		TemplateId = 11829676145,
	},
	{
		Class = "Pants",
		Name = "💧🌊Blue Fade Pants Frost y2k Ocean Aqua stripes",
		TemplateId = 7219383641,
	},
	{
		Class = "Pants",
		Name = "ପ kawaii kitty maid Outfit (BACK)",
		TemplateId = 5444940735,
	},
	{
		Class = "Pants",
		Name = "Cute Grey Jeans Preppy Alt Vamp Emo Y2K Aesthetic",
		TemplateId = 6694509427,
	},
	{
		Class = "Pants",
		Name = "y2k star trendy girl fit da hood",
		TemplateId = 14204917420,
	},
	{
		Class = "Pants",
		Name = "black laced dress w normal black socks",
		TemplateId = 7194467473,
	},
	{
		Class = "Pants",
		Name = "y2k aesthetic cute pretty jean skirt w tat",
		TemplateId = 7199589703,
	},
	{
		Class = "Pants",
		Name = "Gojo",
		TemplateId = 6518979697,
	},
	{
		Class = "Pants",
		Name = "y2k cinnamonroll star outifit ",
		TemplateId = 14269084864,
	},
	{
		Class = "Pants",
		Name = "Mafia Formal Pinstripe 1950 Dress",
		TemplateId = 9474758686,
	},
	{
		Class = "Pants",
		Name = "dress",
		TemplateId = 11429121290,
	},
	{
		Class = "Pants",
		Name = "High Waisted Boxer - Black w/ white hearts 5 Robux",
		TemplateId = 1314676675,
	},
	{
		Class = "Pants",
		Name = "black over outfit",
		TemplateId = 5683801034,
	},
	{
		Class = "Pants",
		Name = "Ripped Light Shorts Y2K Softie Preppy Jeans",
		TemplateId = 8867319292,
	},
	{
		Class = "Pants",
		Name = "━♰Y2K Grunge Emo Black Jeans 2 Rhinestone Belts♰━",
		TemplateId = 7283973572,
	},
	{
		Class = "Pants",
		Name = "😊pink smiley skirt y2k cute preppy school cheer",
		TemplateId = 10312693669,
	},
	{
		Class = "Pants",
		Name = "Preppy Cow cute girl emo black white bloxburg y2k",
		TemplateId = 5434066165,
	},
	{
		Class = "Pants",
		Name = "otf pants red drippy drip",
		TemplateId = 9995650952,
	},
	{
		Class = "Pants",
		Name = "Red Tech Fleece Pants ",
		TemplateId = 11156670068,
	},
	{
		Class = "Pants",
		Name = "evade y2k dress emo gothic",
		TemplateId = 13627705571,
	},
	{
		Class = "Pants",
		Name = "Preppy Set!",
		TemplateId = 6494648978,
	},
	{
		Class = "Pants",
		Name = "y2k",
		TemplateId = 11783401884,
	},
	{
		Class = "Pants",
		Name = "Sage green Lululemon Set Y2K Softie Preppy Goth",
		TemplateId = 8711840289,
	},
	{
		Class = "Pants",
		Name = "pink tropical flower set (=^-ω-^=)",
		TemplateId = 13738326528,
	},
	{
		Class = "Pants",
		Name = "spiderman spiderverse jeans",
		TemplateId = 13729872999,
	},
	{
		Class = "Pants",
		Name = "dollette coquett floral onepiece w mary janes y2k",
		TemplateId = 11698071851,
	},
	{
		Class = "Pants",
		Name = "mummy wraps bones n blood goth emo halloween",
		TemplateId = 10605978271,
	},
	{
		Class = "Pants",
		Name = "{🖤} Butterfly Grunge Goth Emo y2k Vamp",
		TemplateId = 6714635155,
	},
	{
		Class = "Pants",
		Name = "white crop top with jeans ",
		TemplateId = 6715096113,
	},
	{
		Class = "Pants",
		Name = "Ka'Mari Gym Black Sport Shorts With A Little Knot",
		TemplateId = 5050263964,
	},
	{
		Class = "Pants",
		Name = "white softie skirt preppy aesthetic cute y2k fairy",
		TemplateId = 4899180116,
	},
	{
		Class = "Pants",
		Name = "full white pants",
		TemplateId = 5087238148,
	},
	{
		Class = "Pants",
		Name = "Mariposa",
		TemplateId = 7329613116,
	},
	{
		Class = "Pants",
		Name = "Dora ",
		TemplateId = 6319413011,
	},
	{
		Class = "Pants",
		Name = "miles morales spiderverse black jeans",
		TemplateId = 13793412893,
	},
	{
		Class = "Pants",
		Name = "tanktop black grunge streetwear emo da hood",
		TemplateId = 14306826934,
	},
	{
		Class = "Pants",
		Name = "y2k soft fairy doll swag cyber cargo pants",
		TemplateId = 7509113437,
	},
	{
		Class = "Pants",
		Name = "sage preppy set ⚡",
		TemplateId = 7360409964,
	},
	{
		Class = "Pants",
		Name = "Cute Pink Maui Preppy Skirt Aesthetic Y2K Bloxburg",
		TemplateId = 9874935351,
	},
	{
		Class = "Pants",
		Name = "kuromi",
		TemplateId = 6942747542,
	},
	{
		Class = "Pants",
		Name = "cinnamoroll",
		TemplateId = 6303599909,
	},
	{
		Class = "Pants",
		Name = "Pink psd boxers",
		TemplateId = 10499595606,
	},
	{
		Class = "Pants",
		Name = "𝕭𝕭 | Pink Barbie Dunks & Black Jeans Summer",
		TemplateId = 11647165130,
	},
	{
		Class = "Pants",
		Name = "cottage core purpl sage vintage aesthetic bloxburg",
		TemplateId = 10289572874,
	},
	{
		Class = "Pants",
		Name = "RONALDO",
		TemplateId = 11865666608,
	},
	{
		Class = "Pants",
		Name = "NEW STRANGER THINGS TRACKSUIT SHORTS",
		TemplateId = 3483556486,
	},
	{
		Class = "Pants",
		Name = "distressed w white",
		TemplateId = 6090981115,
	},
	{
		Class = "Pants",
		Name = "🎀 Hello Kitty Overalls",
		TemplateId = 11467549354,
	},
	{
		Class = "Pants",
		Name = "y2k grunge swag punk cyber streetwear vamp emo ok",
		TemplateId = 6366077720,
	},
	{
		Class = "Pants",
		Name = "Black-jeans-boy-purple-shoes",
		TemplateId = 5692190045,
	},
	{
		Class = "Pants",
		Name = "Pitch Black Pitch Black Pitch",
		TemplateId = 3804156660,
	},
	{
		Class = "Pants",
		Name = "luffy",
		TemplateId = 12048493122,
	},
	{
		Class = "Pants",
		Name = "Batman Pjs",
		TemplateId = 6812911505,
	},
	{
		Class = "Pants",
		Name = "white",
		TemplateId = 10068455754,
	},
	{
		Class = "Pants",
		Name = "My melody!",
		TemplateId = 6697282430,
	},
	{
		Class = "Pants",
		Name = "spidergwen spiderverse jeans",
		TemplateId = 13729738048,
	},
	{
		Class = "Pants",
		Name = "Y2K Multiverse Low Rise Jeans",
		TemplateId = 14209227393,
	},
	{
		Class = "Pants",
		Name = "Shadowed",
		TemplateId = 5375990370,
	},
	{
		Class = "Pants",
		Name = "white preppy tennis skirt",
		TemplateId = 6361382127,
	},
	{
		Class = "Pants",
		Name = "Bape Half And Half Camo Pants W/ Bapestas",
		TemplateId = 6085956036,
	},
	{
		Class = "Pants",
		Name = "Matching pajamas for hello kitty",
		TemplateId = 12520994743,
	},
	{
		Class = "Pants",
		Name = "Y2k✧",
		TemplateId = 8585614448,
	},
	{
		Class = "Pants",
		Name = "preppy cottage core vintage plaid dress w socks",
		TemplateId = 6296904294,
	},
	{
		Class = "Pants",
		Name = "💎Ripped Black Jeans w/ MU White Sneakers💎",
		TemplateId = 1174596088,
	},
	{
		Class = "Pants",
		Name = "Pure White Pants",
		TemplateId = 6823021663,
	},
	{
		Class = "Pants",
		Name = "Jordan 4 Lightning",
		TemplateId = 6201410567,
	},
	{
		Class = "Pants",
		Name = "ice spice",
		TemplateId = 12107916455,
	},
	{
		Class = "Pants",
		Name = "comfy grey plad sweatpants",
		TemplateId = 6953066579,
	},
	{
		Class = "Pants",
		Name = "frog beanie outfit- jean shorts",
		TemplateId = 6416595821,
	},
	{
		Class = "Pants",
		Name = "💯🔥 Half Red Camo Pants Adidas Shoes",
		TemplateId = 4924696137,
	},
	{
		Class = "Pants",
		Name = "Saitama",
		TemplateId = 438640629,
	},
	{
		Class = "Pants",
		Name = "Black baddie biker shorts x red Jordan 1s",
		TemplateId = 7704810037,
	},
	{
		Class = "Pants",
		Name = "Cute Blue Shark Hood Pants",
		TemplateId = 6347319191,
	},
	{
		Class = "Pants",
		Name = "Beige Cargo Pants W/ Orange Dunks Baddie Y2k",
		TemplateId = 11902287997,
	},
	{
		Class = "Pants",
		Name = "☆⛄💗 Preppy Christmas Pink Smiley Matching Shorts",
		TemplateId = 11727457013,
	},
	{
		Class = "Pants",
		Name = "BFF - Dino Pjs Purple ",
		TemplateId = 6573215502,
	},
	{
		Class = "Pants",
		Name = "blue trueys wit da red boxers",
		TemplateId = 9718515912,
	},
	{
		Class = "Pants",
		Name = "shorts w yellow green dunks",
		TemplateId = 13366256606,
	},
	{
		Class = "Pants",
		Name = "nothing",
		TemplateId = 5168023580,
	},
	{
		Class = "Pants",
		Name = "cottage core dress white preppy xmas Christmas",
		TemplateId = 6986689009,
	},
	{
		Class = "Pants",
		Name = "barbie",
		TemplateId = 10093454594,
	},
	{
		Class = "Pants",
		Name = "ESB WHITE JEANS W/ BLACK BELT X RETO BLUE JORDANS",
		TemplateId = 8787973986,
	},
	{
		Class = "Pants",
		Name = "black corset dress grunge emo y2k halloween witch",
		TemplateId = 7757707261,
	},
	{
		Class = "Pants",
		Name = "Goku",
		TemplateId = 5045241577,
	},
	{
		Class = "Pants",
		Name = "Boy's Plain Black Swim Shorts - Type B",
		TemplateId = 7982775229,
	},
	{
		Class = "Pants",
		Name = "Dark Green Jeans",
		TemplateId = 144076760,
	},
	{
		Class = "Pants",
		Name = "green cottage core dress",
		TemplateId = 11702348860,
	},
	{
		Class = "Pants",
		Name = "Neon rainbow pretty cute pants",
		TemplateId = 9362720953,
	},
	{
		Class = "Pants",
		Name = "low rise black archive cargos",
		TemplateId = 9982819207,
	},
	{
		Class = "Pants",
		Name = "soft yay pink plaid heart dress w socks",
		TemplateId = 6964430139,
	},
	{
		Class = "Pants",
		Name = "y2k",
		TemplateId = 11893468491,
	},
	{
		Class = "Pants",
		Name = "[BOYS] $utairu ENT Merch Pants -BLUE-",
		TemplateId = 6171751296,
	},
	{
		Class = "Pants",
		Name = "y2k da hood girl hello kitty set",
		TemplateId = 12831070847,
	},
	{
		Class = "Pants",
		Name = "Cute Frog Outfit 🐸",
		TemplateId = 6971042936,
	},
	{
		Class = "Pants",
		Name = "★🐬 Preppy cute summer girl y2k blue aloha shorts!",
		TemplateId = 9417527567,
	},
	{
		Class = "Pants",
		Name = "Grey Nik e Tech Fleece Joggers",
		TemplateId = 11736106365,
	},
	{
		Class = "Pants",
		Name = "Cinnamoroll",
		TemplateId = 9910161482,
	},
	{
		Class = "Pants",
		Name = "alt envy y2k 2000s skulls doll grunge thrifted emo",
		TemplateId = 7775283410,
	},
	{
		Class = "Pants",
		Name = "Classic ripped jeans 💖",
		TemplateId = 11998339735,
	},
	{
		Class = "Pants",
		Name = "Spiderman",
		TemplateId = 6090133784,
	},
	{
		Class = "Pants",
		Name = "Maid",
		TemplateId = 6129054479,
	},
	{
		Class = "Pants",
		Name = "white over outfit",
		TemplateId = 5683800744,
	},
	{
		Class = "Pants",
		Name = "♱ evade",
		TemplateId = 12102203580,
	},
	{
		Class = "Pants",
		Name = "light washed jeans",
		TemplateId = 6014962382,
	},
	{
		Class = "Pants",
		Name = "default pink! ✰ ˚ · • . °",
		TemplateId = 6423408305,
	},
	{
		Class = "Pants",
		Name = "Fully Black Pants",
		TemplateId = 1148608872,
	},
	{
		Class = "Pants",
		Name = "cute blue cinnamoroll y2k kawaii hello kitty plaid",
		TemplateId = 13083930595,
	},
	{
		Class = "Pants",
		Name = "vamp twilight fairy 2000s thrift envy subversive",
		TemplateId = 6866621776,
	},
	{
		Class = "Pants",
		Name = "Lululemon",
		TemplateId = 10201895939,
	},
	{
		Class = "Pants",
		Name = "🦋 Blooming Butterfly Bloomers Ensemble ",
		TemplateId = 13577033172,
	},
	{
		Class = "Pants",
		Name = "Grimace [-]",
		TemplateId = 13957523673,
	},
	{
		Class = "Pants",
		Name = "Black Shorts",
		TemplateId = 721804266,
	},
	{
		Class = "Pants",
		Name = "Brown Y2k Cute Vintage Aesthetic Jeans Swag",
		TemplateId = 6895580462,
	},
	{
		Class = "Pants",
		Name = "✨Purple Butterfly Plaid Preppy Cute Emo Y2K Goth",
		TemplateId = 6752704115,
	},
	{
		Class = "Pants",
		Name = "Red Gap Joggers",
		TemplateId = 6729811825,
	},
	{
		Class = "Pants",
		Name = "Miles morales",
		TemplateId = 6546253923,
	},
	{
		Class = "Pants",
		Name = "gray sweats w blue dunks",
		TemplateId = 12474164749,
	},
	{
		Class = "Pants",
		Name = "Brown,orange butterfly shirt",
		TemplateId = 13969436409,
	},
}

return CustomizationList