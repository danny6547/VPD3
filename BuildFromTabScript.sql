/* Script to load data into table "datatest7" from tab-delimited text file with Performance Index, Time and Ship Name columns*/

USE test2;
LOAD DATA LOCAL INFILE "C:/Users/damcl/Documents/Ship Data/CMA CGM/CMA CGM 290816/allcma.tab" INTO TABLE datatest7 IGNORE 1 LINES (PI, Time, ShipName);