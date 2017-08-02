/* Update tempRawISO table with displacements for the nearest value of draft after correcting for trim.
This function will be called when displacement data for a vessel is only given for a mean draft.
*/

DROP PROCEDURE IF EXISTS updateDisplacementWithTrimCorrection;

delimiter //

CREATE PROCEDURE updateDisplacementWithTrimCorrection()

BEGIN

CREATE TABLE Displacement (id INT PRIMARY KEY AUTO_INCREMENT,
							 ModelID INT NOT NULL,
							 Draft_Aft DOUBLE(5, 3),
							 Draft_Fore DOUBLE(5, 3),
							 Draft_Mean DOUBLE(5, 3),
							 LCF DOUBLE(6, 5),
							 TPC DOUBLE(7, 3),
							 Trim DOUBLE(5, 3),
							 Displacement DOUBLE(20, 5));
                             

							 
END;