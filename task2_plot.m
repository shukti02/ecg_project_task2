% clear all; clc; %#ok<*CLSCR>
% load errPeakIdx2; load ECGfeatures
% errTimes = rPeaks(errPeakIdx);
% 
% filtObj = matfile('filteredLeads');
% % errPeak = zeros(1,length(errTimes));
% 
% a = filtObj.V2;
% errPeak = a(errTimes);
% 
% clear a;

% finalIdx = errTimes(find(errPeak>-150));
% newErrPeak = errPeak(find(errPeak>-150));

clf; close all;

% for i = 21 : 50
%     a = filtObj.V2(1,errTimes(i)-49:errTimes(i)+50);
%     plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),errPeak(i),'r'); hold on;
% end

for i = 25101 : 25200
    a = filtObj.V2(1,finalIdx(i)-49:finalIdx(i)+50);
    %plot(finalIdx(3)-49:finalIdx(3)+50,a); hold on; stem(finalIdx(3),newErrPeak(3));
    plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),newErrPeak(i),'r'); hold on;
end


%plot(errTimes(157376)-1000:errTimes(157376)+1000,a); hold on; stem(errTimes(157376),errPeak(157376))