%=============================================================================
% File:			CD1_sfun_raingenerator.m
% Purpose:		Function that computes stochastic raindata
% Author:		W.R.
% Date:			14.10.99	
% Version		001
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_raingenerator(t,x,u,flag,tstep,a,b,c,d)

switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(tstep);
  case 2,
    sys=mdlUpdate(t,x,u,tstep,a,b,c,d);   
  case 3,
     sys=mdlOutputs(t,x,u);    
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
sizes.NumDiscStates  = 5;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 0;	
sizes.NumSampleTimes = 1; 

sys = simsizes(sizes);
x0  = [0,0,0,0,0];
str = [];
ts  = [tstep 0];
%=============================================================================


%=============================================================================
function sys=mdlUpdate(t,x,u,tstep,a,b,c,d)  


if x(1)>0
   %dry weather
   x(1)=x(1)-1;
   x(5)=0;
   sys=x;
else
   if x(2)>0
      x(2)=x(2)-1;
      x(4)=x(4)*0.5 + randn(1)*d*x(3);
      x(5)=x(4)+ x(3);
      if x(5)<0
         x(5)=0;
      end
      sys=x;
   else
   	% next rain
   	x(1)=floor((-1/a*log(rand(1)))*86400/tstep);   % time to next storm in dt   
   	x(2)=floor((-1/b*log(rand(1)))*86400/tstep)+1; % storm duration in dt   
   	x(3)=(-1/c*log(rand(1)))/x(2);                 % mean intensity mm/dt   
      x(5)=0;
      sys=x;
   end
end
%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u)
sys=[x(5)];
%=============================================================================

