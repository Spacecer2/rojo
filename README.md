# Roblox Warzone MW 2019 Recreation

A high-fidelity recreation of the **Modern Warfare 2019 / Warzone** experience within the Roblox engine. This project focuses on delivering "AAA-feel" movement, tight gunplay, and a modular architecture that pushes the boundaries of the platform.

## 🎯 The Vision

To bring the iconic, snappy, and weighty feel of *Call of Duty: Modern Warfare (2019)* to Roblox. This isn't just a clone; it's a technical demonstration of how modular systems, physics-driven procedural animation, and hybrid control architectures can elevate Roblox gameplay.

### Core Pillars
- **⚡ Snappy Responsiveness**: Immediate feedback to player intent
- **🧠 Intelligent Systems**: Cameras and NPCs with intentional behavior
- **🎨 Visual Fidelity**: Warzone-style UI, procedural weapon sway, and fluid animations
- **⚖️ Competitive Integrity**: Client-side prediction with strict server-side validation

## 📂 Project Structure

```
.
├── README.md                          # This file
├── dokumentation/                     # Complete documentation (START HERE)
│   ├── README.md                      # Detailed project documentation
│   ├── Features/                      # 12 feature documentation files
│   ├── Components/                    # System component guides
│   ├── Design/                        # High-level design specifications
│   ├── Assets/                        # Game content & cosmetics
│   ├── Guides/                        # Implementation & tuning guides
│   ├── RobloxDocs/                    # Roblox platform reference (9 guides)
│   └── Archive/                       # Legacy documentation
├── src/                               # Source code
│   ├── character/                     # Movement, FSM, procedural animation
│   ├── client/                        # Client controllers & UI
│   ├── server/                        # Server services
│   ├── shared/                        # Network framework, types, constants
│   └── workspace/                     # Map configurations
├── bin/                               # Build outputs
├── aftman.toml                        # Tool management
├── default.project.json               # Rojo configuration
├── selene.toml                        # Linting configuration
└── test.rbxlx                         # Test project file
```

## 🚀 Quick Start

### Prerequisites
- Roblox Studio
- [Rojo](https://rojo.space/) (for local development)
- [Aftman](https://github.com/LPGhatguy/aftman) (optional, for tool management)

### Build & Run

1. **Build the project:**
   ```bash
   rojo build -o "Projects.rbxlx"
   ```

2. **Start Rojo server for live sync:**
   ```bash
   rojo serve
   ```

3. **Open in Roblox Studio:**
   - Open `Projects.rbxlx` in Roblox Studio
   - Studio will sync with Rojo server automatically

For more help, see [Rojo documentation](https://rojo.space/docs).

## 📖 Documentation

**Start here:** [📚 Detailed Documentation](./dokumentation/README.md)

### Key Resources
- **[Features Guide](./dokumentation/Features/README.md)** - All 12 gameplay features documented
- **[Components Guide](./dokumentation/Components/)** - Individual system documentation
- **[Design Docs](./dokumentation/Design/)** - System specifications
- **[Roblox Docs](./dokumentation/RobloxDocs/)** - Platform reference guides (Luau, Services, Networking, Physics, UI, Performance)

## 🏗️ Architecture Highlights

### State-Driven Design
- **Input Manager**: Normalizes input into intent signals
- **State Machine**: Determines character status (Sprinting, Sliding, ADS, etc.)
- **Movement Controller**: Physics-driven locomotion with `RunService.PreSimulation`
- **Animation Manager**: Blends animations based on state changes
- **Procedural Animator**: Spring-based sway and effects

### Hybrid Drone Camera (Three-Layer Architecture)
1. **Intent (AI)**: Semantic framing decisions
2. **Motion Plan**: Predictive filtering & constraint satisfaction
3. **Physical Body**: Physics simulation with fixed-timestep accumulator

## 📊 Documentation Stats

- **71+ markdown files** across organized folders
- **40,000+ lines** of documentation and code examples
- **11 README files** with consistent structure
- **100+ cross-references** between docs
- **9 Roblox reference guides** covering full development stack

## 🎮 Features Implemented

### Movement & Combat
- ✅ Tactical sprint with double-tap mechanics
- ✅ Slide canceling with momentum-based physics
- ✅ Procedural weapon sway
- ✅ ADS system with dynamic FOV
- ✅ Advanced camera system
- ✅ Weapon controller with ammo management
- ✅ Reload system with progress tracking

### Game Systems
- ✅ State machine-based character control
- ✅ Attribute-based state synchronization
- ✅ Networking framework with remote events
- ✅ Data persistence & loadout system
- ✅ Matchmaking & lobby system
- ✅ Gunsmith service (attachment validation & stat calculation)
- ✅ Weapon attachment system integration

### UI & HUD
- ✅ Gameplay HUD (Ammo, Health, Movement State, Reload Progress)
- ✅ Settings Menu (Input, Audio, Graphics, Accessibility)
- ✅ Gunsmith UI (Attachment selection & stat preview)
- ✅ Barracks Menu (Missions, Identity, Rank, Records, Achievements)
- ✅ Main Menu with tab navigation
- ✅ Loadout Editor with weapon customization

### Code Quality
- ✅ Selene linting standards
- ✅ Aftman tool management
- ✅ Rojo project structure
- ✅ Comprehensive error handling
- ✅ Modular architecture

## 🔧 Development

### Code Standards
- Luau scripting language with type annotations
- `Selene` for code linting
- `Stylua` for code formatting
- `Rojo` for local development sync

### Project Organization
```
src/
├── character/              # Movement & animation systems
├── client/
│   ├── Controllers/        # Camera, Input, Interface, Weapon, Loot logic
│   │   └── WeaponController.luau  # Weapon state & ammo management
│   ├── UI/                 # GUI components & HUD
│   │   ├── GameplayHUD.luau       # In-game HUD
│   │   ├── GunsmithUI.luau        # Attachment selection
│   │   └── Views/                 # Menu views (Home, Loadout, Barracks, Settings)
│   ├── Settings/           # Settings management
│   └── Interface/          # Menu controllers
├── server/
│   ├── Services/           # Data, Player, Matchmaking, Gunsmith, etc.
│   │   └── GunsmithService.luau   # Attachment validation & stats
│   └── ...
├── shared/
│   ├── Framework/          # Network framework
│   ├── Types/              # Type definitions
│   ├── Constants/          # Game constants (Weapons, Attachments, Operators)
│   ├── Settings/           # Settings data structures
│   ├── Utils/              # Utility functions (WeaponUtils, etc.)
│   └── UI/                 # Shared UI components (LootHUD)
└── workspace/              # Map configurations
```

## 📈 Progress

| Phase | Status | Details |
|-------|--------|---------|
| **1. Foundation** | ✅ Complete | Framework, State Machine, Networking, Data Persistence |
| **2. Combat & Fluidity** | ✅ Complete | Movement, ADS, Camera, Matchmaking |
| **3. Code Health** | ✅ Complete | Linting, Toolchain, Stability, Documentation |
| **4. Platform Documentation** | ✅ Complete | Roblox Docs, API Reference, Best Practices |
| **5. Gunsmith & Arsenal** | ✅ Complete | Weapon Framework, Gunsmith, Loadout UI, Recoil |
| **6. Battle Royale Core** | 🔄 In Progress | Gas, Looting, Economy, Gulag (Partial), Match Lifecycle |
| **5. Gunsmith & Arsenal** | 🔄 In Progress | Gunsmith Backend ✅, Gunsmith UI ✅, Weapon Framework (V3) pending |
| **6. UI/UX & Meta-Progression** | 🔄 In Progress | Settings Menu ✅, HUD ✅, Barracks ✅, Battle Pass pending |

## 🛠️ Technical Highlights

- **Attribute-Based Sync**: Decoupled state synchronization using Roblox Attributes
- **Spring Physics**: Custom Spring modules for smooth, organic motion
- **Defensive Design**: Robust initialization with `pcall` and `task.spawn`
- **Hybrid Control**: Kinematic planning + dynamic physics for camera
- **Fixed-Timestep Physics**: Stable 120Hz accumulator for frame-rate independence

## 📦 Build Output

Generated by [Rojo](https://github.com/rojo-rbx/rojo) 7.5.1.

Build outputs (`.rbxlx` files) are created in the root directory:
- `Projects.rbxlx` - Full build output

## 📚 Additional Resources

- [Official Roblox Creator Hub](https://create.roblox.com)
- [Rojo Documentation](https://rojo.space/docs)
- [Luau Language Guide](https://create.roblox.com/docs/luau)
- [Roblox API Reference](https://create.roblox.com/docs/reference/engine)

## 📝 License

See repository for license information.

---

**Ready to dive in?** Start with the [detailed documentation](./dokumentation/README.md).
