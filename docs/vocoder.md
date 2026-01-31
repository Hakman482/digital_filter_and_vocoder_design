# Speech Vocoder Implementation (MATLAB)

## Objective
Implement and analyze a classical channel vocoder that preserves speech intelligibility while replacing harmonic structure with band-limited noise, producing a robotic/synthetic timbre.

## System overview
A vocoder uses:
- **Modulator:** speech
- **Carrier:** white noise (in this implementation)

Pipeline per channel:
1) Band-pass filter speech into a channel band
2) Envelope detection:
   - half-wave rectification
   - low-pass filtering to obtain a smooth envelope
3) Multiply envelope by noise carrier
4) Band-pass filter modulated noise using the matched synthesis filter
5) Sum channels to obtain full-band output

## Key parameters (from implementation)
- Audio: `bkbe2114.wav`
- Sampling frequency: **Fs = 22,000 Hz**
- Analysis bandwidth: **0–11 kHz**
- Number of channels: **12**
- Channel cutoffs computed from:
  \[
  f = 165.4(100.06^{x}-1)
  \]
  producing:
  **[0, 69.53, 168.28, 308.55, 507.79, 790.77, 1192.71, 1763.61, 2574.51, 3726.27, 5362.19, 7685.79, 11000] Hz**
- Analysis/synthesis filters: **elliptic IIR band-pass** per channel
- Envelope LPF: **Butterworth IIR, order 3, fc = 160 Hz**
- Carrier: white noise (same length as input)

## Stage-by-stage signal interpretation
### Original speech (time + spectrum)
- Time domain: speech bursts (syllables/words) separated by low-energy intervals.
- Spectrum: strongest energy at low frequencies, with formant regions typically below ~4–5 kHz.

### After rectification
- Time domain becomes unipolar (negative samples clipped).
- Spectrum gains strong low-frequency/DC components, representing envelope information.

### After 160 Hz low-pass filtering (envelope)
- Time domain becomes a smooth envelope that tracks loudness in that band.
- Spectrum is concentrated below 160 Hz (slow modulation only).

### Envelope × white noise (modulation)
- Time domain looks noisy again, but with amplitude “clouds” aligned to speech rhythm.
- Spectrum becomes broadband (noise-like), with slow modulation imposed by the envelope.

### After synthesis band-pass filtering
- Noise is constrained to the channel band; energy outside the band is attenuated.
- Each channel contributes band-limited, envelope-shaped noise.

### Final output (sum of channels)
- Time domain: dense/noisy waveform with a global envelope similar to original speech.
- Spectrum: more noise-like than original but shows an overall spectral envelope that carries intelligibility.

## What this demonstrates (DSP takeaways)
- Why rectification + LPF is a practical envelope detector
- How filter banks encode speech spectral envelope over time
- Why more channels generally improve intelligibility (better spectral resolution), at higher computational cost
