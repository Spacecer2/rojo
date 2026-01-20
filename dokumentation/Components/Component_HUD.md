# Component: HUD System

Technical documentation for the HUD system, primarily managed by `InterfaceController`.

**Related Docs:**
- [Feature Spec](../Features/Systems/PlayerHUD.md) - Functional Requirements
- [Design Spec](../Design/Design_HUD.md) - UX & Layout

---

## 🏗️ Architecture

The HUD is a client-side system managed by `InterfaceController.luau`. It uses a **Single ScreenGui** approach with multiple Frames for different layers to minimize draw calls and simplify z-index management.

### File Structure
```lua
src/client/
├── Controllers/
│   └── InterfaceController.luau  -- Main entry point
├── UI/
│   ├── Components/
│   │   ├── HUD/
│   │   │   ├── Minimap.luau
│   │   │   ├── AmmoCounter.luau
│   │   │   └── HealthBar.luau
│   │   └── Common/               -- Shared buttons/labels
│   └── Styles/                   -- Theme & Color definitions
```

## 🧩 Component Hierarchy

The `ScreenGui` ("WarzoneHUD") contains:

1.  **Underlay** (ZIndex: 1): Vignettes, Blood Overlays.
2.  **WorldLayer** (ZIndex: 10): 3D Markers projected to screen (Objectives, Pings).
3.  **StaticLayer** (ZIndex: 20): Minimap, Ammo, Health, Squad List.
4.  **Overlay** (ZIndex: 100): Fullscreen menus (Pause, Inventory), Notifications (Level Up).

## 💾 State Management

The HUD is **Reactive**. It listens to specific signals rather than polling in `RenderStepped`.

| State Source | Event | UI Component Updated |
|--------------|-------|----------------------|
| `WeaponController` | `AmmoChanged` | AmmoCounter, WeaponIcon |
| `Character` (Attribute) | `HealthChanged` | HealthBar, BloodOverlay |
| `MatchService` | `MatchStatus` | Scoreboard, Timer |
| `InputService` | `InputChanged` | InteractionPrompts |

## 🚀 Performance Optimizations

1.  **Visible Property**: We toggle `Visible = false` for entire sub-trees (e.g., `SquadList`) when not in use, rather than destroying/recreating instances.
2.  **TextBounds Caching**: Heavy text layout calculations are cached or pre-calculated where possible.
3.  **Event Throttling**: Updates to "Distance to Objective" (WorldLayer) are throttled to 15-30Hz instead of running every frame, as pixel-perfect precision isn't needed for distant markers.

## 🛠️ API Reference

### `InterfaceController`

```lua
-- Shows/Hides specific HUD elements
function InterfaceController:SetVisible(componentName: string, isVisible: boolean)

-- Push a notification to the feed
function InterfaceController:Notify(title: string, message: string, icon: string)

-- Updates the gamemode layout (BR vs MP)
function InterfaceController:SetLayout(mode: "BattleRoyale" | "Multiplayer")
```

---

**Next Steps**:
- Implement individual components in `src/client/UI/Components/HUD/`.
