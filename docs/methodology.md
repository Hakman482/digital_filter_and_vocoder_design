# Methodology

## Tools
- MATLAB
- MATLAB Filter Designer App (for IIR elliptic SOS verification)

## Part 1 — Vocoder workflow
1) Load input audio and confirm playback
2) Plot time-domain waveform
3) Plot magnitude spectrum using FFT for inspection
4) Generate white-noise carrier (same signal length)
5) Design analysis filter bank (12 elliptic band-pass filters)
6) For each channel:
   - band-pass filter speech
   - half-wave rectify
   - low-pass filter (Butterworth, order 3, 160 Hz) to extract envelope
   - multiply envelope with noise
   - synthesis band-pass filter (matched band)
7) Sum channels into final output
8) Plot and compare time + frequency representations across stages

## Part 2 — Filter design workflow (Fs = 48 kHz)
### FIR Equiripple
- Use `firpmord` for minimum order estimation
- Use `firpm` to design LPF/HPF/BPF/BSF
- Compare:
  - minimum order vs a fixed higher order (50/100/130 depending on task)
  - density factor 20 vs 50 (grid resolution)

### IIR Elliptic
- Use `ellipord` to estimate minimum order and band edges
- Use `ellip` to generate coefficients
- Verify in Filter Designer App using SOS structure
- Stress-test by forcing high orders (e.g., 50 or 100) and observe numerical/conditioning limitations

## Analysis outputs
For each filter:
- Magnitude response (dB)
- Phase response
- Group delay (samples)
