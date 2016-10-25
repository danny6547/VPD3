/* Select data for ISO 19030 analysis from raw data table for a given IMO and store in temporary table for analysis, temp raw iso. */

delimiter //

CREATE PROCEDURE createTempRawISO(imo INT)
BEGIN

	DROP TABLE IF EXISTS tempRawISO;
	CREATE TABLE tempRawISO LIKE rawdata;

	INSERT INTO tempRawISO SELECT * FROM rawdata WHERE IMO_Vessel_Number = imo;

END