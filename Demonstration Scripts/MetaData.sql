/* Example showing extraction of values calculated from performance data, including grouping and ordering */

SELECT Name, v.IMO_Vessel_Number, 
	COUNT(Performance_Index) AS '# Performance Data',
    TIMESTAMPDIFF(MONTH, MIN(DateTime_UTC), MAX(DateTime_UTC)) AS 'Data Duration (months)',
    MIN(DATE(DateTime_UTC)) AS 'Start Date'
		FROM vessels v
			JOIN DNVGLPerformanceData pd
				ON v.IMO_Vessel_Number = pd.IMO_Vessel_Number
					GROUP BY IMO_Vessel_Number
						ORDER BY Name;