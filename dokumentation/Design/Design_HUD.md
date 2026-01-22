# Player HUD – Development Specification

## 1. Purpose & Scope

The Player HUD provides real-time tactical feedback to the player during gameplay without obstructing situational awareness. This document defines what is rendered, when it is rendered, and how it behaves, independent of art polish.

This spec focuses on:
*   Runtime behavior and visibility rules
*   Data inputs and update frequency
*   Layout anchors and layering
*   Accessibility and configuration hooks

Visual polish and final art are defined elsewhere. This document is the source of truth for HUD logic and structure.

## 2. Core Design Principles (Translated for Development)

| Principle | Implementation Rule |
| :--- | :--- |
| **Tactical Clarity** | No HUD element may overlap the reticle’s inner 15% screen radius |
| **Context Sensitivity** | Elements must subscribe to game state and self-hide when inactive |
| **MW2019 Authenticity** | Flat UI, minimal outlines, subtle animation only on state change |
| **Accessibility** | All colors, scale, and motion must be user-configurable |

## 3. Coordinate System & Safe Zones

*   **Rendering Space:** Screen-space (resolution independent)
*   **Safe Zone Margin:** 10% inset from each screen edge (user-adjustable)
*   **Anchoring System:**
    *   Top-Center
    *   Center
    *   Bottom-Left
    *   Bottom-Right

**All HUD widgets must:**
*   Anchor to a safe-zone edge
*   Scale uniformly with HUD scale setting
*   Support aspect ratios from 16:9 to 21:9

## 4. HUD Layer Model

The HUD is divided into functional layers with explicit draw priority.

**Layer Order (Back → Front):**
1.  State Layer (persistent match info)
2.  Self Layer (player status)
3.  Action Layer (reticle-adjacent feedback)
4.  Critical Alerts (damage, downed, death)

## 5. State Layer (Top-Center)

### 5.1 Compass Widget
*   **Anchor:** Top-Center
*   **Update Rate:** Per-frame rotation, tick events on fire

**Inputs:**
*   Player yaw
*   Enemy fire direction events

**Behavior:**
*   Linear tape scrolls horizontally
*   Only cardinal directions rendered (N, E, S, W)
*   **Enemy fire:**
    *   Displays red tick at relative bearing
    *   Auto-fades after short duration

**Visibility Rules:**
*   Always visible
*   Fire ticks hidden if no hostile fire received

### 5.2 Match Info Widget

**Modes:**
*   Multiplayer
*   Warzone

**Multiplayer:**
*   Score A vs B
*   Match timer

**Warzone:**
*   Players alive
*   Kills
*   Spectators

**Rules:**
*   Mode determines layout at runtime
*   No animation except numeric change easing
*   No icons unless required for clarity

## 6. Action Layer (Center / Reticle Zone)

### 6.1 Hitmarker System
*   **Trigger:** Damage confirmed event

**Behavior:**
*   Instant pop (≤ 1 frame delay)
*   Fade-out over short duration
*   Optional sound hook

**Variants:**
*   Normal hit
*   Armor hit
*   Kill confirm

### 6.2 Interaction Prompt
*   **Trigger:** Player enters interactable range (Highest-priority interactable only)

**Data:**
*   Input binding (dynamic)
*   Action verb
*   Target name (optional)

**Rules:**
*   Centered just below reticle
*   **Hidden if:**
    *   No valid interactable
    *   Player is downed
    *   Player is in non-interactive state (e.g., stunned)

### 6.3 Grenade Indicator
*   **Trigger:** Live grenade within danger radius

**Behavior:**
*   Arc points toward grenade origin
*   Intensity scales with proximity
*   Auto-removes when threat expires

## 7. Self Layer (Bottom Corners)

### 7.1 Health & Armor (Bottom-Left)

**Multiplayer:**
*   Health auto-regenerates
*   Numeric display optional
*   Damage feedback primarily via screen effects

**Warzone:**
*   Armor plates rendered as segmented bars
*   Color-coded (default: blue)
*   Depletion animates per segment

**Critical State (HP < 30%):**
*   Red pulse overlay
*   Optional audio cue

### 7.2 Squad Panel
*   **Layout:** Vertical list (top to bottom)
*   **Max visible members:** squad size

**Per Member:**
*   Name
*   Health/armor bar
*   **Status icon:**
    *   Downed
    *   Dead
    *   Reviving
    *   Disconnected

**Rules:**
*   Always visible in squad-based modes
*   Collapses entirely in solo modes

### 7.3 Weapon & Ammo (Bottom-Right)

**Weapon:**
*   Current weapon silhouette
*   Updates on weapon swap

**Ammo:**
*   Magazine count (large, bold)
*   Reserve count (small, muted)

**Behavior:**
*   Ammo flashes or pulses when low
*   Mechanical “dry fire” cue on empty

### 7.4 Equipment

**Slots:**
*   Lethal
*   Tactical

**States:**
*   Ready
*   On cooldown
*   Empty

**Visual Rules:**
*   Dimmed when unavailable
*   Cooldown uses radial wipe or numeric timer

## 8. Visual & Motion Rules

**Typography:**
*   **Primary:** Gotham Bold (critical data)
*   **Secondary:** Gotham Medium (labels)

**Animation:**
*   **Standard enter/exit:** ~0.2s spring
*   **No idle motion** unless explicitly enabled
*   Critical alerts may pulse but must be toggleable

**Audio Hooks:**
*   UI sounds are event-driven, not looped
*   All sounds must support mute/volume scaling

## 9. Accessibility & Configuration

**Required Settings Hooks:**
*   HUD scale (80%–120%)
*   Safe zone bounds
*   **Colorblind presets:**
    *   Enemy indicators
    *   Squad colors
*   **Motion reduction:**
    *   Disable HUD sway
    *   Disable pulsing effects

**Rules:**
*   Color must never be the sole indicator of state
*   Icons or shape changes required for critical alerts

## 10. Development Notes
*   Each HUD element should be a self-contained component
*   Visibility controlled by game state subscriptions, not polling
*   **No hardcoded values for:**
    *   Screen position
    *   Colors
    *   Input bindings

## 11. Dependencies & References
*   Functional logic: [PlayerHUD.md](../Features/Systems/PlayerHUD.md)
*   Component architecture: [Component_HUD.md](../Components/Component_HUD.md)