
DROP PROCEDURE IF EXISTS createwindcoefficientdirection;

delimiter //

CREATE PROCEDURE createwindcoefficientdirection()

BEGIN

create table windcoefficientdirection (id INT PRIMARY KEY AUTO_INCREMENT, 
																ModelID INT NOT NULL, 
                                                                Direction DOUBLE(4, 1) NOT NULL,
                                                                Coefficient DOUBLE(9, 8) NOT NULL,
                                                                Name TEXT,
                                                                CONSTRAINT UniModelDirs UNIQUE (ModelID, Direction));
                                                                
END;