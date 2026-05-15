# Swordjin SVG Art Task — UI Icons & Item Sprites

## Project Context
Swordjin is a 2D top-down wuxia action RPG built in Godot 4.4, targeting PWA/HTML5 export.
Art style: clean pixel-art inspired SVGs, dark fantasy theme, 16x16 logical px aesthetic.

## Color Palette
- **Primary**: Gold #FFD700 (accents, titles, rewards)
- **Secondary**: Steel blue #5080C8 (player, UI highlights)
- **Dark BG**: #0D1117 (panels, backgrounds)
- **Health Red**: #E04040
- **Health Green**: #40C040
- **Mana/XP Blue**: #40A0E0
- **Bone White**: #DCE6F0 (skeletons)
- **Rust**: #8B2500 (captain)
- **Purple**: #8C2E8C (merchant)

## SVGs to Generate

### 1. UI Icons (32x32 viewBox, clean stroke style)
All icons should be simple, readable at 16px and 32px. Stroke-based with minimal fills.

| File | Description | Colors |
|------|-------------|--------|
| `ui/heart.svg` | Heart icon (HP) | #E04040 fill, #A02020 stroke |
| `ui/heart_empty.svg` | Empty heart (missing HP) | #404040 fill, #303030 stroke |
| `ui/gold_coin.svg` | Gold coin icon | #FFD700 fill, #B8960F stroke |
| `ui/xp_star.svg` | XP star icon | #40A0E0 fill, #2060A0 stroke |
| `ui/sword_icon.svg` | Sword icon (menu) | #C0C8D0 fill, #808890 stroke |
| `ui/shield_icon.svg` | Shield icon (defense) | #5080C8 fill, #305080 stroke |
| `ui/potion_icon.svg` | HP potion icon | #E04040 fill (potion), #808080 stroke (bottle) |
| `ui/key_icon.svg` | Iron key icon (ch004 gate) | #B0B0B0 fill, #707070 stroke |
| `ui/skill_dodge.svg` | Dodge roll icon (skill1) | #40C0C0 fill, #208080 stroke |
| `ui/pause_icon.svg` | Pause bars icon | #FFFFFF fill |
| `ui/settings_icon.svg` | Gear icon | #C0C0C0 fill, #808080 stroke |
| `ui/arrow_right.svg` | Right arrow (UI nav) | #FFD700 fill |

### 2. Item Sprites (64x64 viewBox, pixel-art style)
These replace the current procedural PNGs. Each should be recognizable at 16px.

| File | Description | Colors |
|------|-------------|--------|
| `items/broken_sword.svg` | Rusty broken blade, chipped edge | #A0A8B0 blade, #8B2500 rust spots |
| `items/steel_dagger.svg` | Clean short dagger | #D0D8E0 blade, #604020 handle |
| `items/captains_blade.svg` | Ornate captain's sword | #E0E8F0 blade, #FFD700 guard, #604020 handle |
| `items/health_potion.svg` | Red HP potion bottle | #E04040 liquid, #808080 bottle, #C0C0C0 cork |

### 3. Title Screen Art (256x128 viewBox)
| File | Description | Colors |
|------|-------------|--------|
| `ui/title_sword.svg` | Crossed swords with banner for title screen | Gold #FFD700, Steel #5080C8, Dark #0D1117 |

### 4. Effects (32x32 viewBox)
| File | Description | Colors |
|------|-------------|--------|
| `effects/hit_spark.svg` | Small spark/impact effect | #FFE040 center, #FF8020 outer |
| `effects/heal_sparkle.svg` | Green sparkle (heal effect) | #40FF40 center, #20A020 outer |

## Technical Requirements
- SVG 1.1 compatible (Godot SVGTinyElement limits)
- All paths should use `viewBox` with consistent sizes
- No external font references
- No embedded bitmaps — pure vector
- Group elements with meaningful `<g id="...">` labels
- Use `stroke-linecap="round"` and `stroke-linejoin="round"` for clean pixel feel
- Each SVG must be valid XML with proper `xmlns`
- Keep file sizes small — optimize paths, no unnecessary decimals

## Godot Import Notes
- Godot 4.4 imports SVG as Texture2D via `SvgImporter`
- Set `svg/scale` in import settings for proper sizing
- SVGs placed in `assets/art/` will be auto-imported by Godot editor