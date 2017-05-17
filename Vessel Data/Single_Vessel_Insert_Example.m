obj11400 = cVesselClass();
obj11400(1).WeightTEU = 11400;
obj11400(1).Engine = 'HHI – Man B&W 12K98ME-C Mk 7';
obj11400(1).Transverse_Projected_Area_Design = 2085;
obj11400(1).Block_Coefficient = 0.6473;
obj11400(1).Length_Overall = 363;
obj11400(1).Breadth_Moulded = 45.6;
obj11400(1).Draft_Design = 13;
obj11400(1).LBP = 348;
obj(1:2) = obj(1:2).assignClass(obj11400);
obj(1).Name = 'CMA CGM CASSIOPEIA';

% Insert data
vessel = cVessel();
vessel.Owner = 'CMA CGM';
vessel.LBP = 348;
vessel.Engine = 'HHI – Man B&W 12K98ME-C Mk 7';
vessel.Transverse_Projected_Area_Design = 2085;
vessel.Block_Coefficient = 0.6473;
vessel.Length_Overall = 363;
vessel.Breadth_Moulded = 45.6;
vessel.Draft_Design = 13;
vessel.insert;

vessel = cVessel('IMO', 9410765);
