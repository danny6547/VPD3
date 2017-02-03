/* Demonstration of insert...on duplicate key update with statements demonstrating whether data is affected when duplicate keys are inserted. */

DROP TABLE IF EXISTS temp1;
CREATE TABLE temp1 (id INT PRIMARY KEY, a INT, b INT, c INT, d INT, e INT, CONSTRAINT ida UNIQUE(a, b));
INSERT INTO temp1 (id, a, b) VALUES (1, 2, 0);
INSERT INTO temp1 (id, a, b) VALUES (2, 2, 1);
INSERT INTO temp1 (id, a, b, c) VALUES (3, 2, 2, 0);
INSERT INTO temp1 (id, a, b, c, d) VALUES (3, 2, 2, 4, 5) ON duplicate key update c = values(c), d = values(d);
INSERT INTO temp1 (id, a, b, c, d) VALUES (3, 2, 2, 4, 4) ON duplicate key update c = values(c), d = values(d);
SELECT (SELECT COUNT(e) FROM temp1) != 0;