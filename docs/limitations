# Limitations & Improvements

## Limitations observed
1) **High-order elliptic IIR designs can fail in MATLAB code**
   - Forcing orders like N=100 produced “could not be safely designed” errors due to numerical ill-conditioning (poles/zeros crowding, coefficient sensitivity).

2) **Even when realized (SOS), very high-order IIR can be impractical**
   - Filter Designer (SOS) can generate the response, but group delay may exhibit extremely large spikes, making such filters unusable in real systems.

3) **Nonlinear phase and frequency-dependent delay in elliptic IIR**
   - Minimum-order elliptic designs meet magnitude specs efficiently, but phase wrapping and delay peaks near band edges distort waveform timing.

4) **Vocoder carrier choice limits naturalness**
   - White noise carrier produces classic robotic timbre; voiced/unvoiced separation is not explicitly modelled beyond envelope tracking.

## Improvements (next iteration)
- Implement IIR designs explicitly as **SOS** in code (not just in the app) using `sosfilt` and scaling.
- Add objective measures:
  - passband ripple and stopband attenuation verification
  - envelope bandwidth and intelligibility proxies for vocoder output
- Parameter sweeps:
  - vocoder: number of bands and envelope cutoff vs intelligibility
  - FIR: order vs attenuation vs latency tradeoff curve
- Add short audio demos:
  - original vs vocoded (5–10 seconds), stored under `data/audio_out/`
