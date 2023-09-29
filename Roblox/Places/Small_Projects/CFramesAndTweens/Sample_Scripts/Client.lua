-- this is the valuescript mentioned in Server.lua

local rs = game:GetService("ReplicatedStorage")

repeat wait() until script.Parent ~= rs

local typeofval = script.Parent.Name
local button = script.Parent
local valtable = {}
local firstTime = true

button.MouseButton1Click:Connect(function()
	local num = 1
	
	for i = 1, num do
		
	for i, v in pairs(button.Parent:GetChildren()) do -- get values from gui text boxes. if no value, 0 is the default
		wait()
		if v:IsA("TextBox") then
			if tonumber(v.text) then	
				table.insert(valtable,tonumber(v.Name),tonumber(v.text))
			else
				table.insert(valtable,tostring(v.Name),0)
			end
		end
	end
	
	table.remove(valtable,4)
	rs.remote:FireServer(typeofval,valtable) -- requested server to perform action
	
	end
end)
