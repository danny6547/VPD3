
DROP PROCEDURE IF EXISTS createWindCoefficientModel;

delimiter //

CREATE PROCEDURE createWindCoefficientModel()

BEGIN

create table `static`.WindCoefficientModel (Wind_Coefficient_Model_Id INT PRIMARY KEY AUTO_INCREMENT, 
										Name nvarchar(100), 
										Description TEXT,
                                        Deleted BOOL NOT NULL);
END;