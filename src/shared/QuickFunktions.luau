--[[
	QuickFunktions.luau - Common utility functions for Roblox development
	Referenced from local documentation and engine patterns.
]]

local QuickFunktions = {}

-- === SERVICES ===
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- === TWEEN HELPERS ===

--- Create a simple position/color tween with optional looping
function QuickFunktions.Tween(instance, duration, goal, options)
	options = options or {}
	local tweenInfo = TweenInfo.new(
		duration,
		options.easingStyle or Enum.EasingStyle.Quad,
		options.easingDirection or Enum.EasingDirection.Out,
		options.repeatCount or 0,
		options.reverses or false,
		options.delayTime or 0
	)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	if options.autoPlay ~= false then
		tween:Play()
	end
	return tween
end

--- SmoothDamp wrapper for spring-like interpolation
function QuickFunktions.SmoothDamp(current, target, velocity, smoothTime, maxSpeed, dt)
	return TweenService:SmoothDamp(current, target, velocity, smoothTime, maxSpeed, dt)
end

-- === INSTANCE HELPERS ===

--- Safely set an attribute with type guard
function QuickFunktions.SetAttribute(instance, name, value)
	if instance and instance.SetAttribute then
		instance:SetAttribute(name, value)
	end
end

--- Get an attribute with fallback
function QuickFunktions.GetAttribute(instance, name, fallback)
	if instance and instance.GetAttribute then
		local val = instance:GetAttribute(name)
		return val ~= nil and val or fallback
	end
	return fallback
end

--- Ensure a model has a PrimaryPart by finding any BasePart
function QuickFunktions.EnsurePrimaryPart(model)
	if model.PrimaryPart then return true end
	local part = model:FindFirstChildWhichIsA("BasePart", true)
	if part then
		model.PrimaryPart = part
		return true
	end
	return false
end

--- Configure all BaseParts in a model (anchor, collisions, etc.)
function QuickFunktions.ConfigureParts(model, config)
	config = config or {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if config.Anchored ~= nil then descendant.Anchored = config.Anchored end
			if config.CanCollide ~= nil then descendant.CanCollide = config.CanCollide end
			if config.CanQuery ~= nil then descendant.CanQuery = config.CanQuery end
			if config.CanTouch ~= nil then descendant.CanTouch = config.CanTouch end
			if config.Massless ~= nil then descendant.Massless = config.Massless end
		end
	end
end

-- === RUNSERVICE BINDING ===

--- Bind a function to PreRender with priority
function QuickFunktions.BindToRender(name, priority, func)
	return RunService:BindToRenderStep(name, priority, func)
end

--- Unbind a render step function by name
function QuickFunktions.UnbindFromRender(name)
	RunService:UnbindFromRenderStep(name)
end

-- === PLAYER HELPERS ===

--- Get the local player safely
function QuickFunktions.GetLocalPlayer()
	return Players.LocalPlayer
end

--- Check if running on client
function QuickFunktions.IsClient()
	return RunService:IsClient()
end

--- Check if running on server
function QuickFunktions.IsServer()
	return RunService:IsServer()
end

--- Check if in Studio
function QuickFunktions.IsStudio()
	return RunService:IsStudio()
end

-- === MATH/VECTOR HELPERS ===

--- Clamp a Vector3 within bounds
function QuickFunktions.ClampVector3(v, min, max)
	return Vector3.new(
		math.clamp(v.X, min.X, max.X),
		math.clamp(v.Y, min.Y, max.Y),
		math.clamp(v.Z, min.Z, max.Z)
	)
end

--- Linear interpolation between two Vector3s
function QuickFunktions.LerpVector3(a, b, t)
	return a:Lerp(b, t)
end

--- Safe CFrame look-at with up vector
function QuickFunktions.LookAt(from, to, up)
	up = up or Vector3.new(0, 1, 0)
	return CFrame.lookAt(from, to, up)
end

-- === DEBUG/LOGGING ===

--- Conditional print based on a flag
function QuickFunktions.DebugPrint(flag, ...)
	-- selene: allow(global_usage)
	if _G.DEBUG and _G.DEBUG[flag] then
		print("[DEBUG:" .. flag .. "]", ...)
	end
end

--- Warn with context
function QuickFunktions.Warn(context, ...)
	warn("[" .. (context or "WARN") .. "]", ...)
end

-- === CLEANUP ===

--- Cleanly destroy an instance and its connections
function QuickFunktions.Cleanup(instance)
	if instance then
		if instance.Disconnect then
			instance:Disconnect()
		elseif instance.Destroy then
			instance:Destroy()
		end
	end
end

return QuickFunktions
