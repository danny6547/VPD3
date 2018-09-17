function params = tableParameters(dbname)
%tableParameters Parameters used to read from database tables
%   Detailed explanation goes here

    params = struct('InServiceTable', '',...
        'InServiceIdentifierColumn', '',...
        'InServiceIdentifierProperty', '',...
        'PerformanceVariable', '',...
        'Raw', '');

    switch dbname
        
        case {'hullperformance', 'static', 'devhempelsqldb'}
%     params(end).Database = ;
            params(end).InServiceTable = 'CalculatedData';
            params(end).InServiceIdentifierColumn = 'Vessel_Configuration_Id';
            params(end).InServiceIdentifierProperty = 'Vessel_Configuration_Id';
            params(end).InServiceJoinCols = {'Raw_Data_Id'};
            params(end).PerformanceVariable = 'speed_loss';
            params(end).Raw(1).RawTable = 'RawData';
            params(end).Raw(1).JoinCols = {'Raw_Data_Id'};
            params(end).Raw(1).RawColumn = 'Vessel_Id';
            params(end).Raw(1).RawIdentifierProperty = 'Vessel_Id';

        case 'force'
%     params(end+1).Database = {'force'};
            params(end).InServiceTable = 'forceraw';
            params(end).InServiceIdentifierColumn = 'imo_number';
            params(end).InServiceIdentifierProperty = 'IMO';
            params(end).InServiceJoinCols = {'start', 'imo_number'};
            params(end).PerformanceVariable = 'speed_index_combined';
            params(end).Raw(1).RawTable = 'RawData';
            params(end).Raw(1).JoinCols = {'DateTime_UTC', 'IMO_Vessel_Number'};
            params(end).Raw(1).RawColumn = 'IMO_Vessel_Number';
            params(end).Raw(1).RawIdentifierProperty = 'IMO';
            params(end).Raw(2).RawTable = 'forceraw';
            params(end).Raw(2).JoinCols = {'start', 'imo_number'};
            params(end).Raw(2).RawColumn = 'imo_number';
            params(end).Raw(2).RawIdentifierProperty = 'IMO';

        case 'dnvgl'
%     params(end+1).Database = {'dnvgl'};
            params(end).InServiceTable = 'PerformanceData';
            params(end).InServiceIdentifierColumn = 'IMO_Vessel_Number';
            params(end).InServiceIdentifierProperty = 'IMO';
            params(end).InServiceJoinCols = {'DateTime_UTC', 'IMO_Vessel_Number'};
            params(end).PerformanceVariable = 'speed_index';
            params(end).Raw(1).RawTable = 'RawData';
            params(end).Raw(1).JoinCols = {'DateTime_UTC', 'IMO_Vessel_Number'};
            params(end).Raw(1).RawColumn = 'IMO_Vessel_Number';
            params(end).Raw(1).RawIdentifierProperty = 'IMO';
            params(end).Raw(2).RawTable = 'dnvglraw';
            params(end).Raw(2).JoinCols = {'DateTime_UTC', 'IMO_Vessel_Number'};
            params(end).Raw(2).RawColumn = 'IMO_Vessel_Number';
            params(end).Raw(2).RawIdentifierProperty = 'IMO';
    end

end