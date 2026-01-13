local Controllers = {}

local function Start()
	local controllersFolder = script.Parent:WaitForChild("Controllers")
	local interfaceFolder = script.Parent:WaitForChild("Interface")
	
	-- 1. Require all Controllers
	for _, module in ipairs(controllersFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local success, controller = pcall(require, module)
			if success then
				Controllers[module.Name] = controller
			else
				warn("[Client] Failed to require controller: " .. module.Name .. " Error: " .. tostring(controller))
			end
		end
	end

	-- 2. Initialize (Init)
	for name, controller in pairs(Controllers) do
		if type(controller.Init) == "function" then
			local success, err = pcall(function() controller:Init() end)
			if not success then
				warn("[Client] Failed to Init controller: " .. name .. " Error: " .. tostring(err))
			end
		end
	end

	-- 3. Start
	for name, controller in pairs(Controllers) do
		if type(controller.Start) == "function" then
			task.spawn(function()
				local success, err = pcall(function() controller:Start() end)
				if not success then
					warn("[Client] Failed to Start controller: " .. name .. " Error: " .. tostring(err))
				end
			end)
		end
	end
	
	-- Start Menu
	local MenuControllerModule = interfaceFolder:WaitForChild("MenuController")
	local success, MenuController = pcall(require, MenuControllerModule)
	if success then
		task.spawn(function()
			MenuController.Start()
		end)
	else
		warn("[Client] Failed to load MenuController: " .. tostring(MenuController))
	end
	
	print("[Client] All Controllers Initialized")
end

task.spawn(Start)