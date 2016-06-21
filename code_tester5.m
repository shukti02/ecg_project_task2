%idx has cluster value for each point, newIdx has cluster values for number of points greater than 50 
%finalCols have beginning and end values of each interval, finalRanges have
%beginning and end values of each interval greater than 50 points

clear all; clc; clf; close all;
load newPks
%load stPtsUndet
k = 90;
tic; idx = kmeans(newPks',k,'Replicates',100); toc; %use MaxIter, Replicates or start
a = 1 : k;
b = bsxfun(@eq,idx,a); %elementwise matrix operation
for i  = 1 : k
    m(i) = length(find(b(:,i)==1));
end
max(m)
min(m)

%store as 2D matrix with initial value of interval 1st column, final value
%of interval 2nd column
finalCols = zeros(k,4);
for i = 1 : k
    finalCols(i,1) = min(newPks(idx==i));
    finalCols(i,2) = max(newPks(idx==i));
    finalCols(i,3) = range(newPks(idx==i));
end
finalCols(:,4)=m;

% n = find(m>=50);
% finalRanges = finalCols(n,:);
% 
% scIdx = bsxfun(@eq,idx,n);
% newIdx = zeros(1,length(idx));
% for i  = 1 : length(idx)
%     if(sum(scIdx(i,:))~=0)
%         newIdx(1,i) = n(scIdx(i,:));
%     else
%         newIdx(1,i) = 0;
%     end
% end
% 
% x = finalRanges(:,3);
% x = x./range(finalIdx); %percentage of interval length