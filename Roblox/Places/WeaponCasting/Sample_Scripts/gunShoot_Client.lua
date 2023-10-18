-- local script (client script)
local rs = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local handle = script:FindFirstAncestor("Handle")
local tool = handle.Parent
local cooldown = false

repeat wait(1) until tool.Parent:IsA("Backpack") or tool.Parent:IsA("Model")

local plr = game:GetService("Players").LocalPlayer
local plrmodel = plr.Character
local mouse = plr:GetMouse()

local ammo = plr:WaitForChild("RocFolder").Ammo

local function shoot()
	if tool.Parent:IsA("Model") then
		if cooldown or ammo.Value < 1 or not plrmodel:FindFirstChild("Gun") then return end
		cooldown = true
		local ray = mouse.UnitRay
		local orig, goal = ray.Origin, ray.Direction.Unit * 500
		local rayparams = RaycastParams.new()
		local result = workspace:Raycast(orig, goal, rayparams)
		local endPos = result and result.Position or mouse.Hit.Position
		rs.pew:FireServer(endPos) -- fires the remote event, notifying the server
	end
	wait(0.5)
	cooldown = false
end

tool.Activated:Connect(shoot)
