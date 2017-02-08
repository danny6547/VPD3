/* Create table for coatings applied to vessels during dry-docking */

USE hull_performance;

CREATE TABLE vesselCoating (id INT PRIMARY KEY AUTO_INCREMENT, IMO_Vessel_Number INT(7), CoatingName VARCHAR(255), DryDockId INT)