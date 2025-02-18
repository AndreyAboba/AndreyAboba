local players = game:GetService("Players")
local identifiedBots = {}
local notifiedPlayers = {}
local botList = {}

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

-- Function to generate specific text with random templates
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

-- Function to show a notification with Yes and No buttons
local function showNotification(playerName)
	if not notifiedPlayers[playerName] then
		Notification:Notify(
			{Title = "Syllinse автобот", Description = playerName .. ' Помечен как бот, это так ебать?"'},
			{OutlineColor = Color3.fromRGB(80, 80, 80), Time = 13, Type = "option"},
			{Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State)
				if State then
					print(playerName .. " ✅Является ботом")
					identifiedBots[playerName] = true
					table.insert(botList, playerName)
				end
			end}
		)
		notifiedPlayers[playerName] = true
	end
end

-- Function to check if a message matches any bot text template
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

-- Connect to the chat event to check messages
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
	-- Universal fallback method
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

-- Function to print the bot list every 5 seconds
local function printBotList()
	while true do
		wait(5)
		print("Identified Bots: " .. table.concat(botList, ", "))
	end
end

-- Start printing the bot list
spawn(printBotList)
