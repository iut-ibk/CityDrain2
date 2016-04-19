%=============================================================================
% File:			mfun_rainread_ixx.m
% Purpose:		Reading of raindata from file in ixxx-format
%               
% Author:		S Achleitner,S. De Toffol, (IUT)
% Date:			20.07.2004	
% Version		001
%=============================================================================

% 
% 
% Parameters:
% file_in:
%   Inputfile where raindata is stored 
% 
% 
%==========================================================================

function  [yout]=mfun_rainread_ixx_old(file)

[DD,a,MM,b,YYYY,hh,c,mm,d,ss,vol] = textread(file,'%2d%1c%2d%1c%4d %2d%1c%2d%1c%2d %f');


Ymin=YYYY-min(YYYY);
timedd = datenum(YYYY,MM,DD,hh,mm,ss); % in days given
timess = timedd.*24.*60.*60; %converted to seconds
simtime = timess - min(timess); %setting smallest time to zero

yout=[simtime,vol];


