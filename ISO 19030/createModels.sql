/* Create table of models, giving the name corresponding to the model identifier.

 ModelID : integer; corresponding to a model identifier in another table
 Name : text; name of the model (e.g. 'Speed Power model 1 for CMA CGM 11500 TEU Class')
 Type : text; one of a predefined set of model types (SpeedPower, Wind, Displacement ...)
 
*/

DROP PROCEDURE IF EXISTS createModels;

delimiter //

CREATE PROCEDURE createModels()

	BEGIN
	
	CREATE TABLE Models (Models_id INT PRIMARY KEY AUTO_INCREMENT,
								 Name VARCHAR(50) UNIQUE,
								 Type VARCHAR(25),
                                 Description VARCHAR(255),
                                 CONSTRAINT UniqueModelsOfType UNIQUE(Models_id, Type)
                                 );
	END;