import wave
import struct
import math
import os

OUTPUT_DIR = "/home/kirk/.picoclaw/workspace/Swordjin_Godot/assets/sfx"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SAMPLE_RATE = 22050

def write_wav(filename, samples):
    path = os.path.join(OUTPUT_DIR, filename)
    w = wave.open(path, "w")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SAMPLE_RATE)
    for s in samples:
        w.writeframesraw(struct.pack("<h", int(max(-32767, min(32767, s)))))
    w.close()
    print("Generated:", path)

def silence(duration: float):
    n = int(SAMPLE_RATE * duration)
    return [0] * n

def sine_tone(freq: float, duration: float, amplitude: float = 0.4):
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * math.sin(2 * math.pi * freq * t / SAMPLE_RATE) for t in range(n)]

def noise(duration: float, amplitude: float = 0.3):
    import random
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * (random.random() * 2 - 1) for _ in range(n)]

def tone_with_decay(freq: float, duration: float, amplitude: float = 0.4):
    n = int(SAMPLE_RATE * duration)
    out = []
    for t in range(n):
        env = 1.0 - (t / n)
        out.append(amplitude * 32767 * env * math.sin(2 * math.pi * freq * t / SAMPLE_RATE))
    return out

def pulse(freq: float, duration: float, duty: float = 0.5, amplitude: float = 0.4):
    n = int(SAMPLE_RATE * duration)
    out = []
    period = SAMPLE_RATE / freq
    for t in range(n):
        env = 1.0 - (t / n)
        val = 1.0 if (t % period) < (period * duty) else -1.0
        out.append(amplitude * 32767 * env * val)
    return out

# Sword Swing — quick low-to-high sweep
sword_swing = []
for freq in range(200, 800, 40):
    sword_swing += sine_tone(freq, 0.01, 0.35)
write_wav("sword_swing.wav", sword_swing)

# Sword Hit — short noise burst + thud
hit = []
hit += noise(0.04, 0.5)
hit += tone_with_decay(120, 0.08, 0.4)
write_wav("sword_hit.wav", hit)

# Skeleton Death — descending low tones + crunch
death = []
for freq in [220, 180, 140, 100]:
    death += tone_with_decay(freq, 0.06, 0.3)
death += noise(0.08, 0.2)
write_wav("skeleton_death.wav", death)

# Player Hurt — sharp high tone
hurt = []
hurt += pulse(600, 0.04, 0.3, 0.5)
hurt += sine_tone(400, 0.06, 0.35)
write_wav("player_hurt.wav", hurt)

# Shield Block — metallic clink
block = []
block += pulse(800, 0.03, 0.2, 0.4)
block += sine_tone(400, 0.04, 0.3)
block += noise(0.02, 0.15)
write_wav("shield_block.wav", block)

# Captain Charge — long low ramp rampage
charge = []
for freq in range(100, 250, 5):
    charge += sine_tone(freq, 0.005, 0.4)
charge += noise(0.1, 0.15)
write_wav("captain_charge.wav", charge)

# Level Complete — bright ascending chime
complete = []
for freq in [440, 554, 659, 880]:
    complete += tone_with_decay(freq, 0.12, 0.35)
write_wav("level_complete.wav", complete)

# UI Click — short blip
click = []
click += sine_tone(1000, 0.03, 0.25)
write_wav("ui_click.wav", click)

print("✅ All SFX placeholders generated in", OUTPUT_DIR)
