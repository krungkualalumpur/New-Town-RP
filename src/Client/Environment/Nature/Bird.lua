--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
--types
type Maid = Maid.Maid
--constants
local BIRD_COUNT = 10

local SUN_RISE = 5
local SUN_SET = 18
--remotes
--variables
--references
local originalBirdModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Nature"):WaitForChild("Bird") 
--local functions 
function PlaySound(id, parent, volumeOptional: number ?)
	task.spawn(function()
		local s = Instance.new("Sound")

		s.Name = "Sound"
		s.SoundId = id
		s.Volume = volumeOptional or 1
        s.RollOffMaxDistance = 350
		s.PlaybackSpeed = math.random(9, 11)/10
		s.Looped = false
		s.Parent = parent
		s:Play()
		s.Ended:Wait()
		s:Destroy()
	end)
end

function prepareBird(bird : Model)
	if bird.Parent == nil then
		return
	end
	local torso = bird:FindFirstChild("Torso") :: BasePart
	local lwing = bird:FindFirstChild("Left Wing") :: BasePart
	local rwing = bird:FindFirstChild("Right Wing") :: BasePart
	
    if lwing and rwing and torso then
        local leftwing = Instance.new("Motor")
        leftwing.Name = "LeftWingMotor"
        leftwing.Part0 = torso
        leftwing.Part1 = lwing
        leftwing.C0 = CFrame.new(-0.5, 0.5, 0)
        leftwing.C1 = CFrame.new(0.5, 0, 0)
        leftwing.MaxVelocity = 0.5
        leftwing.Parent = torso
        local rightwing = Instance.new("Motor")
        rightwing.Name = "RightWingMotor"
        rightwing.Part0 = torso
        rightwing.Part1 = rwing
        rightwing.C0 = CFrame.new(0.5, 0.5, 0)
        rightwing.C1 = CFrame.new(-0.5, 0, 0)
        rightwing.MaxVelocity = 0.5
        rightwing.Parent = torso
        if lwing and rwing and torso then
            lwing.CanCollide = false
            rwing.CanCollide = false
            torso.CanCollide = false
        end
        rightwing.DesiredAngle = -math.pi / 4
        leftwing.DesiredAngle = math.pi / 4
        
        local propulsion = Instance.new("BodyVelocity")
        propulsion.Name = "Propulsion"
        propulsion.Parent = torso
        propulsion.Archivable = false
        local stabilizer = Instance.new("BodyGyro")
        stabilizer.Name = "Stabilizer"
        stabilizer.Parent = torso
        propulsion.Archivable = false

        torso.Anchored = true
    end
end

function flapping(bird : Model)
	if bird.Parent == nil then
		return
	end
    local torso = bird:FindFirstChild("Torso")
	local rightwing = if torso then torso:FindFirstChild("RightWingMotor") :: Motor? else nil
	local leftwing = if torso then torso:FindFirstChild("LeftWingMotor") :: Motor? else nil
	
	task.wait(0.05)
	if torso and rightwing and leftwing then
        rightwing.DesiredAngle = -rightwing.DesiredAngle
        leftwing.DesiredAngle = -leftwing.DesiredAngle
        task.wait(0.05)
        rightwing.DesiredAngle = -rightwing.DesiredAngle
        leftwing.DesiredAngle = -leftwing.DesiredAngle
        task.wait(0.05)
        rightwing.DesiredAngle = -rightwing.DesiredAngle
        leftwing.DesiredAngle = -leftwing.DesiredAngle
        task.wait(0.05)
        rightwing.DesiredAngle = -rightwing.DesiredAngle
        leftwing.DesiredAngle = -leftwing.DesiredAngle
    end
end

function flyingHover(bird : Model, v3)
	if bird.Parent == nil or v3 == nil then
		return
	end
	local torso = bird:FindFirstChild("Torso") :: BasePart ?
	local propulsion = if torso then torso:FindFirstChild("Propulsion") :: BodyVelocity ? else nil
    if torso and propulsion then
        bird:PivotTo(CFrame.lookAt(torso.Position, v3))
        propulsion.Velocity = v3 - torso.Position
        PlaySound("rbxassetid://9113845102", torso)
        local count = 0
        repeat task.wait(); count += 1 until ((v3 - torso.Position).Magnitude < 6) or count >= 1000
        propulsion.Velocity =( v3 - torso.Position).Unit*80
        flapping(bird)
        bird:PivotTo(CFrame.new(v3))
        propulsion.Velocity = Vector3.new()
    end
end

function flyingToDest(bird : Model, v3: Vector3)
	if bird.Parent == nil then
		return
	end
	local torso = bird:FindFirstChild("Torso") :: BasePart ?
	local propulsion = if torso then torso:FindFirstChild("Propulsion") :: BodyVelocity  ? else nil
	--flying up
    if torso and propulsion then 
        torso.Anchored = false
        PlaySound("rbxassetid://9113444803", torso, 1.5)
        flapping(bird)
        propulsion.MaxForce = Vector3.new(9999999,9999999,9999999)
        propulsion.Velocity = Vector3.new(0, 15, 0)
        flapping(bird)
        flapping(bird)
        
        --heading into the dest
        local flyV3 = v3 + Vector3.new(0,250,0)
        bird:PivotTo(CFrame.lookAt(torso.Position, flyV3))
        propulsion.Velocity = ((flyV3) - torso.Position).Unit*80
        local count = 0
        repeat task.wait(); count += 1 until ((flyV3 - torso.Position).Magnitude < 250) or count >= 1000
        --arriving
        local tw = game:GetService("TweenService"):Create(propulsion, TweenInfo.new(1), {Velocity = ( v3 - torso.Position).Unit*80})
        tw:Play()

        --[[task.spawn(function()
            
            
        end)]]
        --propulsion.Velocity =( v3 - torso.Position).Unit*80
        flapping(bird)
        flapping(bird)

        tw.Completed:Wait()
        tw:Destroy()


        repeat task.wait(); propulsion.Velocity = (v3 - torso.Position).Unit*80; count += 1 until ((v3 - torso.Position).Magnitude < 6) or count >= 1000

        propulsion.Velocity = Vector3.new()
        
        flapping(bird)
        flapping(bird)

        bird:PivotTo(CFrame.new(v3))
        torso.Anchored = true
    end
end

local function getARandomTree()
    local trees = workspace:WaitForChild("Assets"):WaitForChild("Environment"):WaitForChild("Trees")

    local i = math.random(1, #trees:GetChildren())
    local tree : Model
    for k,v in pairs(trees:GetChildren()) do
        if k == i then
            tree = v
            break
        end
    end

    return tree
end

--class
return {
    init = function(maid : Maid)

        local function goToATree(birdModel : Model)
            
            local tree = getARandomTree()

            if tree and tree:IsA("Model") then
                local cf, _ = tree:GetBoundingBox()
                flyingToDest(birdModel, cf.Position)
            end
        end

        task.spawn(function()
            for n = 1, BIRD_COUNT do
                local birdModel = originalBirdModel:Clone()
                local spawnOnATree = getARandomTree()
                if spawnOnATree and spawnOnATree:IsA("Model") then
                    local cf, _ = spawnOnATree:GetBoundingBox()
                    birdModel:PivotTo(cf)
                end
                birdModel.Parent = workspace
                prepareBird(birdModel)
                --movement
                task.spawn(function()
                    while task.wait() do
                        if game:GetService("Lighting").ClockTime <= SUN_SET and game:GetService("Lighting").ClockTime >= SUN_RISE then
                            goToATree(birdModel)
                        end
                    end
                end)
                --sound
                task.spawn(function()
                    while task.wait() do
                        if game:GetService("Lighting").ClockTime <= SUN_SET and game:GetService("Lighting").ClockTime >= SUN_RISE then
                            local randomIdGen = math.random(1, 2)
                            PlaySound(if randomIdGen == 1 then "rbxassetid://9113845102" else "rbxassetid://9056670230", birdModel:FindFirstChild("Torso"), math.random(1, 2))
                            task.wait(math.random(25, 100))
                        end
                    end
                end)
            end
        end)
        
    end
}