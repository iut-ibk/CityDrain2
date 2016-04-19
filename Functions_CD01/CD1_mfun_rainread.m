%=============================================================================
% File:			mfun_cd2_Rainread.m
% Purpose:		reads rainfall from               
% Author:		H. Kinzel, IUT
% Date:			Origin: 11.05.2005, Last updated: 6.06.2005	
% Version		003
%=============================================================================

function [T,step] = CD1_mfun_rainread(filename)

extTmp=strfind(filename,'.');
if isempty(extTmp)
	error('CD1_rr needs filename with extention (.ixx .msn) to determ filetype.');
end
ext=filename(extTmp(1:end):end);

switch ext
	case '.ixx',
		[T,step]=CD1_rainread_ixx(filename);
	case '.mse',
		[T,step]=CD1_rainread_mse(filename);
	case '.km2',
		[T,step]=CD1_rainread_km2(filename);
	case '.txt',
		[T,step]=CD1_rainread_txt(filename);
	otherwise
		error('Format %s unknown.',ext);
end





function [A,step]=CD1_rainread_ixx(filename)
[DD,a,MM,b,YYYY,hh,c,mm,d,ss,vol] = textread(filename,'%2d%1c%2d%1c%4d %2d%1c%2d%1c%2d %f');

Ymin=YYYY-min(YYYY);
timedd = datenum(YYYY,MM,DD); % number if days given
timess = timedd.*24.*60.*60.+3600*hh+60*mm+ss; %convert days to seconds an add day seconds
simtime = timess - min(timess); %setting smallest time to zero

A=[simtime,vol];
step=300; %use timstep calc from mse instead?



function sec=CD1_date2sec(YY,MM,DD,hh,mm,ss)
if YY<100 %set all years with only two numerals to be in 1900.
	YY=YY+1900;
end
sec = datenum(YY,MM,DD)*24*60*60 + 3600*hh + 60*mm + ss; %convert days to seconds an add day seconds



function [A,timestep]=CD1_rainread_mse(filename)
%read file in vars
[YY,MM,DD,hh,mm,ss,vol] = textread(filename,'%f %f %f %f %f %f %f');

%calc timestep size (by calc start second modulo 5 resp. 10 for all events)
i5=1;
i10=1;
for i=1:length(YY)
	if mod(mm(i),10)~=0
		i10=0;
		if mod(mm(i),5)~=0
			i5=0;	
		end	
	end
end
timestep=60;
if i5 
	timestep=300;
end
if i10	
	timestep=600;
end

%calc start stop second of file and # of timesteps in handled in file 
startSec=CD1_date2sec(YY(1),MM(1),DD(1),hh(1),mm(1),ss(1));
stopSec=CD1_date2sec(YY(end),MM(end),DD(end),hh(end),mm(end),ss(end));
noTimeSteps=((stopSec-startSec)/timestep)+1;

%create empty output matrix (much faster than create matrix step by step)
A=zeros(noTimeSteps,2);
A(1:end,1)=[0:timestep:stopSec-startSec]';

%fill matrix with volume values
for i=1:length(YY)
	eventEndSec=CD1_date2sec(YY(i),MM(i),DD(i),hh(i),mm(i),ss(i))-startSec;
	outTabPos=1+(eventEndSec/timestep);
	A(outTabPos,2)=vol(i);
end



function [table, intervalLength]=CD1_rainread_km2_readevent(fid)
header_line = fgetl(fid);
%parse header line
[tok_3,rline]=strtok(header_line);	
[tok_date,rline]=strtok(rline);
[tok_time,rline]=strtok(rline);
[tok_0,rline]=strtok(rline);
[tok_no,rline]=strtok(rline);
[tok_ilength,rline]=strtok(rline);
[tok_h,rline]=strtok(rline);

%set vars from header
year=sscanf(tok_date(1:4),'%f');
month=sscanf(tok_date(5:6),'%f');
day=sscanf(tok_date(7:8),'%f');
hour=sscanf(tok_time(1:2),'%f');
minute=sscanf(tok_time(3:4),'%f');
sek=datenum(year,month,day)*86400+hour*3600+minute*60;

noRainEvents=sscanf(tok_no,'%f');
intervalLength=60*sscanf(tok_ilength,'%f');

%read all rainevents
A=[0 0];
for i=1:noRainEvents
	[tok_vol,rline]=strtok(rline);
	if isempty(tok_vol)
		rline = fgetl(fid);
		[tok_vol,rline]=strtok(rline);	
	end
	A=[A;(i-1)*intervalLength+sek intervalLength*sscanf(tok_vol,'%f')/1000];
end	
table=A(2:end,1:end);




function [A,intervalLength]=CD1_rainread_km2(filename)
fid=fopen(filename);
[A,intervalLength]=CD1_rainread_km2_readevent(fid);
while ~feof(fid)
	[B,intervalLength]=CD1_rainread_km2_readevent(fid);

	%fill empty events
	X=zeros((B(1,1)-A(end,1))/intervalLength-1,2);
	for i=1:(B(1,1)-A(end,1))/intervalLength-1
		X(i)=A(end,1)+i*300;
	end
	
	%compose resulting matrix
	A=[A; X; B];
end

%set min time in table to zero
minA=min(A(1:end,1));
A(1:end,1)=(A(1:end,1)-minA);





function [y,step]=CD1_rainread_txt(filename)
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
step=300;