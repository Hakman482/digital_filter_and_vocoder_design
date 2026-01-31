% ************** Load test sound:
[y, Fs] = audioread('bkbe2114.wav');
disp('Press Enter for original sound');
pause
soundsc(y, Fs);
% Create time vector representation of y
t = (0:length(y)-1)./Fs;

% ************** Plot the original sound wave:
figure;
subplot(2,4,1)
plot(t, y, 'b');
title('Original Sound Clip (time)');
ylabel('16-bit data');
xlabel('Time, s')
% ************** Calculate the FFT spectrum of the original sound:
y_fft_raw = abs(fft(y));
max_y_fft = max(y_fft_raw(:));
if max_y_fft > 0
    y_fft = y_fft_raw / max_y_fft;
else
    y_fft = y_fft_raw;
end
 % Normalize with small epsilon to avoid division by zero
Faxis = linspace(0, Fs, length(y)); % Frequency axis array
% ************** Plot the spectrum of the original sound:
subplot(2,4,5)
plot(Faxis, y_fft, 'b')
title('Original Sound Clip (Freq)');
xlabel('Frequency, Hz')
ylabel('Normalized FFT Power')
axis([0 12000 0 1.1]); % [x_start x_end y_min y_max]
% ********Initialize output variable based on the size of y:
if size(y, 2) > 1
y_voc = zeros(size(y)); % Stereo output if y is stereo
else
y_voc = zeros(size(y, 1), 1); % Mono output if y is mono
end
% ************** Generate white noise for multiplication:
wnoise = randn(size(y));
max_w = max(abs(wnoise(:)));
if max_w > 0
    wnoise = wnoise / max_w;
end
 % Normalize with small epsilon to avoid division by zero
% ************** Choose number of channels:
N = 12;
% ************** Calculate the cutoff frequencies:
f = [0, 69.53, 168.28, 308.55, 507.79, 790.77, 1192.71,...
    1763.61, 2574.51, 3726.27, 5362.19, 7685.79, 11000]; % in Hz
% ************** Normalize the cutoff frequencies:
w = f / (Fs / 2);

% ******Plot original signal and its spectrum in a separate figure:
figure;
subplot(2,1,1)
plot(t, y, 'b');
title('Original Sound Clip');
ylabel('Amplitude');
xlabel('Time, s');

subplot(2,1,2)
plot(Faxis, y_fft, 'b');
title('Original Sound Spectrum');
xlabel('Frequency, Hz');
ylabel('Normalized FFT Power');
xlim([0 12000]);



% ************************ STAGE 1 starts here:
for k = 1:N
% ************** STEP 0: BANDPASS FILTERING through filter bank:
Rp = 3; % Passband Ripple
Rs = 60; % Stopband Attenuation
if k == 1 % First channel uses a low-pass filter
[b, a] = ellip(7, Rp, Rs, w(2), 'low');
else % Subsequent channels use band-pass filters
[b, a] = ellip(5, Rp, Rs, [w(k) w(k+1)]);
end
y_bp = filter(b, a, y); % Bandpass filter output
% ************** Plot the bandpass filtered signal:
figure(1)
subplot(2,4,2)
plot(t, y_bp, 'b');
title(['Bandpass Filtered Output (Channel ', num2str(k), ')']);
ylabel('16-bit data');
xlabel('Time, s')
% ************** Calculate the spectrum of bandpass filtered signal:
yf_fft_raw = abs(fft(y_bp));
max_yf_fft = max(yf_fft_raw(:));
if max_yf_fft > 0
    yf_fft = yf_fft_raw / max_yf_fft;
else
    yf_fft = yf_fft_raw;
end
% ************** Plot the spectrum:
subplot(2,4,6)
plot(Faxis, yf_fft, 'b')
title('Bandpass filtered Spectrum')
xlabel('Frequency, Hz')
ylabel('Normalized FFT Power')
axis([0 12000 0 1.1]);
%% ************** STEP 2: Half-wave Rectification:
yr = max(y_bp, 0);
max_yr = max(abs(yr(:)));
if max_yr > 0
    yr = yr / max_yr;
end
 % Normalize
% ************** Plot the rectified sound wave:
subplot(2,4,3)
plot(t, yr, 'r');
title('Rectified Signal (time)');
ylabel('16-bit data');
xlabel('Time, s')
% ************** Calculate the spectrum of rectified signal:
yr_fft_raw = abs(fft(yr));
max_yr_fft = max(yr_fft_raw(:));
if max_yr_fft > 0
    yr_fft = yr_fft_raw / max_yr_fft;
else
    yr_fft = yr_fft_raw;
end

% ************** Plot the spectrum of the rectified signal:
subplot(2,4,7)
plot(Faxis, yr_fft, 'b')
title('Rectified Spectrum')
xlabel('Frequency, Hz')
ylabel('Normalized FFT Power')
axis([0 12000 0 1.1]);
%% ************** STEP 3: Low-Pass Filtering (160 Hz) to Extract Envelope:
[bb, aa] = butter(3, 160/(Fs/2), 'low');
yf = filter(bb, aa, yr);
max_yf = max(abs(yf(:)));
if max_yf > 0
    yf = yf / max_yf;
end
 % Normalize
% ************** Plot the low-pass filtered signal (envelope):
subplot(2,4,4)
plot(t, yf, 'b');
title('Low-Pass Filtered Envelope (time)');
ylabel('16-bit data');
xlabel('Time, s')
%% ************** STEP 4: Multiply Envelope with White Noise:
if length(yf) ~= length(wnoise)
wnoise = randn(size(y));
max_w = max(abs(wnoise(:)));
if max_w > 0
    wnoise = wnoise / max_w;
end
% Normalize
end
y_out = yf .* wnoise;
max_y_out = max(abs(y_out(:)));
if max_y_out > 0
    y_out = y_out / max_y_out;
end
 % Normalize
% ************** Plot the multiplied signal:
subplot(2,4,1)
plot(t, y_out, 'b');
title('Multiplied with White Noise (time)');
ylabel('16-bit data');
xlabel('Time, s')
% ************** Calculate the spectrum of the multiplied signal:
y_out_fft_raw = abs(fft(y_out));
y_out_fft = y_out_fft_raw / (max(y_out_fft_raw) + eps);
% ************** Plot the spectrum:
subplot(2,4,5)
plot(Faxis, y_out_fft, 'b')
title('Multiplied with White Noise Spectrum');
xlabel('Frequency, Hz')
ylabel('Normalized FFT Power')
axis([0 12000 0 1.1]);
%% ************** STEP 5: Final Bandpass Filtering:
y_bp_out = filter(b, a, y_out);
max_y_bp_out = max(abs(y_bp_out(:)));
if max_y_bp_out > 0
    y_bp_out = y_bp_out / max_y_bp_out;
end
 % Normalize
% ************** Plot the final bandpass filtered signal:
subplot(2,4,2)
plot(t, y_bp_out, 'b');
title('Final Bandpass Filtered Signal (time)');
ylabel('16-bit data');
xlabel('Time, s')
% ************** Calculate the spectrum of the final bandpass filtered signal:
yc_fft_raw = abs(fft(y_bp_out));
yc_fft = yc_fft_raw / (max(yc_fft_raw) + eps);
% ************** Plot the spectrum:
subplot(2,4,6)
plot(Faxis, yc_fft, 'b')
title('Final Bandpass Filtered Spectrum');
xlabel('Frequency, Hz')
ylabel('Normalized FFT Power')
axis([0 12000 0 1.1]);
%% ************** STEP 6: Add this channel to output:
y_voc = y_voc + y_bp_out;
end
% After the for k = 1:N loop
if any(isnan(y_voc(:)))
    disp('NaNs detected in y_voc, replacing with zeros');
    y_voc(~isfinite(y_voc)) = 0;
end

disp('Press Enter for vocoder output.');

% Time-domain vocoder output
figure;
subplot(2,1,1);
plot(t, y_voc);
title('Vocoder Output (Time Domain)');
xlabel('Time, s');
ylabel('Amplitude');

% Spectrum of vocoder output
Yvoc_fft_raw = abs(fft(y_voc));
Yvoc_fft = Yvoc_fft_raw / max(Yvoc_fft_raw(:));
Faxis = linspace(0, Fs, length(y_voc));

subplot(2,1,2);
plot(Faxis, Yvoc_fft);
title('Vocoder Output Spectrum');
xlabel('Frequency, Hz');
ylabel('Normalized FFT Power');
xlim([0 12000]);

pause
%% ************** Play vocoder output:
soundsc(y_voc, Fs);
