loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local identifiedBots = {}
local notifiedPlayers = {}
local botList = {}
local selectedBot = nil
local selectedPlayer = "random"
local sayMessage = ""

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

local function generateBotText()
	local templates = {
		"I am a bot. Juice Potato Pop it",
		"I am a bot. Orange Juice Boombox",
		"I am a bot. Cool Roblox Local",
		"I am a bot. Name Player Robux"
	}
	local index = math.random(#templates)
	return templates[index]
end

local function showNotification(playerName)
	if not notifiedPlayers[playerName] then
		notifiedPlayers[playerName] = true
		Notification:Notify(
			{Title = "Syllinse автобот", Description = playerName .. ' Помечен как бот, это так ебать?"'},
			{OutlineColor = Color3.fromRGB(80, 80, 80), Time = 13, Type = "option"},
			{Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State)
				if State then
					print(playerName .. " ✅Является ботом")
					identifiedBots[playerName] = true
					if not table.find(botList, playerName) and playerName ~= localPlayer.Name then
						table.insert(botList, playerName)
						botDropdown:InsertOptions({playerName})
					end
				end
			end}
		)
	end
end

local function checkBotMessage(Msg, Player)
	if not notifiedPlayers[Player.Name] then
		for _, template in ipairs({
			"I am a bot. Juice Potato Pop it",
			"I am a bot. Orange Juice Boombox",
			"I am a bot. Cool Roblox Local",
			"I am a bot. Name Player Robux"
		}) do
			if Msg == template and not identifiedBots[Player.Name] then
				showNotification(Player.Name)
				break
			end
		end
	end
end

local chatEvents = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 10)
if chatEvents then
	local messageDoneFiltering = chatEvents:WaitForChild("OnMessageDoneFiltering", 10)
	if messageDoneFiltering then
		messageDoneFiltering.OnClientEvent:Connect(function(message)
			local player = players:FindFirstChild(message.FromSpeaker)
			local messageText = message.Message or ""

			if player then
				checkBotMessage(messageText, player)
			end
		end)
	else
		warn("Failed to find OnMessageDoneFiltering within the timeout period.")
	end
else
	warn("Failed to find DefaultChatSystemChatEvents within the timeout period.")
	for _, player in pairs(players:GetPlayers()) do
		player.Chatted:Connect(function(message)
			checkBotMessage(message, player)
		end)
	end
	players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			checkBotMessage(message, player)
		end)
	end)
end

local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
	Title = "Syllinse Beta",
	Subtitle = "Beta.nonstable-v1.00",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

local globalSettings = {
	UIBlurToggle = Window:GlobalSetting({
		Name = "UI Blur",
		Default = Window:GetAcrylicBlurState(),
		Callback = function(bool)
			Window:SetAcrylicBlurState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end,
	}),
	NotificationToggler = Window:GlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(bool)
			Window:SetNotificationsState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end,
	}),
	ShowUserInfo = Window:GlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(bool)
			Window:SetUserInfoState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end,
	})
}

local tabGroups = {
	TabGroup1 = Window:TabGroup()
}

local tabs = {
	Main = tabGroups.TabGroup1:Tab({ Name = "Demo", Image = "rbxassetid://18821914323" }),
	Settings = tabGroups.TabGroup1:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" }),
	Bots = tabGroups.TabGroup1:Tab({ Name = "Bots", Image = "rbxassetid://130840043704422" })
}

local sections = {
	MainSection1 = tabs.Main:Section({ Side = "Left" }),
	BotsSectionLeft = tabs.Bots:Section({ Side = "Left" }),
	BotsSectionRight = tabs.Bots:Section({ Side = "Right" }),
	SaySection = tabs.Bots:Section({ Side = "Right" })
}

sections.MainSection1:Header({
	Name = "Header #1"
})
sections.BotsSectionLeft:Header({
	Name = "Identify"
})
sections.BotsSectionRight:Header({
	Name = "Bang"
})
sections.SaySection:Header({
	Name = "BotSay"
})
sections.MainSection1:Button({
	Name = "Button",
	Callback = function()
		Window:Dialog({
			Title = Window.Settings.Title,
			Description = "Lorem ipsum odor amet, consectetuer adipiscing elit. Eros vestibulum aliquet mattis, ex platea nunc.",
			Buttons = {
				{
					Name = "Confirm",
					Callback = function()
						print("Confirmed!")
					end,
				},
				{
					Name = "Cancel"
				}
			}
		})
	end,
})

sections.MainSection1:Input({
	Name = "Input",
	Placeholder = "Input",
	AcceptedCharacters = "All",
	Callback = function(input)
		Window:Notify({
			Title = Window.Settings.Title,
			Description = "Successfully set input to " .. input
		})
	end,
	onChanged = function(input)
		print("Input is now " .. input)
	end,
}, "Input")

sections.MainSection1:Slider({
	Name = "Slider",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Percent",
	Precision = 0,
	Callback = function(Value)
		print("Changed to ".. Value)
	end
}, "Slider")

sections.MainSection1:Toggle({
	Name = "Toggle",
	Default = false,
	Callback = function(value)
		Window:Notify({
			Title = Window.Settings.Title,
			Description = (value and "Enabled " or "Disabled ") .. "Toggle"
		})
	end,
}, "Toggle")

sections.MainSection1:Keybind({
	Name = "Keybind",
	Blacklist = false,
	Callback = function(binded)
		Window:Notify({
			Title = "Demo Window",
			Description = "Pressed keybind - "..tostring(binded.Name),
			Lifetime = 3
		})
	end,
	onBinded = function(bind)
		Window:Notify({
			Title = "Demo Window",
			Description = "Successfully Binded Keybind to - "..tostring(bind.Name),
			Lifetime = 3
		})
	end,
}, "Keybind")

sections.MainSection1:Colorpicker({
	Name = "Colorpicker",
	Default = Color3.fromRGB(0, 255, 255),
	Callback = function(color)
		print("Color: ", color)
	end,
}, "Colorpicker")

local alphaColorPicker = sections.MainSection1:Colorpicker({
	Name = "Transparency Colorpicker",
	Default = Color3.fromRGB(255,0,0),
	Alpha = 0,
	Callback = function(color, alpha)
		print("Color: ", color, " Alpha: ", alpha)
	end,
}, "TransparencyColorpicker")

local rainbowActive
local rainbowConnection
local hue = 0

sections.MainSection1:Toggle({
	Name = "Rainbow",
	Default = false,
	Callback = function(value)
		rainbowActive = value

		if rainbowActive then
			rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
				hue = (hue + deltaTime * 0.1) % 1
				alphaColorPicker:SetColor(Color3.fromHSV(hue, 1, 1))
			end)
		elseif rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
		end
	end,
}, "RainbowToggle")

local optionTable = {
	"Apple",
	"Banana",
	"Orange",
	"Grapes",
	"Pineapple",
	"Mango",
	"Strawberry",
	"Blueberry",
	"Watermelon",
	"Peach"
}

local Dropdown = sections.MainSection1:Dropdown({
	Name = "Dropdown",
	Multi = false,
	Required = true,
	Options = optionTable,
	Default = 1,
	Callback = function(Value)
		print("Dropdown changed: ".. Value)
	end,
}, "Dropdown")

local MultiDropdown = sections.MainSection1:Dropdown({
	Name = "Multi Dropdown",
	Search = true,
	Multi = true,
	Required = false,
	Options = optionTable,
	Default = {"Apple", "Orange"},
	Callback = function(Value)
		local Values = {}
		for Value, State in next, Value do
			table.insert(Values, Value)
		end
		print("Mutlidropdown changed:", table.concat(Values, ", "))
	end,
}, "MultiDropdown")

sections.MainSection1:Button({
	Name = "Update Selection",
	Callback = function()
		Dropdown:UpdateSelection("Grapes")
		MultiDropdown:UpdateSelection({"Banana", "Pineapple"})
	end,
})

sections.MainSection1:Divider()

sections.MainSection1:Header({
	Text = "Header #2"
})

sections.MainSection1:Paragraph({
	Header = "Paragraph",
	Body = "Paragraph body. Lorem ipsum odor amet, consectetuer adipiscing elit. Morbi tempus netus aliquet per velit est gravida."
})

sections.MainSection1:Label({
	Text = "Label. Lorem ipsum odor amet, consectetuer adipiscing elit."
})

sections.MainSection1:SubLabel({
	Text = "Sub-Label. Lorem ipsum odor amet, consectetuer adipiscing элит."
})

-- Add bot names to the Bots tab
local botDropdown = sections.BotsSectionLeft:Dropdown({
	Name = "Bot List",
	Search = true,
	Multi = true,
	Required = false,
	Options = botList,
	Callback = function(Value)
		selectedBot = {}
		for bot, state in pairs(Value) do
			if state then
				table.insert(selectedBot, bot)
			end
		end
		print("Selected bots: " .. table.concat(selectedBot, ", "))
	end,
})

local function updateBotDropdown()
	botDropdown:ClearOptions()
	local currentPlayers = players:GetPlayers()
	local currentPlayerNames = {}
	for _, player in ipairs(currentPlayers) do
		table.insert(currentPlayerNames, player.Name)
	end

	for i = #botList, 1, -1 do
		if not table.find(currentPlayerNames, botList[i]) then
			table.remove(botList, i)
		end
	end

	botDropdown:InsertOptions(botList)
end

for _, player in pairs(players:GetPlayers()) do
	if not table.find(botList, player.Name) and player.Name ~= localPlayer.Name then
		table.insert(botList, player.Name)
	end
end

sections.BotsSectionLeft:Button({
	Name = "Reload",
	Callback = function()
		for i = #botList, 1, -1 do
			if not identifiedBots[botList[i]] then
				table.remove(botList, i)
			end
		end
		updateBotDropdown()
		selectedBot = nil
	end,
})

sections.BotsSectionLeft:Button({
	Name = "Identify",
	Callback = function()
		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Identify", "All")
	end,
})

local speedValue = 50
sections.BotsSectionRight:Slider({
	Name = "Speed",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 0,
	Callback = function(Value)
		speedValue = Value
		print("Speed set to ".. Value)
	end
}, "Speed")

local playerList = {"random"}
for _, player in pairs(players:GetPlayers()) do
	table.insert(playerList, player.Name)
end

local bangPlayerDropdown = sections.BotsSectionRight:Dropdown({
	Name = "Player List",
	Multi = false,
	Required = true,
	Options = playerList,
	Callback = function(Value)
		selectedPlayer = Value
		print("Selected player: " .. Value)
	end,
})

sections.BotsSectionRight:Button({
	Name = "Bang",
	Callback = function()
		local playerName = selectedPlayer == "random" and "r" or selectedPlayer
		local message = string.format("Gang, %s, %d", playerName, speedValue)
		if selectedBot and #selectedBot > 0 then
			for _, bot in ipairs(selectedBot) do
				if bot and bot ~= "" then
					game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/whisper " .. bot .. " " .. message, "All")
				end
			end
		else
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
		end
	end,
})

sections.BotsSectionRight:Button({
	Name = "UnBang",
	Callback = function()
		local message = "unbang"
		if selectedBot and #selectedBot > 0 then
			for _, bot in ipairs(selectedBot) do
				if bot and bot ~= "" then
					game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/whisper " .. bot .. " " .. message, "All")
				end
			end
		else
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
		end
	end,
})

sections.SaySection:Input({
	Name = "SayMessage",
	Placeholder = "Enter message",
	AcceptedCharacters = "All",
	Callback = function(input)
		sayMessage = input
		print("Say message set to: " .. input)
	end,
	onChanged = function(input)
		sayMessage = input
		print("Say message changed to: " .. input)
	end,
}, "Say")

sections.SaySection:Button({
	Name = "Send",
	Callback = function()
		local message = "Say, " .. sayMessage
		if selectedBot and #selectedBot > 0 then
			for _, bot in ipairs(selectedBot) do
				if bot and bot ~= "" then
					game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/whisper " .. bot .. " " .. message, "All")
				end
			end
		else
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
		end
	end,
})

sections.SaySection:Button({
	Name = "SyllinseAD",
	Callback = function()
		local message = "Say, Syllinse BotNetwork on top!"
		if selectedBot and #selectedBot > 0 then
			for _, bot in ipairs(selectedBot) do
				if bot and bot ~= "" then
					game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/whisper " .. bot .. " " .. message, "All")
				end
			end
		else
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
		end
	end,
})

local loopBSayActive = false
local loopBSayMessage = ""
local loopBSayInterval = 5
local loopBSayAmount = 1
local loopBSayConnection

local function stopLoopBSay()
	if loopBSayConnection then
		loopBSayConnection:Disconnect()
		loopBSayConnection = nil
	end
end

local function startLoopBSay()
	if loopBSayActive and loopBSayMessage ~= "" then
		local messageCount = 0
		loopBSayConnection = task.spawn(function()
			while loopBSayActive do
				for i = 1, loopBSayAmount do
					if not loopBSayActive then break end
					local message = "Say, " .. loopBSayMessage
					if selectedBot and #selectedBot > 0 then
						for _, bot in ipairs(selectedBot) do
							if bot and bot ~= "" then
								game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/whisper " .. bot .. " " .. message, "All")
							end
						end
					else
						game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
					end
					messageCount = messageCount + 1
				end
				task.wait(loopBSayInterval)
			end
			stopLoopBSay()
		end)
	end
end

local loopBSaySection = tabs.Bots:Section({ Side = "Left" })

loopBSaySection:Header({
	Name = "LoopBotSay"
})

loopBSaySection:Toggle({
	Name = "LoopBSay",
	Default = false,
	Callback = function(value)
		loopBSayActive = value
		if loopBSayActive then
			startLoopBSay()
		else
			stopLoopBSay()
		end
	end,
}, "LoopBSay")

loopBSaySection:Input({
	Name = "LoopBSayMessage",
	Placeholder = "Enter message",
	AcceptedCharacters = "All",
	Callback = function(input)
		loopBSayMessage = input
		print("LoopBSay message set to: " .. input)
	end,
	onChanged = function(input)
		loopBSayMessage = input
		print("LoopBSay message changed to: " .. input)
	end,
}, "LoopBSayMessage")

loopBSaySection:Slider({
	Name = "Interval",
	Default = 5,
	Minimum = 1,
	Maximum = 60,
	DisplayMethod = "Value",
	Precision = 0,
	Callback = function(Value)
		loopBSayInterval = Value
		print("LoopBSay interval set to ".. Value)
	end
}, "Interval")

loopBSaySection:Slider({
	Name = "Amount",
	Default = 1,
	Minimum = 1,
	Maximum = 10,
	DisplayMethod = "Value",
	Precision = 0,
	Callback = function(Value)
		loopBSayAmount = Value
		print("LoopBSay amount set to ".. Value)
	end
}, "Amount")

MacLib:SetFolder("Maclib")
tabs.Settings:InsertConfigSection("Left")

Window.onUnloaded(function()
	print("Unloaded!")
end)

tabs.Main:Select()
MacLib:LoadAutoLoadConfig()
