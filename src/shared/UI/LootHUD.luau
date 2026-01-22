--!strict
-- src/shared/UI/LootHUD.luau
-- This module creates, updates, and destroys the BillboardGui elements
-- that display loot information above items in the world.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LootData = require(ReplicatedStorage.Shared.Constants.LootData)
local Theme = require(ReplicatedStorage.Shared.Constants.Theme) -- Assuming a Theme module for consistent UI colors/fonts

local LootHUD = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LootUIsFolder = Instance.new("Folder")
LootUIsFolder.Name = "LootUIs"
LootUIsFolder.Parent = PlayerGui

local activeLootGUIs: {[Model]: BillboardGui} = {}

local FONT_GLOBAL = Enum.Font.GothamBold -- Use a consistent font from Theme or define here
local ATTACHMENT_ICON_ID = "rbxassetid://6250684126" -- Placeholder for a generic attachment icon

local function createLootBillboard(lootModel: Model): BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LootBillboard_" .. lootModel.Name
    billboard.Size = UDim2.new(0, 200, 0, 100) -- Base size, will adjust dynamically
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, lootModel.PrimaryPart.Size.Y / 2 + 1, 0) -- Position above the part
    billboard.StudsOffset = Vector3.new(0, lootModel.PrimaryPart.Size.Y / 2 + 1, 0)
    billboard.MaxDistance = LootData.UIVisibleDistance
    billboard.Parent = LootUIsFolder -- Parent to a folder in PlayerGui for organization

    local itemName = lootModel:GetAttribute("ItemName")
    local rarity = lootModel:GetAttribute("Rarity")
    local itemType = lootModel:GetAttribute("ItemType")
    local attachmentIds = lootModel:GetAttribute("AttachmentIds") or {}
    local lootRarityData = LootData.Rarities[rarity] or LootData.Rarities.Common

    -- Background Frame
    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "Background"
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundTransparency = 0.4
    bgFrame.BackgroundColor3 = Theme.Color.DarkGrey -- Using theme color
    bgFrame.BorderSizePixel = 0
    bgFrame.CornerRadius = UDim.new(0, 4)
    bgFrame.Parent = billboard

    -- Item Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemNameLabel"
    nameLabel.Text = itemName
    nameLabel.Size = UDim2.new(1, -10, 0.4, 0)
    nameLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
    nameLabel.AnchorPoint = Vector2.new(0.5, 0)
    nameLabel.Font = FONT_GLOBAL
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = lootRarityData.Color
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextWrapped = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = bgFrame

    -- Attachments Indicator (for Weapons)
    if itemType == LootData.ItemTypes.Weapon and #attachmentIds > 0 then
        local attachmentsFrame = Instance.new("Frame")
        attachmentsFrame.Name = "AttachmentsFrame"
        attachmentsFrame.Size = UDim2.new(1, -10, 0.3, 0)
        attachmentsFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
        attachmentsFrame.AnchorPoint = Vector2.new(0.5, 0)
        attachmentsFrame.BackgroundTransparency = 1
        attachmentsFrame.Parent = bgFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = attachmentsFrame

        for i = 1, math.min(#attachmentIds, 5) do -- Limit to 5 attachment icons
            local icon = Instance.new("ImageLabel")
            icon.Name = "AttachmentIcon" .. i
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Image = ATTACHMENT_ICON_ID -- Generic icon for now
            icon.BackgroundTransparency = 1
            icon.Parent = attachmentsFrame
        end
    end

    -- Pickup Prompt
    local pickupPrompt = Instance.new("TextLabel")
    pickupPrompt.Name = "PickupPrompt"
    pickupPrompt.Text = "[" .. UserInputService:GetStringForKeyCode(LootData.PickupKeybind) .. "] Pick Up"
    pickupPrompt.Size = UDim2.new(1, -10, 0.25, 0)
    pickupPrompt.Position = UDim2.new(0.5, 0, 0.7, 0)
    pickupPrompt.AnchorPoint = Vector2.new(0.5, 0)
    pickupPrompt.Font = FONT_GLOBAL
    pickupPrompt.TextScaled = true
    pickupPrompt.TextColor3 = Theme.Color.Primary -- Use theme color for interaction prompt
    pickupPrompt.BackgroundTransparency = 1
    pickupPrompt.TextWrapped = true
    pickupPrompt.TextXAlignment = Enum.TextXAlignment.Center
    pickupPrompt.Visible = false -- Initially hidden
    pickupPrompt.Parent = bgFrame
    
    billboard.Adornee = lootModel.PrimaryPart -- Adorn to the primary part of the loot model

    return billboard
end

function LootHUD.AddLootUI(lootModel: Model)
    if activeLootGUIs[lootModel] then return end

    local billboard = createLootBillboard(lootModel)
    activeLootGUIs[lootModel] = billboard
end

function LootHUD.RemoveLootUI(lootModel: Model)
    local billboard = activeLootGUIs[lootModel]
    if billboard then
        billboard:Destroy()
        activeLootGUIs[lootModel] = nil
    end
end

function LootHUD.ShowPickupPrompt(lootModel: Model)
    local billboard = activeLootGUIs[lootModel]
    if billboard then
        local pickupPrompt = billboard:FindFirstChild("Background"):FindFirstChild("PickupPrompt")
        if pickupPrompt then
            pickupPrompt.Visible = true
        end
    end
end

function LootHUD.HidePickupPrompt(lootModel: Model)
    local billboard = activeLootGUIs[lootModel]
    if billboard then
        local pickupPrompt = billboard:FindFirstChild("Background"):FindFirstChild("PickupPrompt")
        if pickupPrompt then
            pickupPrompt.Visible = false
        end
    end
end

return LootHUD
