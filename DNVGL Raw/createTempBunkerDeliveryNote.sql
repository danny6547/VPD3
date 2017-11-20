/* Create Temporary Bunker Delivery Note Table, storing data prior to inserting into final table without duplicates */


DROP PROCEDURE IF EXISTS createTempBunkerDeliveryNote;

delimiter //

CREATE PROCEDURE createTempBunkerDeliveryNote()
BEGIN

DROP TABLE IF EXISTS TempBunkerDeliveryNote;

CREATE TABLE TempBunkerDeliveryNote (id INT PRIMARY KEY AUTO_INCREMENT,
								IMO_Vessel_Number INT,
								BDN_Number VARCHAR(100),
								Bunker_Delivery_Date DATE,
								Fuel_Type VARCHAR(100),
								Mass DOUBLE(10, 3),
								Sulphur_Content DOUBLE(2, 1),
								Density_At_15dg DOUBLE(5, 4),
								Lower_Heating_Value DOUBLE(5, 3),
                                CONSTRAINT UniIMO_BDN UNIQUE(IMO_Vessel_Number, BDN_Number));
                                
END