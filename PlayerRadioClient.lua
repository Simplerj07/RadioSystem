-- Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ChannelsModule = require(ReplicatedStorage:WaitForChild("ChannelsModule"))
local RadioFrame = script.Parent.InterfaceRadioUI
local RadioScrollingFrame = RadioFrame:WaitForChild("RadioScrollingFrame")
local MessageTemplate = RadioFrame:WaitForChild("MessageFrame")
local SetCallsignFunction = ReplicatedStorage.Remotes.SetCallsign
local chatMessageEvent = ReplicatedStorage.Remotes.RadioMessageSent
local SendCallsign = ReplicatedStorage.Remotes.SetCallsign
local TopBar = RadioFrame.TopBar
local TransmitButton = TopBar.TransmitButton
local ChannelTextLabel = TopBar.ChannelName
local FrequencyTextLabel = TopBar.FrequencyLabel
local DistressButton = TopBar.Distressbutton
local RadioOn = RadioFrame.RadioOn
local RadioOff = RadioFrame.RadioOff
local ClickSound = RadioFrame.Click
local MessageSound = RadioFrame.MessageSound
local CallsignUi = RadioFrame.CallsignUi
local CallsignTextInput = CallsignUi.CallSignTextBox
local CallsignSubmitButton = CallsignUi.CallsignSubmit
local HideCallSigUiButto = RadioFrame.HideButton
local Callsignnotsetwarninglabel = RadioFrame.NoCallsignsetwarning
local Status = LocalPlayer:WaitForChild("Status")
local Callsign = Status.Callsign

-- Channel
local ChannelString = Status.Channel
local ChannelIndex = 1
local TeamChannels = ChannelsModule.Channels[LocalPlayer.Team.Name] or ChannelsModule.Channels["Default"]
local Channels = TeamChannels.Default
local RadioMessages = {}

for channel, accessible in pairs(TeamChannels.Access) do
	if accessible then
		table.insert(Channels, channel)
	end
end

for _, channel in ipairs(Channels) do
	RadioMessages[channel] = {"", "", "", "", "", ""}
end

-- Set the initial channel based on the player's team
local function SetInitialChannel()
	local initialChannel = TeamChannels.Default[1] or "MAIN COMMUNICATIONS"
	CurrentChannel = initialChannel
	ChannelString.Value = initialChannel
	ChannelTextLabel.Text = initialChannel
	FrequencyTextLabel.Text = TeamChannels.Frequencies[initialChannel] or "470.0000 MHz UHF"
end

-- Functions
local function UpdateGUI(messageColor)
	for i = 1, 6 do
		local messageFrame = RadioScrollingFrame:FindFirstChild("Message" .. i)
		if not messageFrame then
			messageFrame = MessageTemplate:Clone()
			messageFrame.Name = "Message" .. i
			messageFrame.Parent = RadioScrollingFrame
		end
		local messageText = RadioMessages[CurrentChannel][7 - i]
		messageFrame.Visible = messageText ~= ""
		messageFrame.Message.Text = messageText

		-- Customize the panic or dispatch message appearance
		if string.match(messageText, "**PANIC BUTTON PRESSED**") then
			messageFrame.BackgroundColor3 = Color3.fromRGB(255, 85, 0) -- Red for panic
		elseif string.match(messageText, "^RADIO") then
			messageFrame.BackgroundColor3 = Color3.fromRGB(0, 85, 127) -- Blue for dispatch
		else
			messageFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Default black
		end
	end
end

local function AddRadioMessage(Message, Channel)
	if not RadioMessages[Channel] then
		warn("Invalid channel: " .. tostring(Channel))
		return
	end

	table.insert(RadioMessages[Channel], 1, Message)
	table.remove(RadioMessages[Channel], 7)
	if Channel == CurrentChannel then
		UpdateGUI()
	end
end

local function SwitchChannel()
	ChannelIndex = ChannelIndex % #Channels + 1
	CurrentChannel = Channels[ChannelIndex]
	ChannelString.Value = CurrentChannel
	FrequencyTextLabel.Text = TeamChannels.Frequencies[CurrentChannel]
	TransmitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	UpdateGUI()
end

local function SetCallSign(player)
	local callsign = CallsignTextInput.Text
	if callsign ~= "" then
		local success, errorMessage = SetCallsignFunction:InvokeServer(callsign)
		if success then
			Callsignnotsetwarninglabel.Visible = false
		else
			warn(errorMessage)
		end
	else
		print("Please enter a valid callsign.")
	end
end

local function ToggleRadio()
	if Callsign.Value == "" then -- Check the Callsign StringValue instead of CallsignTextInput.Text
		Callsignnotsetwarninglabel.Visible = true
	else
		if TransmitButton.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
			TransmitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			RadioOff:Play()
		else
			TransmitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			RadioOn:Play()
		end
	end
end

-- Event Connections
chatMessageEvent.OnClientEvent:Connect(function(Message, Channel, color, isDispatch)
	local isPanicMessage = string.match(Message, "**PANIC BUTTON PRESSED**")
	-- Add player's message or dispatch/panic message
	AddRadioMessage(Message, Channel)
	
	if isPanicMessage then
		RadioFrame.Distress:Play()  -- Play distress sound for panic message
	elseif isDispatch then
		RadioFrame.DispatchSound:Play()  -- Play dispatch sound for dispatch message
	else
		MessageSound:Play()  -- Default message sound
	end
	UpdateGUI(color)  -- Pass the color to the UpdateGUI function
end)

LocalPlayer.Chatted:Connect(function(Message)
	if TransmitButton.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
		chatMessageEvent:FireServer(Message, CurrentChannel)
		TransmitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

TransmitButton.MouseButton1Click:Connect(ToggleRadio)

DistressButton.MouseButton1Click:Connect(function()
	ClickSound:Play()
	chatMessageEvent:FireServer("**PANIC BUTTON PRESSED**", CurrentChannel)
end)

CallsignSubmitButton.MouseButton1Click:Connect(function()
	SetCallSign(LocalPlayer) 
end)

HideCallSigUiButto.MouseButton1Click:Connect(function()
	if CallsignUi.Visible then
		CallsignUi.Visible = false
		HideCallSigUiButto.Text = "Show"
	else
		HideCallSigUiButto.Text = "Hide"
		CallsignUi.Visible = true
	end
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then return end
	if Input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	if Input.KeyCode == Enum.KeyCode.T then
		ToggleRadio()
	elseif Input.KeyCode == Enum.KeyCode.Y then
		SwitchChannel()
	end
end)
-- Set the initial channel when the script runs
SetInitialChannel()
-- Listen for channel changes and update the GUI
ChannelString:GetPropertyChangedSignal("Value"):Connect(function()
	CurrentChannel = ChannelString.Value
	ChannelTextLabel.Text = CurrentChannel
	FrequencyTextLabel.Text = TeamChannels.Frequencies[CurrentChannel]
	UpdateGUI()
end)
