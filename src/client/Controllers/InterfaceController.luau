local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Framework.Network)

local InterfaceController = {}
local hudGui = nil
local statusLabel = nil

function InterfaceController.Init()
	-- Disable default Roblox UI that interferes with FPS games
	GuiService.TouchControlsEnabled = false
	
	-- Create HUD
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "MatchHUD"
	hudGui.ResetOnSpawn = false
	hudGui.Parent = playerGui
	
	statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, 0, 0, 50)
	statusLabel.Position = UDim2.new(0, 0, 0, 100) -- Top center
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 24
	statusLabel.TextColor3 = Color3.new(1, 1, 1)
	statusLabel.TextStrokeTransparency = 0.5
	statusLabel.Text = "" -- Start empty
	statusLabel.Parent = hudGui
	
	-- Listen for Match Status (Match Progression)
	Network.OnClientEvent("MatchStatus", function(data)
		if data.State == "Warmup" then
			statusLabel.Text = "WARMUP: " .. tostring(data.Time or 0)
			statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		elseif data.State == "Match" then
			statusLabel.Text = "" -- Hide during match
		elseif data.State == "Victory" then
			statusLabel.Text = "VICTORY: " .. tostring(data.Winner)
			statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
		elseif data.State == "Draw" then
			statusLabel.Text = "DRAW"
			statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end)

	-- Listen for Matchmaking/Lobby updates
	local MatchmakingController = require(script.Parent.MatchmakingController)
	MatchmakingController.LobbyChanged.Event:Connect(function(state)
		-- Only show searching text if we are in the menu and not in an active match
		if state.Status == "Searching" or state.Status == "Waiting" then
			statusLabel.Text = string.format("Searching for players... %d / %d", state.PlayerCount or 0, state.MaxPlayers or 0)
			statusLabel.TextColor3 = Color3.new(1, 1, 1)
		end
	end)
end

function InterfaceController.Start()
	print("Interface Controller Started")
end

return InterfaceController