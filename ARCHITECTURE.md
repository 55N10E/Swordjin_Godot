# Swordjin — Mobile PWA RPG
**Architecture Master Plan**
*200+ Manhwa Chapters → Long-form Action RPG*

---

## Overview

| Property | Value |
|----------|-------|
| Engine | Godot 4.4 |
| Target | Mobile PWA (Progressive Web App) |
| Resolution | 640×360 (16:9), scales to mobile |
| Rendering | OpenGL ES 3.0 (mobile-compatible) |
| Art Style | Stylized pixel/SVG hybrid (performance-friendly) |
| Audio | WebAudio API, compressed OGG |
| Storage | IndexedDB (save games), Cache API (PWA assets) |
| Backend | PlayFab (auth, leaderboards, cloud save) |

---

## Story Architecture: 200+ Chapters

### Act Structure (10 Acts × ~20-25 Chapters)

```
Act 01 — Awakening (Ch. 1-20)      Jin discovers the sword, basic combat
Act 02 — Trials (Ch. 21-40)        First dungeon, skill unlocks
Act 03 — Betrayal (Ch. 41-60)      Story twist, new enemy faction
Act 04 — Alliance (Ch. 61-80)      Party members, co-op mechanics
Act 05 — War (Ch. 81-100)          Large-scale battles, army mechanics
Act 06 — Descent (Ch. 101-120)     Dark powers, corruption mechanic
Act 07 — Redemption (Ch. 121-140)  Heal/cleanse mechanics, moral choices
Act 08 — Ascension (Ch. 141-160)   God-tier powers, dimensional travel
Act 09 — Truth (Ch. 161-180)       Final revelations, all factions converge
Act 10 — Destiny (Ch. 181-200+)    Final boss, epilogue, NG+ system
```

### Chapter → Game Mapping Rules

1. **Combat Chapter** (60%): → Combat level, 3-5 min playtime
2. **Story Chapter** (25%): → Cutscene/dialogue + minor interaction
3. **World Chapter** (10%): → Exploration, side quests, hub area
4. **Boss Chapter** (5%): → Major boss fight, 10-15 min, checkpoint system

**Average playtime per chapter: 4 minutes**
**Total campaign: ~13-15 hours** (comparable to full RPG)

---

## Technical Architecture

### PWA Layer
```
┌─────────────────────────────────────┐
│  Service Worker (sw.js)             │
│  • Cache game assets                │
│  • Offline play support             │
│  • Background updates               │
├─────────────────────────────────────┤
│  Web Manifest (manifest.json)       │
│  • Install to home screen           │
│  • Fullscreen landscape             │
│  • Theme colors                     │
├─────────────────────────────────────┤
│  Godot HTML5 Export                 │
│  • WASM runtime                     │
│  • .pck game data                   │
│  • WebAudio                         │
└─────────────────────────────────────┘
```

### Game Data Structure
```
Swordjin_Godot/
├── project.godot              # Main config
├── autoload/                  # Global singletons
│   ├── GameState.gd          # Save/load, progress
│   ├── AudioManager.gd        # BGM/SFX
│   ├── PlayFabClient.gd       # Backend API
│   └── ChapterDatabase.gd     # All chapter data
├── chapters/                  # Content (200+ files)
│   ├── act01/
│   │   ├── chapter001.tscn   # Level scene
│   │   ├── chapter001.json   # Dialogue/story
│   │   └── chapter001.md     # Design doc
│   ├── act02/
│   └── ...
├── characters/               # Player + NPCs
│   ├── jin/
│   ├── allies/
│   └── enemies/
├── combat/                   # Systems
│   ├── weapons/
│   ├── skills/
│   └── status_effects/
├── ui/                       # Interface
│   ├── hud/
│   ├── menus/
│   └── mobile_controls/
├── assets/                   # Art/Audio
│   ├── sprites/             # SVG → PNG pipeline
│   ├── tilesets/
│   ├── animations/
│   ├── bgm/
│   └── sfx/
└── builds/                   # Export targets
    ├── web/                  # PWA build
    ├── android/              # APK (future)
    └── ios/                  # (future)
```

---

## Combat System Evolution

### Phase 1 (Act 1-2): Foundation
- Basic melee (tap/click)
- 4-directional movement
- 1 skill slot
- Simple enemies (skeletons, bandits)

### Phase 2 (Act 3-4): Expansion
- Combo system (3-hit chains)
- 2 skill slots
- Elemental damage (fire/ice)
- Enemy types: ranged, tank, fast

### Phase 3 (Act 5-6): Scale
- Formation system (party of 3)
- Ultimate abilities
- Buff/debuff mechanics
- Army vs army (auto-battle segments)

### Phase 4 (Act 7-8): Depth
- Corruption meter (risk/reward)
- Dual-wielding
- 4 skill slots + 2 ultimates
- Status effects: poison, stun, bleed, freeze

### Phase 5 (Act 9-10): Mastery
- All mechanics combined
- New Game+ with harder modifiers
- Endless dungeon mode
- PvP arena (async)

---

## Mobile UX Design

### Input
```
┌────────────────────────────┐
│  [Virtual D-Pad]   [Attack]│
│     ←↑↓→           [Skill1]│
│                    [Skill2]│
│                    [Ult]   │
│                            │
│     ← Game Area →          │
│                            │
│  [HP/MP]         [Menu]  │
└────────────────────────────┘
```

### Accessibility
- Auto-aim option (tap enemy = auto-attack)
- Simplified controls mode (1-button combat)
- Text size scaling
- Color-blind enemy indicators
- Pause anytime

### Performance Targets
- 60 FPS on mid-range mobile (2019+)
- Load time < 3 seconds per chapter
- Total install size < 100MB
- Offline play: full campaign cached

---

## Asset Pipeline

### Art Strategy
1. **Characters**: Inkscape SVG → batch export PNG
2. **Tilesets**: Tiled editor → Godot tilemap
3. **UI**: 9-patch scalable elements
4. **Effects**: Godot particle systems (GPU)
5. **Backgrounds**: Parallax layers, procedural where possible

### Audio Strategy
- BGM: Ogg Vorbis, loop seamlessly
- SFX: Short WAV → OGG, pooled playback
- Voice: Optional, lightweight (chapter bookends only)

### Generation Script
```bash
# On Packy/Gargoyle
assets/nightly_assets.sh
├── Generate placeholder sprites from SVG templates
├── Batch export at multiple resolutions (1x, 2x, 3x)
├── Optimize PNG (oxipng)
├── Convert audio (ffmpeg)
└── Update Godot resource imports
```

---

## Monetization (Optional)

| Model | Implementation |
|-------|----------------|
| Premium | $4.99 one-time, full game |
| Freemium | Free Act 1, $1.99 per Act or $9.99 all |
| Cosmetics | Skin/weapon skins via PlayFab |
| No ads | Quality of life decision |

---

## Development Phases

### Phase 1: Foundation (Weeks 1-4)
- [x] Basic Godot project structure
- [x] Player movement + attack
- [x] Enemy AI (skeleton)
- [x] HP system + death
- [ ] PWA export working
- [ ] Mobile controls
- [ ] Save/load system

### Phase 2: Vertical Slice (Weeks 5-8)
- [ ] Act 1 complete (20 chapters playable)
- [ ] All core combat mechanics
- [ ] First boss fight
- [ ] Story system (dialogue + cutscenes)
- [ ] PlayFab integration
- [ ] Sound design

### Phase 3: Content Blast (Months 3-6)
- [ ] Automated chapter generation pipeline
- [ ] Manhwa → game conversion at 10 chapters/week
- [ ] Asset generation pipeline
- [ ] Testing framework
- [ ] Balance tuning

### Phase 4: Polish (Months 7-8)
- [ ] Performance optimization
- [ ] Mobile-specific UX
- [ ] Accessibility features
- [ ] Localization (KR, EN, JP)
- [ ] Marketing materials

### Phase 5: Launch (Month 9+)
- [ ] PWA deployment
- [ ] App store wrappers (if desired)
- [ ] Community features
- [ ] Live ops (events, new chapters)

---

## Metrics to Track

```json
{
  "retention": {
    "d1": ">40%",
    "d7": ">20%",
    "d30": ">10%"
  },
  "engagement": {
    "avg_session": "8-12 minutes",
    "chapters_per_day": "5-10",
    "completion_rate": ">30% finish Act 1"
  },
  "technical": {
    "crash_rate": "<0.1%",
    "load_time": "<3s",
    "fps_stable": "95%+ at 60fps"
  }
}
```

---

## Current Status

| Component | Status |
|-----------|--------|
| Godot project | ✅ Running |
| Basic combat | ✅ Working |
| PWA export | 🔄 Nightly pipeline building |
| Chapter templates | 🔄 Generating (Act 1, Ch 1-20) |
| Mobile controls | ⏳ Next sprint |
| Save system | ⏳ After Act 1 vertical slice |
| PlayFab backend | ⏳ After vertical slice |
| Art pipeline | ⏳ Pending asset phase |
| Audio | ⏳ Pending |
| 200+ chapters | ⏳ In progress |

---

## Nightly Pipeline

**Cron:** `0 1 * * *` (01:00 CEST)
**Script:** `scripts/nightly_dev.sh`
**Logs:** `logs/nightly_YYYYMMDD_HHMMSS.log`
**Phases:** foundation → content → assets → export → loop

Each night the system:
1. Checks project health
2. Generates next chapter template
3. Progresses through asset/build phases
4. Commits to git with progress state
5. Attempts HTML5 export if Godot available

---

## Next Immediate Actions

1. **PWA Export Test** — Verify Godot HTML5 build works on Packy
2. **Mobile Controls** — Add virtual joystick + buttons
3. **Save System** — JSON-based chapter progress + IndexedDB
4. **Chapter 1 Complete** — Full Act 1 vertical slice
5. **PlayFab Setup** — Cloud save + auth skeleton

---

*Master Plan v1.0 — 2026-05-11*
*Automated nightly development in progress*
