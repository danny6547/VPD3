
DROP PROCEDURE IF EXISTS createWindCoefficientModel;

delimiter //

CREATE PROCEDURE createWindCoefficientModel()

BEGIN

create table createWindCoefficientModel (Wind_Coefficient_Model_Id INT PRIMARY KEY AUTO_INCREMENT, 
										Name nvarchar(100), 
										Description TEXT,
                                        Deleted BINARY NOT NULL);
END;