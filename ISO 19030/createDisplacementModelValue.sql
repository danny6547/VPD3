/* Create displacement table, allowing displacements to be found for recorded drafts.

 Draft_Aft : metres
 Draft_Fore : metres
 Draft_Mean : metres
 LCF : metres; Length between centre of flotation and mid-ship section
 TPC : tonnes; tonnes per centimetre of additional mass submerged due to change in draft at this draft
 Trim : metres; Draft_Aft - Draft_Mean
 Displacement : m^3; Volume of fluid displaced by the hull
*/

DROP PROCEDURE IF EXISTS createDisplacementModelValue;

delimiter //

CREATE PROCEDURE createDisplacementModelValue()

	BEGIN
	
	CREATE TABLE Displacement_Model_Value (id INT PRIMARY KEY AUTO_INCREMENT,
								 Displacement_Model_Id INT NOT NULL,
								 Draft_Mean FLOAT(15, 3),
								 LCF FLOAT(15, 5),
								 TPC FLOAT(15, 3),
								 Trim FLOAT(15, 3),
								 Displacement FLOAT(15, 5),
                                 CONSTRAINT UniqueModelDraft UNIQUE(Displacement_Model_Id, Draft_Mean),
                                 CONSTRAINT UniqueModelDraftTrim UNIQUE(Displacement_Model_Id, Draft_Mean, Trim)
                                 );
								 
	END;