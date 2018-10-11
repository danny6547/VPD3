function [tbl, names, types] = veinlandFileTable(obj)
%veinlandFileTable Summary of this function goes here
%   Detailed explanation goes here

% Read data specification file
filename = obj.SpecFile;
file_xml = xmlread(filename);
el = file_xml.getElementsByTagName('xs:element');
ii = 0;
currAttName = el.item(ii).getAttribute('name');
reprow = [];
while ~strcmp(currAttName, 'REPROW') && ii <= (el.getLength - 1)

    ii = ii + 1;
    currAttName = el.item(ii).getAttribute('name');
    reprow = el.item(ii);
end

% Error if attributes not found in file
if isempty(reprow)
end

% Iterate names and types
complex_xml = reprow.getElementsByTagName('xs:complexType');
attribute_xml = complex_xml.item(0).getElementsByTagName('xs:attribute');
nVar = attribute_xml.getLength;
name_c = cell(1, nVar);
type_c = cell(1, nVar);
for ii = 1:nVar
    
    name_c{ii} = char( attribute_xml.item(ii-1).getAttribute('name') );
    type_c{ii} = char( attribute_xml.item(ii-1).getAttribute('type') );
end

% Create temporary cell with appropriate types
type_c = strrep(type_c, 'xs:', '');
char_l = strcmp(type_c, 'string');
double_l = strcmp(type_c, 'double') | strcmp(type_c, 'int');

% Append unspecified values found in files
foundVar = [...    
    {'dcrate_ae1_in'       }
    {'dcrate_ae2_in'       }
    {'density_ae1_in'      }
    {'density_ae2_in'      }
    {'depth'               }
    {'draft_fwd'           }
    {'flowcounter_ae1_in'  }
    {'flowcounter_ae2_in'  }
    {'lcvalue_ae1_in'      }
    {'lcvalue_ae2_in'      }
    {'lcvalue_me'          }
    {'seawater_temp'       }
    {'temperature_ae1_in'  }
    {'temperature_ae2_in'  }
    {'true_wind_speed_unit'}];
nVar = nVar + numel(foundVar);

doubleAppend_l = [true(1, numel(foundVar)-1), false];
charAppend_l = ~doubleAppend_l;
char_l = [char_l, charAppend_l];
double_l = [double_l, doubleAppend_l];

% Create temporary cell with appropriate types
temp_c = cell(1, nVar);
tempChar = 'a';
tempDouble = 1;

% Append unspecified values found in files
temp_c(char_l) =    {tempChar};
temp_c(double_l) =  {tempDouble};
name_c = [name_c, foundVar(:)'];

% Convert cell to table and remove all rows
tbl = cell2table(temp_c, 'VariableNames', name_c);
tbl(1, :) = [];

% Output
names = name_c;
types = cell(1, nVar);
types(char_l) = {'char'};
types(double_l) = {'double'};