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
    -- Limit output to 1000 entries
    if #DeveloperConsole.Output > 1000 then
        table.remove(DeveloperConsole.Output, 1)
    end
end

function DeveloperConsole.ExecuteCommand(input)
    if not input or input == "" then return end
    
    table.insert(DeveloperConsole.History, input)
    if #DeveloperConsole.History > 100 then
        table.remove(DeveloperConsole.History, 1)
    end
    
    local args = input:split(" ")
    local commandNamePart = table.remove(args, 1)
    if not commandNamePart then return end
    local commandName = commandNamePart:lower()
    
    local command = DeveloperConsole.Commands[commandName]
    if command and command.Callback then
        local success, result = pcall(function()
            return (command.Callback :: any)(unpack(args))
        end)
        if success then
            if result ~= nil then
                DeveloperConsole.Log("SUCCESS", tostring(result :: any))
            end
        else
            DeveloperConsole.Log("ERROR", "Command failed: " .. tostring(result :: any or "Unknown error"))
        end
    else
        DeveloperConsole.Log("ERROR", "Unknown command: " .. commandName)
    end
end

-- Register built-in commands
DeveloperConsole.RegisterCommand(
    "help",
    function(cmdName)
        if cmdName then
            local cmd = DeveloperConsole.Commands[cmdName:lower()]
            if cmd then
                DeveloperConsole.Log("INFO", "=== " .. cmd.Name .. " ===")
                DeveloperConsole.Log("INFO", "Description: " .. cmd.Description)
                DeveloperConsole.Log("INFO", "Syntax: " .. cmd.Syntax)
                return nil
            end
        end
        
        DeveloperConsole.Log("INFO", "=== AVAILABLE COMMANDS ===")
        for name, cmd in pairs(DeveloperConsole.Commands) do
            DeveloperConsole.Log("INFO", "  " .. name .. " - " .. cmd.Description)
        end
        return nil
    end,
    "Show available commands or specific help",
    "help [command]",
    {"help", "help clear"}
)

DeveloperConsole.RegisterCommand(
    "clear",
    function()
        table.clear(DeveloperConsole.Output)
        return "Console cleared"
    end,
    "Clear console output",
    "clear",
    {"clear"}
)

DeveloperConsole.RegisterCommand(
    "history",
    function()
        DeveloperConsole.Log("INFO", "=== COMMAND HISTORY ===")
        for i, cmd in ipairs(DeveloperConsole.History) do
            DeveloperConsole.Log("INFO", string.format("%d: %s", i, cmd))
        end
        return nil
    end,
    "Show command history",
    "history",
    {"history"}
)

DeveloperConsole.RegisterCommand(
    "find",
    function(name)
        if not name then return "Usage: find <name>" end
        local results = {}
        for _, child in ipairs(workspace:GetDescendants()) do
            if child.Name:lower():find(name:lower()) then
                table.insert(results, child:GetFullName())
            end
            if #results >= 10 then break end
        end
        
        DeveloperConsole.Log("INFO", string.format("Found %d matches:", #results))
        for _, path in ipairs(results) do
            DeveloperConsole.Log("INFO", "  " .. path)
        end
        return #results > 0 and "Search complete" or "No matches found"
    end,
    "Search for instances in workspace",
    "find <name>",
    {"find Baseplate"}
)

DeveloperConsole.RegisterCommand(
    "info",
    function(path)
        if not path then return "Usage: info <path>" end
        -- Very basic path resolver
        local segments = path:split(".")
        local current = game
        for _, seg in ipairs(segments) do
            current = current:FindFirstChild(seg)
            if not current then break end
        end

        if not current then return "Instance not found" end
        
        DeveloperConsole.Log("INFO", "=== Instance Info ===")
        DeveloperConsole.Log("INFO", "Name: " .. current.Name)
        DeveloperConsole.Log("INFO", "Class: " .. current.ClassName)
        DeveloperConsole.Log("INFO", "Parent: " .. tostring(current.Parent))
        return nil
    end,
    "Get basic info about an instance",
    "info <path>",
    {"info Workspace.Baseplate"}
)

DeveloperConsole.RegisterCommand(
    "perf",
    function()
        local Stats = game:GetService("Stats")
        DeveloperConsole.Log("INFO", "=== PERFORMANCE ===")
        DeveloperConsole.Log("INFO", string.format("Memory: %.2f MB", Stats:GetTotalMemoryUsageMb()))
        DeveloperConsole.Log("INFO", string.format("Heartbeat: %.2f FPS", 1/game:GetService("RunService").Heartbeat:Wait()))
        return nil
    end,
    "Show performance statistics",
    "perf",
    {"perf"}
)

return DeveloperConsole
