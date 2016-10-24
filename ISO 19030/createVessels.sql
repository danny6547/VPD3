/* Create vessel table, containing all vessel data required */

CREATE TABLE Vessels (id INT PRIMARY KEY AUTO_INCREMENT, IMO_Vessel_Number INT, Name VARCHAR(100), Owner VARCHAR(100), Engine_Model VARCHAR(100), Wind_Resist_Coeff_Head DOUBLE(10, 5), Wind_Resist_Coeff_Dir DOUBLE(10, 5), Transverse_Projected_Area_Design DOUBLE(10, 5), LBP DOUBLE(10, 5));