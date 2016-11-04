/* Script to load data into table "Performance Data" from tab-delimited text file with Performance Index, Time and Ship Name columns */
USE test2;
LOAD DATA LOCAL INFILE 'C://Users//damcl//Documents//Ship Data//test//AllButCMAYM.tab' INTO TABLE `Performance Data` IGNORE 0 LINES (`Performance Index`, Date, IMO);