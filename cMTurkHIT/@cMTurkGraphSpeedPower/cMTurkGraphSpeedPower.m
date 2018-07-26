classdef cMTurkGraphSpeedPower < cMTurkHIT
    %CMTURKGRAPHSPEEDPOWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        CurveName;
    end
    
    properties(Access=protected, Hidden)
        
        CoordinateName1 = 'Speed';
        CoordinateName2 = '';
    end
    
    properties(Hidden)
        
        MinSpeedName = 'MinSpeed_1';
        MaxSpeedName = 'MaxSpeed_1';
        MinPowerName = 'MinPower_1';
        MaxPowerName = 'MaxPower_1';
        GraphImageOffsetHorizontal = 50;
        GraphImageOffsetVertical = 75;
        PhysicalSpeedName = 'Speed_Physical';
        PhysicalPowerName = 'Power_Physical';
        ImageSpeedName = 'Speed_Image';
        ImagePowerName = 'Power_Image';
        GraphWidthPixels
        GraphHeightPixels
    end
    
    properties(Hidden)
        
        CurveObj;
    end
    
    properties(Dependent, Hidden)
        
        NCurve;
    end
    
    methods
        
       function obj = cMTurkGraphSpeedPower()
        
            obj.ColumnNames = {'Speed', 'Power'};
            obj = obj.assignDefaults;
       end
    end
    
    methods(Static, Hidden)
        
        [rows, cols] = requestCropIdx(img)
        [rows, cols] = areaFromExtents(bl, tr, sz)
        ax = concatPixelAxes(filename)
        [h] = plotDragRectangle(varargin)
        [fig] = anonymiseUI(filename)
        [html] = printHTMLImageInput(urlidx)
        html = encloseDiv(html);
        [html] = bulletPoints(html)
        [html] = text(html);
        plotHorizontalLines(ax, y);
    end
    
    methods
        
        function obj = set.CurveName(obj, name)
            
            % Check curve name
            name = validateCellStr(name);
            validateattributes(name, {'cell'}, {'vector'});
            
            % Unique
            if ~isequal(numel(name), numel(unique(name)))
                
                errid = 'CurveName:MustBeUnique';
                errmsg = 'Every element of CurveName must be unique';
                error(errid, errmsg);
            end
            obj.CurveName = name;
            
            % Update Column Labels
            labels2_c = repmat({'Horizontal', 'Vertical'}, 1, numel(name));
            labels1_c = [name(:), repmat({''}, numel(name), 1)]';
            labels1_c = labels1_c(:)';
            labels_c = [labels1_c; labels2_c];
            obj.ColumnLabels = labels_c;
        end
        
        function n = get.NCurve(obj)
            
            n = numel(obj.CurveName);
        end
        
        function obj = set.CurveObj(obj, obj2)
            
            validateattributes(obj2, {'cMTurkGraphSpeedPower'}, {});
            objDir = {obj.Directory};
            [obj2.Directory] = deal(objDir{:});
            obj.CurveObj = obj2;
        end
        
        function obj = set.GraphImageOffsetHorizontal(obj, off)
            
            obj.validateInteger(off);
            obj.GraphImageOffsetHorizontal = off;
        end
        
        function obj = set.GraphImageOffsetVertical(obj, off)
            
            obj.validateInteger(off);
            obj.GraphImageOffsetVertical = off;
        end
        
        function obj = set.GraphWidthPixels(obj, off)
            
            obj.validateInteger(off);
            obj.GraphWidthPixels = off;
        end
        
        function obj = set.GraphHeightPixels(obj, off)
            
            obj.validateInteger(off);
            obj.GraphHeightPixels = off;
        end
    end
end
