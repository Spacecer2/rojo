# Luau Language Reference

Modern scripting language for Roblox game development.

## 📖 Overview

Luau is a dynamically-typed scripting language used in Roblox. It extends Lua with type annotations, improved performance, and modern syntax.

## Core Language Features

### Variables & Types
```lua
-- Dynamic typing
local number: number = 42
local text: string = "Hello"
local flag: boolean = true
local none: nil = nil

-- Tables (dictionaries/arrays)
local array = {1, 2, 3}
local dict = {name = "Player", score = 100}

-- Functions
local function add(a: number, b: number): number
    return a + b
end

-- Lambda functions
local multiply = function(a, b) return a * b end
```

### Control Flow
```lua
-- If statements
if condition then
    -- code
elseif other_condition then
    -- code
else
    -- code
end

-- Loops
for i = 1, 10 do
    print(i)
end

for i, value in ipairs(array) do
    print(i, value)
end

while condition do
    -- code
end

repeat
    -- code
until condition
```

### Object-Oriented Programming
```lua
local Class = {}
Class.__index = Class

function Class.new(name)
    local self = setmetatable({}, Class)
    self.name = name
    return self
end

function Class:Method()
    print(self.name)
end

local instance = Class.new("Example")
instance:Method()
```

## Type Annotations

### Basic Types
```lua
local integer: number = 5
local decimal: number = 3.14
local text: string = "text"
local logic: boolean = true
local null: nil = nil
```

### Union Types
```lua
local maybe: string | nil = "value"
local flexible: number | string = 42
```

### Table Types
```lua
local point: {x: number, y: number} = {x = 10, y = 20}
local mixed: {number} = {1, 2, 3}
```

### Function Types
```lua
local callback: (number) -> string = function(n)
    return tostring(n)
end

local handler: (...any) -> nil = function(...)
    print(...)
end
```

## Common Operations

### String Operations
```lua
local str = "Hello"
local len = #str  -- length
local concat = str .. " World"  -- concatenation
local upper = string.upper(str)
local lower = string.lower(str)
local sub = string.sub(str, 1, 2)
```

### Table Operations
```lua
local t = {1, 2, 3}
table.insert(t, 4)  -- add at end
table.remove(t, 1)  -- remove at index
local size = #t
table.sort(t)
table.concat(t, ", ")
```

### Type Checking
```lua
local t = type(value)  -- "number", "string", "table", etc.
local is_instance = typeof(value)  -- Roblox-specific types
```

## Best Practices

1. **Use type annotations** - Helps catch errors early
2. **Prefer local variables** - Faster and safer than globals
3. **Use meaningful names** - Self-documenting code
4. **Handle errors with pcall** - Prevent script crashes

```lua
local success, result = pcall(function()
    return someRiskyOperation()
end)

if success then
    print("Result:", result)
else
    print("Error:", result)
end
```

5. **Use events and signals** - Decouple systems with events

```lua
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({_bindable = Instance.new("BindableEvent")}, Signal)
end

function Signal:Connect(callback)
    return self._bindable.Event:Connect(callback)
end

function Signal:Fire(...)
    self._bindable:Fire(...)
end
```

## Resources

- [Official Luau Documentation](https://luau-lang.org)
- [Roblox Luau API](https://create.roblox.com/docs/en-us/reference/engine/libraries)
- [Type Annotations Guide](https://create.roblox.com/docs/en-us/scripting/lua/type-annotations)

---

**See Also:**
- [Services Reference](#services-reference) for built-in Roblox services
- [RemoteEvents & Functions](#networking) for client-server communication
