/* Update tempRawISO table with displacements for the nearest values of mean draft and trim.

This function will be called when displacement data for a vessel is only given for fore and aft drafts, or for mean draft and trim.
*/

DROP PROCEDURE IF EXISTS updateDisplacementFromDraftTrim;

delimiter //

CREATE PROCEDURE updateDisplacementFromDraftTrim()

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