--[[
	ViewManager - Scalable view management system
	Handles switching between different menu views (PLAY, WEAPONS, etc.)
]]
local ViewManager = {}

local container = nil
local views = {}
local currentView = nil

function ViewManager.SetContainer(frame)
	container = frame
end

function ViewManager.RegisterView(name, viewModule)
	views[name] = viewModule
end

function ViewManager.SwitchTo(viewName)
	if not container then
		warn("[ViewManager] Container not set!")
		return
	end
	
	-- Hide current view
	if currentView then
		if typeof(currentView) == "Instance" or (type(currentView) == "table" and currentView.Destroy) then
			currentView:Destroy()
		end
		currentView = nil
	end
	
	-- Show new view with error handling
	local viewModule = views[viewName]
	if viewModule then
		local success, result = pcall(function()
			if viewModule.Create then
				return viewModule.Create(container)
			elseif type(viewModule) == "function" then
				return viewModule(container)
			else
				warn("[ViewManager] View " .. viewName .. " has invalid format")
				return nil
			end
		end)
		
		if success and result then
			currentView = result
		else
			warn("[ViewManager] Failed to create view " .. viewName .. ": " .. tostring(result))
			-- Create error placeholder
			local errorFrame = Instance.new("Frame")
			errorFrame.Name = "ErrorView"
			errorFrame.Size = UDim2.fromScale(1, 1)
			errorFrame.BackgroundTransparency = 1
			errorFrame.Parent = container
			
			local errorLabel = Instance.new("TextLabel")
			errorLabel.Text = "Error loading " .. viewName .. " view"
			errorLabel.Font = Enum.Font.GothamBold
			errorLabel.TextSize = 18
			errorLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
			errorLabel.Size = UDim2.new(1, 0, 0, 50)
			errorLabel.Position = UDim2.fromScale(0, 0.5)
			errorLabel.AnchorPoint = Vector2.new(0, 0.5)
			errorLabel.BackgroundTransparency = 1
			errorLabel.Parent = errorFrame
			
			currentView = errorFrame
		end
	else
		warn("[ViewManager] View " .. viewName .. " not registered")
	end
end

function ViewManager.GetCurrentView()
	return currentView
end

return ViewManager
