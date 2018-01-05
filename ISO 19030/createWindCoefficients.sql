
DROP PROCEDURE IF EXISTS createwindcoefficientdirection;

delimiter //

CREATE PROCEDURE createwindcoefficientdirection()

BEGIN

create table windcoefficientdirection (id INT PRIMARY KEY AUTO_INCREMENT, 
																Models_id INT NOT NULL UNIQUE, 
                                                                Direction DOUBLE(4, 1) NOT NULL DEFAULT 0,
                                                                Coefficient DOUBLE(9, 8) NOT NULL DEFAULT 0,
                                                                CONSTRAINT UniModelDirs UNIQUE (Models_id, Direction));
                                                                
END;