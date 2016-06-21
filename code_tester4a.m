% clear all; clc; clf; %#ok<*CLSCR>
featObj = matfile('ECGfeatures');
filtObj = matfile('filteredLeads');

a1 = featObj.rPeaks(1,820941:820956);
b1 = filtObj.V2(1,540980000:540990000);
c1 = b1(a1(1,:)-540980000*ones(1,length(a1)));


plot(540980000:540990000,b1); hold on; stem(a1,c1);

% [PKS, LOC] = findpeaks(double(b(a(4)-10:a(4)+10)));