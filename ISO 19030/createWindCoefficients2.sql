
create table hull_performance.windcoefficientdirection (id INT PRIMARY KEY AUTO_INCREMENT, 
																ModelID INT, 
                                                                Direction DOUBLE(4, 1),
                                                                Coefficient DOUBLE(9, 8),
                                                                Name TEXT,
                                                                CONSTRAINT UniModelDirs UNIQUE (ModelID, Direction));
                                                                
/* Almaviva head wind coeff: 0.000151200 */