-- server script
local rs = game:GetService("ReplicatedStorage")
local ss = game:GetService("ServerStorage")
local debri = game:GetService("Debris")
local pew = rs:FindFirstChild("pew") -- a remote event to be fired by client and received by server
local plrdebounces = {}

pew.OnServerEvent:Connect(function(plr, info)
	if table.find(plrdebounces, plr.UserId) then 
		plr:Kick("cooldown")
		return
	end
	
	local infotab = {info}
	local userid = plr.UserId 
	local index = table.insert(plrdebounces, userid)
	
	local rocfold = plr:FindFirstChild("RocFolder")	
	if not rocfold or rocfold.Ammo.Value < 1 then
		plr:Kick("only "..tostring(rocfold.Ammo.Value))
	end
	rocfold.Ammo.Value -= 1
	
	local gun = plr.Character:FindFirstChild("Gun").Handle
	local bulet = ss.bullet:Clone()

	if not gun then return end
	bulet.plr.Value = plr.Name

	bulet.Position = gun.Position
	
	bulet.CFrame = CFrame.lookAt(bulet.Position, info)
	bulet.Parent = game.Workspace
		
	wait(0.3)
	table.remove(plrdebounces, index)
end)
