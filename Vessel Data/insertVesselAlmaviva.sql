/* Add Vessel data for CMA CGM Almaviva */

use hull_performance;

INSERT INTO Vessels (IMO_Vessel_Number, Name, 				Owner, 		Engine_Model, Transverse_Projected_Area_Design, Block_Coefficient, Length_Overall, Breadth_Moulded, Draft_Design, LBP, WindModelID, Speed_Power_Source)
			 VALUES (9450648, 		    'CMA CGM Almaviva', 'CMA CGM', '12k98me-c7',  1330, 							0.62, 			  334, 			  42.8, 		   15, 			 319, 1, '\\hempel.net\Function\RD\Group\Marine Business Support\Hull and propeller performance\Vessels\CMA CGM\Hempel Collaboration\model tests\Model Tests 8500 SHI\Calm Water Model Tests for HN1787s - 8500TEU Container Carrier\SFRMRSHOP1216012914290.pdf');