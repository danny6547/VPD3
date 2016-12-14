/* Get coating for ship at input DateTime */

delimiter //

CREATE PROCEDURE vesselCoatingAtDate(OUT coating VARCHAR(255), INOUT datet DATETIME, imo INT(7))

BEGIN

	SELECT (SELECT CoatingName FROM vesselcoating
				WHERE DryDockId =
					(SELECT id FROM DryDockDates
						WHERE IMO_Vessel_Number = imo AND
							EndDate <= datet LIMIT 1))
	INTO coating;

END