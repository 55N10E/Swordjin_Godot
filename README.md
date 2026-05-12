# Swordjin ⚔

A lightweight fantasy action RPG built in Godot 4.4.1, targeting mobile-first PWA deployment.

## Quick Start

**Engine:** Godot 4.4.1-stable (GL Compatibility)
**Resolution:** 640×360 (scales to mobile)
**Export:** HTML5 / PWA via `patch_pwa.sh`

### Features (v0.34)
- Touch controls + keyboard input (WASD + Space)
- Chapter system: JSON-driven acts + chapters
- Boss fight: Skeleton Captain with shield + charge attack
- Chapter Manager UI: act tabs, chapter grid, progress bar
- Audio: SFX pool (8-channel), BGM crossfade, placeholder sounds
- Save/Load: GameState with chapter progress + IndexedDB (web)
- Title screen with start/continue/chapter select

### SFX Placeholders
8 WAV placeholders generated via Python (`scripts/generate_sfx.py`):
- sword_swing, sword_hit, skeleton_death, player_hurt
- shield_block, captain_charge, level_complete, ui_click

### BGM Placeholders
2 ambient loops (`scripts/generate_bgm.py`):
- bgm_title (8s pad) — title screen
- bgm_battle (4s drone) — combat

### Chapters (v0.34)
| Act | Chapter | Title | Boss |
|-----|---------|-------|------|
| 1 | 001 | The Rusted Blade | — |
| 1 | 002 | The Merchant's Plea | — |
| 1 | 003 | The Iron Gate | Skeleton Captain |

### Deploy
```bash
cd scripts
./patch_pwa.sh      # Inject SW + manifest into Godot HTML5 export
```

### Controls
| Key | Action |
|-----|--------|
| WASD / Touch D-pad | Move |
| Space / Tap | Attack |
| C | Chapter select |
| M | Mute |
| R | Restart chapter |

### Dev Notes
- Godot `.uid` files tracked for team sync
- `.gitignore` ignores `.godot/imported/` build cache but keeps `.sample` files for audio

---
*Built with ☕, stubbornness, and the spirit of a resurrected Packard Bell.*
