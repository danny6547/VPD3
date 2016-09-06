/* Script demonstrating how to generate a full datetime value from date and time values in a DNVGL RawData table */ 

use test2;
SELECT ADDTIME(Date_UTC, Time_UTC) AS 'Full Date', Date_UTC, Time_UTC, IMO_Vessel_Number, Wind_Force_Kn From rawdata;