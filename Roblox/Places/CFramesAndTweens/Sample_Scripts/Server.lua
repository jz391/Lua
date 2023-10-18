local rs = game:GetService("ReplicatedStorage") 
local gui = game:GetService("StarterGui")
local tweening = false
local twenserv = game:GetService("TweenService")

local valscript = rs.valuescript 
local part = game.Workspace.experimentBox.specialpart
local pos = part.Parent.Pos

-- distribute valuescript to all textbuttons (a script that will fire the remote, requesting the server to do something)
for i, v in pairs(gui.valuegui:GetDescendants()) do 
	if v:IsA("TextButton") then
		local clone = valscript:Clone()
		clone.Parent = v
	end
end

rs.remote.OnServerEvent:Connect(function(plr, valtype, tabl) --setting cframes from remote event to part and pos model
	if tweening == false then
		tweening = true --debounce active
		local twentarget = {}
		
		local tweninf = TweenInfo.new(
		1, -- Time to tween (after delay)
		Enum.EasingStyle.Exponential, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- Tween repeats
		false, -- Reverse tween
		0 -- Delay tween 
		)
		
		if valtype == "Rotate" then
			twentarget.CFrame = part.CFrame*(CFrame.Angles(math.rad(tabl[1]), math.rad(tabl[2]), math.rad(tabl[3])))
		elseif valtype == "Move" then
			twentarget.CFrame = part.CFrame*(CFrame.new(tabl[1], tabl[2], tabl[3]))
		else
			plr:Kick("invalid value type")
		end
		local tween = twenserv:Create(part,tweninf, twentarget)
		tween:Play()
		wait(0.05)
		tweening = false --finished tween, disabling debounce
	end
end)
