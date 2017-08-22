/* Create displacement table, allowing displacements to be found for recorded drafts.

 Draft_Aft : metres
 Draft_Fore : metres
 Draft_Mean : metres
 LCF : metres; Length between centre of flotation and mid-ship section
 TPC : tonnes; tonnes per centimetre of additional mass submerged due to change in draft at this draft
 Trim : metres; Draft_Aft - Draft_Mean
 Displacement : m^3; Volume of fluid displaced by the hull
*/

DROP PROCEDURE IF EXISTS createDisplacement;

delimiter //

CREATE PROCEDURE createDisplacement()

	BEGIN
	
	CREATE TABLE Displacement (id INT PRIMARY KEY AUTO_INCREMENT,
								 ModelID INT NOT NULL,
								 Draft_Mean DOUBLE(5, 3),
								 LCF DOUBLE(6, 5),
								 TPC DOUBLE(7, 3),
								 Trim DOUBLE(5, 3),
								 Displacement DOUBLE(20, 5),
                                 CONSTRAINT UniqueModelDraft UNIQUE(ModelID, Draft_Mean),
                                 CONSTRAINT UniqueModelDraftTrim UNIQUE(ModelID, Draft_Mean, Trim)
                                 );
								 
	END;