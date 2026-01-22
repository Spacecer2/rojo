# Gamepasses & Monetization

## System Design & Vision

This document outlines the strategy and implementation for Gamepasses and other monetization features within the project. Our overarching vision is to create a sustainable revenue model that supports continuous development and content creation, while rigidly adhering to "non-pay-to-win" principles. We believe that monetization should enhance, not detract from, the player experience.

## Key Principles (2025-2026 Best Practices)

Our monetization strategy is built on the following core principles:

-   **Value-Driven & Fair Play**: All Gamepasses and purchasable items are designed to offer clear, tangible value without providing any direct gameplay advantages. We are committed to a strict "no pay-to-win" policy, ensuring that skill and strategy remain the sole determinants of success in the game.
-   **Enhanced User Experience**: Monetization features should primarily focus on convenience, cosmetic personalization, and accelerated progression. This allows players to customize their experience or save time, while keeping core gameplay accessible to everyone.
-   **Variety and Accessibility**: We aim to offer a range of price points and benefits (e.g., Starter Packs, VIP, XP Boosters) to cater to different player budgets and preferences. This ensures broad accessibility to our monetization offerings.
-   **Non-Intrusive Promotion**: Monetization will be integrated thoughtfully into the game's UI and progression systems, utilizing subtle environmental cues and clear menu navigation rather than aggressive or disruptive pop-ups.
-   **Sustainable Development**: The revenue generated from these monetization efforts directly funds the game's long-term development, including new content, features, and ongoing maintenance, ensuring a vibrant and evolving game environment.

## Implementation Guide

### MarketplaceService Wrapper

We use a central `MarketplaceService` wrapper to handle purchase prompts and ownership checks consistently.

#### Checking Ownership
```lua
local MarketplaceService = game:GetService("MarketplaceService")
local success, ownsPass = pcall(function()
    return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
end)
```

#### Handling Purchases
Purchases should be handled server-side using `ProcessReceipt` for Developer Products, but for Gamepasses, we listen to `PromptGamePassPurchaseFinished`.

### Proposed Gamepasses

| Name | Description | Suggested Price |
|------|-------------|-----------------|
| **VIP Access** | Special chat tag, unique operator skin, and XP boost. | 400 - 800 Robux |
| **XP Booster** | Permanent 1.2x XP multiplier. | 250 Robux |
| **Starter Bundle** | Instant unlock of a mid-tier weapon and 5,000 Currency. | 150 - 300 Robux |

## Integration with DataService

Gamepass benefits should be integrated into `DataService.UpdateClient` and relevant gameplay systems. Ownership should be checked upon player join and whenever a benefit is accessed.

```lua
-- Example: Applying XP Boost from Gamepass
function DataService.AddXP(player, amount)
    local pData = sessionData[player.UserId]
    if pData then
        if pData.OwnsXPBoostPass then
            amount = amount * 1.2
        end
        -- ... rest of logic
    end
end
```
