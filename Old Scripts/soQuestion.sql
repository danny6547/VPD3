CREATE TABLE TimeData (id INTEGER AUTO_INCREMENT PRIMARY KEY, A INT, date DATE);
INSERT INTO TimeData (A, Date) VALUES 
	(1,    '2011-09-08'),
    (1,    '2011-09-09'),
    (1,    '2011-09-10'),
    (1,    '2011-10-03'),
    (1,    '2011-10-04'),
    (1,    '2011-10-05'),
    (1,    '2014-09-10'),
    (1,    '2014-09-11'),
	(1,    '2014-09-12');

CREATE TABLE TimeInterval (id INTEGER AUTO_INCREMENT PRIMARY KEY, A INT, EndDate DATE, StartDate Date);
INSERT INTO TimeInterval (A, EndDate, StartDate) VALUES 
	(1,    '2011-09-17',    '2011-10-02'),
    (1,    '2014-08-10',    '2014-09-09'),
    (2,    '2009-03-27',    '2009-09-23');