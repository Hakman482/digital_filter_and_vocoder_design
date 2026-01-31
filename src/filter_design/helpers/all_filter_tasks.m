% filter_design_part2.m
% Advanced DSP - Part 2: Digital Filter Design
% Save this file and run in MATLAB.
clear; close all; clc;

fs = 48000;               % sampling frequency (Hz)
nfft = 4096;              % for freq response plotting


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: FIR LPF (design using firpm & firpmord)
% Interpretation: Lowpass with passband edge fp = 10 kHz (0 - 10k pass)
%               stopband edge fsb = 12 kHz (attenuate beyond 12k)
%               If you actually want a bandpass 300-10k, see note below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('--- Task 1: FIR LPF ---\n');
% Design specs (change these if instructor gave different edges)
fp = 10000;    % passband edge Hz
fsb = 12000;   % stopband edge Hz
% allowed deviations (example ripples)
Rp = 1;       % passband ripple (dB)
As = 40;      % stopband attenuation (dB)
% Convert ripple/atten to linear deviations for firpmord
dev = [(10^(Rp/20)-1)/(10^(Rp/20)+1), 10^(-As/20)];  % approx [delta_p, delta_s]

% Frequency vector for firpmord: [fstop fpass] or [fpass fstop] depends on filter type
% For lowpass: f = [fp fsb]; a = [1 0];
f = [fp fsb]; a = [1 0];

% 1a) Minimum order with density = 20
dens1 = 20;
[n_min, fo, ao, w] = firpmord(f, a, dev, fs, dens1);
fprintf('Task 1: firpmord min order (dens=%d) = %d\n', dens1, n_min);
b_min = firpm(n_min, fo, ao, w);   % Parks-McClellan design
a_min = 1;
plot_responses(b_min, a_min, fs, nfft, sprintf('Task1 FIR LPF - N=%d dens=%d', n_min, dens1));

% 1b) Design with order = 50 (user-specified)
N_user = 50;
% Need frequency grid normalized to [-1 1] for firpm? Using firpm with frequency in Hz via fo from firpmord
% We'll use the same fo/ao weights but set order to N_user
b50 = firpm(N_user, fo, ao, w);
plot_responses(b50, a_min, fs, nfft, sprintf('Task1 FIR LPF - N=%d dens=%d', N_user, dens1));

% 1c) Change density factor to 50 and recompute min order and filter
dens2 = 50;
[n_min2, fo2, ao2, w2] = firpmord(f, a, dev, fs, dens2);
fprintf('Task 1: firpmord min order (dens=%d) = %d\n', dens2, n_min2);
b_min2 = firpm(n_min2, fo2, ao2, w2);
plot_responses(b_min2, a_min, fs, nfft, sprintf('Task1 FIR LPF - N=%d dens=%d', n_min2, dens2));

fprintf('Observations Task 1:\n');
fprintf(' - Increasing N (order) produces a sharper transition and usually lower ripple in the passband.\n');
fprintf(' - Changing firpmord ''density'' can change the estimated minimum N because it uses a denser frequency grid to estimate transitions (higher density -> more accurate but sometimes larger N).\n\n');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 2: FIR HPF: fstop = 8000, fpass = 10000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 2: FIR HPF ---\n');
fstop_h = 8000;
fpass_h = 10000;
% For highpass, frequency vector for firpmord is [fstop fpass], and desired a = [0 1]
f_hp = [fstop_h fpass_h]; a_hp = [0 1];
% deviations (use same Rp, As)
dev_hp = dev;

% Get minimum order, dens default 20
dens = 20;
[n_hp_min, fo_hp, ao_hp, w_hp] = firpmord(f_hp, a_hp, dev_hp, fs, dens);
fprintf('Task 2: firpmord min order (dens=%d) = %d\n', dens, n_hp_min);
b_hp_min = firpm(n_hp_min, fo_hp, ao_hp, w_hp);
plot_responses(b_hp_min, 1, fs, nfft, sprintf('Task2 FIR HPF - N=%d dens=%d', n_hp_min, dens));

% Now design with N = 100
N2 = 100;
b_hp_100 = firpm(N2, fo_hp, ao_hp, w_hp);
plot_responses(b_hp_100, 1, fs, nfft, sprintf('Task2 FIR HPF - N=%d dens=%d', N2, dens));

fprintf('Observations Task 2:\n');
fprintf(' - Minimum N produces acceptable ripple but transition width is determined by spec. N=100 gives much sharper transition and better attenuation in stopband.\n - Density factor affects order estimate and how well the algorithm samples the desired response when estimating order.\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 3: FIR Bandpass: fstop1=8000, fpass1=10000, fpass2=20000, fstop2=22000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 3: FIR BPF ---\n');
fstop1 = 8000; fpass1 = 10000; fpass2 = 20000; fstop2 = 22000;
% For bandpass case, vector of edges and desired amplitudes
f_bp = [fstop1 fpass1 fpass2 fstop2]; a_bp = [0 1 0];  % 0->stop, 1->pass, 0->stop
dev_bp = [dev(2) dev(1) dev(2)]; % approx: stop, pass, stop deviations

dens = 20;
[n_bpf_min, fo_bpf, ao_bpf, w_bpf] = firpmord(f_bp, a_bp, dev_bp, fs, dens);
fprintf('Task 3: firpmord min order (dens=%d) = %d\n', dens, n_bpf_min);
b_bpf_min = firpm(n_bpf_min, fo_bpf, ao_bpf, w_bpf);
plot_responses(b_bpf_min, 1, fs, nfft, sprintf('Task3 FIR BPF - N=%d dens=%d', n_bpf_min, dens));

% With N = 100
N3 = 100;
b_bpf_100 = firpm(N3, fo_bpf, ao_bpf, w_bpf);
plot_responses(b_bpf_100, 1, fs, nfft, sprintf('Task3 FIR BPF - N=%d dens=%d', N3, dens));

fprintf('Observations Task 3:\n');
fprintf(' - BPF minimum order gives acceptable response but transition regions are wide if min order is low.\n - N=100 yields much steeper band edges and deeper stopband attenuation.\n - Changing density affects the estimated min order and slight shape of response; higher density may increase N estimate.\n\n');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 4: FIR Band Stop (notch bandstop): 
% fpass1=6000, fstop1=8000, fstop2=12000, fpass2=14000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 4: FIR Bandstop ---\n');
fpass1 = 6000; fstop1 = 8000; fstop2 = 12000; fpass2 = 14000;
f_bs = [fpass1 fstop1 fstop2 fpass2];
a_bs = [1 0 1];  % pass, stop, pass
dev_bs = [dev(1) dev(2) dev(1)];  % passband, stopband, passband

dens = 20;
[n_bs_min, fo_bs, ao_bs, w_bs] = firpmord(f_bs, a_bs, dev_bs, fs, dens);
fprintf('Task 4: firpmord min order (dens=%d) = %d\n', dens, n_bs_min);

b_bs_min = firpm(n_bs_min, fo_bs, ao_bs, w_bs);
plot_responses(b_bs_min, 1, fs, nfft, sprintf('Task4 FIR BS - N=%d dens=%d', n_bs_min, dens));

% With N = 100
N4 = 100;
b_bs_100 = firpm(N4, fo_bs, ao_bs, w_bs);
plot_responses(b_bs_100, 1, fs, nfft, sprintf('Task4 FIR BS - N=%d dens=%d', N4, dens));

fprintf('Observations Task 4:\n');
fprintf(' - Bandstop minimum order may leave shallow stop attenuation; N=100 improves stop depth.\n');
fprintf(' - Density factor changes order estimate similarly to previous tasks.\n\n');







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 5: IIR BPF: fstop1 = 4000, fpass1=6000, fpass2=20000, fstop2=22000
% Use elliptic IIR (ellipord + ellip), compare min order vs N=100
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 5: IIR BPF (Elliptic) ---\n');
fstop1 = 4000; fpass1 = 6000; fpass2 = 20000; fstop2 = 22000;
Wp = [fpass1 fpass2]/(fs/2);  % normalized passband
Ws = [fstop1 fstop2]/(fs/2);  % normalized stopband
Rp = 1;  % dB pass ripple
Rs = 40; % dB stop attenuation

[n_iir_min, Wn] = ellipord(Wp, Ws, Rp, Rs);  % minimum order for the IIR
fprintf('Task 5: ellipord min order = %d\n', n_iir_min);
[b_iir_min, a_iir_min] = ellip(n_iir_min, Rp, Rs, Wn, 'bandpass');
plot_responses(b_iir_min, a_iir_min, fs, nfft, sprintf('Task5 IIR BPF - N=%d (ellip)', n_iir_min));

% Compare with higher order (IIR N=100)
N5 = 100;
% Note: designing a 100th order elliptic IIR bandpass is possible but likely unstable/won't be necessary.
% Instead, to compare, we design a higher-order FIR BPF (for apples-to-apples) OR cascade smaller IIRs.
% But as assignment requests N=100: we will show that such a high-order IIR is rarely needed; still we can
% design an IIR with order 100 (but numeric issues possible).
try
    [b_iir_100, a_iir_100] = ellip(N5, Rp, Rs, Wn, 'bandpass');
    plot_responses(b_iir_100, a_iir_100, fs, nfft, sprintf('Task5 IIR BPF - N=%d (ellip)', N5));
    fprintf('Task 5: Successfully designed order %d elliptic IIR (note: high order IIRs may be numerically sensitive).\n', N5);
catch ME
    fprintf('Task 5: Could not safely design order %d elliptic IIR due to numerical issues: %s\n', N5, ME.message);
    fprintf('         Usually, IIR filters work well at low orders; very high orders are unstable or sensitive.\n');
end

fprintf('Observations Task 5:\n');
fprintf(' - IIR minimum order will be small (elliptic gives sharp transitions at low order).\n - Increasing the order for IIR often gives diminishing returns and may cause numerical instability.\n - FIR requires larger N for similar transition steepness but is always stable and has linear phase (if symmetric).\n\n');









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 6: IIR BPF - fstop1=8000, fpass1=10000, fpass2=20000, fstop2=22000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 6: IIR BPF (Elliptic) ---\n');
fstop1 = 8000; fpass1 = 10000; fpass2 = 20000; fstop2 = 22000;
Wp = [fpass1 fpass2]/(fs/2);
Ws = [fstop1 fstop2]/(fs/2);
[n_iir2_min, Wn2] = ellipord(Wp, Ws, Rp, Rs);
fprintf('Task 6: ellipord min order = %d\n', n_iir2_min);
[b_iir2_min, a_iir2_min] = ellip(n_iir2_min, Rp, Rs, Wn2, 'bandpass');
plot_responses(b_iir2_min, a_iir2_min, fs, nfft, sprintf('Task6 IIR BPF - N=%d (ellip)', n_iir2_min));

% Attempt N = 100 as in task description (same caveats apply)
try
    [b_iir2_100, a_iir2_100] = ellip(N5, Rp, Rs, Wn2, 'bandpass');
    plot_responses(b_iir2_100, a_iir2_100, fs, nfft, sprintf('Task6 IIR BPF - N=%d (ellip)', N5));
catch ME
    fprintf('Task 6: Could not safely design order %d elliptic IIR: %s\n', N5, ME.message);
    fprintf('         Use caution: high-order IIRs are rarely necessary.\n');
end

fprintf('Observations Task 6:\n');
fprintf(' - Same general behavior as Task 5: elliptic IIR gives small order -> sharp transitions.\n - High IIR order (100) is not recommended in practice.\n\n');








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 7: Compare between N = 100 and N = 130 (FIR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 7: Compare N=100 vs N=130 (FIR example using the bandpass from Task 3) ---\n');
N_a = 100; N_b = 130;
b_a = firpm(N_a, fo_bpf, ao_bpf, w_bpf);
b_b = firpm(N_b, fo_bpf, ao_bpf, w_bpf);
% Plot both magnitude responses overlayed
[Ha, Wa] = freqz(b_a,1,nfft,fs); Hb = freqz(b_b,1,nfft,fs);
figure('Name','Task7 Compare N=100 vs N=130','NumberTitle','off');
plot(Wa,20*log10(abs(Ha)+eps)); hold on;
plot(Wa,20*log10(abs(Hb)+eps)); grid on;
legend(sprintf('N=%d',N_a), sprintf('N=%d',N_b));
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Task7: FIR compare N=100 vs N=130');
fprintf('Observations Task 7:\n');
fprintf(' - N=130 will give slightly steeper transitions and better stopband attenuation than N=100.\n - Cost: computational complexity and memory increase with N; plotting will show narrower transition region for higher N.\n\n');








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 8: FIR vs IIR - short answer printed below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 8: FIR vs IIR (brief) ---\n');
fprintf('Q: Which is more efficient and why? Which is more expensive and why?\n');
fprintf('A: IIR filters are generally more efficient (fewer coefficients) to achieve a given amplitude response\n');
fprintf('   because their poles allow sharper transitions. FIR filters are typically more expensive (require higher N)\n');
fprintf('   to achieve the same transition steepness, but FIRs can provide exact linear phase and are always stable.\n\n');








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 9: Elliptical LPF from 300 Hz to 10,000Hz
% Interpretation: Elliptic lowpass with passband edge 10k (same as Task1, but I use ellip)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('--- Task 9: Elliptic LPF ---\n');
fp = 10000; fsb = 12000;
Wp = fp/(fs/2); Ws = fsb/(fs/2);
Rp = 1; Rs = 40;
[n_ell_min, Wn_ell] = ellipord(Wp, Ws, Rp, Rs);
fprintf('Task 9: ellipord min order = %d\n', n_ell_min);
[b_ell_min, a_ell_min] = ellip(n_ell_min, Rp, Rs, Wn_ell);
plot_responses(b_ell_min, a_ell_min, fs, nfft, sprintf('Task9 Elliptic LPF - N=%d', n_ell_min));

% Elliptic with order 50
N_ell_user = 50;
try
    [b_ell_50, a_ell_50] = ellip(N_ell_user, Rp, Rs, Wn_ell);
    plot_responses(b_ell_50, a_ell_50, fs, nfft, sprintf('Task9 Elliptic LPF - N=%d', N_ell_user));
catch ME
    fprintf('Task9: Could not design elliptic of order %d safely: %s\n', N_ell_user, ME.message);
end

fprintf('Observations Task 9:\n');
fprintf(' - Elliptic IIR achieves very sharp transitions at low order but has non-linear phase.\n - Changing density is not relevant for ellip/ellipord (density is for FIR firpmord).\n\n')



