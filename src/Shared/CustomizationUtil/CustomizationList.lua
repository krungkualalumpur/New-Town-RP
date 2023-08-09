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
        Name = "Black Fox Ears",
        TemplateId = 6076612186
    },
    {
        Class = "Accessory",
        Name = "Black Messy Wavy Hair",
        TemplateId = 5461548581
    },
    {
        Class = "Accessory",
        Name = "Black Pointy Fluffy Ears",
        TemplateId = 5459995751
    },
    {
        Class = "Accessory",
        Name = "Blizzaria Warlock",
        TemplateId = 105341547
    },
    {
        Class = "Accessory",
        Name = "Blue Jay Fedora",
        TemplateId = 63992958
    },
    {
        Class = "Accessory",
        Name = "Carton Emoji Head",
        TemplateId = 6098841412
    },
    {
        Class = "Accessory",
        Name = "Chill Cap",
        TemplateId = 321570512
    },
    {
        Class = "Accessory",
        Name = "Dominus Empyreus",
        TemplateId = 21070012
    },
    {
        Class = "Accessory",
        Name = "Dominus Formidulosus",
        TemplateId = 4255053867
    },
    {
        Class = "Accessory",
        Name = "Dominus Frigidus",
        TemplateId = 48545806
    },
    {
        Class = "Accessory",
        Name = "Evil Side",
        TemplateId = 4753467054
    },
    {
        Class = "Accessory",
        Name = "Fluffy Aesthetic Bunny Hat",
        TemplateId = 6447775593
    },
    {
        Class = "Accessory",
        Name = "Flushed Mask",
        TemplateId = 6346782295
    },
    {
        Class = "Accessory",
        Name = "Gaming Kitty Headphones (Pink)",
        TemplateId = 6502214579
    },
    {
        Class = "Accessory",
        Name = "Lightweight Top Hat",
        TemplateId = 44114473
    },
    {
        Class = "Accessory",
        Name = "Midnight Acolyte Motorcycle Helmet",
        TemplateId = 3806324286
    },
    {
        Class = "Accessory",
        Name = "Milk Bag",
        TemplateId = 5978325196
    },
    {
        Class = "Accessory",
        Name = "Peppermint Headphones",
        TemplateId = 67250704
    },
    {
        Class = "Accessory",
        Name = "Ring of Fire Fedora",
        TemplateId = 169286712
    },


    {
        Class = "Face",
        Name = "$.$",
        TemplateId = 10831558 
    },
    {
        Class = "Face",
        Name = ":]",
        TemplateId = 18151826 
    },
    {
        Class = "Face",
        Name = ">_<",
        TemplateId = 18151826 
    },
    {
        Class = "Face",
        Name = "Big Sad Eyes",
        TemplateId = 391496223 
    },
    {
        Class = "Face",
        Name = "Bling",
        TemplateId = 25975243 
    },
    {
        Class = "Face",
        Name = "Classic Goof",
        TemplateId = 7074661 
    },
    {
        Class = "Face",
        Name = "Classic Vampire",
        TemplateId = 7074836 
    },
    {
        Class = "Face",
        Name = "Cutiemouse",
        TemplateId = 15885121 
    },
    {
        Class = "Face",
        Name = "Dizzy",
        TemplateId = 10907551 
    },
    {
        Class = "Face",
        Name = "Drool",
        TemplateId = 7074893 
    },
    {
        Class = "Face",
        Name = "Drooling Noob",
        TemplateId = 24067718 
    },
    {
        Class = "Face",
        Name = "Glee",
        TemplateId = 7074729 
    },
    {
        Class = "Face",
        Name = "Good Intentioned",
        TemplateId = 7317793 
    },
    {
        Class = "Face",
        Name = "Happy Wink",
        TemplateId = 236399287 
    },
    {
        Class = "Face",
        Name = "Heeeeeey...",
        TemplateId = 21635565 
    },
    {
        Class = "Face",
        Name = "Joyful Smile",
        TemplateId = 209995366 
    },
    {
        Class = "Face",
        Name = "Laughing Fun",
        TemplateId = 226217449 
    },
    {
        Class = "Face",
        Name = "Playful Vampire",
        TemplateId = 2409285794 
    },
    {
        Class = "Face",
        Name = "Shiny Teeth",
        TemplateId = 20722130 
    },
    {
        Class = "Face",
        Name = "Squiggle Mouth",
        TemplateId = 25166274 
    },
    {
        Class = "Face",
        Name = "Super Happy Joy",
        TemplateId = 280988698 
    },
    {
        Class = "Face",
        Name = "Suspicious",
        TemplateId = 209994929 
    },
    {
        Class = "Face",
        Name = "Trance",
        TemplateId = 29109681 
    },
    {
        Class = "Face",
        Name = "Whistle",
        TemplateId = 22877700 
    },
    {
        Class = "Face",
        Name = "Winky",
        TemplateId = 7074864 
    },
    {
        Class = "Face",
        Name = "YAAAWWN",
        TemplateId = 162068415 
    },


    {
        Class = "Pants",
        Name = "Black Jeans",
        TemplateId = 6706227802
    },
    {
        Class = "Pants",
        Name = "Black Plaid Pants",
        TemplateId = 5909059980
    },
    {
        Class = "Pants",
        Name = "Black Slacks",
        TemplateId = 129459077
    },
    {
        Class = "Pants",
        Name = "Blue Adidas Shoes",
        TemplateId = 110454014
    },
    {
        Class = "Pants",
        Name = "Dominus Aureus Tuxedo",
        TemplateId = 1094268791
    },
    {
        Class = "Pants",
        Name = "Dominus Aureus Tuxedo",
        TemplateId = 1094268791
    },
    {
        Class = "Pants",
        Name = "Eid Thobe -",
        TemplateId = 5458352178
    },
    {
        Class = "Pants",
        Name = "Hot Red Set",
        TemplateId = 6710082263
    },
    {
        Class = "Pants",
        Name = "Indie Jeans",
        TemplateId = 6627221819
    },
    {
        Class = "Pants",
        Name = "Light Blue Washed Jeans W White Shoes",
        TemplateId = 6837045696
    },
    {
        Class = "Pants",
        Name = "Medical Pants",
        TemplateId = 6669238626
    },
    {
        Class = "Pants",
        Name = "Police Pants",
        TemplateId = 5143941362
    },
    {
        Class = "Pants",
        Name = "Rainbow Evil Pants",
        TemplateId = 6743958962
    },
    {
        Class = "Pants",
        Name = "Red Fade Pants",
        TemplateId = 5933260365
    },
    {
        Class = "Pants",
        Name = "black striped pjs + white air forces",
        TemplateId = 5018223613
    },
    {
        Class = "Pants",
        Name = "skinny biker jeans",
        TemplateId = 5726988765
    },
    {
        Class = "Pants",
        Name = "{💙} Lovely Butterflies & Laces",
        TemplateId = 6710772749
    },
    {
        Class = "Pants",
        Name = "✨🌑Off-White Supreme Gold & Space",
        TemplateId = 4786183811
    },
    {
        Class = "Pants",
        Name = "🔥Black & Red Pants",
        TemplateId = 5933262354
    },
    {
        Class = "Pants",
        Name = "😈Evil Pants",
        TemplateId = 4779968118
    },

    {
        Class = "Shirt",
        Name = "Anime Reaper Hoodie",
        TemplateId = 6589047278
    },
    {
        Class = "Shirt",
        Name = "Black Aesthetic",
        TemplateId = 5532806467
    },
    {
        Class = "Shirt",
        Name = "Black LV Jacket",
        TemplateId = 6702201167
    },
    {
        Class = "Shirt",
        Name = "Blizzaria Warlock [TOP]",
        TemplateId = 3325147608
    },
    {
        Class = "Shirt",
        Name = "Blue Christmas Sweater",
        TemplateId = 6066041449
    },
    {
        Class = "Shirt",
        Name = "Blue Collared Sweater w Shirt",
        TemplateId = 6773375942
    },
    {
        Class = "Shirt",
        Name = "Bunny Crop Top",
        TemplateId = 6699286494
    },
    {
        Class = "Shirt",
        Name = "Dominus Aureus Tuxedo",
        TemplateId = 1599009787
    },
    {
        Class = "Shirt",
        Name = "Guitar Tee with Black Jacket",
        TemplateId = 4047884046
    },
    {
        Class = "Shirt",
        Name = "Hysteric Glamour Knit",
        TemplateId = 6738013560
    },
}
--references
--local functions
--class

return CustomizationList