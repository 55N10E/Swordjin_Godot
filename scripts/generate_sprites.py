#!/usr/bin/env python3
"""Procedural pixel art sprite generator for Swordjin."""
import os
from PIL import Image, ImageDraw

ASSETS = "/home/kirk/.picoclaw/workspace/Swordjin_Godot/assets/art"

def draw_pixel(draw, x, y, color, scale=1):
    draw.rectangle([x*scale, y*scale, (x+1)*scale-1, (y+1)*scale-1], fill=color)

def gen_sprite(name, pixels, palette, size=16, scale=2, subdir="characters"):
    out = f"{ASSETS}/{subdir}/{name}.png"
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img = Image.new("RGBA", (size*scale, size*scale), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    for y, row in enumerate(pixels):
        for x, ch in enumerate(row):
            color = palette.get(ch, (0,0,0,0))
            if color[3] > 0:
                draw_pixel(draw, x, y, color, scale)
    img.save(out)
    print(f"Generated {name}")

# Palettes
P = {' ': (0,0,0,0), 's': (200,50,50,255), 'h': (80,60,40,255), 
     'b': (60,100,180,255), 'd': (40,40,40,255), 'l': (200,170,120,255),
     'r': (160,40,40,255), 'w': (220,220,220,255), 'B': (30,30,120,255)}

Sk = {' ': (0,0,0,0), 'b': (220,230,240,255), 'B': (190,200,210,255),
      'e': (0,200,0,255), 'E': (200,0,0,255), 'd': (50,50,50,255), 's': (30,35,40,255)}

Pt = {' ': (0,0,0,0), 'r': (40,200,60,200), 'R': (20,120,30,200),
      'g': (150,150,150,200), 'G': (100,100,100,200), 'c': (200,200,200,200)}

# Sprites
PLAYER_IDLE = [
    "       hh       ", "      hssh      ", "      sssh      ", "       ss       ",
    "       bb       ", "      bBbb      ", "     bbBbbb     ", "     bBbbBb     ",
    "      bbb       ", "      bbb       ", "      d d       ", "      d d       ",
    "      d d       ", "     dd dd      ", "                ", "                ",
]

SKELETON_IDLE = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    bb    bb    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_CAPTAIN = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "    sss  sss    ", "    d      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

POTION = [
    "      cccc      ", "      cccc      ", "      gggg      ", "     grrrrg     ",
    "    gRRRRRrg    ", "    gRRRRRrg    ", "    gRRRRRrg    ", "     grrrrg     ",
    "      gggg      ", "       gg       ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SWORD_BROKEN = [
    "                ", "                ", "       dd       ", "       dd       ",
    "       dd       ", "       dd       ", "       dd       ", "       ll       ",
    "       ll       ", "       ll       ", "      llll      ", "      llll      ",
    "                ", "                ", "                ", "                ",
]

SWORD_STEEL = [
    "                ", "       dd       ", "       dd       ", "       dd       ",
    "       dd       ", "       dd       ", "       dd       ", "       ll       ",
    "       ll       ", "       ll       ", "      ssss      ", "      ssss      ",
    "                ", "                ", "                ", "                ",
]

if __name__ == "__main__":
    print("=== Generating Swordjin pixel art assets ===")
    gen_sprite("player_idle", PLAYER_IDLE, P)
    gen_sprite("skeleton_idle", SKELETON_IDLE, Sk, subdir="enemies")
    gen_sprite("skeleton_captain", SKELETON_CAPTAIN, Sk, subdir="enemies")
    gen_sprite("potion", POTION, Pt, subdir="items")
    gen_sprite("sword_broken", SWORD_BROKEN, Pt, subdir="items")
    gen_sprite("sword_steel", SWORD_STEEL, Pt, subdir="items")
    print("Done.")
