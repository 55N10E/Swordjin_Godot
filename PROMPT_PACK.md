# Swordjin — Project Scope & Prompt Pack

## Project Identity
**Swordjin** is a 2D top-down action RPG in Godot 4.4, targeting PWA/HTML5 export.
Genre: Wuxia-themed hack-and-slash with chapter-based progression.

## What's REAL (functional code)

- **Player movement & combat** (`player.gd`, 175 lines): WASD movement, attack with hitbox, damage/death, knockback lunge, health bar, damage numbers. Works.
- **Enemy AI** (`skeleton.gd` 153 lines, `skeleton_archer.gd` 179 lines, `skeleton_captain.gd` 204 lines): Detection range, chase behavior, melee/ranged attacks, hit detection. Works.
- **Chapter system** (`chapter_manager.gd` 132 lines + `chapter_database.gd` autoload): JSON-driven chapter loading, unlock progression, chapter select UI. Works.
- **Dialogue system** (`dialogue_manager.gd` 115 lines): Typewriter text, trigger-based (start/objective_complete), auto-advance. Works.
- **Mobile controls** (`mobile_controls.gd` 103 lines): Virtual joystick + attack/skill buttons, auto-detects touch. Works.
- **Audio system** (`audio_manager.gd` autoload): SFX pool with pitch variation, BGM crossfade, volume control. Works.
- **Gate mechanic** (`iron_gate.gd`): Iron Gate scene for Ch004 — blocks exit until captain drops key, player touches gate to open. Works.
- **Juice** (`screen_shake.gd`, `hit_stop.gd`, `damage_number.gd`): Screen shake on heavy hits, freeze frames, floating damage numbers. Works.
- **Chapter data** (ch001–ch004 JSON): Enemy layouts, stats, dialogue triggers, rewards. Structured and complete.
- **Merchant ally** (`merchant_ally.gd` 66 lines): Follows player, heals periodically, combat dialogue. Works.

## What's COSPLAY (placeholder/stub/missing)

- **Sprite system**: ✅ **v0.67** AnimatedSprite2D replaces Polygon2D for all characters. Procedural pixel art sprite sheets (idle/walk/attack). Polygon2D kept as fallback comment.
- **Animations**: ✅ **v0.67** AnimatedSprite2D with idle/walk/attack states for player, skeleton, captain, archer, merchant. Sprite sheets generated procedurally via `generate_sprites_v2.py`.
- **Sound assets**: ✅ **v0.68** Generated .wav files in `assets/sfx/` (10 SFX) + `assets/bgm/` (3 BGM tracks). All real audio, not placeholders.
- ~~**Weapon system**~~ ✅ **v0.60**: WEAPON_STATS dict with broken_sword, steel_dagger, captain_blade. Auto-equip best weapon. DMG/cooldown read from GameState.equipped_weapon.
- **Skill system**: Mobile controls have a `skill1_btn` wired to dodge roll (_start_dodge). Charged heavy attack not yet implemented.
- **Level design**: ✅ **v0.69** Procedural TileMap arenas via `arena_builder.gd`. 4 themed tilesets (field, forest, fortress, dark_fortress). 7 tile types with physics collision.
- **PWA export**: `export_presets.cfg` exists but no verified HTML5 export pipeline.
- ~~**Chapters 4+**~~: Ch004 exists with gate mechanic + captain + archer. Act 2 not yet started.
- **Dummy enemy** (`dummy.gd`): Test target, not a real enemy type.
- **Save system** ✅ **v0.58**: `user://swordjin_save.json` persists chapter progress, HP, max HP, XP, gold, weapons, skills. Auto-save on chapter complete. Continue button loads last save.
- **UI**: Title screen, chapter select, pause menu, and fade transitions exist. No settings or inventory screen.

## Scope to Finished Product

### Must-Have (MVP — Playable Demo)
1. **Replace Polygon2D with pixel art sprites** ✅ **v0.67**: AnimatedSprite2D with procedural sprite sheets for all characters (idle/walk/attack). Player has 3 idle + 3 walk + 4 attack frames.
2. **Tilemap levels** ✅ **v0.69**: Procedural TileMap arenas via `arena_builder.gd`. 4 themed tilesets (field, forest, fortress, dark_fortress). 40×22 tile arena with border walls, theme-specific layouts (ponds, tree clusters, corridors, lava), physics collision on walls/hazards.
3. **Weapon stat differentiation**: broken_sword (8 DMG, 0.4s cooldown) → steel_dagger (12 DMG, 0.3s cooldown) → captain's blade (15 DMG, 0.5s). Swap on chapter unlock.
4. **Sound effects** ✅ **v0.68**: 10 SFX (sword swing/hit, arrow fire/impact, skeleton death, player hurt, captain charge, shield block, level complete, ui click) + 3 BGM tracks (battle, title, ambience). Generated procedural audio.
5. **Chapter 4 completion** ✅ **v0.68**: Boss gate chapter — captain drops key, door opens, chapter complete = Act 1 done.
6. **Save game** ✅ **v0.58**: Save chapter progress + HP + weapon to `user://save.json`. Auto-save on chapter complete. Continue button loads last save.

### Should-Have (Polished Demo)
7. **Attack animations**: 4-frame swing anim for player. 2-frame attack for skeletons. Captain has shield-block anim.
8. **Pause menu** ✅ v0.62
9. **HP potions** ✅ v0.61
10. **Chapter transitions** ✅ v0.65: Fade-to-black between chapters. Victory screen showing XP gained.

### Nice-to-Have (Full Release)
11. **Act 2**: 4 more chapters with new enemy types (ghost, assassin, boss).
12. **PWA HTML5 export** ✅ v0.26: Touch controls, responsive canvas, offline caching via service worker.
13. **Skill system** ✅ v0.63: Dodge roll (skill1 button), charged heavy attack (hold attack).
14. **Procedural audio**: Use Godot AudioStreamGenerator for sfx if wav assets unavailable.

## Architecture Constraints
- Godot 4.4, GDScript only, target HTML5
- All game data in JSON (chapters/ directory) — no hard-coded level data in scripts
- Autoload singletons: `GameState`, `AudioManager`, `ChapterDatabase`, `ScreenShake`, `HitStop`
- Keep `Polygon2D` fallback for any missing sprite (never crash on missing texture)
