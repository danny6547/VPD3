SELECT `Rows of raw data`,
		`Rows of performance data`,
        nShips as 'Number of vessels',
        nDD AS 'Number of dry-docking intervals'
        FROM
(SELECT COUNT(*) AS 'Rows of performance data' FROM DNVGLPerformanceData) pd
	JOIN
(SELECT COUNT(*) AS 'Rows of raw data',
		COUNT(DISTINCT(IMO_Vessel_Number)) AS nShips
	FROM DNVGLRaw) rd
    JOIN
(SELECT COUNT(*) AS nDD FROM drydockdates) dd