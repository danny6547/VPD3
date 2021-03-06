
DROP PROCEDURE IF EXISTS createWindCoefficientModelValue;

delimiter //

CREATE PROCEDURE createWindCoefficientModelValue()

BEGIN

create table `static`.WindCoefficientModelValue (id INT PRIMARY KEY AUTO_INCREMENT,
										Wind_Coefficient_Model_Id INT(10) NOT NULL,
										Direction FLOAT(15, 3) DEFAULT 0,
										Coefficient FLOAT(15, 13) DEFAULT 0,
										CONSTRAINT UniqueModelValue UNIQUE(Wind_Coefficient_Model_Id, Direction));
END;