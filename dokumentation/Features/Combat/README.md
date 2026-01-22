# 🔫 Combat Systems

This document outlines the core combat systems that define the gunplay experience of our game. Our vision is to deliver a "AAA-feel" combat system that is responsive, skill-based, and deeply customizable, mirroring the acclaimed gunplay of *Call of Duty: Modern Warfare (2019)*.

## System Design & Vision

The combat system is built on three core pillars:

- **Authentic & Grounded Gunplay:** Every aspect of the combat experience, from weapon handling to ballistics, is designed to feel authentic and grounded in realism. We use a hybrid hitscan/projectile system to balance the responsiveness of hitscan with the realism of projectile-based ballistics at long range.
- **Player Skill & Mastery:** The combat system is designed to be easy to learn but difficult to master. Recoil patterns are predictable but challenging, and the time-to-kill (TTK) is low, rewarding accuracy and fast reflexes. This creates a high skill ceiling that will keep players engaged for the long term.
- **Deep Customization & Player Agency:** The Gunsmith system is the heart of our combat experience. It allows players to customize their weapons with a vast array of attachments, each with its own set of trade-offs. This gives players a high degree of agency in crafting a loadout that suits their playstyle.

## 📄 Features

| Feature | Description |
|---------|-------------|
| [WeaponFramework.md](WeaponFramework.md) | Hitscan/Projectile hybrid ballistics system with penetration and falloff. |
| [GunsmithSystem.md](GunsmithSystem.md) | Attachment-based weapon customization with real-time stat modification. |
| [VisualRecoil.md](VisualRecoil.md) | Camera feedback, weapon sway, and haptic vibration patterns that provide visceral feedback. |

## 🎯 Overview

Combat in this game centers around responsive, skill-based gunplay. The system combines:
- **Realistic ballistics** with hitscan and projectile options
- **Customizable weapons** through an attachment system
- **Visual feedback** that rewards player skill through recoil control

## 🔗 Related Documentation

- [Features/INDEX.md](../INDEX.md) - Cross-references and dependency graph
- [Features/README.md](../README.md) - All features overview
- [BattleRoyale/](../BattleRoyale/) - How combat feeds into BR mechanics
- [Components/WeaponFramework*](../../Components/) - Implementation details

---

**Start with [WeaponFramework.md](WeaponFramework.md) to understand the combat pipeline.**
