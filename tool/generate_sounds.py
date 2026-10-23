"""Generate original chess feedback sounds; no external samples required."""

import math
from pathlib import Path
import random
import struct
import wave

RATE = 44100
DEST = Path(__file__).resolve().parents[1] / "assets" / "sounds"


def impact(t, seed, frequency):
    rng = random.Random(seed)
    # A repeatable short noise impulse plus damped wooden resonances.
    noise = rng.uniform(-1, 1) * math.exp(-t * 120)
    return noise * 0.28 + sum(
        math.sin(2 * math.pi * frequency * ratio * t) * math.exp(-t * decay) * gain
        for ratio, decay, gain in [(1, 35, 0.48), (2.73, 55, 0.18)]
    )


def render(name, duration, sample):
    values = []
    count = round(duration * RATE)
    for n in range(count):
        t = n / RATE
        fade = min(1, n / 90, (count - 1 - n) / 350)
        value = max(-1, min(1, sample(t, n) * fade))
        values.append(round(value * 26000))
    with wave.open(str(DEST / f"{name}.wav"), "wb") as output:
        output.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        output.writeframes(struct.pack(f"<{len(values)}h", *values))


def capture(t, n):
    value = impact(t, n, 310) * 0.65
    if t >= 0.065:
        value += impact(t - 0.065, n + 19, 210) * 0.7
    return value


def check(t, _n):
    value = 0
    for start, frequency in [(0, 660), (0.12, 880)]:
        age = t - start
        if age >= 0:
            attack = min(1, age / 0.008)
            value += 0.36 * attack * math.exp(-age * 15) * math.sin(
                2 * math.pi * frequency * age
            )
    return value


if __name__ == "__main__":
    DEST.mkdir(parents=True, exist_ok=True)
    render("move", 0.18, lambda t, n: impact(t, n, 380))
    render("capture", 0.29, capture)
    render("check", 0.45, check)
