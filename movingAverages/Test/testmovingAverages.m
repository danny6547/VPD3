classdef testmovingAverages < matlab.unittest.TestCase
% testmovingAverages Test function movingAverages.
%   1. testAvgStruct will test that function will return in PERSTRUCT
%   a struct with fields 'Average', 'StartDate' and 'EndDate' containing 
%   the corresponding data over the durations given by vector DURATION for 
%   the data in struct PERSTRUCT and that the size of AVGSTRUCT matches the
%   size of PERSTRUCT.
%   2. testmovingAverages will test that when input REVERSE has value TRUE,
%   the start and end dates returned in AVGSTRUCT will be counted in
%   increments of DURATION back from the latest date input in
%   PERSTRUCT.DATE, and that the averages calculated will correspond to
%   those between these dates.

properties(Constant = true)
    
    NumData = 30;
    PerfData = [nan(1, 5), abs(randn(1, testmovingAverages.NumData)), nan(1, 5)]';
    DateData = (1:(testmovingAverages.NumData + 10))';
    AvgStruct = struct('Average', [],...
        'StartDate', [], ...
        'EndDate', []);
    DateStrForm = 'dd-mm-yyyy';
    
end

methods(Static)
    
    function perStruct = perStruct
       % perStruct Returns test input PERSTRUCT
       
        datestring_c = cellstr(datestr(testmovingAverages.DateData, ...
           testmovingAverages.DateStrForm));
        perStruct = struct('Date', {},...
            'Performance_Index', []);
        perStruct(1).Date = datestring_c;
        perStruct(1).Performance_Index = testmovingAverages.PerfData;
        
    end
    
    function durStruct = emptyDuration
       % emptyDuration Returns "Duration" struct with no data
       
        durStruct = struct('Average', [], 'StartDate', [],...
            'EndDate', []);
    end
    
    function inputMat = inputPermutations
       % inputPermutations All permutations of logical scalar inputs
       
       inputMat = logical(dec2bin(0:(2^3-1)) - '0');
       
    end
    
end

methods(Test)

    function testAvgStruct(testcase)
        % 1.
        
        % Inputs
        in_perStruct = testcase.perStruct;
        in_dur = [10, 4.25];
        datedata_v = testcase.DateData;
        
        durStruct = struct('Average', [], 'StartDate', [],...
            'EndDate', []);
        exp_avgStruct = struct('Duration', []);
        
        durStruct(1).StartDate = [0.5, 10.5, 20.5, 30.5];
        durStruct(1).EndDate = [10.5, 20.5, 30.5, 40.5];
        tempAv = nan(1, length(durStruct(1).StartDate));
        
        for ai = 1:length(durStruct(1).StartDate)
            
            currSD = ceil( durStruct(1).StartDate(ai) );
            currED = floor( durStruct(1).EndDate(ai) );
            tempAv(ai) = nanmean(in_perStruct.Performance_Index(currSD:currED));
        end
        
        durStruct(1).Average = tempAv;
        delimDates = [min(datedata_v) - 0.5:in_dur(2):max(datedata_v) + 0.5,...
            max(datedata_v) + 0.5];
        durStruct(2).StartDate = delimDates(1:end-1);
        durStruct(2).EndDate = delimDates(2:end);
        
        si = ceil( delimDates(1:end-1) );
        ei = floor( delimDates(2:end) );
        ei(2:4:end) = ei(2:4:end)-1;
        ei(end) = length(datedata_v);
        
        for ai = 1:length(si)
            
%             currSD = ceil( durStruct(2).StartDate(ai) );
%             currED = floor( durStruct(2).EndDate(ai) );
            tempAv(ai) = nanmean(in_perStruct.Performance_Index(si(ai):ei(ai)));
        end
        
        durStruct(2).Average = tempAv;
        nan_l = isnan(tempAv);
        durStruct(2).StartDate(nan_l) = [];
        durStruct(2).EndDate(nan_l) = [];
        durStruct(2).Average(nan_l) = [];
        
        exp_avgStruct.Duration = durStruct;
        
        % Execute
        act_avgStruct = movingAverages(in_perStruct, in_dur);
        
        % Verify
        msg_avgStruct = ['AVGSTRUCT expected to contain moving averages'...
            ' over durations contained in DURATIONS.'];
        testcase.verifyEqual(act_avgStruct, exp_avgStruct, msg_avgStruct);
        
    end
    
    function testReverseTrimRemove(testcase)
       % 2.
        
        % Inputs
        inputMat = testcase.inputPermutations;
        numTests = size(inputMat, 1);
        datedata = testcase.DateData;
        datedata = datedata(1:end-5);
        
        for ti = 1:numTests
            
            currReverse = inputMat(ti, 1);
            currTrim = inputMat(ti, 2);
            currRemove = inputMat(ti, 3);
            
            in_perstruct = testcase.perStruct;
            in_perstruct.Date(end-4:end) = [];
            in_perstruct.Performance_Index(end-4:end) = [];
            in_dur = 10;
            
            filtDate = datedata(isnan(in_perstruct.Performance_Index));
            
            tstep = 1;
            preDates = datedata(:)' - 0.5*tstep;
            postDates = datedata(:)' + 0.5*tstep;
            numDur = ceil( (max(postDates) - min(preDates))  / in_dur);
            
            % Divide vector up into durations counting from end
            if currReverse
                delimDates = linspace(postDates(end), ...
                    postDates(end)-(numDur*in_dur), numDur+1);
%                 delimDates = postDates(end):-in_dur:postDates(1);
%                 delimDates = [postDates(1), preDates(in_dur:in_dur:end)];
                endDates = delimDates(1:end-1);
                startDates = delimDates(2:end);
            else
                delimDates = linspace(preDates(1), ...
                    preDates(1)+(numDur*in_dur), numDur+1);
%                 delimDates = preDates(1):in_dur:numDur*in_dur;
%                 delimDates = [delimDates, delimDates(end)+in_dur];
%                 delimDates = [preDates(1:in_dur:end), postDates(end)];
                startDates = delimDates(1:end-1);
                endDates = delimDates(2:end);
            end
            
            % Remove durations whose start or end exceed those of the dates
            if currRemove
                if any(startDates < min(preDates))
                    filt_l = startDates < min(datedata);
                    startDates(filt_l) = [];
                    endDates(filt_l) = [];
                end
                if any(endDates > max(postDates))
                    filt_l = endDates > max(datedata);
                    startDates(filt_l) = [];
                    endDates(filt_l) = [];
                end
            end
            
            % Trim start and end dates to match extents of date data
            if currTrim
                if any(startDates) < min(filtDate)
                    startDates(startDates < min(filtDate)) = min(filtDate);
                end
                if any(endDates) > max(filtDate)
                    endDates(endDates > min(filtDate)) = max(filtDate);
                end
            end
            
            dur_st = testcase.emptyDuration;
            dur_st.StartDate = sort( startDates );
            dur_st.EndDate = sort( endDates );
            
            tempAv = nan(1, length(dur_st(1).StartDate));
            for ai = 1:length(dur_st.StartDate)
                
                currSD = ceil( dur_st(1).StartDate(ai) );
                currED = floor( dur_st(1).EndDate(ai) );
                if currED > length(in_perstruct.Performance_Index)
                    currED = length(in_perstruct.Performance_Index);
                end
                if currSD < 1
                    currSD = 1;
                end
                tempAv(ai) = nanmean(in_perstruct.Performance_Index(currSD:currED));
            end
            
            dur_st.Average = tempAv;
            nan_l = isnan(tempAv);
            dur_st.StartDate(nan_l) = [];
            dur_st.EndDate(nan_l) = [];
            dur_st.Average(nan_l) = [];
            
            exp_avgstruct = struct('Duration', dur_st);
            
            % Execute
            act_avgstruct = movingAverages(in_perstruct, in_dur, ...
                currReverse, currTrim, currRemove);
            
            % Verify
            msg_avgstruct = ['Start, End Dates and their averages are expected'...
                ' to be counted back from the latest date when input REVERSE '...
                'has value TRUE.'];
            testcase.verifyEqual(act_avgstruct, exp_avgstruct, msg_avgstruct);
            
        end
    end
end

end