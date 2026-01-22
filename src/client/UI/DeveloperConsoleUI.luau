--[[
	DeveloperConsoleUI - UI for the developer console
	Handles rendering, input, and output display
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local DeveloperConsole = require(script.Parent.Parent.Controllers.DeveloperConsole)

local DeveloperConsoleUI = {}

local screenGui = nil
local consoleFrame = nil
local outputScroll = nil
local inputField = nil
local historyIndex = 0
local consoleConnections = {}

-- Color mapping
local function getColorForLevel(level)
	return DeveloperConsole.Levels[level] or Color3.fromRGB(200, 200, 200)
end

-- Create console UI
function DeveloperConsoleUI.Create(parent)
	if screenGui then
		DeveloperConsoleUI.Close()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DeveloperConsole"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent
	
	-- Main console frame
	consoleFrame = Instance.new("Frame")
	consoleFrame.Name = "ConsoleFrame"
	consoleFrame.Size = UDim2.new(0, 800, 0, 500)
	consoleFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
	consoleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	consoleFrame.BorderSizePixel = 0
	consoleFrame.Parent = screenGui
	Instance.new("UICorner", consoleFrame).CornerRadius = UDim.new(0, 4)
	
	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 35)
	titleBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = consoleFrame
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = "◆ DEVELOPER CONSOLE"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.fromOffset(10, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Text = "✕"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 18
	closeButton.Size = UDim2.new(0, 35, 0, 35)
	closeButton.Position = UDim2.new(1, -35, 0, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.BorderSizePixel = 0
	closeButton.Parent = titleBar
	
	closeButton.MouseButton1Click:Connect(function()
		DeveloperConsoleUI.Close()
	end)
	
	-- Output scroll frame
	outputScroll = Instance.new("ScrollingFrame")
	outputScroll.Name = "OutputScroll"
	outputScroll.Size = UDim2.new(1, -20, 1, -90)
	outputScroll.Position = UDim2.fromOffset(10, 45)
	outputScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	outputScroll.BorderSizePixel = 0
	outputScroll.ScrollBarThickness = 6
	outputScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
	outputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	outputScroll.Parent = consoleFrame
	
	local outputLayout = Instance.new("UIListLayout")
	outputLayout.Padding = UDim.new(0, 2)
	outputLayout.Parent = outputScroll
	
	-- Input field
	local inputContainer = Instance.new("Frame")
	inputContainer.Name = "InputContainer"
	inputContainer.Size = UDim2.new(1, -20, 0, 35)
	inputContainer.Position = UDim2.new(0, 10, 1, -40)
	inputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	inputContainer.BorderSizePixel = 0
	inputContainer.Parent = consoleFrame
	Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 4)
	
	inputField = Instance.new("TextBox")
	inputField.Name = "InputField"
	inputField.Size = UDim2.new(1, -10, 1, -4)
	inputField.Position = UDim2.fromOffset(5, 2)
	inputField.BackgroundTransparency = 1
	inputField.TextColor3 = Color3.new(1, 1, 1)
	inputField.TextSize = 13
	inputField.Font = Enum.Font.Code
	inputField.PlaceholderText = "Enter command... (type 'help' for commands)"
	inputField.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	inputField.ClearTextOnFocus = false
	inputField.TextXAlignment = Enum.TextXAlignment.Left
	inputField.Parent = inputContainer
	
	-- Update canvas size function
	local function updateCanvasSize()
		outputScroll.CanvasSize = UDim2.new(0, 0, 0, outputLayout.AbsoluteContentSize.Y + 10)
		-- Auto-scroll to bottom
		task.spawn(function()
			task.wait()
			outputScroll.CanvasPosition = Vector2.new(0, outputScroll.CanvasSize.Y.Offset)
		end)
	end
	
	outputLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	
	-- Output entry creation
	local function createOutputEntry(entry)
		local entryFrame = Instance.new("Frame")
		entryFrame.Size = UDim2.new(1, -10, 0, 20)
		entryFrame.BackgroundTransparency = 1
		entryFrame.Parent = outputScroll
		
		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(0, 60, 0, 20)
		timeLabel.Position = UDim2.fromOffset(0, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = "[" .. entry.Timestamp .. "]"
		timeLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		timeLabel.Font = Enum.Font.Code
		timeLabel.TextSize = 11
		timeLabel.TextXAlignment = Enum.TextXAlignment.Left
		timeLabel.Parent = entryFrame
		
		local messageLabel = Instance.new("TextLabel")
		messageLabel.Size = UDim2.new(1, -70, 0, 20)
		messageLabel.Position = UDim2.fromOffset(65, 0)
		messageLabel.BackgroundTransparency = 1
		messageLabel.Text = entry.Message
		messageLabel.TextColor3 = getColorForLevel(entry.Level)
		messageLabel.Font = Enum.Font.Code
		messageLabel.TextSize = 12
		messageLabel.TextXAlignment = Enum.TextXAlignment.Left
		messageLabel.TextWrapped = true
		messageLabel.AutomaticSize = Enum.AutomaticSize.Y
		messageLabel.Parent = entryFrame
		
		-- Update entry frame height when message label resizes
		messageLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			entryFrame.Size = UDim2.new(1, -10, 0, math.max(20, messageLabel.AbsoluteSize.Y))
		end)
		
		updateCanvasSize()
	end
	
	-- Listen for new output
	table.insert(consoleConnections, DeveloperConsole.OutputChanged.Event:Connect(function(entry)
		createOutputEntry(entry)
	end))
	
	-- Listen for output cleared (destroy output Frames only; UIListLayout is not a Frame)
	table.insert(consoleConnections, DeveloperConsole.OutputCleared.Event:Connect(function()
		for _, child in ipairs(outputScroll:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		updateCanvasSize()
	end))
	
	-- Load existing output
	for _, entry in ipairs(DeveloperConsole.Output) do
		createOutputEntry(entry)
	end
	
	-- Input handling
	table.insert(consoleConnections, inputField.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local input = inputField.Text
			inputField.Text = ""
			historyIndex = 0
			DeveloperConsole.ExecuteCommand(input)
		end
	end))
	
	-- History navigation, Tab autocomplete, Escape to close
	table.insert(consoleConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not DeveloperConsole.IsOpen then return end
		
		if input.KeyCode == Enum.KeyCode.Escape then
			DeveloperConsoleUI.Close()
			return
		end
		
		-- Only handle these when input has focus (console open)
		local focused = UserInputService:GetFocusedTextBox()
		if focused ~= inputField then return end
		
		if input.KeyCode == Enum.KeyCode.Up then
			if #DeveloperConsole.History > 0 then
				historyIndex = math.min(historyIndex + 1, #DeveloperConsole.History)
				inputField.Text = DeveloperConsole.History[#DeveloperConsole.History - historyIndex + 1] or ""
			end
		elseif input.KeyCode == Enum.KeyCode.Down then
			if historyIndex > 0 then
				historyIndex = historyIndex - 1
				if historyIndex > 0 then
					inputField.Text = DeveloperConsole.History[#DeveloperConsole.History - historyIndex + 1] or ""
				else
					inputField.Text = ""
				end
			end
		elseif input.KeyCode == Enum.KeyCode.Tab then
			local text = inputField.Text
			local firstToken = text:match("^%s*(%S+)") or ""
			if firstToken ~= "" and not text:match("%s") then
				local suggestions = DeveloperConsole.GetAutocompleteSuggestions(firstToken)
				if #suggestions > 0 then
					inputField.Text = suggestions[1]
					inputField.CursorPosition = #suggestions[1] + 1
				end
			end
		end
	end))
	
	-- Focus input when console opens
	task.wait()
	inputField:CaptureFocus()
	
	DeveloperConsole.IsOpen = true
end

-- Close console
function DeveloperConsoleUI.Close()
	for _, c in ipairs(consoleConnections) do
		if c and c.Disconnect then c:Disconnect() end
	end
	table.clear(consoleConnections)
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	consoleFrame = nil
	outputScroll = nil
	inputField = nil
	DeveloperConsole.IsOpen = false
end

-- Toggle console
function DeveloperConsoleUI.Toggle()
	if DeveloperConsole.IsOpen then
		DeveloperConsoleUI.Close()
	else
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		DeveloperConsoleUI.Create(playerGui)
	end
end

return DeveloperConsoleUI
