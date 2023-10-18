-- making a client script for this is unneccesary, this server script is distributed to each player upon entering

local players = game:GetService("Players")
local servstore = game:GetService("ServerStorage")
local WeaponModule = require(servstore:WaitForChild("Weapons"))
local dmg = WeaponModule["Sword"].Damage
local tool = script.Parent
local plr
local plrmodel
local db = false -- debounce

tool.Equipped:Connect(function()
	plrmodel = tool.Parent
	plr = players:GetPlayerFromCharacter(plrmodel)
end)

tool.Handle.Touched:Connect(function(object)
	if db then return end
	db = true
	if object:IsA("Accessory") then return end
    
	local touchhuman = object.Parent:FindFirstChild("Humanoid")
	if touchhuman then
	if not plrmodel or (plrmodel.HumanoidRootPart.Position-object.Position).Magnitude >= 22 then
		tool:Destroy()
		return
	end

	touchhuman:TakeDamage(dmg)
	tool.Handle.BrickColor = BrickColor.Random()
	wait(0.05)
	tool.Handle.BrickColor = BrickColor.new(255,0,0)
	end
	db = false
end)

