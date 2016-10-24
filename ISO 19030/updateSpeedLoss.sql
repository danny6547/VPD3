/* Calculate speed loss as a percentage */

UPDATE tempRawISO SET Speed_Loss = (100 * (Speed_Through_Water - Expected_Speed_Through_Water) / Expected_Speed_Through_Water);