%=============================================================================
% File:			CD1_sfun_dwfgenerator.m
% Purpose:		Function that compose dwfdata
% Author:		kat
% Date:			050810
% Version		1
%=============================================================================
function [sys,x0,str,ts] = CD1_sfun_dwfgenerator(t,x,u,flag,tstep,yy,yye)

switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(tstep);
  case 2,
    sys=mdlUpdate(t,x,u,tstep,yy,yye);   
  case 3,
     sys=mdlOutputs(t,x,u,tstep);    
  case {1,4,9}  
     sys=[];    
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end
%=============================================================================


%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 0;	
sizes.NumSampleTimes = 1; 

sys = simsizes(sizes);
x0  = [0];
str = [];
ts  = [tstep 0];
%=============================================================================


%=============================================================================
function sys=mdlUpdate(t,x,u,tstep,yy,yye)  

%calc timeindex for dwf
n=fix(t/86400);

if mod(n+1,6)==0;
    sys=yye(1+(t-n*86400)/tstep);
elseif mod(n+1,7)==0;
    sys=yye(1+(t-n*86400)/tstep);
else
sys=yy(1+(t-n*86400)/tstep);
end
%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u,tstep)
if t==0;
    out=0.000001;
else
    out=x(1);
end

sys=[out];
%=============================================================================