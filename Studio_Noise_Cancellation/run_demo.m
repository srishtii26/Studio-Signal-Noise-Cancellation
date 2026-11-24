% Studio signal noise cancellation: reproducible synthetic speech experiment.
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'src'));
out = fullfile(root,'results');
if ~exist(out,'dir'), mkdir(out); end
[x,fs] = audioread(fullfile(root,'audio','noisy_audio.wav'));
[s,fs2] = audioread(fullfile(root,'audio','clean_reference.wav'));
[r,fs3] = audioread(fullfile(root,'audio','noise_reference.wav'));
assert(fs==fs2 && fs==fs3 && numel(x)==numel(s) && numel(x)==numel(r));
z = spectral_subtraction(x,fs,0.5);
[e,estimatedNoise] = lms_cancel(z,r,32,0.01);
score = @(a) 10*log10(sum(s.^2)/max(sum((a-s).^2),eps));
values = [score(x); score(z); score(e)];
T = table({'Noisy';'Spectral subtraction';'Spectral + LMS'},values,'VariableNames',{'Stage','SNR_dB'});
disp(T); writetable(T,fullfile(out,'snr.csv'));
audiowrite(fullfile(out,'spectral_audio.wav'),max(-1,min(1,z)),fs);
audiowrite(fullfile(out,'cleaned_audio.wav'),max(-1,min(1,e)),fs);
t=(0:numel(x)-1)/fs;
f=figure('Name','Waveform comparison');
subplot(4,1,1); plot(t,s); title('Clean reference');
subplot(4,1,2); plot(t,x); title('Noisy input');
subplot(4,1,3); plot(t,z); title('Spectral subtraction');
subplot(4,1,4); plot(t,e); title('Spectral subtraction + LMS'); xlabel('Time (s)');
saveas(f,fullfile(out,'waveforms.png'));
f=figure('Name','SNR comparison'); bar(values); set(gca,'XTick',1:3,'XTickLabel',{'Noisy','Spectral','Hybrid'}); ylabel('SNR (dB)'); grid on;
saveas(f,fullfile(out,'snr.png'));
