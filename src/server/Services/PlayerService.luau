local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)

local PlayerService = {}

function PlayerService.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerService.OnPlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		PlayerService.OnPlayerRemoving(player)
	end)
end

function PlayerService.OnPlayerAdded(player)
	print("Player joined: " .. player.Name)
	DataService.LoadData(player)
	
	-- Force spawn location "Way Higher" (Y=1000)
	player.CharacterAdded:Connect(function(character)
		-- Wait for root part
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)
		if rootPart then
			-- Pivot to high altitude to avoid baseplate clipping
			character:PivotTo(CFrame.new(0, 1000, 0))
		end
	end)
end

function PlayerService.OnPlayerRemoving(player)
	print("Player leaving: " .. player.Name)
	DataService.SaveData(player)
end

return PlayerService