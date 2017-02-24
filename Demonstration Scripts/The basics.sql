SELECT IMO_Vessel_Number, Name, Owner FROM Vessels;
SELECT IMO_Vessel_Number, Name, Owner FROM Vessels LIMIT 15;
SELECT IMO_Vessel_Number, Name, Owner FROM Vessels WHERE Owner = 'Yang Ming';
SELECT IMO_Vessel_Number, DateTime_UTC, AVG(Performance_Index) AS 'Average Performance' FROM performancedatadnvgl WHERE DateTime_UTC BETWEEN '2015-01-01' AND '2016-01-01' GROUP BY IMO_Vessel_Number;

/*
SELECT p.IMO_Vessel_Number, Owner, nAME, DateTime_UTC, Performance_Index FROM performancedatadnvgl p
	JOIN Vessels v
		ON p.IMO_Vessel_Number = v.IMO_Vessel_Number
			GROUP BY IMO_Vessel_Number
			 LIMIT 15;
             */

SELECT v.IMO_Vessel_Number, Name, Owner, Displacement, Trim, Exponent_A FROM speedpowercoefficients s
	JOIN vessels v
		ON s.IMO_Vessel_Number = v.IMO_Vessel_Number;