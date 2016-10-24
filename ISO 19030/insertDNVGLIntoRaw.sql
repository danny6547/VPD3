/* Insert data from raw DNVGL raw table into raw data table for input IMO, where only rows with datetime, imo paris not already in the raw data table will be inserted.*/

INSERT INTO rawdata (DateTime_UTC, Speed_Over_Ground) SELECT DateTime_UTC, Speed_GPS FROM DNVGLRaw WHERE IMO_Vessel_Number = 9410765;