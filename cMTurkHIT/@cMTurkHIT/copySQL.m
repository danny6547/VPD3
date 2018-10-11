function sql = copySQL(obj)
%copySQL Copy SQL to clipboard
%   Detailed explanation goes here

sql = obj.printSQL();
clipboard('copy', sql);
end