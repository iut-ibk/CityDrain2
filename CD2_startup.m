% Path setting for CITY DRAIN 2.0
% IUT Institute of Infrastructure - Unit of Environmental Engineering

cd02path='C:\Program Files\CityDrain01';

cd02path_full=genpath(cd02path);
k=strcmp(cd02path_full,'');

disp('Matlab-path for CITY DRAIN 2.0:');

if k==1
	disp('HAS NOT BEEN SET !!');
	disp('Please check in startup.m if path is set correctly.');
	disp(' ');
	disp(' ');
else

	disp(cd02path);
	path(path,cd02path_full);
	disp(' ');
	disp(' ');

end

clear('cd02path');clear('cd02path_full');clear('k');

% In case CITY DRAIN program files are moved, please insert the correct path above