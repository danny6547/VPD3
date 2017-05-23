/* Script demonstrating how to get basic metadata on ships and their data from a "Performance Data" table */ 

SELECT
	IMO_Vessel_Number,
	COUNT(*) As 'Number of data points',
    date_format((DateTime_UTC), '%M/%Y') As 'Start of data',
    date_format(MAX(DateTime_UTC), '%M/%Y') As 'End of data',
    ROUND(datediff(MAX(DateTime_UTC), MIN(DateTime_UTC))/(365.25/12)) AS 'Months of Data'
    FROM rawdata
    /* WHERE  IS NOT NULL */
    GROUP BY IMO_Vessel_Number;
    
/*SELECT 
	ShipName, 
	COUNT(Time), 
   count(1) as TotalAll,
   count(PI) as TotalNotNull,
   count(1) - count(PI) as TotalNull,
   100.0 * count(PI) / count(1) as PercentNotNull
   FROM datatest7 GROUP BY ShipName;*/