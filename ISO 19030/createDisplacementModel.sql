/* Create displacement table, allowing displacements to be found for recorded drafts.

 Draft_Aft : metres
 Draft_Fore : metres
 Draft_Mean : metres
 LCF : metres; Length between centre of flotation and mid-ship section
 TPC : tonnes; tonnes per centimetre of additional mass submerged due to change in draft at this draft
 Trim : metres; Draft_Aft - Draft_Mean
 Displacement : m^3; Volume of fluid displaced by the hull
*/

DROP PROCEDURE IF EXISTS createDisplacementModel;

delimiter //

CREATE PROCEDURE createDisplacementModel()

	BEGIN
	
	CREATE TABLE DisplacementModel (Displacement_Model_Id INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
								 Name NVARCHAR(100),
								 Description TEXT,
								 Deleted BOOL
                                 );
								 
	END;