% clear all; clc; clf; close all; %#ok<*CLSCR>
featObj = matfile('~/Desktop/SHUKTI/ECGfeatures.mat');
filtObj = matfile('~/Desktop/SHUKTI/filteredLeads.mat');
interval = [filtObj.intOnset,filtObj.intOffset];
rPeaks = featObj.rPeaks;

diff = zeros(1,length(rPeaks));
diff(1) = rPeaks(2)-rPeaks(1);
for k = 2:length(rPeaks)-1
    diff(k) = min((rPeaks(k+1)-rPeaks(k)),(rPeaks(k)-rPeaks(k-1)));
end
diff(length(rPeaks)) = rPeaks(length(rPeaks))-rPeaks(length(rPeaks)-1);

errTimes = rPeaks(diff<=460);

%to remove intervals which were left out during detection
errTimes(errTimes<interval(1,1)) = [];
for i = 1:length(interval)-1
    errTimes(errTimes>interval(i,2)&errTimes<interval(i+1,1))= [];
end
errTimes(errTimes>interval(end,2)) = [];

clear rPeaks k

a = filtObj.V2;
errPeak = a(errTimes);

clear a;

finalIdx = errTimes(errPeak>-150);
newErrPeak = errPeak(errPeak>-150);

% save('finalIdx.mat','finalIdx');
% save('newErrPeak.mat','newErrPeak');

% clear errTimes errPeak diff
% clf; close all;

%------------------- for plotting the error peaks
% figure(1)
% for i = 41 : 70
%     a = filtObj.V2(1,finalIdx(i)-49:finalIdx(i)+50);
%     plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),newErrPeak(i),'r'); hold on;
% end

% %-------------------- for plotting part of the original signal
% a1 = featObj.rPeaks(1,722306:722319);
% b1 = filtObj.V2(1,466430000:466440000);
% c1 = b1(a1(1,:)-466430000*ones(1,length(a1)));
% 
% figure(2)
% plot(466430000:466440000,b1); hold on; stem(a1,c1);