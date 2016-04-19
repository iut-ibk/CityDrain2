%=============================================================================
% File:			mfun_cd2_flowread.m
% Purpose:		read parameters (q and if availabel component values) from
%               file. Values are saperated by space or tabs. First line 
%               describes component names.
%               File example:
%
%               time       q     co2     cu
%                  0     1.2    0.11   0.02
%                300     1.1    0.12   0.03
%
% Reamarks:     For CityDrain 1.0 first line can be discarded.
% Author:		H. Kinzel, IUT
% Date:			Origin: 25.04.2005, Last updated: 29.04.2005	
% Version		002
%=============================================================================

function [y,n] = CD1_mfun_flowread_old(filename)

n=''; %component names for CD2. for CD=''.

fid=fopen(filename);
line = fgetl(fid);

% discard all empty lines
while isempty(line)
	line = fgetl(fid);
end

% test if at least  one char is in line. if then take line values as names.
if ~isempty(find(isletter(line)))
	n=line;
	line = fgetl(fid);
end

y=sscanf(line,'%f')';
line = fgetl(fid);
while ischar(line)
	y=[y;sscanf(line,'%f')'];
	line = fgetl(fid);
end	

fclose(fid);
