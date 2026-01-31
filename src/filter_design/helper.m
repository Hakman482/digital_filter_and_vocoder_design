%% Helper function for plotting (magnitude (dB), phase, group delay)
function plot_responses(b, a, fs, nfft, titleStr)
    % b: numerator (FIR b, IIR b)
    % a: denominator (IIR a or 1 for FIR)
    [H, W] = freqz(b, a, nfft, fs);
    magdb = 20*log10(abs(H) + eps);
    ph = unwrap(angle(H));
    figure('Name', titleStr, 'NumberTitle', 'off');
    subplot(3,1,1);
    plot(W, magdb); grid on;
    ylabel('Magnitude (dB)'); title([titleStr ' - Magnitude']);
    subplot(3,1,2);
    plot(W, ph); grid on;
    ylabel('Phase (rad)'); title([titleStr ' - Phase']);
    subplot(3,1,3);
    % group delay
    [gd, w_gd] = grpdelay(b,a,nfft,fs);
    plot(w_gd, gd); grid on;
    ylabel('Group delay (samples)'); xlabel('Frequency (Hz)');
    title([titleStr ' - Group delay']);
end
