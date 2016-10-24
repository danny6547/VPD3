/* Create Tables */
/* CREATE TABLE numbers (id INT PRIMARY KEY AUTO_INCREMENT, number INT, nearest INT, Diff DOUBLE(10, 5), Cond Bool);
INSERT INTO numbers (number) VALUES (2502);
INSERT INTO numbers (number) VALUES (2494);
INSERT INTO numbers (number) VALUES (2508);
INSERT INTO numbers (number) VALUES (2489);
INSERT INTO numbers (number) VALUES (2513);
INSERT INTO numbers (number) VALUES (2487);

CREATE TABLE lookups (id INT PRIMARY KEY AUTO_INCREMENT, a INT);
INSERT INTO lookups (a) VALUES (2500);
INSERT INTO lookups (a) VALUES (2490);*/

/* Access Scalar */
/* SELECT number, ABS( number - 2500 ) AS distance FROM 
(
(SELECT number FROM `numbers` WHERE number >= 2500 ORDER BY number LIMIT 7) 
UNION 
ALL (SELECT number FROM `numbers` WHERE number < 2500 ORDER BY number DESC LIMIT 6) 
)
AS n ORDER BY distance LIMIT 1; */

/* Access Vector */
/* (SELECT * FROM numbers FORCE INDEX (PRIMARY) WHERE number <= 9999 ORDER BY number DESC LIMIT 1)
UNION
(SELECT * FROM numbers FORCE INDEX (PRIMARY) WHERE number >= 2500 ORDER BY number LIMIT 1) */

SELECT number, MIN(Difference) AS 'Shortest', number + 'Shortest' AS 'A' FROM 
		(SELECT number, a, ABS(number - a) AS 'Difference' FROM numbers
			JOIN lookups) AS tempTable1 GROUP BY number;
            
UPDATE tempTable1 SET A = number + Shortest;

/* SELECT number, a, ABS(number - a) AS 'Difference' FROM numbers
JOIN lookups*/