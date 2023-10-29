--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
--modules
--types
--constants
--variables
--references
--local functions
--class

return function(rarity : {[any] : number}) : any
    local count = 0
    for _,v in pairs(rarity) do
        count += v
    end

    local randNum = Random.new()
    local rnd = randNum:NextNumber(0, count)

    for i,v in pairs(rarity) do
        if rnd < v then
            return i
        end
        rnd -= v
    end
    return
end
