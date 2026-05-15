#!/usr/bin/env python3
"""Generate procedural tileset images for Swordjin chapter arenas.

Creates a 16x16 pixel tileset PNG with themed tiles for each chapter:
  - Ch1 "The Rusted Blade"  → field/grass theme
  - Ch2 "The Merchant's Plea" → forest theme
  - Ch3 "The Iron Gate" → fortress/stone theme
  - Ch4 "The Gate Opens" → dark fortress theme

Tile types per theme:
  0: empty/void
  1: ground (walkable)
  2: wall (collision)
  3: wall_top (visual top edge)
  4: decoration (grass tuft, bush, crack, etc)
  5: path/road
  6: water/lava (hazard)

Output: assets/tileset_<theme>.png (16 tiles × 16px = 256×16 image)
"""

from PIL import Image
import os

TILE_SIZE = 16
TILE_COUNT = 7  # tile types 0-6
PALETTE_SCALE = 1  # each logical pixel = 1 real pixel (Godot scales via texture_filter)

# Theme color palettes: {tile_type: (r, g, b)}
THEMES = {
    "field": {
        0: (20, 26, 30),       # void
        1: (58, 72, 48),       # ground (dark grass)
        2: (42, 38, 35),       # wall (dark stone)
        3: (62, 56, 50),       # wall top (lighter stone)
        4: (70, 90, 45),       # decoration (grass tuft)
        5: (75, 65, 48),       # path (dirt)
        6: (35, 55, 75),       # water
    },
    "forest": {
        0: (25, 32, 25),       # void
        1: (48, 65, 38),       # ground (mossy)
        2: (35, 28, 22),       # wall (tree trunk / dark)
        3: (55, 45, 35),       # wall top (bark)
        4: (40, 80, 30),       # decoration (bush)
        5: (60, 52, 38),       # path (forest floor)
        6: (30, 50, 65),      # water (pond)
    },
    "fortress": {
        0: (35, 20, 15),       # void
        1: (65, 50, 42),       # ground (stone floor)
        2: (50, 35, 28),       # wall (dark brick)
        3: (75, 55, 45),       # wall top (lighter brick)
        4: (80, 40, 30),       # decoration (blood/crack)
        5: (55, 45, 38),       # path (worn stone)
        6: (80, 30, 15),       # lava
    },
    "dark_fortress": {
        0: (28, 14, 10),       # void
        1: (55, 40, 35),       # ground (dark stone)
        2: (40, 25, 20),       # wall (blackened brick)
        3: (60, 42, 35),       # wall top
        4: (70, 30, 20),       # decoration (ember)
        5: (48, 38, 32),       # path
        6: (90, 25, 10),       # lava (bright)
    },
}

# Per-tile pixel patterns (16x16). 0=base, 1=lighter, 2=darker, 3=accent
# Stored as list of (dy, dx, shade) for pixels that differ from base
TILE_PATTERNS = {
    0: [],  # solid void
    1: [    # ground with subtle noise
        (2, 3, 1), (4, 8, 2), (6, 1, 2), (8, 12, 1),
        (10, 5, 2), (12, 10, 1), (14, 3, 2), (3, 11, 1),
        (7, 6, 2), (11, 14, 1), (1, 9, 2), (13, 7, 1),
    ],
    2: [    # wall with brick lines
        # horizontal mortar lines
        (4, 0, 3), (4, 1, 3), (4, 2, 3), (4, 3, 3), (4, 4, 3),
        (4, 5, 3), (4, 6, 3), (4, 7, 3), (4, 8, 3), (4, 9, 3),
        (4, 10, 3), (4, 11, 3), (4, 12, 3), (4, 13, 3), (4, 14, 3), (4, 15, 3),
        (9, 0, 3), (9, 1, 3), (9, 2, 3), (9, 3, 3), (9, 4, 3),
        (9, 5, 3), (9, 6, 3), (9, 7, 3), (9, 8, 3), (9, 9, 3),
        (9, 10, 3), (9, 11, 3), (9, 12, 3), (9, 13, 3), (9, 14, 3), (9, 15, 3),
        # vertical offset mortar (staggered bricks)
        (0, 7, 3), (1, 7, 3), (2, 7, 3), (3, 7, 3),
        (5, 3, 3), (6, 3, 3), (7, 3, 3), (8, 3, 3),
        (10, 11, 3), (11, 11, 3), (12, 11, 3), (13, 11, 3),
    ],
    3: [    # wall top with highlight edge
        (0, 0, 1), (0, 1, 1), (0, 2, 1), (0, 3, 1), (0, 4, 1),
        (0, 5, 1), (0, 6, 1), (0, 7, 1), (0, 8, 1), (0, 9, 1),
        (0, 10, 1), (0, 11, 1), (0, 12, 1), (0, 13, 1), (0, 14, 1), (0, 15, 1),
        (15, 0, 2), (15, 1, 2), (15, 2, 2), (15, 3, 2), (15, 4, 2),
        (15, 5, 2), (15, 6, 2), (15, 7, 2), (15, 8, 2), (15, 9, 2),
        (15, 10, 2), (15, 11, 2), (15, 12, 2), (15, 13, 2), (15, 14, 2), (15, 15, 2),
    ],
    4: [    # decoration — small cross/dot pattern
        (6, 7, 1), (6, 8, 1), (7, 6, 1), (7, 7, 1), (7, 8, 1), (7, 9, 1),
        (8, 7, 1), (8, 8, 1), (9, 7, 1),
    ],
    5: [    # path with worn center
        (7, 4, 1), (7, 5, 1), (7, 6, 1), (7, 7, 1), (7, 8, 1),
        (7, 9, 1), (7, 10, 1), (7, 11, 1),
        (8, 4, 1), (8, 5, 1), (8, 6, 1), (8, 7, 1), (8, 8, 1),
        (8, 9, 1), (8, 10, 1), (8, 11, 1),
    ],
    6: [    # water/lava with ripple
        (3, 4, 1), (3, 5, 1), (3, 6, 1), (3, 7, 1), (3, 8, 1), (3, 9, 1), (3, 10, 1), (3, 11, 1),
        (7, 2, 1), (7, 3, 1), (7, 4, 1), (7, 5, 1), (7, 6, 1), (7, 7, 1), (7, 8, 1),
        (7, 9, 1), (7, 10, 1), (7, 11, 1), (7, 12, 1), (7, 13, 1),
        (11, 4, 1), (11, 5, 1), (11, 6, 1), (11, 7, 1), (11, 8, 1), (11, 9, 1), (11, 10, 1), (11, 11, 1),
    ],
}

def shade_color(base_rgb, shade):
    """Apply shade modifier to base color. 0=base, 1=lighter, 2=darker, 3=mortar/accent."""
    r, g, b = base_rgb
    if shade == 0:
        return (r, g, b)
    elif shade == 1:  # lighter
        return (min(r + 18, 255), min(g + 18, 255), min(b + 18, 255))
    elif shade == 2:  # darker
        return (max(r - 14, 0), max(g - 14, 0), max(b - 14, 0))
    elif shade == 3:  # mortar/accent (much darker)
        return (max(r - 25, 0), max(g - 25, 0), max(b - 25, 0))
    return (r, g, b)


def generate_tile(theme_name: str, tile_type: int) -> Image.Image:
    """Generate a single 16x16 tile image."""
    colors = THEMES[theme_name]
    base = colors.get(tile_type, colors[1])
    pattern = TILE_PATTERNS.get(tile_type, [])
    
    img = Image.new("RGB", (TILE_SIZE, TILE_SIZE), base)
    pixels = img.load()
    
    for dy, dx, shade in pattern:
        if 0 <= dy < TILE_SIZE and 0 <= dx < TILE_SIZE:
            pixels[dx, dy] = shade_color(base, shade)
    
    return img


def generate_tileset(theme_name: str) -> Image.Image:
    """Generate full tileset: TILE_COUNT tiles side by side."""
    total_w = TILE_COUNT * TILE_SIZE
    tileset = Image.new("RGB", (total_w, TILE_SIZE), (0, 0, 0))
    
    for tile_type in range(TILE_COUNT):
        tile = generate_tile(theme_name, tile_type)
        tileset.paste(tile, (tile_type * TILE_SIZE, 0))
    
    return tileset


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "assets")
    os.makedirs(out_dir, exist_ok=True)
    
    for theme_name in THEMES:
        tileset = generate_tileset(theme_name)
        path = os.path.join(out_dir, f"tileset_{theme_name}.png")
        tileset.save(path)
        print(f"  Generated: {path} ({tileset.width}x{tileset.height})")
    
    print("Done. All tilesets generated.")


if __name__ == "__main__":
    main()