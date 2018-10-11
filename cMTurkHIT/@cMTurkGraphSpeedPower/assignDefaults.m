function [obj, ins] = assignDefaults(obj)
%assignDefaults Assign default values
%   Detailed explanation goes here

ins{1} = ['The task has two types of data transcription: enter the maximum and minimum of the values in an image, and enter the values corresponding to a number of curves by reading the values off the axes.'];
ins{end+1} = ['In the first of these, you simply enter the smallest value in the input labelled ''Lowest Value'' and the highest in that labelled ''Highest Value''. The only thing to note is that these two values must be taken from the values arranged in a straight line, and not any around the edges of the image, as shown below:']; 
ins{end+1} = ['<img alt="image3_url" src="https://image.ibb.co/crUApJ/Graph_axis_explainer.jpg"/>']; 
ins{end+1} = ['The second task is to input the values of the curves in the image. This is done by typing the vertical values corresponding to the horizontal values of the curve at a number of points along the curve.'];
ins{end+1} = ['The points along the curve are given under the table heading "Horizontal". To find the corresponding "Vertical" values, the following procedure is recommended.'];
ins{end+1} = ['The procedure is to start at the first "Horizontal" value and find the corresponding tick mark on the horizontal axis, follow the blue line vertically until it intersects the curve. The corresponding "Vertical" value is read from the vertical axis by taking a straight line horizontally from this point (use a ruler if it helps) to the vertical axis. The below image should illustrate the procedure.']; 
ins{end+1} = ['<img alt="image3_url" class="img-responsive center-block" src="https://image.ibb.co/m405Od/Graph_Digitsation_Explainer.jpg" />'];
ins{end+1} = ['You must input a "Vertical" value for every "Horizontal" value.']; 
ins{end+1} = ['Each curve is clearly labelled in the image and a corresponding name is given above each pair of horizontal and vertical input fields.']; 
ins{end+1} = ['Repeat the procedure for every curve for which input fields are given.']; 

% Assign bullet point HTML tags
bullets = true(1, length(ins));
bullets([1, 3, 4, 7]) = false;
ins(bullets) = obj.bulletPoints(ins(bullets));
ins(~bullets) = obj.text(ins(~bullets));

% ins = obj.bulletPoints(ins);

% Enclose contiguous bullet points in bullet point list
% notBullets = ~bullets;
% notBullets([1, end]) = false;
% ins(notBullets) = strcat('</ul>', ins(notBullets), '<ul>');

% Enclose all in bullet point list
% ins = ['<ul>', ins, '</ul>'];

% % Create object for graph axes ranges
% obj2 = cMTurkGraphSpeedPower();
% obj2.C


% Assign
obj.TemplateSite = 'Transcription From Images';
obj.Instructions = ins;
obj.NumRows = 25;

end