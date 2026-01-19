# Gamepasses & Monetization

This document outlines the strategy and implementation for Gamepasses and other monetization features within the project.

## Overview

Gamepasses provide permanent benefits to players for a one-time Robux purchase. In this project, we aim to offer value-driven, non-"pay-to-win" perks that enhance the user experience.

## Key Principles (2025-2026 Best Practices)

- **Value-Based Pricing**: Price passes according to their perceived benefit.
- **Variety**: Offer a range of price points (e.g., Starter Pack, VIP, Elite).
- **Non-Intrusive Promotion**: Use in-game UI and subtle environmental cues rather than aggressive pop-ups.
- **Fair Play**: Avoid locking core gameplay mechanics behind a paywall. Focus on convenience, cosmetics, and progression accelerators.

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
