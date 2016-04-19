%=============================================================================
% File:			CD1_sfun_rainread_mse.m
% Purpose:		Function that reads raindata from ASCII file in mse format
% Author:		Wolfagng Rauch, Stefan Achleitner
% Date:			Original: 14.10.1999, Last updated: 02.09.2004
% Version		002
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_rainread_mse_old(t,x,u,flag,filename,tstep)

%fid=fopen(filename,'r');		%open rainfile
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(filename,tstep);
  case 2,
    sys=mdlUpdate(t,x,u,tstep);   
  case 3,
     sys=mdlOutputs(t,x,u);    
  case 9,
     sys=mdlTerminate(t,x,u);
  case {1,4}  
     sys=[];    
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end
%=============================================================================


%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(filename,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 11;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 0;	
sizes.NumSampleTimes = 1; 

fid=fopen(filename,'r');		%open rainfile


% Read first line of datafile for initializing x0
year=fscanf(fid,'%d',1);
mon=fscanf(fid,'%d',1);
day=fscanf(fid,'%d',1);
hour=fscanf(fid,'%d',1);
min=fscanf(fid,'%d',1);
sec=fscanf(fid,'%d',1);
n=fscanf(fid,'%f\n',1);
file_pos=ftell(fid);

sys = simsizes(sizes);
x0  = [year,mon,day,hour,min,sec,n*tstep/1000,0,file_pos,0,fid];
str = [];
ts  = [tstep 0];
%=============================================================================


%=============================================================================
function sys=mdlUpdate(t,x,u,tstep)

fid=x(11);
if x(10)>0
   x(10)=x(10)-1;
   sys=x;
else
   status=fseek(fid,x(9),'bof');   
   if feof(fid)==0  
      year=fscanf(fid,'%d',1);
       if isempty(year)==1    % if empty spaces insted eof
         sys = zeros(11,1);	% end simulation with outputsignal(2)=1
         sys(8)=1;
         break
      end
      mon=fscanf(fid,'%d',1);
      day=fscanf(fid,'%d',1);
      hour=fscanf(fid,'%d',1);
      min=fscanf(fid,'%d',1);
      sec=fscanf(fid,'%d',1);
      n=fscanf(fid,'%f\n',1);
      
      %calculate time difference between input lines in days
      od=datenum(x(1),x(2),x(3),x(4),x(5),x(6));
      nd=datenum(year,mon,day,hour,min,sec);
      dat_diff=(nd-od);
      if abs(dat_diff-tstep/86400)>0.0001
         % No rain input - so output = 0
         % date states updated
         x(10)=floor(dat_diff/tstep*86400)-1; % -1 : regular sampling interval otherwise missed    
         ndd=datestr(nd-tstep/86400);
         ndv=datevec(ndd);
         sys = [ndv(1),ndv(2),ndv(3),ndv(4),ndv(5),ndv(6),0,0,x(9),x(10),x(11)];
      else
         file_pos=ftell(fid);
         sys = [year,mon,day,hour,min,sec,n*tstep/1000,0,file_pos,0,fid];   
      end
   else
      % end simulation with outputsignal(2)=1
      sys = zeros(11,1);
      sys(7)=0;
      sys(8)=1;
   end
end
%=============================================================================

%=============================================================================
function sys=mdlOutputs(t,x,u)
sys=[x(7),x(8)];
%=============================================================================

%=============================================================================
function sys=mdlTerminate(t,x,u);
fclose(x(11));  % Close rainfile
sys=[];
%=============================================================================
