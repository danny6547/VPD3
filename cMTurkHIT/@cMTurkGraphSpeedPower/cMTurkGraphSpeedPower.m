classdef cMTurkGraphSpeedPower < cMTurkHIT
    %CMTURKGRAPHSPEEDPOWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        NCurves;
    end
    
    properties(Hidden)
        
        
    end
    
    methods
    
       function obj = cMTurkGraphSpeedPower()
    
       end
    
    end
    
    methods(Static, Hidden)
        
        [rows, cols] = requestCropIdx(img)
        [rows, cols] = areaFromExtents(bl, tr, sz)
        ax = concatPixelAxes(filename)
        [h] = plotDragRectangle(varargin)
        [fig] = anonymiseUI(filename)
        [html] = printHTMLImageInput(urlidx)
    end
end
