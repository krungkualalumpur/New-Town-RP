--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Zone = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Zone"))

local MarketplaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketplaceUtil"))
--types
type Maid = Maid.Maid
--constants
local VIP_PLR_COLLISION_KEY = "VIPPlayerCollision"
local VIP_ZONE_TAG = "VIPZone"
--variables
--references
--local functions
--class
local VIPZone = {}

function VIPZone.init(maid : Maid)
    PhysicsService:RegisterCollisionGroup(VIP_PLR_COLLISION_KEY)
    PhysicsService:RegisterCollisionGroup(VIP_ZONE_TAG)

    PhysicsService:CollisionGroupSetCollidable(VIP_PLR_COLLISION_KEY, VIP_ZONE_TAG, false)

    for _,v in pairs(CollectionService:GetTagged(VIP_ZONE_TAG)) do
        if v:IsA("BasePart") then
            v.CollisionGroup = VIP_ZONE_TAG
        end
    end

   
    local vipZone = maid:GiveTask(Zone.new(CollectionService:GetTagged(VIP_ZONE_TAG)))

    maid:GiveTask(vipZone.playerEntered:Connect(function(plr : Player, zonePart : BasePart)
        local character = plr.Character
        assert(character and character.PrimaryPart)

        if not MarketplaceService:UserOwnsGamePassAsync(plr.UserId, MarketplaceUtil.getGamePassIdByName("VIP Feature")) then
            MarketplaceService:PromptGamePassPurchase(plr, MarketplaceUtil.getGamePassIdByName("VIP Feature"))
        end
        --[[local hit = character.PrimaryPart

        local function adjustV3(v3 : Vector3, fn : (number, Enum.Axis) -> number)
            return Vector3.new(fn(v3.X, Enum.Axis.X), fn(v3.Y, Enum.Axis.Y), fn(v3.Z, Enum.Axis.Z))
        end
        
        local relativeV3 = adjustV3(zonePart.CFrame:PointToObjectSpace(hit.Position), function(n : number, axis : Enum.Axis)
            local axisNumber = if (axis == Enum.Axis.X) then zonePart.Size.X elseif (axis == Enum.Axis.Y) then zonePart.Size.Y elseif (axis == Enum.Axis.Z) then zonePart.Size.Z else nil
            assert(axisNumber)
            return math.clamp(n, -axisNumber*0.5, axisNumber*0.5) 
        end) 
        
        print(hit.AssemblyLinearVelocity.Unit)
        local cf, size = character:GetBoundingBox()
        character:PivotTo(CFrame.new(zonePart.CFrame:PointToWorldSpace(relativeV3) - (hit.AssemblyLinearVelocity.Unit)*size.Magnitude))
       -- hit.Position = zonePart.CFrame:PointToWorldSpace(relativeV3) - (hit.AssemblyLinearVelocity.Unit)*hit.Size.Magnitude
        hit.AssemblyLinearVelocity = Vector3.new()]]
        return
    end))

    return
end

return VIPZone