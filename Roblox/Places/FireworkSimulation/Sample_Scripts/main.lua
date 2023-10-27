-- server script

local Debris = game:GetService("Debris")
local TServ = game:GetService("TweenService")
local ServStorage = game:GetService("ServerStorage")
local FireworkLauncher = workspace.Part  --Make sure your firework is facing up orelse it will shoot the fireworks the wrong way
local FireworkModels = ServStorage:FindFirstChild("FireworksFolder")
local Particles = ServStorage:FindFirstChild("ParticlesFolder")

--settings

--firework settings
local function F_Amount() return math.random(50, 70) end --randomizes from integers 50 to 70 inclusive
	
-- these are upwards force
local F_lowForce = 280 
local F_maxForce = 320

local F_UpOffset = 0 --up distance from the launcher
local F_TrailLength = 25
local F_LingerTime = 1.5
local F_RandomOffset = 30 --the spread of how far apart fireworks can go

--particle settings
local P_maxDist = 100
local P_LowestLimit = 70 --lowest amt of particles
local P_HighLimit = 120 --max amt of particles
local P_ShootTime = 2
local P_TrailLength = 15
local P_LingerTime = 1

local ParticleSettings = TweenInfo.new(P_ShootTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0)

if not Particles then
	Particles = {}
	for i = 1, 30 do
		local newPart = Instance.new("Part")
		newPart.Shape = "Ball"
		newPart.Size = Vector3.new(2.2, 2.2, 2.2)
		newPart.Color = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255)) --may not work
		newPart.Material = Enum.Material.Neon
		Particles[i] = newPart
	end
else
	local T = {}
	for i, v in pairs(Particles:GetChildren()) do
		T[i] = v
	end		
	Particles = T
end

if not FireworkModels then
	FireworkModels = {}
	for i = 1, 30 do
		local newPart = Instance.new("Part")
		newPart.Size = Vector3.new(1.5, 3, 1.5)
		newPart.Color = Color3.fromRGB(math.random(130, 255), math.random(130, 255), math.random(90, 255)) --may not work
		newPart.Material = Enum.Material.SmoothPlastic
		FireworkModels[i] = newPart
	end
else
	local T = {}
	for i, v in pairs(FireworkModels:GetChildren()) do
		T[i] = v
	end		
	FireworkModels = T
end

local function launch()
	local function CreateTrail(initColor, intensity, lifetime, length, parent)
		local trail = Instance.new("Trail")
		local O = Instance.new("Attachment")
		local I = Instance.new("Attachment")
		O.Position = parent.Size/2 * intensity
		I.Position = -parent.Size/2 * intensity
		trail.Attachment0 = O
		trail.Attachment1 = I
		trail.Color = ColorSequence.new(initColor, parent.Color)
		trail.FaceCamera = true
		trail.LightInfluence = 0
		trail.MaxLength = length
		trail.Lifetime = lifetime		
		trail.Attachment0 = O
		trail.Attachment1 = I
		O.Parent, I.Parent, trail.Parent = parent, parent, parent
	end
	
	for i = 1, math.floor(F_Amount()) do
		spawn(function()
		local firework = FireworkModels[math.random(1, #FireworkModels)]:Clone()
		CreateTrail(Color3.fromRGB(255, 238, 0), 0.8, F_LingerTime, F_TrailLength, firework)
		firework.Velocity = Vector3.new(math.random(-F_RandomOffset, F_RandomOffset), math.random(F_lowForce, F_maxForce), math.random(-F_RandomOffset, F_RandomOffset))
		firework.Anchored = false
		firework.CFrame = CFrame.new(FireworkLauncher.Position.X, FireworkLauncher.Position.Y + F_UpOffset, FireworkLauncher.Position.Z) * CFrame.Angles(FireworkLauncher.CFrame:ToOrientation())
		firework.CanTouch = false
		firework.CanCollide = false
		spawn(function()
			local NumParticles = math.random(P_LowestLimit, P_HighLimit)
			local newParticle = Particles[math.random(1, #Particles)]:Clone()
			
			while true do
				local Y1 = firework.Position.Y
				task.wait(0.35)
				local Y2 = firework.Position.Y
				
				if Y1-Y2 > 1 then
					task.wait(0.1)
					local function randForce() return math.random(-P_maxDist, P_maxDist) end
					newParticle.Position = firework.Position
					newParticle.CanTouch = false
					newParticle.Anchored = true
					firework.Anchored = true
					firework.Transparency = 0	
					
					spawn(function()
						task.wait(F_LingerTime)
						firework:Destroy()	
					end)
					
					local goal = {}
					goal.Position = Vector3.new(newParticle.Position.X + randForce(), newParticle.Position.Y + randForce(), newParticle.Position.Z + randForce())

					newParticle.Parent = workspace
					CreateTrail(Color3.new(newParticle.Color.R + 0.005, newParticle.Color.G + 0.005, newParticle.Color.B + 0.005), 1, P_LingerTime, P_TrailLength, newParticle)
					local Tween = TServ:Create(newParticle, ParticleSettings, goal)
					Tween:Play()
					local T
					T = Tween.Completed:Connect(function()
						newParticle.Transparency = newParticle.Transparency/2.5
						task.wait(P_LingerTime*0.35)
						newParticle.Transparency = 0
						task.wait(P_LingerTime*0.6)
						newParticle:Destroy()
						T:Disconnect()
						return
					end)
					break
				end
			end
		end)
		firework.Parent = workspace
		end)
	end
end

while task.wait(math.random(0.9, 3.4)) do spawn(launch) end
