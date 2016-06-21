function rPeakDet(patient)
%This function finds r peaks from all the 12 leads
%patient - the file containing the data
%'filteredLeads.mat' - the file containing the ECG of all the 12 leads for the patient after filtering

% path to data
cd ~/Desktop/SHUKTI/

filtMatObj = matfile(strcat('filteredLeads_short.mat'));
ecgFeat = matfile('ECGfeatures_short.mat', 'Writable', true);

%divide the entire signal into 12 parts, this is the maximum signal length
%that can be efficiently processed
maxSigLen = floor(length(filtMatObj.I)./12); 

%intOnset and intOffset define the intervals where the signal is good enough to analyse 
intOnset = int32(filtMatObj.intOnset);
intOffset = int32(filtMatObj.intOffset);

rTimeCell = cell(1, length(intOnset));
parfor seg = 1:length(filtMatObj.intOnset)

    disp(strcat(num2str(seg), '/', num2str(length(filtMatObj.intOnset))))

    initSegStart = intOnset(seg);
    rCount = 0;
    iterCount = 0;
    
    segStart = initSegStart;
    %each interval is divided into smaller parts of length 200ms
    segTime = zeros(1, ceil((intOffset(seg) - intOnset(seg) + 1)./200)); 
    
    %Intervals under 3000ms are omitted signals (bad quality) and hence must not be considered
    while(segStart + 2999 <= intOffset(seg)) 
               
        iterCount = iterCount + 1;
       
        %segIdx defines the interval to be processed, if the interval is larger than the maximum signal length 
        %defined above then only the signal from the starting point to the maximum signal length shall be processed
        segIdx = segStart:min(intOffset(seg), initSegStart+(iterCount * maxSigLen) - 1); 
       
        segTimeLoc = getRpeaks(filtMatObj, segIdx);
        
        %save actual peak position in segTime
        if(isempty(segTimeLoc))
            segStart = segStart + length(segIdx) - 500;
            
        elseif(length(segTimeLoc) == 1)
            segTime(rCount + 1) = segTimeLoc + segIdx(1) - 1;
            
            rCount = rCount + 1;
            
            segStart = segStart + length(segIdx) - 500;
            
        else
            segTime(rCount + 1:rCount + length(segTimeLoc) - 1) = ...
                segTimeLoc(1:end - 1) + double(segIdx(1)) - 1;

            rCount = rCount + length(segTimeLoc) - 1;
            
            segStart = segStart + floor(mean(segTimeLoc(end-1:end))) - 1;
        end
    end
    %save peak positions in each segment as a cell
    rTimeCell{seg} = unique(segTime(1:rCount));
end

%finally save the detected peak positions to the matfile
rTime = cell2mat(rTimeCell);
ecgFeat.rPeaks = rTime;

end


function rLocs = getRpeaks(filtMatObj, segIdx)
%finds r peaks in every lead within the interval defined by segIdx

signal = cell(12, 1);

signal{1} = filtMatObj.I(1, segIdx);
signal{2} = filtMatObj.II(1, segIdx);
signal{3} = filtMatObj.III(1, segIdx);
signal{4} = filtMatObj.aVF(1, segIdx);
signal{5} = filtMatObj.aVL(1, segIdx);
signal{6} = filtMatObj.aVR(1, segIdx);
signal{7} = filtMatObj.V1(1, segIdx);
signal{8} = filtMatObj.V2(1, segIdx);
signal{9} = filtMatObj.V3(1, segIdx);
signal{10} = filtMatObj.V4(1, segIdx);
signal{11} = filtMatObj.V5(1, segIdx);
signal{12} = filtMatObj.V6(1, segIdx);

%indices of r peaks in the interval, for every lead
rWave = cellfun(@detRwave4lead, signal, 'UniformOutput', false);

%align peaks of all leads with respect to the lead V2
rLocs = alignRpeaks(rWave, signal{8, 1});


end

function rPeaks = detRwave4lead(signal)
%finds r peaks in the vector 'signal'

if(length(signal) < 3000) %intervals under 3000ms are omitted signals
    rPeaks = [];
    return;
end

[C, L] = wavedec(double(signal), 7, 'db8'); %7-level wavelet decomposition 

sqSignal = (recDecSignal(C, L, 'db8', 4:7)).^2; %wavelet reconstruction from levels 4-7, squared

pks = max(sqSignal);
%considering the omitted signals, there should be atleast one peak every
%3000ms, since the omitted signals are less than 3000ms 
minPeaks = floor(length(signal)./3000);
threshold = pks;

iter = 0; 


while(length(pks) ~= minPeaks)
%checks if the minimum number of peaks are present and finds them; if not
%returns an empty matrix   
    iter = iter + 1;
    
    threshold = 0.8*threshold;
    pks = findpeaks(sqSignal, 'MinPeakDistance', 1000, ...
        'NPeaks', minPeaks, 'MinPeakHeight', threshold, ...
        'SortStr', 'descend');
    
    if(iter > 50)
        warning('Loop limit reached')
        rPeaks = [];
        return;
    end
end

%position of all the peaks in the signal
[~, rPeaks] = findpeaks(sqSignal, 'MinPeakDistance', 200, ...
    'NPeaks', floor(length(signal)./200), 'MinPeakHeight', 0.2*pks(end));
%problem: fixing the max numer of peaks might give something in between and
%miss out something at the end of the signal

end



function rPeaks = alignRpeaks(rWave, refSignal)
%aligns the peaks detected in all the leads (stored in rWave) with the
%reference signal
allPeaks = rWave{1};

for l = 2:12
    ts1 = allPeaks;
    ts2 = rWave{l};
    
    idx1 = [];
    idx2 = [];
    if(isempty(ts1))
        allPeaks = ts2;
        continue;
    elseif(isempty(ts2));
        continue;
    elseif(length(ts1) == 1)
        if(min(abs(ts2 - ts1)) <= 150)
            idx1 = 1;
            [~, idx2] = min(abs(ts2 - ts1)); %indices of minimum values
        end
    elseif(length(ts2) == 1)
        if(min(abs(ts1 - ts2)) <= 150);
            [~, idx1] = min(abs(ts1 - ts2)); 
            idx2 = 1;
        end
        %if over 30000 peaks are detected, break it down into smaller parts for computation
    elseif(length(ts1) > 30000 || length(ts2) > 30000) 
        numSegs = ceil(max(length(ts1), length(ts2))./30000);
        segPoints = floor(linspace(1, length(ts1) + 1 , numSegs + 1));
        onset = 1;
        for k = 1:numSegs
            locTs1 = ts1(segPoints(k):segPoints(k+1)-1);
            [~, offset] = min(abs(ts2 - ts1(segPoints(k+1)-1)));
            locTs2 = ts2(onset:offset);
            
            %align the peaks in each segment of the two leads with each
            %other with maximum allowable range +/-150 and Gap Penalty 150
            [locIdx1, locIdx2] = ...
                samplealign(locTs1', locTs2', 'Band', 150, 'GAP', 150);
            
            %save the new indices
            idx1 = union(idx1, locIdx1 + segPoints(k) - 1);
            idx2 = union(idx2, locIdx2 + onset - 1);
            
            onset = offset + 1;
        end
    else
        [idx1, idx2] = samplealign(ts1', ts2', 'Band', 150, 'GAP', 150);
    end
    
    %find points which were missed during realignment
    miss1 = ts1(setdiff(1:length(ts1), idx1));
    miss2 = ts2(setdiff(1:length(ts2), idx2));
    miss = union(miss1, miss2);
    
    if(~isempty(idx1) && ~isempty(idx2))
        alignedTP = [ts1(idx1); ts2(idx2)];
        [~, maxIdx] = max(abs(refSignal(alignedTP)));
        
        %find linear indices of maximum values obtained from the reference
        %signal at the aligned peak positions
        subIdx = sub2ind(size(alignedTP), maxIdx, 1:size(alignedTP, 2));
        
        %combine the realigned and missed peaks to get all the peaks 
        allPeaks = union(miss, alignedTP(subIdx));
    else
        allPeaks = miss;
    end
    
end

if(length(allPeaks) < 2)
    rPeaks = [];
    return
end

% find out, which R peak was detected in which lead
potRPeaks = zeros(12, length(allPeaks));
for l = 1:12
    ts = rWave{l};
    idx = [];
    if(isempty(ts))
        continue;
    elseif(length(ts) == 1)
        [~, idx] = min(allPeaks - ts);
    elseif(length(allPeaks) > 30000)
        numSegs = ceil(length(allPeaks)./30000);
        segPoints = floor(linspace(1, length(allPeaks) + 1 , numSegs + 1));
        onset = 1;
        for k = 1:numSegs
            locTs1 = allPeaks(segPoints(k):segPoints(k+1)-1);
            [~, offset] = min(abs(ts - allPeaks(segPoints(k+1)-1)));
            locTs2 = ts(onset:offset);
            
            locIdx1 = ...
                samplealign(locTs1', locTs2', 'Band', 150, 'GAP', 150);
            
            idx = union(idx1, locIdx1 + segPoints(k) - 1);
            %idx2 = union(idx2, locIdx2 + onset - 1);
            
            onset = offset + 1;
        end
    else
        idx = samplealign(allPeaks', ts', 'Band', 150, 'GAP', 150);
    end
    potRPeaks(l, idx) = allPeaks(idx);
    
end

% only those peaks, which where detected sufficiently often
rPeaks = allPeaks(:, sum(potRPeaks ~= 0) > 9);   
   
end
    



