#!/usr/bin/env python3
"""Swordjin Sprite Sheet Generator v2 — Animated pixel art sprites.

Generates sprite sheets for all characters with idle, walk, and attack frames.
Each sprite sheet is a horizontal strip: frame0, frame1, frame2, ...
Frame size: 16x16 pixels, scaled 2x = 32x32 display.
"""
import os
from PIL import Image, ImageDraw

OUT = "/home/kirk/.picoclaw/workspace/Swordjin_Godot/assets/art"
SCALE = 2
SPRITE_SIZE = 16  # logical pixels per frame

def px(draw, x, y, color, s=SCALE):
    draw.rectangle([x*s, y*s, (x+1)*s-1, (y+1)*s-1], fill=color)

def draw_sprite(draw, ox, oy, pixels, palette, s=SCALE):
    """Draw a single sprite at offset (ox, oy) in logical pixels."""
    for y, row in enumerate(pixels):
        for x, ch in enumerate(row):
            color = palette.get(ch, (0,0,0,0))
            if color[3] > 0:
                px(draw, ox+x, oy+y, color, s)

def make_sheet(name, frames, palette, subdir, frame_w=16, frame_h=16):
    """Create a horizontal sprite sheet from a list of frame definitions."""
    out_dir = f"{OUT}/{subdir}"
    os.makedirs(out_dir, exist_ok=True)
    out_path = f"{out_dir}/{name}.png"
    
    w = frame_w * SCALE * len(frames)
    h = frame_h * SCALE
    img = Image.new("RGBA", (w, h), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    
    for i, frame_pixels in enumerate(frames):
        draw_sprite(draw, i * frame_w, 0, frame_pixels, palette)
    
    img.save(out_path)
    print(f"  {name}.png — {len(frames)} frames, {w}x{h}px")
    return out_path

# === PALETTES ===
PLAYER_PAL = {
    ' ': (0,0,0,0),
    'h': (100,60,30,255),    # hair dark brown
    'H': (140,80,40,255),    # hair light
    's': (220,180,140,255),  # skin
    'S': (190,150,110,255),  # skin shadow
    'b': (50,80,160,255),    # blue tunic
    'B': (30,55,120,255),    # blue tunic shadow
    'd': (60,45,30,255),     # dark brown (boots/belt)
    'l': (180,160,120,255),  # leather
    'w': (200,200,210,255),  # sword blade
    'W': (240,240,250,255),  # sword blade highlight
    'r': (160,40,40,255),    # red accent
    'c': (80,80,80,255),     # dark gray
}

SKELETON_PAL = {
    ' ': (0,0,0,0),
    'b': (220,230,240,255),  # bone white
    'B': (180,190,200,255),  # bone shadow
    'e': (0,220,0,255),      # eye glow green
    'E': (0,160,0,255),      # eye dim
    'd': (50,50,60,255),     # dark joint
    'r': (100,30,30,255),    # rust on captain
    's': (30,35,45,255),     # shield dark
    'S': (60,70,80,255),     # shield light
    'g': (180,160,40,255),   # gold trim
}

CAPTAIN_PAL = {
    ' ': (0,0,0,0),
    'b': (220,230,240,255),
    'B': (180,190,200,255),
    'e': (220,0,0,255),      # red eyes
    'E': (160,0,0,255),
    'd': (50,50,60,255),
    'r': (100,30,30,255),
    's': (80,80,100,255),    # shield
    'S': (120,120,140,255),
    'g': (180,160,40,255),   # gold
}

ARCHER_PAL = {
    ' ': (0,0,0,0),
    'b': (200,210,220,255),
    'B': (160,170,180,255),
    'e': (0,180,0,255),
    'E': (0,120,0,255),
    'd': (50,50,60,255),
    'a': (120,70,30,255),    # bow wood
    'A': (160,100,40,255),   # bow highlight
    'f': (60,100,40,255),    # fletching
}

MERCHANT_PAL = {
    ' ': (0,0,0,0),
    's': (220,180,140,255),  # skin
    'S': (190,150,110,255),
    'p': (140,40,140,255),   # purple robe
    'P': (100,20,100,255),
    'h': (100,60,30,255),   # hat
    'H': (130,80,40,255),
    'g': (180,160,40,255),   # gold
    'd': (60,45,30,255),
}

# === SPRITE FRAMES ===
# Each frame is a 16x16 character grid

# --- PLAYER ---
PLAYER_IDLE_0 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_IDLE_1 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_IDLE_2 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_WALK_0 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "     d         ", "     d d       ",
    "      dd       ", "     dd        ", "                ", "                ",
]

PLAYER_WALK_1 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_WALK_2 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "        d      ", "       d d     ",
    "        dd     ", "        dd     ", "                ", "                ",
]

PLAYER_ATTACK_0 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_ATTACK_1 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss  w   ", "     bbb  wW   ", "    bBbbBwwW   ", "    bbbbbBww    ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_ATTACK_2 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSssSss    ",
    "     ssss wW   ", "     bbb wwW   ", "    bBbbBwwW   ", "    bbbbbB w    ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

PLAYER_ATTACK_3 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     bbb       ", "    bBbbBb     ", "    bbbbbB     ",
    "     bbbb      ", "     bbbb      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

# --- SKELETON ---
SKELETON_IDLE_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    bb    bb    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_IDLE_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    bb    bb    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_WALK_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    b      B    ", "   bB           ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_WALK_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    B      b    ", "          Bb    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_ATTACK_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    bb    bb    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

SKELETON_ATTACK_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb  d  ", "      bbbbB d   ", "      bbbb  d   ", "     bb  bb d   ",
    "    bb    bb    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

# --- SKELETON CAPTAIN ---
CAPTAIN_IDLE_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "    sss  sss    ", "    d      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

CAPTAIN_IDLE_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "    sss  sss    ", "    d      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

CAPTAIN_WALK_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "    s      sss  ", "   dS      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

CAPTAIN_WALK_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "   sss      s   ", "    d      Sd   ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

CAPTAIN_ATTACK_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     ss  ss     ",
    "    sss  sss    ", "    d      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

CAPTAIN_ATTACK_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb  s  ", "      bbbbS sS  ", "      bbbb  sS  ", "     ss  ss sS  ",
    "    sss  sss    ", "    d      d    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

# --- SKELETON ARCHER ---
ARCHER_IDLE_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    b      b    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

ARCHER_IDLE_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    b      b    ", "    B      B    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

ARCHER_WALK_0 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    b       B   ", "   bB          ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

ARCHER_WALK_1 = [
    "       bb       ", "      bbbb      ", "     bb  bb     ", "     b eeeb     ",
    "     b BBBb     ", "      bbbb      ", "      bbbb      ", "     bb  bb     ",
    "    B       b   ", "          Bb    ", "                ", "                ",
    "                ", "                ", "                ", "                ",
]

# --- MERCHANT ---
MERCHANT_IDLE_0 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     ppp       ", "    pPppPp     ", "    pppppP     ",
    "     pppp      ", "     pppp      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

MERCHANT_IDLE_1 = [
    "     hhhhhh     ", "    hHHHHHh    ", "    ssssss     ", "    sSsSss     ",
    "     ssss      ", "     ppp       ", "    pPppPp     ", "    pppppP     ",
    "     pppp      ", "     pppp      ", "      dd       ", "     d  d      ",
    "     d  d      ", "    dd  dd     ", "                ", "                ",
]

if __name__ == "__main__":
    print("=== Swordjin Sprite Sheet Generator v2 ===\n")
    
    print("[Player]")
    make_sheet("player_idle", [PLAYER_IDLE_0, PLAYER_IDLE_1, PLAYER_IDLE_2], PLAYER_PAL, "characters")
    make_sheet("player_walk", [PLAYER_WALK_0, PLAYER_WALK_1, PLAYER_WALK_2], PLAYER_PAL, "characters")
    make_sheet("player_attack", [PLAYER_ATTACK_0, PLAYER_ATTACK_1, PLAYER_ATTACK_2, PLAYER_ATTACK_3], PLAYER_PAL, "characters")
    
    print("\n[Skeleton]")
    make_sheet("skeleton_idle", [SKELETON_IDLE_0, SKELETON_IDLE_1], SKELETON_PAL, "enemies")
    make_sheet("skeleton_walk", [SKELETON_WALK_0, SKELETON_WALK_1], SKELETON_PAL, "enemies")
    make_sheet("skeleton_attack", [SKELETON_ATTACK_0, SKELETON_ATTACK_1], SKELETON_PAL, "enemies")
    
    print("\n[Skeleton Captain]")
    make_sheet("captain_idle", [CAPTAIN_IDLE_0, CAPTAIN_IDLE_1], CAPTAIN_PAL, "enemies")
    make_sheet("captain_walk", [CAPTAIN_WALK_0, CAPTAIN_WALK_1], CAPTAIN_PAL, "enemies")
    make_sheet("captain_attack", [CAPTAIN_ATTACK_0, CAPTAIN_ATTACK_1], CAPTAIN_PAL, "enemies")
    
    print("\n[Skeleton Archer]")
    make_sheet("archer_idle", [ARCHER_IDLE_0, ARCHER_IDLE_1], ARCHER_PAL, "enemies")
    make_sheet("archer_walk", [ARCHER_WALK_0, ARCHER_WALK_1], ARCHER_PAL, "enemies")
    
    print("\n[Merchant]")
    make_sheet("merchant_idle", [MERCHANT_IDLE_0, MERCHANT_IDLE_1], MERCHANT_PAL, "npcs")
    
    print("\n=== Done! ===")