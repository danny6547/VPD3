SELECT `Number of Ships analysed by DNVGL`, 
	   `Number of Ships analysed by us` FROM
(SELECT COUNT(DISTINCT(IMO_Vessel_Number)) AS 'Number of Ships analysed by DNVGL' FROM dnvglperformancedata) b
	JOIN
(SELECT COUNT(DISTINCT(IMO_Vessel_Number)) AS 'Number of Ships analysed by us' FROM performancedata) a;