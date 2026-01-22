# System Design: Settings & Configuration

## System Design & Vision

The settings system is a critical component of the player experience, providing a comprehensive suite of options for customizing controls, audio, and graphics. It is designed to be a pillar of player agency, accessibility, and performance optimization, empowering players to tailor the game to their specific hardware, preferences, and needs. The design is guided by the following core principles:

- **Player Empowerment:** Our goal is to give players as much control as possible over their experience. The settings menu is not just a collection of options, but a powerful tool that allows players to fine-tune every aspect of the game, from the sensitivity of their mouse to the color of their crosshair.
- **Accessibility for All:** We are committed to making our game accessible to as many players as possible. The settings menu includes a wide range of accessibility options, including colorblind modes, customizable subtitles, and remappable controls. We believe that everyone should be able to enjoy our game, regardless of their abilities.
- **Performance and Scalability:** We understand that our players have a wide range of hardware, from high-end gaming PCs to older laptops. The graphics settings are designed to be highly scalable, allowing players to find the perfect balance of visual quality and performance for their system.
- **A Clean and Intuitive UI:** A powerful settings menu is useless if it's difficult to navigate. The UI is designed to be clean, organized, and easily navigable, with all options logically grouped into categories. This ensures that players can quickly find the settings they're looking for without getting lost in a sea of options.

## 🎯 Design Philosophy
- **Immediate Feedback**: Changes (like sensitivity or FOV) should apply instantly, not require a restart.
- **Granularity**: "Pro" players need decimal-level precision for sensitivity.
- **Accessibility**: Options to reduce motion sickness (Camera Shake, Blur) are mandatory.
- **Contextual Help**: Every setting should have a tooltip explaining *what* it does, ideally with a visual preview.

---

## 🗂️ Categories & Options

The UI will be divided into horizontal tabs.

### 1. 🎮 Controller / Input
Crucial for defining the "feel" of movement.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Mouse Sensitivity** | Slider (0.1 - 5.0) | 1.0 | Base camera rotation speed. |
| **ADS Sensitivity Multiplier** | Slider (0.1 - 1.0) | 0.8 | Speed reduction when Aiming Down Sights. |
| **Invert Vertical Look** | Toggle | Off | Inverts Y-axis. |
| **Crouch Behavior** | Toggle / Hold | Toggle | Determines if 'C' needs to be held. |
| **Prone Behavior** | Toggle / Hold | Hold | Input required to go prone. |
| **Sprint Behavior** | Toggle / Hold | Toggle | Input required to sprint. |
| **Tactical Sprint Activation** | Dropdown | Double Tap | Single Tap Run, Double Tap, or Auto Tac Sprint. |
| **ADS Behavior** | Toggle / Hold | Hold | Input required to aim. |
| **Equipment Behavior** | Hold / Instant | Hold | Hold to cook grenades vs instant throw. |

### 2. 🖥️ Graphics & Display
Visual clarity vs. Immersion.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Field of View (FOV)** | Slider (60 - 120) | 80 | Horizontal viewing angle. |
| **ADS FOV** | Independent / Affected | Affected | Whether ADS zooms in based on base FOV. |
| **Motion Blur** | Toggle | On | Cinematic blur on camera rotation. |
| **Weapon Motion Blur** | Toggle | On | Blur specifically on the weapon model. |
| **Camera Shake** | Slider (0% - 100%) | 100% | Intensity of explosions/sprint shake. |
| **Bullet Impacts** | Toggle | On | Show bullet holes on surfaces. |
| **Gore / Dismemberment** | Toggle | On | Visual violence settings. |

### 3. 🔊 Audio
Spatial awareness tuning.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Master Volume** | Slider (0 - 100) | 100 | Global volume. |
| **Music Volume** | Slider (0 - 100) | 70 | Menu and in-game music. |
| **Effects Volume** | Slider (0 - 100) | 100 | Footsteps, gunshots, explosions. |
| **Hitmarker Sound** | Dropdown | Modern | Classic (MW2) or Modern (MW2019) sounds. |

### 4. 📟 Interface (HUD)
Screen real-estate management.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **HUD Safe Area** | Slider | 1.0 | Shrinks UI towards center (good for ultra-wide). |
| **Mini-Map Rotation** | Toggle | On | Rotates map with player vs. fixed North. |
| **Crosshair Visibility** | Toggle | On | Show/Hide hipfire reticle. |
| **Telemetry** | Toggle | Off | Show FPS and Ping counters. |
| **Killfeed Duration** | Slider (1s - 10s) | 5s | How long kill messages stay on screen. |

---

## 🛠️ Technical Architecture

### Data Structure (`SettingsData`)
Settings are stored as a flat dictionary within the player's profile data, grouped by category keys for organization.

```lua
export type SettingsProfile = {
    Input: {
        MouseSensitivity: number,
        TacticalSprint: "DoubleTap" | "SingleTap" | "Auto",
        -- ...
    },
    Graphics: {
        FOV: number,
        MotionBlur: boolean,
        -- ...
    },
    -- ...
}
```

### Client-Side Implementation (`SettingsManager`)
**Location:** `src/client/Settings/SettingsManager.luau`

The settings manager is the central hub for applying changes. It does not run per-frame logic itself but **signals** other systems to update.

1.  **Initialization**: Loads data from player attributes (`ClientSettings`) or defaults via `SettingsData`.
2.  **Application**:
    *   **FOV**: Updates `workspace.CurrentCamera.FieldOfView`.
    *   **Sensitivity**: Updates `CameraData` (or attributes) read by `CameraController`.
    *   **Input**: Updates configuration in `InputManager`.
3.  **Persistence**: Changes are cached locally and saved via `SettingsManager.SaveSettings` (player attributes). The **Settings** tab uses `SettingsView` and `SettingsManager`; there is no separate `SettingsController`.

### Integration Points

*   **`MovementController`**: Listens for `SettingsChanged("TacticalSprint")` to adjust the double-tap timing logic.
*   **`CameraController`**: Reads `Settings.Input.Sensitivity` inside its `Update` loop (or via attribute) to scale delta input.
*   **`MusicController`**: Binds directly to `Settings.Audio.MusicVolume` to adjust `SoundGroup` volume.

## 🖥️ UI Layout Mockup

```text
+---------------------------------------------------------------+
|  [ GAMEPLAY ]  [ GRAPHICS ]  [ AUDIO ]  [ INTERFACE ]         |
+---------------------------------------------------------------+
|                                                               |
|  FIELD OF VIEW                                                |
|  <------------------|--------------------> [ 100 ]            |
|  (Preview Image showing FOV difference)                       |
|                                                               |
|  MOTION BLUR                                                  |
|  [ ON ] / OFF                                                 |
|                                                               |
|  CAMERA SHAKE                                                 |
|  <---------------------------|-----------> [ 75% ]            |
|                                                               |
+---------------------------------------------------------------+
| [ RESET TAB ]                                 [ APPLY ]       |
+---------------------------------------------------------------+
```
