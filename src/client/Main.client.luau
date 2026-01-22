local Controllers = {}
local LoadingScreen = require(script.Parent:WaitForChild("UI"):WaitForChild("LoadingScreen"))

-- Show loading screen immediately
LoadingScreen.Create()
LoadingScreen.SetProgress(0, "Initializing...")

-- Prevent character from falling while loading
game:GetService("Players").LocalPlayer:SetAttribute("InMenu", true)

local function Start()
	local controllersFolder = script.Parent:WaitForChild("Controllers")
	local interfaceFolder = script.Parent:WaitForChild("Interface")
	
	-- Calculate total work for accurate progress
	local controllerModules = {}
	
	-- Wait for any initial children (sometimes replication is slightly delayed)
	if #controllersFolder:GetChildren() == 0 then
		controllersFolder.ChildAdded:Wait()
	end
	
	for _, module in ipairs(controllersFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			table.insert(controllerModules, module)
		end
	end
	
	local totalWork = #controllerModules * 3 + 2 -- Each controller: require, init, start + Menu require + Menu start
	local completedWork = 0
	
	-- Update progress helper
	local function updateProgress(status, increment)
		increment = increment or 1
		completedWork = completedWork + increment
		local progress = math.min(95, (completedWork / totalWork) * 100)
		LoadingScreen.SetProgress(progress, status)
	end
	
	-- Step 1: Require all Controllers (0-30%)
	LoadingScreen.SetProgress(5, "Loading Controllers...")
	for _, module in ipairs(controllerModules) do
		local success, controller = pcall(require, module)
		if success then
			Controllers[module.Name] = controller
			updateProgress("Loaded " .. module.Name)
		else
			warn("[Client] Failed to require controller: " .. module.Name .. " Error: " .. tostring(controller))
			updateProgress("Warning: " .. module.Name .. " failed")
		end
		task.wait() -- Yield to show progress
	end
	
	-- Step 2: Initialize (Init) (30-60%)
	LoadingScreen.SetProgress(35, "Initializing Systems...")
	for name, controller in pairs(Controllers) do
		if type(controller.Init) == "function" then
			local success, err = pcall(function() controller:Init() end)
			if not success then
				warn("[Client] Failed to Init controller: " .. name .. " Error: " .. tostring(err))
			end
			updateProgress("Initialized " .. name)
			task.wait() -- Yield to show progress
		end
	end
	
	-- Initialize UI systems
	task.spawn(function()
		local UI = script.Parent:WaitForChild("UI")
		local GameplayHUD = require(UI:WaitForChild("GameplayHUD"))
		local WeaponController = require(script.Parent:WaitForChild("Controllers"):WaitForChild("WeaponController"))
		
		-- Initialize HUD and Weapon Controller
		GameplayHUD.Init()
		WeaponController.Init()
		
		-- Connect WeaponController to HUD
		WeaponController.WeaponStateChanged:Connect(function(state)
			GameplayHUD.UpdateAmmo(state.Ammo, state.Reserve, state.MaxAmmo, state.MaxReserve)
			GameplayHUD.UpdateWeaponName(state.Weapon)
			GameplayHUD.UpdateReloadProgress(state.ReloadProgress or 0, state.IsReloading or false)
		end)
		
		-- Connect movement state to HUD (wait for character)
		local player = game:GetService("Players").LocalPlayer
		local function setupCharacterConnections(character)
			if not character then return end
			
			-- Movement state
			character:GetAttributeChangedSignal("MovementState"):Connect(function()
				local state = character:GetAttribute("MovementState")
				GameplayHUD.UpdateMovementState(state)
			end)
			
			-- Health monitoring
			local humanoid = character:WaitForChild("Humanoid", 5)
			if humanoid then
				humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					GameplayHUD.UpdateHealth(humanoid.Health, humanoid.MaxHealth)
				end)
				-- Initial health update
				GameplayHUD.UpdateHealth(humanoid.Health, humanoid.MaxHealth)
			end
		end
		
		-- Setup for existing character or wait for spawn
		if player.Character then
			setupCharacterConnections(player.Character)
		end
		player.CharacterAdded:Connect(setupCharacterConnections)
		
		updateProgress("UI Systems Initialized")
	end)
	
	-- Step 3: Start Controllers (60-80%)
	LoadingScreen.SetProgress(65, "Starting Systems...")
	for name, controller in pairs(Controllers) do
		if type(controller.Start) == "function" then
			task.spawn(function()
				local success, err = pcall(function() controller:Start() end)
				if not success then
					warn("[Client] Failed to Start controller: " .. name .. " Error: " .. tostring(err))
				end
			end)
			updateProgress("Started " .. name)
			task.wait() -- Yield to show progress
		end
	end
	
	-- Step 4: Start Menu (80-95%)
	LoadingScreen.SetProgress(85, "Loading Menu Interface...")
	local MenuControllerModule = interfaceFolder:WaitForChild("MenuController")
	local success, MenuController = pcall(require, MenuControllerModule)
	if success then
		updateProgress("Menu Module Loaded")
		task.wait()
		
		task.spawn(function()
			local menuSuccess, menuErr = pcall(function()
				MenuController.Start()
			end)
			if not menuSuccess then
				warn("[Client] Failed to Start MenuController: " .. tostring(menuErr))
			end
		end)
		updateProgress("Menu Initialized")
	else
		warn("[Client] Failed to load MenuController: " .. tostring(MenuController))
		updateProgress("Menu Failed")
	end

	-- Complete (95-100%)
	LoadingScreen.SetProgress(100, "Ready!")
	task.wait(0.5) -- Brief pause to show 100%
	LoadingScreen.Hide()
	
	-- Initialize Developer Console
	task.spawn(function()
		local DeveloperConsole = require(script.Parent.Controllers.DeveloperConsole)
		local DeveloperConsoleUI = require(script.Parent.UI.DeveloperConsoleUI)
		local GameCommands = require(script.Parent.Controllers.GameCommands)
		
		-- Register all game commands
		GameCommands.RegisterAll()
		
		-- Setup console toggle (I key)
		local UserInputService = game:GetService("UserInputService")
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			
			if input.KeyCode == Enum.KeyCode.I then
				DeveloperConsoleUI.Toggle()
			end
		end)
		
		-- Listen for server responses
		local Network = require(ReplicatedStorage.Framework.Network)
		Network.OnClientEvent("DevResponse", function(response)
			if response.Command == "playerdata_get" then
				if response.Field then
					DeveloperConsole.Log("INFO", response.Field .. ": " .. tostring(response.Value))
				elseif response.Data then
					DeveloperConsole.Log("INFO", "=== PLAYER DATA ===")
					for key, value in pairs(response.Data) do
						if type(value) ~= "table" then
							DeveloperConsole.Log("INFO", key .. ": " .. tostring(value))
						end
					end
				end
			elseif response.Success then
				DeveloperConsole.Log("SUCCESS", "Command executed successfully")
				if response.Field and response.Value ~= nil then
					DeveloperConsole.Log("INFO", response.Field .. " = " .. tostring(response.Value))
				end
			end
		end)
		
		print("[Client] Developer Console initialized (Keybind: I)")
	end)
	
	print("[Client] All Controllers Initialized")
end

task.spawn(Start)
