import wave
import struct
import math
import random
import os

OUTPUT_DIR = "/home/kirk/.picoclaw/workspace/Swordjin_Godot/assets/sfx"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100  # Higher quality

def write_wav(filename, samples, sr=SAMPLE_RATE):
    path = os.path.join(OUTPUT_DIR, filename)
    w = wave.open(path, "w")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    for s in samples:
        w.writeframesraw(struct.pack("<h", int(max(-32767, min(32767, s)))))
    w.close()
    print("Generated:", path)

def noise(duration, amplitude=0.3, seed=None):
    if seed:
        random.seed(seed)
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * (random.random() * 2 - 1) for _ in range(n)]

def sine_tone(freq, duration, amplitude=0.4):
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * math.sin(2 * math.pi * freq * t / SAMPLE_RATE) for t in range(n)]

def tone_with_decay(freq, duration, amplitude=0.4, decay_exp=1.0):
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * ((1.0 - t/n)**decay_exp) * math.sin(2 * math.pi * freq * t / SAMPLE_RATE) for t in range(n)]

def pulse(freq, duration, duty=0.5, amplitude=0.4):
    n = int(SAMPLE_RATE * duration)
    out = []
    period = SAMPLE_RATE / freq
    for t in range(n):
        env = 1.0 - (t / n)
        val = 1.0 if (t % period) < (period * duty) else -1.0
        out.append(amplitude * 32767 * env * val)
    return out

def filtered_noise(duration, center_freq, bandwidth=0.3, amplitude=0.3):
    """Bandpass-filtered-ish noise using ring modulation."""
    n = int(SAMPLE_RATE * duration)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        nval = random.random() * 2 - 1
        carrier = math.sin(2 * math.pi * center_freq * t)
        # Simple modulation to concentrate energy around center_freq
        val = nval * carrier
        env = 1.0
        if t < 0.01:
            env = t / 0.01
        elif t > duration - 0.05:
            env = max(0, (duration - t) / 0.05)
        out.append(amplitude * 32767 * env * val)
    return out

def whoosh(duration=0.2, amplitude=0.4):
    """White noise with descending filter sweep."""
    n = int(SAMPLE_RATE * duration)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        nval = random.random() * 2 - 1
        # Descending cutoff
        cutoff = 8000 * (1 - t/duration) + 200
        # Simple lowpass approximation: sample-and-hold at cutoff rate
        hold = int(SAMPLE_RATE / cutoff)
        if i % hold == 0:
            out.append(amplitude * 32767 * nval)
        else:
            out.append(out[-1] if out else 0)
    # Add subtle sine sweep
    sweep = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 400 * (1 - t/duration) + 100
        sweep.append(0.15 * 32767 * math.sin(2 * math.pi * freq * t))
    return [a + b for a, b in zip(out, sweep)]

# === SFX v2: Better quality ===

# Sword Swing — whoosh + subtle metal shimmer
swing = whoosh(0.18, 0.35)
swing += [s * 0.3 for s in sine_tone(800, 0.04, 0.2)]  # metal shimmer tail
write_wav("sword_swing.wav", swing)

# Sword Hit — layered: crisp transient + body + decay
hit = []
hit += filtered_noise(0.03, 3000, amplitude=0.5)  # crisp transient
hit += tone_with_decay(150, 0.10, 0.4, 2.0)         # thud body
hit += tone_with_decay(60, 0.15, 0.25, 1.5)          # sub rumble
write_wav("sword_hit.wav", hit)

# Skeleton Death — rattle + descending bones + crunch
death = []
for freq in [350, 280, 220, 160, 100]:
    death += tone_with_decay(freq, 0.05, 0.25, 1.2)
death += filtered_noise(0.06, 1500, amplitude=0.2)  # crunch
death += [s * 0.15 for s in noise(0.04, 0.3)]  # debris
write_wav("skeleton_death.wav", death)

# Player Hurt — sharp sting + dull thud
hurt = []
hurt += pulse(800, 0.02, 0.2, 0.5)
hurt += sine_tone(500, 0.03, 0.3)
hurt += tone_with_decay(200, 0.08, 0.3, 1.5)
write_wav("player_hurt.wav", hurt)

# Shield Block — metallic ring + low thud
block = []
block += pulse(1200, 0.04, 0.15, 0.35)   # bright metallic
block += sine_tone(600, 0.05, 0.25)       # ring
block += tone_with_decay(100, 0.08, 0.3, 1.0)  # thud
block += filtered_noise(0.02, 4000, amplitude=0.15)  # spark
write_wav("shield_block.wav", block)

# Captain Charge — low rumble ramp + war cry trail
charge = []
for freq in range(80, 220, 3):
    charge += sine_tone(freq, 0.004, 0.35)
charge += [s * 0.2 for s in filtered_noise(0.10, 300, amplitude=0.3)]
charge += tone_with_decay(50, 0.20, 0.2, 0.8)  # sub rumble
write_wav("captain_charge.wav", charge)

# Level Complete — bright major triad arpeggio
complete = []
for freq, dur in [(523, 0.15), (659, 0.15), (784, 0.15), (1047, 0.25)]:
    complete += tone_with_decay(freq, dur, 0.35, 1.5)
write_wav("level_complete.wav", complete)

# UI Click — short bright blip
click = sine_tone(1200, 0.02, 0.2)
click += [s * 0.5 for s in sine_tone(1800, 0.01, 0.15)]
write_wav("ui_click.wav", click)

print("✅ All SFX v2 generated with higher quality (44.1kHz) in", OUTPUT_DIR)

# === New SFX: Arrow sounds ===

# Bow Fire (string twang + airy release)
bow_fire = []
bow_fire += tone_with_decay(220, 0.05, 0.4, 1.5)   # low twang
bow_fire += tone_with_decay(440, 0.03, 0.3, 1.0)     # high twang
bow_fire += filtered_noise(0.06, 2000, amplitude=0.25)  # airy release
bow_fire += [s * 0.15 for s in whoosh(0.08, 0.3)]      # arrow launch whoosh
write_wav("bow_fire.wav", bow_fire)

# Arrow Hit (sharp thud + wood crack)
arrow_hit = []
arrow_hit += filtered_noise(0.02, 3500, amplitude=0.5)  # sharp transient
arrow_hit += tone_with_decay(400, 0.04, 0.35, 2.0)       # thud
arrow_hit += tone_with_decay(800, 0.02, 0.2, 1.5)        # crack
write_wav("arrow_hit.wav", arrow_hit)

# Arrow Impact (duller — wall/floor hit)
arrow_impact = []
arrow_impact += filtered_noise(0.03, 1200, amplitude=0.35)  # body
arrow_impact += tone_with_decay(250, 0.06, 0.3, 1.8)           # sub thud
arrow_impact += [s * 0.1 for s in filtered_noise(0.02, 5000, amplitude=0.2)]  # debris
write_wav("arrow_impact.wav", arrow_impact)

print("✅ +3 arrow SFX generated with higher quality (44.1kHz) in", OUTPUT_DIR)
