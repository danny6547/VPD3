SELECT IMO_Vessel_Number, 
	COUNT(Performance_Index) AS '# Performance Data',
	COUNT(Speed_Index) AS '# Speed Data',
    TIMESTAMPDIFF(MONTH, MIN(DateTime_UTC), MAX(DateTime_UTC)) AS 'Data Duration (months)',
    MIN(DateTime_UTC) AS 'Start Date',
    MAX(DateTime_UTC) AS 'End Date'
		FROM DNVGLPerformanceData
			GROUP BY IMO_Vessel_Number
				ORDER BY IMO_Vessel_Number DESC;