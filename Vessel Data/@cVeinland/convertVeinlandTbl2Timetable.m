function [tbl] = convertVeinlandTbl2Timetable(obj, tbl)
%convertDates Convert Veinland table to timetable
%   Detailed explanation goes here

dateFormStr = obj.DateFormStr;
tbl.report_date = datetime(tbl.report_date, 'InputFormat', dateFormStr);
tbl = table2timetable(tbl);
end