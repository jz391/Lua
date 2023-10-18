
local PlayerService = game:GetService("Players")
local Weapons = require(game:GetService("ServerStorage").Weapons)
local bullet = script.Parent

local PLR_ID = bullet.plrId.Value -- player id of this gun owner
local DMG = Weapons["Gun"].Damage
local SPEED = 70

local touchConnection
touchConnection = bullet.Touched:Connect(function(hitPart)
	local hitModel = hitPart:FindFirstAncestorWhichIsA("Model")
	
	local playerHit = PlayerService:GetPlayerFromCharacter(hitModel)
	local modelHumanoid = hitModel:FindFirstChild("Humanoid")
	
	-- cases where bullet should do nothing
	if hitPart.Name == "Handle" then return end -- prevent from destroying others' weapons
	if playerHit and PLR_ID == playerHit.UserId then return end -- prevent bullet from damaging self
	
	bullet.BodyVelocity.Velocity = Vector3.zero -- stops the bullet from moving
	touchConnection:Disconnect() --prevent event from retriggering the function

	coroutine.wrap(function() -- creates a new thread (kind of)
		if modelHumanoid and modelHumanoid.Health > 0 then
			hitModel.Humanoid:TakeDamage(DMG) --damages player (could also damage NPC)
		elseif not hitPart:IsGrounded() then
			hitPart.Transparency *= 0.5
			task.wait(0.17)
			hitPart:Destroy()
		end
	end)()
	
	-- visuals
	bullet.Material = "Neon"
	bullet.BrickColor = BrickColor.new("Really red")
	bullet.Transparency = 0.9
	for i = 1, 4, 0.5 do
		task.wait()
		bullet.Transparency = 0.9/i
	end
	
	bullet.BodyVelocity:Destroy()
	bullet:Destroy()
end)

bullet.Anchored = false
bullet.BodyVelocity.Velocity = bullet.CFrame.LookVector*SPEED

task.wait(2.5)
bullet.Transparency = 0.7
task.wait(0.5)
bullet:Destroy()
