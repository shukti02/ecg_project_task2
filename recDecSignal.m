function recSignal = recDecSignal(C, L, wavelet, scales)
%to calculate reconstruction using coefficients only of specific levels specified by scales
%if scales is a scalar equal to level+1 then last aprox coef.s are returned
%as it is
if(nargin < 4)
    scales = 1:length(L)-1;
end

level = length(L) - 2;
revScales = ones(size(scales)).*(level + 2) - scales; %reverse scales, eg 1:5-1=4, 2:5-2=3 ... if 3 levels of decomposition

%reconstruction
coefs = zeros(size(C));

n = 1;
plotNum = length(scales);
for m = 1:length(revScales)

    comp = revScales(m);
    if(comp ==1)
        idx = 1;
    else
        idx = 1 + sum(L(1:comp-1));
    end
    seq = C(idx:idx + L(comp) - 1);
%     figure
%     coef = upcoef('d', seq, wavelet, m );
%     plot(coef(1:600))
%     title(num2str(m))
    
%     subplot(6, 2, m)
%     plot(seq)
%     title(num2str(m))
    coefs(idx:idx+L(comp)-1) = seq;
    
%     subplot(plotNum, 1, n)
%     plot(seq)
%     title(strcat('scale =', num2str(scales(m))));
%     n = n + 1;
end

recSignal = waverec(coefs, L, wavelet);