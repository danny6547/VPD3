/* Create table detailing whether analysis complies with standard ISO19030-2 and if not, which part is non-compliant. */

CREATE TABLE StandardCompliance (id INT PRIMARY KEY AUTO_INCREMENT,
								 IMO_Vessel_Number INT(7) NOT NULL,
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
                                 CONSTRAINT UniqueAnalysis UNIQUE(IMO_Vessel_Number, StartDate, EndDate)
								 );