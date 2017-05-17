dd = cVesselDryDockDates();
dd = dd.assignDates('2009-04-30', '2011-04-10');
vessel = cVessel();
vessel.IMO_Vessel_Number = 9450624;
vessel.DryDockDates = dd;
vessel.insertIntoDryDockDates;

dd = cVesselDryDockDates();
dd = dd.assignDates('', '');
vessel = cVessel();
vessel.IMO_Vessel_Number = [];
vessel.DryDockDates = dd;
vessel.insertIntoDryDockDates;