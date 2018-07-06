/* Create table detailing whether analysis complies with standard ISO19030-2 and if not, which part is non-compliant. Also include a comment including any additional relevant information. */

DROP PROCEDURE IF EXISTS createAnalysis;

delimiter //

CREATE PROCEDURE createAnalysis()

BEGIN

	CREATE TABLE Analysis (id INT PRIMARY KEY AUTO_INCREMENT,
									 IMO_Vessel_Number INT(7) NOT NULL COMMENT 'International Maritime Organisation Vessel Number',
									 StartDate DATETIME NOT NULL,
									 EndDate DATETIME NOT NULL,
									 Compliant BOOLEAN DEFAULT FALSE,
									 WindResistanceApplied BOOLEAN DEFAULT FALSE,
									 SpeedPowerInRange BOOLEAN DEFAULT FALSE,
									 SFOCInRange BOOLEAN,
									 SensorsAccurate BOOLEAN DEFAULT FALSE,
									 DisplacementTablesUsed BOOLEAN DEFAULT FALSE,
									 ChauvenetFiltered BOOLEAN DEFAULT FALSE,
									 Validated BOOLEAN DEFAULT FALSE,
									 FrequencySufficient BOOLEAN DEFAULT FALSE,
                                     Comment TEXT,
									 CONSTRAINT UniqueAnalysis UNIQUE(IMO_Vessel_Number, StartDate, EndDate)
									 );
									 
END;