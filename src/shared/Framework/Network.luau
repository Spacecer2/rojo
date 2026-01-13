local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = {}
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

function Network.GetRemote(name, type)
	local remote = Remotes:FindFirstChild(name)
	if not remote and RunService:IsServer() then
		remote = Instance.new(type or "RemoteEvent")
		remote.Name = name
		remote.Parent = Remotes
	end
	return remote
end

function Network.FireServer(name, ...)
	local remote = Network.GetRemote(name)
	if remote then
		remote:FireServer(...)
	end
end

function Network.FireClient(player, name, ...)
	local remote = Network.GetRemote(name)
	if remote then
		remote:FireClient(player, ...)
	end
end

function Network.OnServerEvent(name, callback)
	local remote = Network.GetRemote(name)
	if remote then
		return remote.OnServerEvent:Connect(callback)
	end
end

function Network.OnClientEvent(name, callback)
	local remote = Network.GetRemote(name)
	if remote then
		return remote.OnClientEvent:Connect(callback)
	end
end

return Network