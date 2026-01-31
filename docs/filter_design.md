# Digital Filter Design & Analysis (MATLAB, Fs = 48 kHz)

## Objective
Design and analyze FIR and IIR filters in MATLAB, focusing on:
- LPF, HPF, BPF, BSF responses
- Order effects on magnitude, phase, and group delay
- Density factor effects in FIR equiripple design
- Practical limitations in high-order elliptic IIR design

All tasks use **Fs = 48 kHz** (Nyquist = 24 kHz).

---

## FIR Equiripple (Parks–McClellan: firpmord + firpm)

### Task 1 — FIR LPF
- Passband: 300 Hz to 10 kHz
- Specs: ~1 dB ripple, ~40 dB stopband attenuation
- Compared:
  - minimum order vs fixed **N = 50**
  - density factors **DF = 20 vs DF = 50**
Key result:
- Higher order sharpens transition and deepens stopband, but group delay increases (≈ N/2).
- Density factor does not change the true response; it mainly smooths the plotted curve.

### Task 2 — FIR HPF
- Stopband edge: 8 kHz
- Passband edge: 10 kHz
- Compared:
  - minimum order **N = 34** vs fixed **N = 100**
  - DF = 20 vs 50 (for N=100)
Key result:
- N=100 gives deeper stopband (~-100 to -120 dB) and sharper transition.
- Delay is constant: ~17 samples (N=34) vs ~50 samples (N=100).

### Task 3 — FIR BPF
- Passband: 10–20 kHz
- Stopbands: below 8 kHz and above 22 kHz
- Compared:
  - minimum order (~34) vs **N = 100**
  - DF = 20 vs 50
Key result:
- N=100 yields more rectangular bandpass and deeper stopbands (~-120 to -140 dB).
- Constant delay increases from ~17 to ~50 samples.

### Task 4 — FIR BSF (Notch)
- Reject: 8–12 kHz
- Pass: below 6 kHz and above 14 kHz
- Compared:
  - minimum order (~36) vs **N = 100**
  - DF = 20 vs 50
Key result:
- N=100 yields a much deeper notch (~-110 to -130 dB) and steeper transitions.
- Constant delay rises to ~50 samples for N=100.

### Task 7 — FIR order comparison (BPF)
- Same spec as Task 3
- Compared: **N = 100 vs N = 130**
Key result:
- Stopband improves (roughly -80 dB → -100 dB) with steeper roll-off.
- Delay increases from ~50 samples to ~65 samples (≈ N/2).
- Compute cost rises ~30% (extra taps).

**FIR takeaway:** Increasing order improves selectivity and stopband rejection but increases fixed latency and per-sample operations; density factor mainly improves frequency-grid/plot resolution, not filter behaviour.

---

## IIR Elliptic (ellipord + ellip, plus Filter Designer App)

### Task 5 — IIR Elliptic BPF
- Normalized edges (Nyquist = 24 kHz):
  - stop1 4 kHz, pass1 6 kHz, pass2 20 kHz, stop2 22 kHz
- Specs: ~1 dB ripple, ~80 dB attenuation
- Result:
  - Minimum order (≈4) meets spec with sharp transitions.
  - Forced **N = 100** fails in MATLAB code (“could not be safely designed”).
  - Filter Designer App (SOS) can realize N=100 but shows extreme delay spikes (impractical).

### Task 6 — IIR Elliptic BPF
- Passband: 10–20 kHz
- Stopbands: below 8 kHz and above 22 kHz
- Result:
  - Minimum order (≈5) meets spec; nonlinear phase and frequency-dependent delay peaks near band edges.
  - Forced N=100 fails in MATLAB code; App shows large delay spikes (order 10^4 samples).

### Task 9 — IIR Elliptic LPF
- Pass up to ~10 kHz (useful band from ~300 Hz)
- Minimum order ≈5 meets the spec with manageable delay.
- Forced **N = 50** shows pathological behaviour:
  - deep narrow notches (~-300 dB)
  - highly irregular phase near cutoff
  - significant negative delay spike (indicative of ill-conditioning / extreme sensitivity)

**IIR takeaway:** Elliptic IIR filters are highly efficient at low order for magnitude specs, but they introduce nonlinear phase and frequency-dependent delay. Forcing very high orders can produce numerical instability or unusable delay behaviour, even if SOS implementations “work” in tools.

---

## Task 8 — FIR vs IIR summary (engineering trade-off)
- **IIR:** lower order for same magnitude selectivity ⇒ lower compute and usually lower delay, but nonlinear phase and sensitivity/stability concerns.
- **FIR:** higher order (more compute) but linear phase and guaranteed stability with symmetric real coefficients; predictable constant group delay.
