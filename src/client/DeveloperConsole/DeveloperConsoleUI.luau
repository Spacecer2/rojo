local DeveloperConsole = require(script.Parent)

local DeveloperConsoleUI = {
    _instance = nil
}

local COLORS = {
    INFO = Color3.fromRGB(200, 200, 200),
    WARNING = Color3.fromRGB(255, 200, 0),
    ERROR = Color3.fromRGB(255, 100, 100),
    SUCCESS = Color3.fromRGB(100, 255, 100),
    DEBUG = Color3.fromRGB(100, 200, 255),
    Background = Color3.fromRGB(20, 20, 25),
    TitleBar = Color3.fromRGB(0, 162, 255),
    InputBackground = Color3.fromRGB(40, 40, 45)
}

function DeveloperConsoleUI.Create(parent)
    if DeveloperConsoleUI._instance then return DeveloperConsoleUI._instance end

    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "DeveloperConsole"
    consoleFrame.Size = UDim2.fromScale(0.6, 0.7)
    consoleFrame.Position = UDim2.fromScale(0.2, 0.15)
    consoleFrame.BackgroundColor3 = COLORS.Background
    consoleFrame.BorderSizePixel = 0
    consoleFrame.ClipsDescendants = false
    consoleFrame.Parent = parent
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = COLORS.TitleBar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = consoleFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "◆ DEVELOPER CONSOLE"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Parent = titleBar

    -- Dragging Logic
    local dragging = false
    local dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = consoleFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            consoleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Size = UDim2.fromOffset(40, 40)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        DeveloperConsoleUI.Toggle()
    end)
    
    -- Output panel
    local outputScroll = Instance.new("ScrollingFrame")
    outputScroll.Name = "OutputScroll"
    outputScroll.Size = UDim2.new(1, -20, 1, -100)
    outputScroll.Position = UDim2.fromOffset(10, 50)
    outputScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    outputScroll.BorderSizePixel = 0
    outputScroll.ScrollBarThickness = 6
    outputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputScroll.Parent = consoleFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = outputScroll

    local function createLogEntry(entry)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = string.format("[%s] %s", entry.Timestamp, entry.Message)
        label.TextColor3 = COLORS[entry.Level] or COLORS.INFO
        label.Font = Enum.Font.Code
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = outputScroll
        
        outputScroll.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y)
        outputScroll.CanvasPosition = Vector2.new(0, math.max(0, listLayout.AbsoluteContentSize.Y - outputScroll.AbsoluteSize.Y))
    end

    -- Initial logs
    for _, entry in ipairs(DeveloperConsole.Output) do
        createLogEntry(entry)
    end

    -- Listen for new logs
    local lastCount = #DeveloperConsole.Output
    task.spawn(function()
        while consoleFrame.Parent do
            if #DeveloperConsole.Output > lastCount then
                for i = lastCount + 1, #DeveloperConsole.Output do
                    createLogEntry(DeveloperConsole.Output[i])
                end
                lastCount = #DeveloperConsole.Output
            elseif #DeveloperConsole.Output < lastCount then
                -- Cleared
                for _, child in ipairs(outputScroll:GetChildren()) do
                    if child:IsA("TextLabel") then child:Destroy() end
                end
                lastCount = #DeveloperConsole.Output
            end
            task.wait(0.1)
        end
    end)
    
    -- Input field
    local inputField = Instance.new("TextBox")
    inputField.Name = "InputField"
    inputField.Size = UDim2.new(1, -20, 0, 30)
    inputField.Position = UDim2.new(0, 10, 1, -40)
    inputField.BackgroundColor3 = COLORS.InputBackground
    inputField.TextColor3 = Color3.new(1, 1, 1)
    inputField.TextSize = 14
    inputField.Font = Enum.Font.Code
    inputField.PlaceholderText = "Enter command..."
    inputField.ClearTextOnFocus = false
    inputField.TextXAlignment = Enum.TextXAlignment.Left
    inputField.Parent = consoleFrame
    
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = inputField.Text
            if input ~= "" then
                DeveloperConsole.ExecuteCommand(input)
                inputField.Text = ""
            end
            task.wait()
            inputField:CaptureFocus()
        end
    end)

    -- Resize Handle
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(15, 15)
    resizeHandle.Position = UDim2.new(1, -15, 1, -15)
    resizeHandle.BackgroundColor3 = COLORS.TitleBar
    resizeHandle.BackgroundTransparency = 0.5
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = consoleFrame

    local resizing = false
    local resizeStart, startSize

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = consoleFrame.AbsoluteSize
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newSizeX = math.max(300, startSize.X + delta.X)
            local newSizeY = math.max(200, startSize.Y + delta.Y)
            consoleFrame.Size = UDim2.fromOffset(newSizeX, newSizeY)
        end
    end)
    
    DeveloperConsoleUI._instance = consoleFrame
    return consoleFrame
end

function DeveloperConsoleUI.Toggle()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local console = playerGui:FindFirstChild("DeveloperConsoleGui")
    
    if not console then
        console = Instance.new("ScreenGui")
        console.Name = "DeveloperConsoleGui"
        console.ResetOnSpawn = false
        console.DisplayOrder = 100
        console.Parent = playerGui
        
        DeveloperConsoleUI.Create(console)
        DeveloperConsole.IsOpen = true
        
        local inputField = DeveloperConsoleUI._instance:FindFirstChild("InputField", true)
        if inputField then inputField:CaptureFocus() end
    else
        console.Enabled = not console.Enabled
        DeveloperConsole.IsOpen = console.Enabled
        
        if console.Enabled then
            local inputField = DeveloperConsoleUI._instance:FindFirstChild("InputField", true)
            if inputField then inputField:CaptureFocus() end
        end
    end
end

return DeveloperConsoleUI
