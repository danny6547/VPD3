function [obj] = defaultInstructions(obj)
%defaultInstructions Summary of this function goes here
%   Detailed explanation goes here

obj.Instructions = {'Type the values into the table under the appropriate row names.'...
                    'DO NOT hit the "Enter" or "Return" key on your keyboard until all values are entered, otherwise the HIT will be submitted partially complete.'...
                    'Type all available numeric digits for each value (0-9), any decimal points found (.), and any minus sign (-) and no other characters.'...
                    'Ignore any rows additional to the number of rows in the image.'
                    };
end