function [obj, ins] = assignDefaults(obj)
%assignDefaults Assign default values
%   Detailed explanation goes here

ins{1} = ['The task has two types of data transcription: enter the maximum and minimum of the values in an image, and enter the values corresponding to a number of curves by reading the values off the axes.'];
ins{end+1} = ['In the first of these, you simply enter the smallest value in the input labelled ''Lowest Value'' and the highest in that labelled ''Highest Value''. The only thing to note is that these two values must be taken from the values arranged in a straight line, and not any around the edges of the image, as shown below:']; 
ins{end+1} = ['<img alt="image3_url" src="https://image.ibb.co/crUApJ/Graph_axis_explainer.jpg"/>']; 
ins{end+1} = ['The second task is to input the values of the curves in the image. This is done by typing the horizontal and vertical values corresponding to the curve at a number of points along the curve.'];
ins{end+1} = ['You must choose the points along the curve yourself, and the following procedure is recommended.'];
ins{end+1} = ['The procedure is to start at the bottom-left of the curve and read the value off the horizontal axis by taking a line straight down from this point to the axis, and estimating the value where it intercepts the axis by looking at the nearest values given there. The corresponding "Vertical" value is read from the vertical axis by taking a straight line horizontally from the point to the vertical axis. Then take another point further along the curve and repeat. You do not need to enter the values in order from bottom-left to top-right of the curve, but doing so may make the task simpler. It is very important that the points that you input cover the whole range of the curve (i.e. they go from the start to the end of the curve) and you should try to space the points evenly along the curve as much as possible. The below image should illustrate the procedure.']; 
ins{end+1} = ['<img alt="image3_url" class="img-responsive center-block" src="https://image.ibb.co/m405Od/Graph_Digitsation_Explainer.jpg" />'];
ins{end+1} = ['You must input a value into every input field.']; 
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

end