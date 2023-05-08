clear
[xI, ~] = audioread('xI.wav');
[xQ, ~] = audioread('xQ.wav');
x = sender(xI, xQ);
y = TSKS10channel(x);
[zI, zQ, A, tau] = receiver(y);

SNRzI = 20*log10(norm(xI)/norm(zI-xI));
SNRzQ = 20*log10(norm(xQ)/norm(zQ-xQ));

if (SNRzI >= 25 && SNRzQ >= 25)
    fprintf('RÄTT!\nA: %.2f\ntau: %.2f\nSNRzQ: %.2f\nSNRzI: %.2f\n', A, tau, SNRzQ, SNRzI);
else
    fprintf('FEL!\nA: %.2f\ntau: %.2f\nSNRzQ: %.2f\nSNRzI: %.2f\n', A, tau, SNRzQ, SNRzI);
end