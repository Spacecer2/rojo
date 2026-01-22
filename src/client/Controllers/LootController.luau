--!strict
-- src/client/Controllers/LootController.luau
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LootData = require(ReplicatedStorage.Shared.Constants.LootData)
local LootHUD = require(ReplicatedStorage.Shared.UI.LootHUD) -- Will create this next

local ClientToServerEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClientToServer")
local ServerToClientEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ServerToClient")

local requestPickupRemote = ClientToServerEvents:WaitForChild("RequestPickup")
local lootPickedUpEvent = ServerToClientEvents:WaitForChild("LootPickedUp")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local LootController = {}

local currentNearestLoot: Model? = nil
local activeLootItems: {Model} = {} -- Stores loot models that are currently active in the world

local function updateNearestLoot()
    local nearestDistSq = math.huge
    local nearestLootCandidate: Model? = nil

    local charPos = humanoidRootPart.Position
    local interactDistance = LootData.InteractionDistance

    -- Remove any destroyed loot items from activeLootItems
    for i = #activeLootItems, 1, -1 do
        if not activeLootItems[i] or not activeLootItems[i].Parent then
            LootHUD.RemoveLootUI(activeLootItems[i])
            table.remove(activeLootItems, i)
        end
    end

    -- Find all loot models in the workspace (this might need optimization for very large maps)
    -- For now, iterate through a known folder. Later, use spatial partitioning.
    local serverLootFolder = Workspace:FindFirstChild("ServerLoot")
    if serverLootFolder then
        for _, lootModel in ipairs(serverLootFolder:GetChildren()) do
            if lootModel:IsA("Model") and lootModel.PrimaryPart then
                local distSq = (lootModel.PrimaryPart.Position - charPos).Magnitude^2
                if distSq <= (LootData.UIVisibleDistance + 5)^2 then -- Within UI visible range + some buffer
                    if not table.find(activeLootItems, lootModel) then
                        table.insert(activeLootItems, lootModel)
                        LootHUD.AddLootUI(lootModel) -- Add UI for newly discovered loot
                    end
                end
                
                if distSq < nearestDistSq and distSq <= interactDistance^2 then
                    nearestDistSq = distSq
                    nearestLootCandidate = lootModel
                end
            end
        end
    end

    if nearestLootCandidate ~= currentNearestLoot then
        if currentNearestLoot then
            LootHUD.HidePickupPrompt(currentNearestLoot)
        end
        currentNearestLoot = nearestLootCandidate
        if currentNearestLoot then
            LootHUD.ShowPickupPrompt(currentNearestLoot)
        end
    end
end

local function onPickupAction(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
    if inputState == Enum.UserInputState.Begin then
        if currentNearestLoot then
            -- Request server to pick up the item
            requestPickupRemote:FireServer(currentNearestLoot)
            LootHUD.HidePickupPrompt(currentNearestLoot) -- Hide immediately, server will confirm
            currentNearestLoot = nil -- Clear nearest, as we've requested pickup
            return Enum.ContextActionResult.Sink -- Consume input
        end
    end
    return Enum.ContextActionResult.Pass
end

local function onLootPickedUp(pickedUpLootModel: Model)
    -- Server confirmed pickup, remove UI and stop tracking
    LootHUD.RemoveLootUI(pickedUpLootModel)
    local index = table.find(activeLootItems, pickedUpLootModel)
    if index then
        table.remove(activeLootItems, index)
    end
    if currentNearestLoot == pickedUpLootModel then
        currentNearestLoot = nil
    end
end

function LootController.Init()
    -- Bind pickup key
    ContextActionService:BindAction(
        "PickupLoot",
        onPickupAction,
        false, -- Don't create touch button
        LootData.PickupKeybind
    )
    
    -- Connect to server event for loot picked up
    lootPickedUpEvent.OnClientEvent:Connect(onLootPickedUp)

    -- Update nearest loot every frame
    RunService.Heartbeat:Connect(updateNearestLoot)

    print("LootController Initialized.")
end

return LootController
