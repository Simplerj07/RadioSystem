local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChannelsModule = require(ReplicatedStorage:WaitForChild("ChannelsModule"))
local player = Players.LocalPlayer
local HandHeldUI = script.Parent.HandHeldUI
local RadioFrame = HandHeldUI.RadioFrame
local DeptName = RadioFrame.DeptChannel
local Frame = HandHeldUI.Frame
local UnitStates = RadioFrame.Unit
local TextButton = HandHeldUI.UnitSwitchButton
local onRadio = HandHeldUI.ONbutton
local Sound = HandHeldUI.Sound
local RS = HandHeldUI.RS
local InterfaceRadioUi = script.Parent.InterfaceRadioUI
local InterfaceRadioUiLocalScript = script.Parent.PlayerRadioClient
local Status = player:WaitForChild("Status")
local ChannelString = Status.Channel
local RadioONBoolvalue = Status.RadioON


local teamName = player.Team.Name
local TeamChannels = ChannelsModule.Channels[teamName] or ChannelsModule.Channels["Default"]
local Channels = TeamChannels.Default
local ChannelIndex = 1

-- Update DeptName label with team abbreviation
local function getTeamAbbreviation(teamName)
	local abbreviation = ""
	local words = {}
	for word in teamName:gmatch("%a+") do
		table.insert(words, word)
	end
	if #words == 1 then
		abbreviation = words[1]:upper()
	else
		for _, word in ipairs(words) do
			abbreviation = abbreviation .. word:sub(1, 1):upper()
		end
	end
	return abbreviation
end

DeptName.Text = getTeamAbbreviation(teamName)

local function TurnOnOffRadio()
	RadioFrame.Visible = not RadioFrame.Visible -- toggle visibility of RadioFrame
	Frame.BackgroundColor3 = RadioFrame.Visible and Color3.new(0.333333, 1, 0) or Color3.new(255, 0, 0)

	if RadioFrame.Visible then
		RS:Play()
		wait(2) -- wait for 2 seconds
		InterfaceRadioUiLocalScript.Enabled = true
		InterfaceRadioUi.Visible = true -- turn on the InterfaceRadioUi
		RadioONBoolvalue.Value = true

	else
		RadioONBoolvalue.Value = false
		InterfaceRadioUi.Visible = false -- turn off the InterfaceRadioUi
		InterfaceRadioUiLocalScript.Enabled = false
	end
end

local function SwitchChannelHandheld()
	if RadioONBoolvalue.Value then
		Sound:Play()
		ChannelIndex = ChannelIndex % #Channels + 1
		ChannelString.Value = Channels[ChannelIndex]
		InterfaceRadioUi.TopBar.TransmitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	else
		warn("Cannot switch channels while the radio is off.")
	end
end

onRadio.MouseButton1Click:Connect(TurnOnOffRadio)
TextButton.MouseButton1Click:Connect(SwitchChannelHandheld)

-- Listen for channel changes and update the handheld GUI
ChannelString:GetPropertyChangedSignal("Value"):Connect(function()
	UnitStates.Text = ChannelString.Value
end)
