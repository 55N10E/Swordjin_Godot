import wave, struct, math, os

OUTPUT = "/home/kirk/.picoclaw/workspace/Swordjin_Godot/assets/bgm/theme01_ambience.wav"
SR = 22050
DURATION = 30.0
n = int(SR * DURATION)
samples = []

for t in range(n):
    lfo = 0.5 + 0.5 * math.sin(2 * math.pi * 0.1 * t / SR)
    s = 0.15 * math.sin(2 * math.pi * 60 * t / SR) * lfo
    s += 0.10 * math.sin(2 * math.pi * 58 * t / SR) * (1 - lfo)
    s += 0.05 * math.sin(2 * math.pi * 120 * t / SR) * lfo
    samples.append(s * 32767)

w = wave.open(OUTPUT, "w")
w.setnchannels(1)
w.setsampwidth(2)
w.setframerate(SR)
fmt = "<{n}h".format(n=len(samples))
w.writeframes(struct.pack(fmt, *map(int, samples)))
w.close()

print("Generated", OUTPUT, "size", os.path.getsize(OUTPUT), "bytes")
