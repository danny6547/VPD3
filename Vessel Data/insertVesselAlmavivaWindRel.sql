/* Add data for Vessel CMA CGM Almaviva to WindCoefficients */

use test2;

INSERT INTO WindCoefficientDirection (IMO_Vessel_Number, Start_Direction, End_Direction, Coefficient) 
			 VALUES (9450648, 		    0, 				 	 30, 			0.0001512),
					 (9450648, 		    30, 				 60, 			0.2e-5),
					 (9450648, 		    60, 				 90, 			0.3e-5),
					 (9450648, 		    90, 				120, 			0.4e-5),
					 (9450648, 		   120, 				150, 			0.5e-5),
					 (9450648, 		   150, 				180, 			0.6e-5),
					 (9450648, 		   180, 				210, 			0.55e-5),
					 (9450648, 		   210, 				240, 			0.45e-5),
					 (9450648, 		   240, 				270, 			0.35e-5),
					 (9450648, 		   270, 				300, 			0.25e-5),
					 (9450648, 		   300, 				330, 			0.15e-5),
					 (9450648, 		   330, 				 0, 			0.05e-5);
