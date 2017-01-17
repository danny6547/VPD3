/* Create tempRaw table, a temporary table used to insert data from DNVGLRaw to RawData */

DROP PROCEDURE IF EXISTS createTempRaw;

delimiter //

CREATE PROCEDURE createTempRaw(imo INT)

BEGIN

DROP TABLE IF EXISTS tempRaw;
CREATE TABLE tempRaw LIKE dnvglraw;
INSERT INTO tempRaw (SELECT * FROM dnvglraw WHERE IMO_Vessel_Number = imo);
CALL convertDNVGLRawToRawData;

END;