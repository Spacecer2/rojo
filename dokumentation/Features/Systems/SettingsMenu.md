# Settings Menu: Input, Audio & Graphics Options

## Overview
The settings menu is a critical component of the player experience, providing a comprehensive suite of options for customizing controls, audio, and graphics. It is designed to be a pillar of player agency and accessibility, empowering players to tailor the game to their specific hardware, preferences, and needs.

## System Design & Vision

The design of the settings menu is guided by the following core principles:

- **Player Empowerment:** Our goal is to give players as much control as possible over their experience. The settings menu is not just a collection of options, but a powerful tool that allows players to fine-tune every aspect of the game, from the sensitivity of their mouse to the color of their crosshair.
- **Accessibility for All:** We are committed to making our game accessible to as many players as possible. The settings menu includes a wide range of accessibility options, including colorblind modes, customizable subtitles, and remappable controls. We believe that everyone should be able to enjoy our game, regardless of their abilities.
- **Performance and Scalability:** We understand that our players have a wide range of hardware, from high-end gaming PCs to older laptops. The graphics settings are designed to be highly scalable, allowing players to find the perfect balance of visual quality and performance for their system.
- **A Clean and Intuitive UI:** A powerful settings menu is useless if it's difficult to navigate. The UI is designed to be clean, organized, and easily navigable, with all options logically grouped into categories. This ensures that players can quickly find the settings they're looking for without getting lost in a sea of options.

## Settings Architecture

### Storage System
```lua
-- LocalStorage (Client-persisted)
local Settings = {
    Version = 2, -- For migration on updates
    LastModified = tick(),
    Categories = {
        Input = {},
        Audio = {},
        Graphics = {}
    }
}

-- Server-side player preferences (cosmetic settings)
local PlayerPreferences = {
    UserId = player.UserId,
    HUDSize = 1.0,
    ColorblindMode = "None",
    Brightness = 1.0
}
```

### Settings File Location
- **Windows**: `%APPDATA%\Roblox\LocalStorage\game_settings.json`
- **Stored encrypted** to prevent tampering
- **Cloud backup** option (servers store backup)

## Settings Categories

### 1. Input Settings

#### Sensitivity
```
Mouse Sensitivity:     ■□□□□ 1.0
Controller Sensitivity: ■■□□□ 2.5
ADS Sensitivity:       ■□□□□ 0.8 (Scoped multiplier)
Vertical Multiplier:   ■■■□□ 1.2 (Y-axis adjustment)
```

#### Control Schemes
- **Default**: Standard WASD + Mouse
- **Southpaw**: IJKL + Right-stick aim
- **Custom**: Full key rebinding

#### Key Bindings
```
Movement
├─ Forward:            W
├─ Backward:           S
├─ Left Strafe:        A
├─ Right Strafe:       D
├─ Jump:               Space
├─ Crouch:             Ctrl
├─ Prone:              Z
└─ Sprint:             Shift

Combat
├─ Fire:               Mouse1
├─ Aim Down Sight:     Mouse2
├─ Reload:             R
├─ Melee:              V
├─ Equipment Use:      E
├─ Grenade:            G
├─ Switch Weapon:      Q
└─ Ping/Callout:       C

UI
├─ Menu:               Esc
├─ Map:                M
├─ Loadout:            L
├─ Squad:              T
└─ Voice Chat:         V (hold)
```

#### Advanced Input
- **Aim Assist** (Controller only)
  - [ ] Enabled
  - Strength: ■■□□□ 2.5
  - Type: Slowdown / Snap

- **Button Hold vs Toggle**
  - [ ] Sprint (Hold)
  - [x] Crouch (Toggle)
  - [x] ADS (Hold)

- **Dead Zone Settings** (Controller)
  - Analog Stick: ■□□□□ 0.15 (smaller = more sensitive)
  - Trigger: ■□□□□ 0.05

#### Mouse Options
- [x] Raw Input (bypass Windows acceleration)
- [x] Mouse Smoothing (frame-independent input)
- Polling Rate: 1000 Hz dropdown

### 2. Audio Settings

#### Volume Master
```
Master Volume:      ■■■■■ 100%
└─ Effects:         ■■■■■ 100% (Weapons, impacts)
└─ Dialogue:        ■■■■□ 80%
└─ Music:           ■■■□□ 60%
└─ UI:              ■■■■□ 80% (Menu clicks)
└─ Voice Chat:      ■■■■■ 100%
```

#### Audio Output
- **Device Selection**: Dropdown (headphones, speakers, etc.)
- **Speaker Setup**: Stereo / 5.1 Surround / 7.1 Surround
- **Sample Rate**: 44.1 kHz / 48 kHz / 96 kHz

#### Audio Features
- [x] 3D Positional Audio (footsteps direction)
- [x] Realistic Doppler Effect (moving enemies)
- [x] Sound Occlusion (reduced volume through walls)
- [x] Dynamic Mix (voice chat boosts volume if quiet)

#### Voice Chat Settings
- **Input Device**: Dropdown (microphone selection)
- **Microphone Volume**: ■■■■□ 80%
- **Echo Cancellation**: [x] Enabled
- **Noise Suppression**: ■■□□□ Medium (filters background)
- **Voice Activation**: 
  - [x] Push-to-Talk (V key)
  - [ ] Voice Activation (always on)

#### Advanced Audio
- **Equalizer Presets**:
  - Flat (Neutral)
  - Enhanced (Highlight gunshots & voices)
  - Bass Boost
  - Custom (manual adjustment)

- **Mono Audio**: [ ] For accessibility (hearing loss)

### 3. Graphics Settings

#### Rendering Quality
```
Graphics Mode: High ▼
├─ Low (60+ FPS focus)
├─ Medium (Balanced)
├─ High (Quality focus)
└─ Ultra (Max settings, 30+ FPS)

Automatic Quality: [x] Enabled
```

#### Resolution & Framerate
- **Resolution**: 1920x1080 ▼ (with common presets)
- **Aspect Ratio**: 16:9 (auto-detect or manual)
- **Target FPS**: 60 ▼ (30, 60, 120, 144, 240, Unlimited)
- **V-Sync**: [x] Enabled (prevents screen tearing)

#### Visual Effects
```
Draw Distance:   ■■■■■ 500m
LOD Quality:     ■■■□□ Medium
Shadows:         ■■■□□ Medium
Particle Effects: ■■■■□ High
Bloom/Glow:      ■■■□□ Medium
Depth of Field:  [ ] Off (performance)
```

#### UI Scaling
- **HUD Scale**: ■■■■■ 100%
- **Font Size**: ■■■■□ Large
- **Opacity**: ■■■■■ 100%

#### Color & Accessibility
- **Brightness**: ■■■■□ 110%
- **Contrast**: ■■■■■ 100%
- **Saturation**: ■■■■■ 100%
- **Colorblind Mode**:
  - None (Default)
  - Deuteranopia (Red-Green)
  - Protanopia (Red-Blind)
  - Tritanopia (Blue-Yellow)

#### Weapon Rendering
- [x] Show weapon in FPS view
- [ ] Hide weapon when idle
- **Lens Distortion**: ■■□□□ Low (scope sway effect)

#### Performance Monitoring
- [x] Show FPS Counter (Top-right)
- [x] Show Ping (Network latency)
- [x] Show Frame Time Graph (visible stutters)

### Advanced Options

#### Network
- **Network Buffer**: ■■■□□ Medium
  - Low: Less latency, more jitter
  - Medium: Balanced
  - High: Smoother, higher latency

- **Update Rate**: 30 Hz ▼ (frequency server updates)

- [x] Interpolate Server Updates (smooth movement)

#### Gameplay
- **Damage Numbers**: [x] Show (floating +28 on hits)
- **Kill Callouts**: [x] Show (announcer feedback)
- **Killcam**: [x] Enabled (see how you died)
  - Duration: 3-10 seconds
- **Blood Effects**: [x] Enabled ([ ] for low-violence mode)

#### Developer
- [ ] Console Enabled (Debug mode)
- [ ] Cheats (disabled in multiplayer)
- Network Debug: [ ] Show packet loss

## Settings UI Flow

### Main Settings Menu
```
┌─────────────────────────────────┐
│        SETTINGS MENU            │
├─────────────────────────────────┤
│ ▶ INPUT                         │
│ ▶ AUDIO                         │
│ ▶ GRAPHICS                      │
│ ▶ GAME (Gameplay options)       │
│ ▶ ACCESSIBILITY                 │
│                                 │
│ [Reset to Defaults]             │
│ [Save & Close]                  │
└─────────────────────────────────┘
```

### Input Settings Submenu
```
┌─────────────────────────────────┐
│      INPUT SETTINGS             │
├─────────────────────────────────┤
│ SENSITIVITY                     │
│ ├─ Mouse: [slider + value]      │
│ ├─ ADS: [slider + value]        │
│ └─ Vertical: [slider + value]   │
│                                 │
│ CONTROL SCHEME: Default ▼       │
│ [Rebind Keys]                   │
│ [Load Profile]                  │
│                                 │
│ ADVANCED                        │
│ ├─ [x] Raw Input                │
│ ├─ [x] Mouse Smoothing          │
│ └─ Dead Zone: [slider]          │
│                                 │
│ [Default]  [Cancel]  [Save]     │
└─────────────────────────────────┘
```

## Profiles & Presets

### Keybind Profiles
- Save custom keybind layouts
- Profile slots: Default, Profile 1-5
- Export/Import profiles (text file)
- Share profiles with friends

### Sensitivity Presets
```lua
local SensitivityPresets = {
    {
        Name = "eSports",
        Mouse = 0.8,
        ADS = 0.6,
        VerticalMultiplier = 1.0
    },
    {
        Name = "Competitive",
        Mouse = 1.2,
        ADS = 0.8,
        VerticalMultiplier = 1.1
    },
    {
        Name = "Casual",
        Mouse = 2.0,
        ADS = 1.5,
        VerticalMultiplier = 1.2
    },
    {
        Name = "Console",
        Mouse = 1.5, -- Controller 1
        ADS = 1.0,
        VerticalMultiplier = 1.0
    }
}
```

## Persistence & Cloud Sync

### Automatic Save
- Settings saved on every change
- 500ms debounce (don't spam disk writes)
- Version checked on load (migration if needed)

### Cloud Backup
- Optional: Sync settings to server
- Allows multi-device consistency
- Restore from cloud if local corrupt

### Import/Export
- Export settings as JSON file
- Manually edit if desired (JSON format)
- Import from file

## Accessibility Features

### Color Blindness Support
- All UI uses patterns + colors
- Deuteranopia mode (red-green)
- Protanopia mode (red-blind)
- Tritanopia mode (blue-yellow)

### Motor Accessibility
- Remappable all keys
- Toggle options (don't require holding)
- Larger clickable areas
- Customizable cursor size

### Hearing Accessibility
- [x] Mono Audio (combine stereo to mono)
- [x] Subtitles (all dialogue, SFX descriptions)
- Visual indicators for directional sounds

### Visual Accessibility
- [ ] High Contrast Mode (increases saturation)
- [ ] Reduce Motion (minimizes camera shake)
- Scalable UI size
- Font selection (dyslexia-friendly options)

## Performance Impact

### Graphics Quality Tiers
| Setting | Low | Medium | High | Ultra |
|---------|-----|--------|------|-------|
| Draw Distance | 200m | 350m | 500m | 700m |
| Shadow Quality | Off | Low | Med | High |
| Particle Count | 50% | 75% | 100% | 150% |
| Expected FPS | 120+ | 90+ | 60+ | 30+ |

## Network Synchronization

### Server-Stored Preferences
```lua
-- Non-sensitive settings (cosmetic)
local SyncedSettings = {
    HUDScale = 1.0,
    ColorblindMode = "None",
    Brightness = 1.0
}

-- Local-only settings (sensitive/performance)
local LocalSettings = {
    KeyBindings = {},
    GraphicsSettings = {},
    AudioLevels = {}
}
```

## Testing Checklist

- [ ] All sliders adjust values smoothly
- [ ] Dropdown menus work properly
- [ ] Checkbox toggles function correctly
- [ ] Key rebinding captures input correctly
- [ ] Settings persist after restart
- [ ] Cloud sync working (if enabled)
- [ ] Graphics presets apply correctly
- [ ] Audio output device selection works
- [ ] Colorblind modes render properly
- [ ] Controller support functional
- [ ] Reset to defaults clears all changes
- [ ] Multiple profiles switch seamlessly

## Future Enhancements

- Per-weapon sensitivity profiles
- Custom crosshair styles
- Stream overlay settings (for Twitch)
- Gameplay recording settings (highlight system)
- Advanced network diagnostics
- Seasonal cosmetic settings
- Controller layout presets
- Accessibility preset templates
