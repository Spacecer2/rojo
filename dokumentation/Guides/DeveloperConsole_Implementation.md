# Developer Console Implementation Guide

## Overview

A sophisticated in-game terminal for game development with:
- Command execution with autocomplete
- Error logging and stack traces  
- Variable inspection
- Performance monitoring
- Command history with navigation
- Copy-to-clipboard support
- Formatted output with color coding
- Advanced search and filtering

## Architecture

```
DeveloperConsole/
├── DeveloperConsole.luau          # Core console logic & command registry
├── DeveloperConsoleUI.luau        # UI rendering & input handling
├── CommandRegistry.luau           # Command definitions & validation
└── init.luau                      # Integration point
```

## Core Components

### 1. DeveloperConsole Module

**Location:** `src/client/DeveloperConsole.luau`

**Responsibilities:**
- Command execution
- Output logging
- History management
- Autocomplete suggestions
- Filtering & searching

**Key API:**
```lua
DeveloperConsole.RegisterCommand(name, callback, description, syntax, examples)
DeveloperConsole.ExecuteCommand(input)
DeveloperConsole.Log(level, message, data)
DeveloperConsole.GetAutocompleteSuggestions(input)
DeveloperConsole.GetFormattedOutput(filter)
DeveloperConsole.CopyToClipboard(text)
```

**Output Levels:**
- `INFO` - General information (200,200,200)
- `WARNING` - Warning messages (255,200,0)
- `ERROR` - Errors (255,100,100)
- `SUCCESS` - Success confirmations (100,255,100)
- `DEBUG` - Debug output (100,200,255)

### 2. DeveloperConsoleUI Module

**Location:** `src/client/DeveloperConsole/DeveloperConsoleUI.luau`

**Responsibilities:**
- Render console window
- Handle user input
- Display output with formatting
- Autocomplete dropdown
- Command history navigation

**Features:**
- **Input Field**: Text input with syntax highlighting
- **Output Panel**: Scrollable output display with colors
- **Autocomplete**: Dropdown showing command suggestions
- **History**: Arrow keys to navigate command history
- **Copy Button**: Right-click to copy entries to clipboard
- **Filter Tabs**: Switch between Info/Errors/All
- **Search**: Search through output history

### 3. CommandRegistry Module

**Location:** `src/client/DeveloperConsole/CommandRegistry.luau`

**Built-in Commands:**

#### Navigation & Help
- `help [command]` - Show available commands or specific help
- `clear` - Clear console output
- `history [num]` - Show last N commands

#### Debugging
- `vars [filter]` - Inspect game variables (player, character, etc.)
- `perf` - Show performance statistics
- `errors` - Show only error messages
- `all` - Show all messages
- `warn` - Show only warnings

#### Development
- `find <name>` - Search for instances in workspace
- `info <instance>` - Get detailed info about instance
- `test <command>` - Run unit tests
- `profile` - Start performance profiling
- `memory` - Show memory usage

#### Network
- `network` - Show network stats
- `lag <ms>` - Add artificial lag for testing
- `packet` - Show packet info

## Implementation Steps

### Step 1: Create DeveloperConsole.luau

Core module with command registry and logging:

```lua
local DeveloperConsole = {
    Enabled = true,
    History = {},
    Commands = {},
    Output = {},
    IsOpen = false
}

function DeveloperConsole.RegisterCommand(name, callback, description, syntax, examples)
    DeveloperConsole.Commands[name:lower()] = {
        Name = name,
        Callback = callback,
        Description = description,
        Syntax = syntax,
        Examples = examples
    }
end

function DeveloperConsole.Log(level, message, data)
    table.insert(DeveloperConsole.Output, {
        Level = level,
        Message = message,
        Data = data,
        Timestamp = os.date("%H:%M:%S")
    })
end

function DeveloperConsole.ExecuteCommand(input)
    -- Parse and execute command
end

return DeveloperConsole
```

### Step 2: Create DeveloperConsoleUI.luau

UI rendering with input handling:

```lua
local DeveloperConsoleUI = {}

function DeveloperConsoleUI.Create(parent)
    -- Create console GUI
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "DeveloperConsole"
    consoleFrame.Size = UDim2.fromScale(0.6, 0.7)
    consoleFrame.Position = UDim2.fromScale(0.2, 0.15)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    consoleFrame.BorderSizePixel = 0
    consoleFrame.Parent = parent
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
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
        DeveloperConsoleUI.Close()
    end)
    
    -- Output panel
    local outputScroll = Instance.new("ScrollingFrame")
    outputScroll.Size = UDim2.new(1, 0, 1, -90)
    outputScroll.Position = UDim2.fromOffset(0, 40)
    outputScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    outputScroll.BorderSizePixel = 0
    outputScroll.ScrollBarThickness = 8
    outputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputScroll.Parent = consoleFrame
    
    -- Input field
    local inputField = Instance.new("TextBox")
    inputField.Name = "InputField"
    inputField.Size = UDim2.new(1, -20, 0, 40)
    inputField.Position = UDim2.fromOffset(10, consoleFrame.AbsoluteSize.Y - 50)
    inputField.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    inputField.TextColor3 = Color3.new(1, 1, 1)
    inputField.TextSize = 14
    inputField.Font = Enum.Font.Courier
    inputField.PlaceholderText = "Enter command... (type 'help' for commands)"
    inputField.ClearTextOnFocus = false
    inputField.Parent = consoleFrame
    
    -- Input handling
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = inputField.Text
            inputField.Text = ""
            DeveloperConsole.ExecuteCommand(input)
        end
    end)
    
    return consoleFrame
end

return DeveloperConsoleUI
```

### Step 3: Integration

**In `src/client/Main.client.luau`:**

```lua
local DeveloperConsole = require(ReplicatedStorage:WaitForChild("DeveloperConsole"))
local DeveloperConsoleUI = require(ReplicatedStorage:WaitForChild("DeveloperConsole"):WaitForChild("DeveloperConsoleUI"))

-- Register the console UI open keybind (P key for power)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        if not DeveloperConsole.IsOpen then
            local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            DeveloperConsoleUI.Create(playerGui)
            DeveloperConsole.IsOpen = true
        end
    end
end)
```

## Command Examples

### Help System
```
> help
=== AVAILABLE COMMANDS ===
  help - Show command help
  clear - Clear console output
  history - Show command history
  ...

> help find
=== find ===
Description: Search for instances in workspace
Syntax: find <name> [parent]
Examples:
  > find Baseplate
  > find Enemy Workspace.Enemies
```

### Debugging Commands
```
> vars
=== PLAYER VARIABLES ===
Name: Player1
UserId: 123456789
Character: Character
  Health: 100/100

> perf
=== PERFORMANCE STATS ===
Workspace Model Count: 125
Memory Usage: 248 MB
FPS: 60

> errors
[Filter: Errors only]
[14:23:45] ✕ LoadoutService failed: Invalid ID
[14:25:12] ✕ Movement: NaN velocity detected
```

### Development Commands
```
> find Enemy
✓ Found 3 instances:
  - Workspace > Enemies > Enemy1
  - Workspace > Enemies > Enemy2
  - Workspace > Enemies > Enemy3

> info Workspace.Enemies.Enemy1
=== Instance Info ===
ClassName: Model
Children: 5 (Humanoid, HumanoidRootPart, etc.)
Parent: Workspace.Enemies
Health: 50/100
```

## Advanced Features

### 1. Autocomplete
```
User types: "hel"
Suggestions dropdown shows:
  - help
  - helper_command

Press Tab or arrow key to select
```

### 2. History Navigation
```
User presses Up arrow: Previous command recalled
User presses Down arrow: Next command recalled
Max 100 commands stored in history
```

### 3. Copy to Clipboard
```
Right-click on error:
✕ LoadoutService failed: Invalid ID

[Copy Error] [Copy Full Stack]
Copies to clipboard for pasting into bug reports
```

### 4. Filtering & Search
```
Filter tabs at top:
[All Messages] [Errors Only] [Warnings] [Debug]

Search box:
"Search output..." > "weapon" 
Shows only lines mentioning "weapon"
```

### 5. Color-Coded Output
```
✓ Command executed successfully  (Green)
✕ Error occurred                  (Red)
⚠ Warning message               (Yellow)
ℹ Info message                   (Gray)
◆ Debug output                   (Light Blue)
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `P` | Toggle console open/close |
| `Up/Down` | Navigate command history |
| `Tab` | Autocomplete current command |
| `Ctrl+C` | Copy selected line |
| `Ctrl+L` | Clear all output |
| `Ctrl+A` | Select all in input |
| `Escape` | Close console |

## Performance Considerations

1. **Output Limit**: Keep only last 1000 entries
2. **Lazy Rendering**: Only render visible output lines
3. **Event Debouncing**: Throttle rapid logging
4. **Memory**: Clear old entries periodically

## Testing

```lua
-- Register test command
DeveloperConsole.RegisterCommand(
    "test_console",
    function()
        DeveloperConsole.Log("SUCCESS", "Test passed!")
        return "Console working"
    end,
    "Test the console system",
    "test_console",
    { "test_console" }
)

-- Usage
> test_console
✓ Test passed!
```

## Future Enhancements

- Live code execution (Lua sandbox)
- Breakpoints and stepping
- Network packet inspection
- Custom watch expressions
- Plugin system for commands
- Settings persistence
- Profiling integration
- Asset browser

## Integration Checklist

- [ ] Create `DeveloperConsole.luau`
- [ ] Create `DeveloperConsoleUI.luau`
- [ ] Add keyboard input handler (P key)
- [ ] Register built-in commands
- [ ] Add to `Main.client.luau`
- [ ] Test command execution
- [ ] Test autocomplete
- [ ] Test history navigation
- [ ] Test output filtering
- [ ] Deploy to game

