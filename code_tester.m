clear all; clc;

feat1 = matfile('ECGfeatures_short');
feat2 = matfile('ECGfeatures_2_short');
filtObj = matfile('filteredLeads2_short');
a = feat1.rPeaks;
b = feat2.rPeaks;

tic
%points in b that weren't detected in a
c = 0;
for i = 1:length(b)
    n = bsxfun(@eq,a,b(i));
    if (sum(n)==0)
        c = cat(1,c,i);
    end  
end

%points in a that weren't detected in b
d = 0;
for i = 1:length(a)
    n = bsxfun(@eq,b,a(i));
    if (sum(n)==0)
        d = cat(1,d,i);
    end  
end

toc

c(1) = []; d(1) = [];
clear a b

n = filtObj.V2;
n1 = n(c); n2 = n(d);

clear n

figure(1)
for i = 1 : 20
    a = filtObj.V2(1,c(i)-49:c(i)+50);
    plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),n1(i),'r'); hold on;
end

% %remove error peaks
% 
% for i = 1:length(finalIdx)
%     a = find(x==finalIdx(i)); 
%     x(a) = []; 
% end