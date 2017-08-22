/* Create table of models, giving the name corresponding to the model identifier.

 ModelID : integer; corresponding to a model identifier in another table
 Name : text; name of the model (e.g. 'Speed Power model 1 for CMA CGM 11500 TEU Class')
 Type : text; one of a predefined set of model types (SpeedPower, Wind, Displacement ...)
 
*/

DROP PROCEDURE IF EXISTS createModels;

delimiter //

CREATE PROCEDURE createModels()

	BEGIN
	
	CREATE TABLE Models (id INT PRIMARY KEY AUTO_INCREMENT,
								 ModelID INT NOT NULL,
								 Name VARCHAR(255) UNIQUE,
								 Type VARCHAR(25),
                                 CONSTRAINT UniqueModelsOfType UNIQUE(ModelID, Type)
                                 );
	END;