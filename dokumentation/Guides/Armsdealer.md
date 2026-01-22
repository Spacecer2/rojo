This screen is where the player **views, edits, and manages a saved weapon loadout**. It combines **menu navigation, item slots, stats, and a 3D visual presentation** into one interface.

---

## 1. Screen Identity & Purpose

### 🔧 **Title: “EDIT LOADOUTS”**

* Located at the **top-left**
* Confirms the current mode is **loadout configuration**, not matchmaking or gameplay
* This screen is **non-interactive gameplay-wise** (no combat, no movement)

---

## 2. Left Sidebar – Loadout Preset List

This navigation column provides rapid access to pre-configured loadouts, optimizing for player efficiency and quick iteration.

### 📋 **Preset Loadout Names**

Examples shown:

* Meta M13
* Warzone Support
* **Warzone SMG** (highlighted / selected)
* Warzone AR
* Warzone Crossbow
* Warzone Sniper
* WZ/MP Semi
* Challenge Chaser
* Streak Denial
* Main Multiplayer

### 🧭 Functional Design:

*   Each entry represents a **fully saved loadout preset**, encapsulating all weapon, perk, and equipment configurations.
*   **Rapid Context Switching**: Clicking a loadout name instantaneously loads its associated data, updating the central panel and visual showcase without perceptible delay. This minimizes friction and supports rapid experimentation.
*   The **blue highlight + star icon** denotes the currently active or favorite preset. This visual cue provides immediate feedback on the player's current selection, a critical element in high-stakes environments.

### 🎯 Design Rationale:

*   **Efficiency**: A vertical list facilitates quick scanning and selection, critical for players who frequently switch between specialized loadouts.
*   **Clarity**: The emphasis on concise, player-defined names and minimal iconography prioritizes readability, reducing cognitive load. This supports rapid decision-making, a core requirement in a competitive game.
*   **Modularity**: This design implicitly supports an underlying system where loadout data is self-contained and atomic, allowing for seamless swapping and future expansion.

---

## 3. Center Panel – Loadout Components (Core GUI)

This is the **functional heart** of the screen.

---

### 🔫 **Primary Weapon Slot**

**Top center-left**

* Label: **Primary Weapon**
* Weapon shown: **Royal Covert M13**
* Category: *Submachine Gun* (as shown in UI)
* Weapon level progress bar:

  * Example: **433 / 2200 XP**
* Star icons:

  * Indicate rarity, blueprint tier, or mastery level

#### GUI behavior:

* Clicking this opens:

  * Gunsmith
  * Attachments
  * Camos
  * Weapon details

---

### 🔫 **Secondary Weapon Slot**

**Directly below primary**

* Label: **Secondary Weapon**
* Weapon shown: **Bling Stasis**
* Category: *Handgun*
* Shows weapon level and progress

#### GUI behavior:

* Same interaction style as primary weapon
* Smaller visual emphasis (secondary role)

---

## 4. Perks Section

Located **below the weapons**, laid out horizontally.

### 🧩 **Perk Slots**

* Three perk icons displayed side by side
* Examples shown:

  * **E.O.D.**
  * **Ghost**
  * **Tracker**

### Visual design:

* Circular icons
* Greyed or colored depending on selection
* Muted tones to avoid visual clutter

### Function:

* Each slot represents a **passive ability**
* Clicking opens perk selection menu

---

## 5. Equipment Section

### 💣 **Lethal Equipment**

* Slot labeled **Lethal**
* Example shown: **Thermite**
* Small icon + name

### 🧪 **Tactical Equipment**

* Slot labeled **Tactical**
* Example shown: **Heartbeat Sensor**

### UI logic:

* Equipment is visually smaller than weapons
* Placed lower because it’s **supporting gear**
* Icons are simple and universally recognizable

---

## 6. Right Side – Visual Loadout Showcase

This area is **purely visual**, not a menu.

### 🧱 **Weapon Table Display**

* A realistic tabletop scene showing:

  * Primary weapon (gold-accented SMG)
  * Secondary pistol
  * Knife
  * Tactical gear
  * Grenade
* Items are laid out as if physically placed

### 🎨 Purpose:

* Immersion
* Aesthetic feedback
* Gives the loadout a **“real gear” feel**

### Important:

* This section **does not affect stats**
* It updates automatically when loadout items change

---

## 7. Lighting & Color Language

### 🎭 Visual Theme:

* Dark background
* Soft spotlight on weapons
* Metallic highlights
* Minimal color usage

### Color meanings:

* **Blue** → active selection
* **Gold** → rarity / premium / blueprint
* **Grey** → inactive or neutral
* **Red (circle with slash)** → restricted or incompatible item (perk conflict)

---

## 8. Information Density & UX Design

### Why the GUI works:

* Left = **navigation**
* Center = **configuration**
* Right = **visual feedback**

This follows a classic **3-column UI hierarchy**:

1. Choose preset
2. Edit components
3. See the result

No pop-ups, no clutter, no unnecessary text.

---

## 9. What This Screen Does NOT Do

* ❌ No matchmaking
* ❌ No stats comparison
* ❌ No firing range
* ❌ No enemy info

It is **strictly a preparation and customization interface**.

---

## Overall Summary

This GUI is designed to:

* Quickly switch between saved loadouts
* Clearly separate weapons, perks, and equipment
* Provide strong visual immersion without overwhelming the player
* Allow fast edits with minimal menu depth

It’s a **clean, modular, military-themed configuration screen** optimized for both mobile and controller use.

