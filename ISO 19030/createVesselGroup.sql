/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselGroup;

delimiter //

CREATE PROCEDURE createVesselGroup()

BEGIN

	CREATE TABLE `static`.VesselGroup (id INT PRIMARY KEY AUTO_INCREMENT, 
								Name nvarchar(50) NOT NULL,
								Description text,   
								Select_Vessels_Query text,  
								Responsible text,
								Report_Id               nvarchar(50),
								Group_Id                nvarchar(50),
								Created                 datetime,
								Created_By              varchar(255),
								Modified                datetime,
								Modified_By				varchar(255)
														 );
END;