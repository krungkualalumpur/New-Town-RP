--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
type FishData = {
    Name : string,
    Common : number
}
--modules
--types
--constants
--variables
--references
--local functions
--class
return {
    [1] = {
        Name = "Salmon",
        Common = 30
    },
    [2] = {
        Name = "Goldfish",
        Common = 60
    },
    [3] = {
        Name = "Catfish",
        Common = 25
    }
} :: {[number] : FishData}
