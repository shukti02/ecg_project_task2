%program to detect undetected peaks using V2 only
tic; clear all; clc; clf; close all; %#ok<*CLSCR>
featObj = matfile('ECGfeatures_2_short');
filtObj = matfile('filteredLeads2_short');
interval = [filtObj.intOnset,filtObj.intOffset];
rPeaks = featObj.rPeaks;
diff = zeros(1,length(rPeaks));
for k = 1:length(rPeaks)-1
    diff(k) = rPeaks(k+1)-rPeaks(k);
end
n = find(diff>=900); %add <3000ms
chkTimes(:,1) = rPeaks(n);
chkTimes(:,2) = rPeaks(n+ones(1,length(n)));

clear rPeaks k

warning('off','all');
undet = cell(length(chkTimes),1);
for i = 1:length(chkTimes)
    chkSig = filtObj.V2(1,chkTimes(i,1)+50:(chkTimes(i,2)-50));
    chkSig = double(-1.*chkSig);
    [~,locs] = findpeaks(chkSig,'MinPeakHeight',100,'MinPeakDistance',200);
    undet{i,1} = locs;
end
warning('on','all');

A = cellfun('isempty',undet);
x = find(~A);
B = undet(x); C = chkTimes(x,1)+50;

newPks = [];
for i = 1:length(x)
    m = B{i}+C(i);
    newPks = [newPks,m];
end

%to remove intervals which were left out during detection
newPks(newPks<interval(1,1)) = [];
for i = 1:length(interval)-1
    newPks(newPks>interval(i,2)&newPks<interval(i+1,1))= [];
end
newPks(newPks>interval(end,2)) = [];

save('newPks.mat','newPks');
clearvars -except newPks featObj filtObj

a = filtObj.V2;
newPksVal = a(newPks);
clear a;
newPksVal = -1.*newPksVal;
save('newPksVal.mat','newPksVal'); toc;

%-----------------to plot undetected peaks-------------------------------
% clf; close all;
% figure(1)
% for i = 1 : 60
%     a = filtObj.V2(1,newPks(i)-49:newPks(i)+50);
%     a = -1.*a;
%     plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),newPksVal(i),'r'); hold on;
% end

%---------------to plot from original data-------------------------------
% figure(2)
% a1 = newPks(1,62:64);
% b1 = filtObj.V2(1,19500000:19510000);
% b1 = -1.*b1;
% c1 = b1(a1(1,:)-19500000*ones(1,length(a1)));
% 
% figure(2)
% plot(19500000:19510000,b1); hold on; stem(a1,c1);