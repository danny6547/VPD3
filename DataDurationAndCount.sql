/* Script demonstrating how to get basic metadata on ships and their data from a "Performance Data" table */ 

SELECT 
	ShipName, 
	COUNT(*) As 'Number of data points', 
    date_format((Time), '%M/%Y') As 'Start of data',
    date_format(MAX(Time), '%M/%Y') As 'End of data',
    ROUND(datediff(MAX(Time), MIN(Time))/(365.25/12)) AS 'Months of Data'
    FROM test2.datatest7 
    WHERE PI IS NOT NULL 
    GROUP BY ShipName;
    
/*SELECT 
	ShipName, 
	COUNT(Time), 
   count(1) as TotalAll,
   count(PI) as TotalNotNull,
   count(1) - count(PI) as TotalNull,
   100.0 * count(PI) / count(1) as PercentNotNull
   FROM datatest7 GROUP BY ShipName;*/