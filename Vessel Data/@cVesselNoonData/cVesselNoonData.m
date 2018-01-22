classdef cVesselNoonData
    %CVESSELNOONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
       function obj = cVesselNoonData()
            
       end
    end
    
    methods(Static)
       
       function [repN, firstRowA] = numRows2Repeat(a, b, varargin)
       % numRows2Repeat Number of repetitions needed
       
       % Input: vectors only
       validateattributes(a, {'numeric'}, {'vector'});
       validateattributes(b, {'numeric'}, {'vector'});
       
       searchMethod = 'previous';
       if nargin > 2
           
           searchMethod = varargin{1};
           validateattributes(searchMethod, {'char'}, {'vector'});
           validatestring(searchMethod, {'exact', 'nearest', 'previous'});
       end
       
       % Initialise output
       repN = nan(size(b));
       
       % Find indices to values in a matching/closest to elements of b
       switch searchMethod
           
           case 'exact'
               [~, idx] = ismember(b, a);
               
           case 'previous'
               
               prevValue = interp1(a, a, b, 'previous');
               [~, idx] = ismember(prevValue, a);
       end
       
       % Repeat until last element of a
       if idx(end) ~= numel(a)
           
           idx(end+1) = numel(a);
       end
       
       % Find number of elements of a to repeat each element of b for
       for ii = 1:numel(idx)-1
           
           currLower = idx(ii);
           currUpper = idx(ii+1);
           
           if ii == numel(idx)-1
               currRange_l = a >= a(currLower) & a <= a(currUpper);
           else
               currRange_l = a >= a(currLower) & a < a(currUpper);
           end
           currRep = numel(a(currRange_l));
           repN(ii) = currRep;
       end
       
       % Find how many of a to skip
       if idx(1) ~= 1
           
           firstRowA = idx(1);
       else
           
           firstRowA = 1;
       end
       end
       
       function data = repeatRows(repN, data)
           
           data_c = cell(1, numel(repN));
           for ri = 1:numel(repN)
               
               data_c{ri} = repmat(data(ri, :), repN(ri), 1);
           end

           data = vertcat(data_c{:});
       end
       
       function [d, firstRowA] = findRepeat(a, b, c, varargin)
           
           % Make both Column vectors
           a = a(:);
           b = b(:);
           
           % Find number of rows to repeat for each row of b
           [reps, firstRowA] = cVesselNoonData.numRows2Repeat(a, b, varargin{:});
           
           % Repeat b to size of a
           d = cVesselNoonData.repeatRows(reps, c);
       end
       
       function tbl = findRepeatTables(a, aIdx, b, bIdx, varargin)
       % findRepeatTables Find common values and repeat b to fit a
       
       % Input
       validateattributes(a, {'table'}, {});
       validateattributes(aIdx, {'char'}, {'row'}, ...
           'cVesselNoonData.findRepeatTables', 'aIdx', 2);
       validateattributes(b, {'table'}, {});
       validateattributes(bIdx, {'char'}, {'row'}, ...
           'cVesselNoonData.findRepeatTables', 'bIdx', 4);
       
       % Extract index vectors
       ai_v = a.(aIdx);
       bi_v = b.(bIdx);
       
       % Repeat lower-freq data to higher freq
       [c, firstRowA] = cVesselNoonData.findRepeat(ai_v, bi_v, b, varargin{:});
       
       % Concatenate repeated data to higher-freq data
       tbl = [a(firstRowA:end, :), c];
       
       end
       
       
    end
end