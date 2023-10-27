-- local script (client script)
local Debris = game:GetService("Debris")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local origin = Vector3.new(0, 0, 0)
local radius = 25
local clamp, sin, acos = math.clamp, math.sin, math.acos -- preload functions

local anim = 0
while task.wait() do
	anim += 0.05
	local pos = mouse.X
	local Obj = Instance.new("Part")
	Obj.Anchored = true
	Obj.Size = Vector3.new(2, 2, 2)

	local x, y, z = clamp(mouse.hit.X, -radius, radius), 4+sin(anim)*3, radius

	local preimage = Obj:Clone()
	preimage.Position = Vector3.new(x, y, z)
	preimage.Color = Color3.new()

	--start converting 2d to 3d
	print(x/radius)
	z = sin(acos(x/radius))*radius -- z = sqrt(radius^2-x^2) --alternate formula

	Obj.Position = Vector3.new(x, y, z)
	local Obj2 = Obj:Clone()
	Obj2.Position = Vector3.new(Obj2.Position.X, Obj2.Position.Y, -Obj2.Position.Z)
	Obj.Color = Color3.new(1,1,1)
	
	Obj2.Parent = workspace
	Obj.Parent = workspace
	preimage.Parent = workspace
	
	Debris:AddItem(Obj, 1)
	Debris:AddItem(Obj2, 1)
	Debris:AddItem(preimage, 1)
end
