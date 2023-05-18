% Program for HeartRate & RespirationRate estimation
%--------------------------------------------------------------------------
% input
% 

close all;
clear;
format compact

fs = 2000;
fs_ecg = 20;
start   = 30 ;     % Seconds to start data [s]
stop    = 600 ;     % Seconds to end data [s]
desample = 100;
deFs = fs / desample;
lenSection = 10;
nSection = 57;


ERROR = zeros(1, 30);
signalHandle.isPlot = 0;
signalHandle.freRange = [0.6; 1.5];
signalHandle.periodRange = flipud( 1 ./ ([45; 90] / 60));
signalHandle.fftLenMuti = 20;
signalHandle.nInt = 15;
for iii = 1 : 30
    if iii < 10
        file = load(['C:\Resources\202210\datasets_subject_01_to_10_scidata\GDN000',num2str(iii), '\GDN000', num2str(iii),'_1_Resting']);
    else
        file = load(['C:\Resources\202210\datasets_subject_01_to_10_scidata\GDN00',num2str(iii), '\GDN00', num2str(iii),'_1_Resting']);
    end
    radarI = file.radar_i;
    radarQ = file.radar_q ;
    x = radarI + 1j * radarQ;
    x = x(1 : 10 : end) ;
%     x = lowpass(x, 5, 200, 'Steepness', 0.99) ;
    x = x(1 : (desample / 10) : end);
    
    

    x = highpass(x, 0.8, deFs, 'Steepness', 0.9) ;
    x = x(start * deFs : stop * deFs);
    
    radarSig = file.tfm_ecg1;
    ecgSig = file.tfm_ecg1((start * 2000) : 100 : end);
%     figure; plot(ecgSig);
    %%
    Results = zeros(nSection, 2);
    for ii = 1 : nSection
       signalHandle.signal = ecgSig(lenSection * ((ii - 1) * fs_ecg) + 1 : lenSection * (ii * fs_ecg));
       signalHandle.fs = fs_ecg;
       referFre = myFFT(signalHandle);
       Results(ii, 1) = 60 * referFre;


       signalHandle.fs = deFs;
       signalHandle.signal = x(lenSection * ((ii - 1) * deFs) + 1 : lenSection * (ii * deFs));
       pamdf = myPAMDF(signalHandle);
       ERROR(iii) = ERROR(iii) + (abs(referFre * 60 - 60 / pamdf) < 1);
       Results(ii, 2) = 60 / pamdf;
       
    end
    figure(1); clf;
    plot(Results);
end
ERROR =(ERROR / nSection);
mean(ERROR')



