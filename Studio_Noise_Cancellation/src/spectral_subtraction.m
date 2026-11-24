function y = spectral_subtraction(x,fs,noiseSeconds)
% Magnitude spectral subtraction with weighted overlap-add inverse STFT.
x = mean(x,2); N = numel(x);
L = round(0.032*fs); H = floor(L/2); K = 2^nextpow2(L);
w = sqrt(0.5-0.5*cos(2*pi*(0:L-1)'/L));
p = [zeros(L,1); x; zeros(L,1)];
starts = 1:H:(numel(p)-L+1);
X = zeros(K,numel(starts));
for j=1:numel(starts)
    idx=starts(j)+(0:L-1); X(:,j)=fft(p(idx).*w,K);
end
% Select frames wholly inside the known noise-only opening.
noiseFrames = starts>=L+1 & starts+L-1<=L+floor(noiseSeconds*fs);
assert(any(noiseFrames),'Noise-only interval is too short.');
noiseMag=mean(abs(X(:,noiseFrames)),2);
mag=abs(X); enhanced=max(mag-noiseMag,0.05*mag).*exp(1i*angle(X));
y=zeros(size(p)); weight=zeros(size(p));
for j=1:numel(starts)
    idx=starts(j)+(0:L-1); frame=real(ifft(enhanced(:,j)));
    y(idx)=y(idx)+frame(1:L).*w; weight(idx)=weight(idx)+w.^2;
end
y=y./max(weight,eps); y=y(L+1:L+N);
end
