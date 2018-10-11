/* Create tempRaw table, a temporary table used to insert data from DNVGLRaw to RawData */

DROP PROCEDURE IF EXISTS createTempForceRaw;

delimiter //

CREATE PROCEDURE createTempForceRaw(imo INT)

BEGIN

DROP TABLE IF EXISTS tempForceRaw;
/* CREATE TABLE tempRaw LIKE dnvglraw; */

CREATE TABLE tempForceRaw LIKE `force`.`forceraw`;

ALTER TABLE tempForceRaw ADD COLUMN Seawater_Temperature DOUBLE (20, 5), 
ADD COLUMN Displacement DOUBLE (20, 5), 
ADD COLUMN DateTime_UTC DATETIME,
/*ADD COLUMN Air_Temperature DOUBLE (20, 5), */
ADD COLUMN Latitude DOUBLE (20, 5),
ADD COLUMN Longitude DOUBLE (20, 5),
ADD COLUMN Mass_Consumed_Fuel_Oil DOUBLE (20, 5), 
ADD COLUMN Air_Pressure DOUBLE (20, 5),
ADD COLUMN Relative_Wind_Speed DOUBLE (20, 5), 
ADD COLUMN Relative_Wind_Direction DOUBLE (20, 5),
ADD COLUMN Shaft_Revolutions DOUBLE (20, 5),
ADD COLUMN Static_Draught_Fore DOUBLE (20, 5),
ADD COLUMN Static_Draught_Aft DOUBLE (20, 5),
ADD COLUMN Lower_Caloirifc_Value_Fuel_Oil DOUBLE (20, 5),
ADD COLUMN Density_Fuel_Oil_15C DOUBLE (20, 5),
ADD COLUMN Speed_Through_Water DOUBLE (20, 5),
ADD COLUMN Ship_Heading DOUBLE (20, 5),
ADD COLUMN Rudder_Angle DOUBLE (20, 5),
ADD COLUMN Water_Depth DOUBLE (20, 5),
ADD COLUMN Shaft_Torque DOUBLE (20, 5),
ADD COLUMN IMO_Vessel_Number INT(7),
ADD COLUMN Delivered_Power INT(7),
ADD COLUMN Speed_Over_Ground DOUBLE (20, 5)
;

/* Seawater_Temperature, Displacement, Air_Temperature, Mass_Consumed_Fuel_Oil, Air_Pressure, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, */

INSERT INTO tempForceRaw (name, imo_number, filtered, start, xend, lat_N, lat_t1, lat_t2, lat_mean, lon_N, lon_t1, lon_t2, lon_mean, sog_N, sog_t1, sog_t2, sog_min, sog_max, sog_mean, sog_std, cog_N, cog_t1, cog_t2, cog_min, cog_max, cog_mean, cog_std, stw_N, stw_t1, stw_t2, stw_min, stw_max, stw_mean, stw_std, hdt_N, hdt_t1, hdt_t2, hdt_min, hdt_max, hdt_mean, hdt_std, wins_N, wins_t1, wins_t2, wins_min, wins_max, wins_mean, wins_std, wind_N, wind_t1, wind_t2, wind_min, wind_max, wind_mean, wind_std, airt_N, airt_t1, airt_t2, airt_min, airt_max, airt_mean, airt_std, airp_N, airp_t1, airp_t2, airp_min, airp_max, airp_mean, airp_std, rot_N, rot_t1, rot_t2, rot_min, rot_max, rot_mean, rot_std, rud_N, rud_t1, rud_t2, rud_min, rud_max, rud_mean, rud_std, pitch_N, pitch_t1, pitch_t2, pitch_min, pitch_max, pitch_mean, pitch_std, roll_N, roll_t1, roll_t2, roll_min, roll_max, roll_mean, roll_std, dpt_N, dpt_t1, dpt_t2, dpt_min, dpt_max, dpt_mean, dpt_std, spow_N, spow_t1, spow_t2, spow_min, spow_max, spow_mean, spow_std, srpm_N, srpm_t1, srpm_t2, srpm_min, srpm_max, srpm_mean, srpm_std, strq_N, strq_t1, strq_t2, strq_min, strq_max, strq_mean, strq_std, sthr_N, sthr_t1, sthr_t2, sthr_min, sthr_max, sthr_mean, sthr_std, piid, speed_index_propeller, consumption_index_propeller, speed_index_hull, consumption_index_hull, speed_index_combined, consumption_index_combined, distance_through_water, fuel_oil_consumption_iso_corrected, shaft_power_estimate, shaft_power, shaft_thrust, shaft_power_estimate_from_rpm00, advance_ratio_estimate00, propeller_torque_coefficient, propeller_tourque_coefficient_estimate00, propeller_tourque_coefficient_estimate01, propeller_thrust_estimate00, shaft_power_theoretical, shaft_power_reference_condition_normalized, shaft_power_estimate_reference_condition_normalized, fuel_oil_consumption_reference_condition_normalized, shaft_power_charter_party_condition_normalized, shaft_power_estimate_charter_party_condition_normalized, charter_party_seaState, charter_party_wind, fuel_oil_consumption_charter_party_condition_normalized, loading_reference, shaft_power_loading_condition_normalized, shaft_power_estimate_loading_condition_normalized, fuel_oil_consumption_loading_condition_normalized, specific_fuel_oil_consumption_reference, specific_fuel_oil_consumption_normalized_to_reference_mcr, excessresistanceestimate01, iso19030speedloss, consolidateddepth, type, average_speed, report_start_utc, report_end_utc, remaining_distance, heading, report_lat, report_lon, draught_aft, draught_fore, distance_logged, distance_observed, wind_speed, wind_direction, air_temperature, barometric_pressure, sea_state, waves_direction, min_water_depth, water_temperature, me_power, me_turbo_charger_rpm, propeller_rpm, pump_index, sg_production, cp_propeller_pitch, cp_propeller_pitch_unit, report_shaft_thrust, main_engine_hfo_consumption, main_engine_hfo_ls_consumption, main_engine_mdo_consumption, total_hfo_consumption, total_hfo_ls_consumption, total_mdo_consumption, remaining_hfo, remaining_hfo_ls, remaining_mdo, main_engine_mdo_ls_consumption, main_engine_mgo_consumption, main_engine_bio_consumption, total_mdo_ls_consumption, total_mgo_consumption, total_bio_consumption, remaining_mdo_ls, remaining_mgo, remaining_bio, lower_calorific_value_for_bio, lower_calorific_value_for_hfo, lower_calorific_value_for_ls_hfo, lower_calorific_value_for_ls_mdo, lower_calorific_value_for_mdo, lower_calorific_value_for_mgo, payload, payload_unit, voyagename, eventid, eventstart, eventend, eventname)
	(SELECT name, imo_number, filtered, start, xend, lat_N, lat_t1, lat_t2, lat_mean, lon_N, lon_t1, lon_t2, lon_mean, sog_N, sog_t1, sog_t2, sog_min, sog_max, sog_mean, sog_std, cog_N, cog_t1, cog_t2, cog_min, cog_max, cog_mean, cog_std, stw_N, stw_t1, stw_t2, stw_min, stw_max, stw_mean, stw_std, hdt_N, hdt_t1, hdt_t2, hdt_min, hdt_max, hdt_mean, hdt_std, wins_N, wins_t1, wins_t2, wins_min, wins_max, wins_mean, wins_std, wind_N, wind_t1, wind_t2, wind_min, wind_max, wind_mean, wind_std, airt_N, airt_t1, airt_t2, airt_min, airt_max, airt_mean, airt_std, airp_N, airp_t1, airp_t2, airp_min, airp_max, airp_mean, airp_std, rot_N, rot_t1, rot_t2, rot_min, rot_max, rot_mean, rot_std, rud_N, rud_t1, rud_t2, rud_min, rud_max, rud_mean, rud_std, pitch_N, pitch_t1, pitch_t2, pitch_min, pitch_max, pitch_mean, pitch_std, roll_N, roll_t1, roll_t2, roll_min, roll_max, roll_mean, roll_std, dpt_N, dpt_t1, dpt_t2, dpt_min, dpt_max, dpt_mean, dpt_std, spow_N, spow_t1, spow_t2, spow_min, spow_max, spow_mean, spow_std, srpm_N, srpm_t1, srpm_t2, srpm_min, srpm_max, srpm_mean, srpm_std, strq_N, strq_t1, strq_t2, strq_min, strq_max, strq_mean, strq_std, sthr_N, sthr_t1, sthr_t2, sthr_min, sthr_max, sthr_mean, sthr_std, piid, speed_index_propeller, consumption_index_propeller, speed_index_hull, consumption_index_hull, speed_index_combined, consumption_index_combined, distance_through_water, fuel_oil_consumption_iso_corrected, shaft_power_estimate, shaft_power, shaft_thrust, shaft_power_estimate_from_rpm00, advance_ratio_estimate00, propeller_torque_coefficient, propeller_tourque_coefficient_estimate00, propeller_tourque_coefficient_estimate01, propeller_thrust_estimate00, shaft_power_theoretical, shaft_power_reference_condition_normalized, shaft_power_estimate_reference_condition_normalized, fuel_oil_consumption_reference_condition_normalized, shaft_power_charter_party_condition_normalized, shaft_power_estimate_charter_party_condition_normalized, charter_party_seaState, charter_party_wind, fuel_oil_consumption_charter_party_condition_normalized, loading_reference, shaft_power_loading_condition_normalized, shaft_power_estimate_loading_condition_normalized, fuel_oil_consumption_loading_condition_normalized, specific_fuel_oil_consumption_reference, specific_fuel_oil_consumption_normalized_to_reference_mcr, excessresistanceestimate01, iso19030speedloss, consolidateddepth, type, average_speed, report_start_utc, report_end_utc, remaining_distance, heading, report_lat, report_lon, draught_aft, draught_fore, distance_logged, distance_observed, wind_speed, wind_direction, air_temperature, barometric_pressure, sea_state, waves_direction, min_water_depth, water_temperature, me_power, me_turbo_charger_rpm, propeller_rpm, pump_index, sg_production, cp_propeller_pitch, cp_propeller_pitch_unit, report_shaft_thrust, main_engine_hfo_consumption, main_engine_hfo_ls_consumption, main_engine_mdo_consumption, total_hfo_consumption, total_hfo_ls_consumption, total_mdo_consumption, remaining_hfo, remaining_hfo_ls, remaining_mdo, main_engine_mdo_ls_consumption, main_engine_mgo_consumption, main_engine_bio_consumption, total_mdo_ls_consumption, total_mgo_consumption, total_bio_consumption, remaining_mdo_ls, remaining_mgo, remaining_bio, lower_calorific_value_for_bio, lower_calorific_value_for_hfo, lower_calorific_value_for_ls_hfo, lower_calorific_value_for_ls_mdo, lower_calorific_value_for_mdo, lower_calorific_value_for_mgo, payload, payload_unit, voyagename, eventid, eventstart, eventend, eventname
		FROM forceraw WHERE imo_number = imo AND start IS NOT NULL AND xend IS NOT NULL);

CALL convertForceRawToRawData;

END;