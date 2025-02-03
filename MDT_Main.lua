local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SetCallsignEvent = ReplicatedStorage.Remotes:WaitForChild("SetCallsignEvent")

local Status = LocalPlayer:WaitForChild("Status")

local RadioFrame = script.Parent:WaitForChild("HomePage")
local CallsignContainer = RadioFrame.ForegroundContainer.UnitsFrame:WaitForChild("MainFrame") -- The container for cloned templates
local CallsignTemplate = RadioFrame.ForegroundContainer.UnitsFrame:WaitForChild("UnitTemplate") -- The template to be cloned

SetCallsignEvent.OnClientEvent:Connect(function(playerName, callsign)
	-- Check if a frame for this player already exists
	local existingFrame = CallsignContainer:FindFirstChild(playerName)
	if existingFrame then
		existingFrame.Callsign.Text = callsign -- Update the callsign
	else
		-- Clone the template
		local units = CallsignTemplate:Clone()
		units.Name = playerName
		units.Username.Text = playerName
		units.Callsign.Text = callsign
		units.Visible = true
		units.Parent = CallsignContainer

		-- Update the status for the cloned unit
		local player = Players:FindFirstChild(playerName)
		if player then
			local playerStatus = player:WaitForChild("Status")
			local function updateStatus()
				if playerStatus.OnDuty.Value then
					units.StatusMessage.Text = "In Service"
					units.Status.ImageColor3 = Color3.new(0.419608, 1, 0.14902) -- Green color
				else
					units.StatusMessage.Text = "Out of Service"
					units.Status.ImageColor3 = Color3.new(1, 0, 0) -- Red color
				end
			end

			-- Listen for changes in the OnDuty value for the cloned unit
			playerStatus.OnDuty:GetPropertyChangedSignal("Value"):Connect(updateStatus)

			-- Initial status update
			updateStatus()
		end
	end
end)
