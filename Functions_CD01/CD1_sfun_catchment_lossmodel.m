%=============================================================================
% File:			sfun_catchment_lossmodel_v01
% Purpose:		Simple runoff model based on initial loss and permanent loss
% Author:		W.R. a. A.S.
% Date:			14.10.99	
% Version		001
%=============================================================================
function [sys,x0,str,ts] = sfun_catchment_lossmodel_v01(t,x,u,flag,initloss,permloss,rfcoeff)

switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
  case 2,
    sys=mdlUpdate(t,x,u,initloss,permloss);  
  case 3,
    sys=mdlOutputs(t,x,u,initloss,rfcoeff);
  case {1,4,9}  
     sys=[];    
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end
%=============================================================================


%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;  
sys = simsizes(sizes);
x0  = [0];
str = [];
SYS(7)=1;
ts  = [-1 0];
%=============================================================================


%=============================================================================
% u=rain (input)
% x=actual loss (state)
%=============================================================================
function sys=mdlUpdate(t,x,u,initloss,permloss)
if u>0					% rain
   if x<initloss
      u=u-initloss+x;
      if u<0
         x=initloss+u;
      else
         x=initloss;
      end 
   end
else						% dry weather
   x=x-permloss;
   if x<0
      x=0;
   end
end
sys=x;
%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u,initloss,rfcoeff)
if u-(initloss-x)>0
   sys=(u-(initloss-x))*rfcoeff;
else
   sys=0;
end
%=============================================================================
