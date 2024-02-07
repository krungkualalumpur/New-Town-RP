--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
--types
type Maid = Maid.Maid
--constants
local DEFAULT_COLLISION_GROUP_KEY = "Default"
local VIP_PLR_COLLISION_KEY = "VIPPlayerCollision"

--references
--variables
--local function
local function initFootBallField(inst : Instance, maid : Maid)
    local footBallSpawner = inst:FindFirstChild("Spawner")
    assert(footBallSpawner and footBallSpawner:IsA("BasePart"), "No football spawner detected/spawner is not a part!")
    
    local detectors = inst:FindFirstChild("Detectors")
    local borders = inst:FindFirstChild("Borders")
    local ball = inst:FindFirstChild("Ball") :: BasePart

    assert(detectors, "No detectors detected")
    assert(borders, "No borders detected")
    assert(ball and ball:IsA("BasePart"), "No football detected")

    --set collisions
    local borderCollisionGroupKey = "Border"
    local footballCollisionGroupKey = "Football"

    PhysicsService:RegisterCollisionGroup(borderCollisionGroupKey)
    PhysicsService:RegisterCollisionGroup(footballCollisionGroupKey)
    PhysicsService:RegisterCollisionGroup(VIP_PLR_COLLISION_KEY)

    for _,border in pairs(borders:GetChildren()) do
        if border:IsA("BasePart") then
            border.CollisionGroup = borderCollisionGroupKey
        end
    end
    ball.CollisionGroup = footballCollisionGroupKey

    PhysicsService:CollisionGroupSetCollidable(borderCollisionGroupKey, footballCollisionGroupKey, true)
    PhysicsService:CollisionGroupSetCollidable(borderCollisionGroupKey, DEFAULT_COLLISION_GROUP_KEY, false)
    PhysicsService:CollisionGroupSetCollidable(borderCollisionGroupKey, VIP_PLR_COLLISION_KEY, false)
    PhysicsService:CollisionGroupSetCollidable(borderCollisionGroupKey, 'Player', false)


    local function resetfootball()
        ball.Position = footBallSpawner.Position
        ball.AssemblyLinearVelocity = Vector3.new()
        ball.AssemblyAngularVelocity = Vector3.new()
    end

    for _,detector in pairs(detectors:GetChildren()) do
        if detector:IsA("BasePart") then
            maid:GiveTask(detector.Touched:Connect(function(hit : BasePart)
                if hit:IsA("BasePart") and (hit == ball) then
                    resetfootball()
                end
            end))
        end
    end

    resetfootball()  
end

--class
local Minigame = {}

function Minigame.init(maid : Maid)
    for k, v in pairs(CollectionService:GetTagged("Minigame")) do
        local className = v:GetAttribute("Class")
        if className == "Football" then
            initFootBallField(v, maid)
        end
    end
end

return Minigame