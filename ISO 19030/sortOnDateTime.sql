/* Sort data in temp raw ISO by time */

INSERT INTO tempRawISO SELECT * FROM tempRawISO ORDER BY DateTime_UTC;