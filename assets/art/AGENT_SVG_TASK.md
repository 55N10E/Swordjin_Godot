# Swordjin SVG Art Generation Task

## Mission
Generate all missing SVG art assets for Swordjin (Godot 4.4 wuxia action RPG). These replace procedural PNG sprites with proper scalable vector graphics.

## Current State
- **Done:** UI icons (12 SVGs in `assets/art/ui/`), item sprites (4 SVGs in `assets/art/items/`), effects (2 SVGs in `assets/art/effects/`), title sword (`ui/title_sword.svg`)
- **Missing:** Character SVGs, tilemap/environment SVGs, background SVGs

## Color Palette (from TASK_SVG_ICONS.md)
- **Primary**: Gold #FFD700 (accents, titles, rewards)
- **Secondary**: Steel blue #5080C8 (player, UI highlights)
- **Dark BG**: #0D1117 (panels, backgrounds)
- **Health Red**: #E04040
- **Health Green**: #40C040
- **Mana/XP Blue**: #40A0E0
- **Bone White**: #DCE6F0 (skeletons)
- **Rust**: #8B2500 (captain)
- **Purple**: #8C2E8C (merchant)

## Character Palettes (from generate_sprites_v2.py)
### Player (Jin)
- Hair: dark brown #644020, light #8C5028
- Skin: #DCB48C, shadow #BE966E
- Blue tunic: #3250A0, shadow #1E3B78
- Dark brown boots/belt: #3C2D1E
- Leather: #B4A078
- Sword blade: #C8C8D2, highlight #F0F0FA
- Red accent: #A02828

### Skeleton
- Bone: #DCE6F0, shadow: #B4BEC8
- Eye glow: #00DC00, dim: #00A000
- Dark joint: #32323C
- Rust: #641E1E

### Skeleton Captain
- Bone: #DCE6F0, shadow: #B4BEC8
- Red eyes: #DC0000, dim: #A00000
- Shield: #505064 light: #78788C
- Gold trim: #B4A028

### Skeleton Archer
- Bone: #C8D2DC, shadow: #A0AAB4
- Eye: #00B400, dim: #007800
- Bow wood: #78461E, highlight: #A06428
- Fletching: #3C6428

### Merchant
- Skin: #DCB48C, shadow: #BE966E
- Purple robe: #8C288C, shadow: #641464
- Hat: #644020, light: #8C5028
- Gold: #B4A028

## SVGs to Generate

### 1. Character Sprites (64x64 viewBox each, pixel-art style)

Each character needs idle, walk, and attack animation frames as separate SVGs.
Godot AnimatedSprite2D will reference these as sprite_frames.

| File | Description | Colors |
|------|-------------|--------|
| `characters/player_idle.svg` | Player idle pose, sword at side | Player palette |
| `characters/player_walk.svg` | Player walking pose | Player palette |
| `characters/player_attack.svg` | Player mid-swing, sword extended | Player palette |
| `characters/player_dodge.svg` | Player dodge roll pose (leaning/rolling) | Player palette, 50% opacity trail |
| `characters/player_hurt.svg` | Player knocked back, flash red overlay | Player palette + red tint |
| `enemies/skeleton_idle.svg` | Skeleton standing, glowing eyes | Skeleton palette |
| `enemies/skeleton_walk.svg` | Skeleton mid-stride | Skeleton palette |
| `enemies/skeleton_attack.svg` | Skeleton lunging with rusty blade | Skeleton palette |
| `enemies/skeleton_death.svg` | Skeleton collapsing/bones scattering | Skeleton palette |
| `enemies/captain_idle.svg` | Captain with shield raised | Captain palette |
| `enemies/captain_walk.svg` | Captain advancing | Captain palette |
| `enemies/captain_attack.svg` | Captain shield-bash + sword | Captain palette |
| `enemies/captain_charge.svg` | Captain charging forward (special) | Captain palette |
| `enemies/archer_idle.svg` | Archer with bow drawn | Archer palette |
| `enemies/archer_walk.svg` | Archer moving | Archer palette |
| `enemies/archer_shoot.svg` | Archer releasing arrow | Archer palette |
| `npcs/merchant_idle.svg` | Merchant standing with pack | Merchant palette |
| `npcs/merchant_heal.svg` | Merchant casting heal glow | Merchant palette + green glow |

### 2. Tilemap/Environment Tiles (32x32 viewBox each)

| File | Description | Colors |
|------|-------------|--------|
| `tiles/grass_tile.svg` | Grass field tile (ch001 arena) | #2D5A1E, #3A6E28, #1E4A14 |
| `tiles/forest_tile.svg` | Dark forest floor tile (ch002) | #2A3A1E, #1E2E14, #3A4A28 |
| `tiles/stone_tile.svg` | Fortress stone tile (ch003) | #505860, #3A4048, #606870 |
| `tiles/fortress_tile.svg` | Iron fortress tile (ch004) | #404858, #303848, #505868 |
| `tiles/wall_top.svg` | Wall top (collision boundary) | #303848, #202830 |
| `tiles/wall_side.svg` | Wall side face | #283040, #1E2838 |
| `tiles/tree_1.svg` | Deciduous tree obstacle | #1E4A14 trunk, #2D5A1E canopy |
| `tiles/tree_2.svg` | Pine tree obstacle | #1E4A14 trunk, #1E3A0E canopy |
| `tiles/rock_1.svg` | Small rock obstacle | #505860, #3A4048 |
| `tiles/iron_gate.svg` | Large iron gate (ch004) | #606878 frame, #404858 fill |
| `tiles/path_marker.svg` | Path/road marking | #8A7A5A, #6A5A3A |

### 3. Backgrounds (256x144 viewBox, landscape)

| File | Description | Colors |
|------|-------------|--------|
| `bg/field_sunset.svg` | Ch001 — open field at dusk | #0D1117 sky, #FF8020 horizon, #2D5A1E grass |
| `bg/forest_night.svg` | Ch002 — dark forest | #0A0E14 sky, #1A2A1E trees, #0E1A0A ground |
| `bg/fortress_dawn.svg` | Ch003 — stone fortress | #141820 sky, #5080C8 dawn, #505860 stone |
| `bg/iron_throne.svg` | Ch004 — iron gate fortress | #0D1117 sky, #8B2500 gate glow, #404858 walls |

### 4. VFX/Effects (32x32 viewBox)

| File | Description | Colors |
|------|-------------|--------|
| `effects/slash_arc.svg` | Sword slash arc effect | #E0E8F0 blade, #FFD700 tip |
| `effects/dodge_trail.svg` | Dodge roll ghost trail | #5080C8 at 30% opacity |
| `effects/death_burst.svg` | Enemy death particle burst | #DCE6F0 bones, #FF8020 spark |
| `effects/level_up.svg` | Level up sparkle column | #FFD700, #40A0E0 |
| `effects/potion_glow.svg` | Potion pickup glow circle | #40C040, #E04040 |

## Technical Requirements
- SVG 1.1 compatible (Godot SVGTinyElement limits)
- All paths use `viewBox` with consistent sizes per category
- No external font references
- No embedded bitmaps — pure vector
- Group elements with meaningful `<g id="...">` labels
- Use `stroke-linecap="round"` and `stroke-linejoin="round"` for clean pixel feel
- Each SVG must be valid XML with proper `xmlns`
- Keep file sizes small — optimize paths, no unnecessary decimals
- Character sprites: recognizable at 16px, detailed at 64px
- Tilemap tiles: seamless tiling (edges should blend)
- Backgrounds: layered with groups for parallax potential

## Godot Import Notes
- Godot 4.4 imports SVG as Texture2D via `SvgImporter`
- Set `svg/scale` in import settings for proper sizing
- SVGs placed in `assets/art/` will be auto-imported by Godot editor
- AnimatedSprite2D frames: each SVG is a separate frame in the sprite_frames resource