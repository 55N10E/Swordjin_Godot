import wave, math, struct, os

BASE = os.path.dirname(os.path.abspath(__file__))
BGM_DIR = os.path.join(BASE, "..", "assets", "bgm")
os.makedirs(BGM_DIR, exist_ok=True)

SAMPLE_RATE = 22050

def pad_tone(duration=5.0, freq=110.0, amp=0.15):
    n = int(SAMPLE_RATE * duration)
    data = bytearray()
    for i in range(n):
        t = i / SAMPLE_RATE
        env = 1.0 if t < 0.5 else max(0, 1 - (t - 0.5) / (duration - 0.5))
        s = math.sin(2 * math.pi * freq * t)
        s += 0.5 * math.sin(2 * math.pi * freq * 1.5 * t)
        s += 0.25 * math.sin(2 * math.pi * freq * 2.0 * t)
        val = int(32767 * amp * env * s)
        data += struct.pack('<h', val)
    return bytes(data)

def drone(duration=3.0, freq=65.41, amp=0.12):
    n = int(SAMPLE_RATE * duration)
    data = bytearray()
    for i in range(n):
        t = i / SAMPLE_RATE
        env = min(1.0, t * 2) * (1.0 if t < duration - 0.5 else (duration - t) * 2)
        s = math.sin(2 * math.pi * freq * t)
        s += 0.3 * math.sin(2 * math.pi * freq * 2.01 * t + 1)
        s += 0.15 * math.sin(2 * math.pi * freq * 3.01 * t + 2)
        val = int(32767 * amp * env * s)
        data += struct.pack('<h', val)
    return bytes(data)

def write_wav(name, audio, duration):
    path = os.path.join(BGM_DIR, name + ".wav")
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(audio)
    print("BGM: %s (%.1fs)" % (path, duration))

write_wav("bgm_title",  pad_tone(8.0,  110.0, 0.15), 8.0)
write_wav("bgm_battle", drone(4.0,   65.41, 0.12), 4.0)
print("Done")
