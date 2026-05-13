#!/usr/bin/env python3
import wave, struct, math, random, os

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "sfx")
os.makedirs(OUTPUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples, sr=SAMPLE_RATE):
    path = os.path.join(OUTPUT_DIR, filename)
    w = wave.open(path, "w")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    for s in samples:
        w.writeframesraw(struct.pack("h", int(max(-32767, min(32767, s)))))
    w.close()
    print("Generated: " + path)

def sine_tone(freq, duration, amplitude=0.4):
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * math.sin(2 * math.pi * freq * t / SAMPLE_RATE) for t in range(n)]

def tone_with_decay(freq, duration, amplitude=0.4, decay_exp=1.0):
    n = int(SAMPLE_RATE * duration)
    return [amplitude * 32767 * ((1.0 - t/n)**decay_exp) * math.sin(2 * math.pi * freq * t / SAMPLE_RATE) for t in range(n)]

def filtered_noise(duration, center_freq, amplitude=0.3):
    n = int(SAMPLE_RATE * duration)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        nval = random.random() * 2 - 1
        carrier = math.sin(2 * math.pi * center_freq * t)
        val = nval * carrier
        env = 1.0
        if t < 0.01:
            env = t / 0.01
        elif t > duration - 0.05:
            env = max(0, (duration - t) / 0.05)
        out.append(amplitude * 32767 * env * val)
    return out

def whoosh(duration=0.2, amplitude=0.4):
    n = int(SAMPLE_RATE * duration)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        nval = random.random() * 2 - 1
        cutoff = 8000 * (1 - t/duration) + 200
        hold = int(SAMPLE_RATE / cutoff)
        if i % hold == 0:
            out.append(amplitude * 32767 * nval)
        else:
            out.append(out[-1] if out else 0)
    sweep = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 400 * (1 - t/duration) + 100
        sweep.append(0.15 * 32767 * math.sin(2 * math.pi * freq * t))
    return [a + b for a, b in zip(out, sweep)]

# Bow Fire
bow_fire = []
bow_fire += tone_with_decay(220, 0.05, 0.4, 1.5)
bow_fire += tone_with_decay(440, 0.03, 0.3, 1.0)
bow_fire += filtered_noise(0.06, 2000, amplitude=0.25)
bow_fire += [s * 0.15 for s in whoosh(0.08, 0.3)]
write_wav("bow_fire.wav", bow_fire)

# Arrow Hit
arrow_hit = []
arrow_hit += filtered_noise(0.02, 3500, amplitude=0.5)
arrow_hit += tone_with_decay(400, 0.04, 0.35, 2.0)
arrow_hit += tone_with_decay(800, 0.02, 0.2, 1.5)
write_wav("arrow_hit.wav", arrow_hit)

# Arrow Impact
arrow_impact = []
arrow_impact += filtered_noise(0.03, 1200, amplitude=0.35)
arrow_impact += tone_with_decay(250, 0.06, 0.3, 1.8)
arrow_impact += [s * 0.1 for s in filtered_noise(0.02, 5000, amplitude=0.2)]
write_wav("arrow_impact.wav", arrow_impact)

print("Done! +3 arrow SFX in " + OUTPUT_DIR)
