% Path setting for CITY DRAIN 1.0
% IUT Institute of Environmental Engineering

cd01path='C:\Program Files\CityDrain01';

cd01path_full=genpath(cd01path);
k=strcmp(cd01path_full,'');

disp('Matlab-path for CITY DRAIN 1.0:');

if k==1
	disp('HAS NOT BEEN SET !!');
	disp('Please check in startup.m if path is set correctly.');
	disp(' ');
	disp(' ');
else

	disp(cd01path);
	path(path,cd01path_full);
	disp(' ');
	disp(' ');

end

clear('cd01path');clear('cd01path_full');clear('k');

% In case CITY DRAIN program files are moved, please insert the correct path above