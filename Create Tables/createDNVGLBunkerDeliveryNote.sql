/* Create Bunker Delivery Note Table for Vessels */

DROP PROCEDURE IF EXISTS createDNVGLBunkerDeliveryNote;

delimiter //

CREATE PROCEDURE createDNVGLBunkerDeliveryNote()

BEGIN

CREATE TABLE BunkerDeliveryNote (id INT PRIMARY KEY AUTO_INCREMENT,
								IMO_Vessel_Number INT(7),
								BDN_Number VARCHAR(100),
								Bunker_Delivery_Date DATETIME,
								Fuel_Type VARCHAR(100),
								Mass FLOAT(15, 3),
								Sulphur_Content FLOAT(15, 1),
								Density_At_15dg FLOAT(15, 4),
								Lower_Heating_Value FLOAT(15, 3),
								Density_Change_Rate_Per_C FLOAT(15, 10),
								Deleted BINARY,
                                CONSTRAINT UniIMO_BDN UNIQUE(IMO_Vessel_Number, BDN_Number)
                                );
END