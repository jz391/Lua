local rs = game:GetService("ReplicatedStorage")
repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") -- wait for one player to fully load

game:GetService("RunService").RenderStepped:Connect(function()
	local a = rs.Union:Clone()
	a.Parent = game.Workspace
	a.Position = Vector3.new(math.random(-23.126, 5.134),math.random(3.628, 21.143),math.random(-15.963, 12.882))
	a.CFrame = CFrame.new(a.Position) * CFrame.Angles(math.random(),math.random(),math.random())
	a.SurfaceLight.Color = Color3.new(math.random(), math.random(), math.random())
end)

[[
originally was this old code, until it was recently updated

while true do
	local a = rs.Union:Clone()
	a.Parent = game.Workspace
	a.Position = Vector3.new(math.random(-23.126, 5.134),math.random(3.628, 21.143),math.random(-15.963, 12.882))
end
]]
