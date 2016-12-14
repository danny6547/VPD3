/* Insert rows of data from tab file into PerformanceDataDNVGL which have different IMO, Date values than those in the table */

/* delimiter //

CREATE PROCEDURE insertWithoutDuplicates()
BEGIN */

DROP TABLE IF EXISTS tempPerData;
CREATE TABLE IF NOT EXISTS tempPerData LIKE PerformanceDataDNVGL;
LOAD DATA LOCAL INFILE 'C://Users//damcl//Documents//Ship Data//TMS//aspc2.tab' INTO TABLE PerformanceDataDNVGL IGNORE 0 LINES (Performance_Index, DateTime_UTC, IMO_Vessel_Number);

/* INSERT INTO PerformanceDataDNVGL (Performance_Index, DateTime_UTC, IMO_Vessel_Number)
				Select Performance_Index, DateTime_UTC, IMO_Vessel_Number
					FROM tempPerData as a
						WHERE NOT EXISTS(Select Performance_Index, DateTime_UTC, IMO_Vessel_Number FROM PerformanceDataDNVGL as b
							WHERE a.DateTime_UTC = b.DateTime_UTC and a.IMO_Vessel_Number = b.IMO_Vessel_Number); */
                            
DROP TABLE tempPerData;