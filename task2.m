clear all; clc; clf; close all; %#ok<*CLSCR>
load ECGfeatures

diff = zeros(1,length(rPeaks));
diff(1) = rPeaks(2)-rPeaks(1);
for k = 2:length(rPeaks)-1
    diff(k) = min((rPeaks(k+1)-rPeaks(k)),(rPeaks(k)-rPeaks(k-1)));
end
diff(length(rPeaks)) = rPeaks(length(rPeaks))-rPeaks(length(rPeaks)-1);

clear rPeaks k

errPeakIdx = find(diff<=460);
save('errPeakIdx2.mat','errPeakIdx');

% remData = find(diff>=3000 | diff<=200); %greater than 3000, removed data
% origDiff = diff;
% diff(remData) = []; %to ignore those data points in the statistical calculations

% meanDiff = mean(diff)
% modeDiff = mode(diff)
% sdDiff = std(diff)

% origDiff(remData) = modeDiff; %to hide these data points from appearing as erroneous peaks
% 
% fracDevDiff = (origDiff-modeDiff*ones(1,length(origDiff)))./modeDiff;
% absDev = abs(fracDevDiff);
% 
% errPeakIdx = find(absDev>0.7249);
% percentMis = 100*length(errPeakIdx)/length(origDiff)
% 
% a = origDiff;
% a(errPeakIdx)=[];
% max(a)
% min(a)
% 
% plot(1:length(origDiff),absDev)
% 
% figure(2)
% plot(1:length(a),a)
% 
% save('errPeakIdx.mat','errPeakIdx');