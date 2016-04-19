%=============================================================================
% File:			CD1_sfun_catchment_flowmodel_DWF.m
% Purpose:		Combination of dry and wet weather flow including pollution
% Author:		W.R.
% Date:			14.10.99	
% Version		001
%=============================================================================
function [sys,x0,str,ts] = CD1_sfun_catchment_flowmodel_DWF(t,x,u,flag,n_comp,DWF_C,tstep)

% Flow model
% Combination of dry weather flow and runoff
% Including Pollution
% Pollution with simple Component model
% input from runoff_models in mm per timestep
% all other input in m3/s; g/m3; m2
% Output in m3/s and g/m3

% The following outlines the general structure of an S-function.
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(tstep,n_comp);   
  case 3,
    sys = mdlOutputs(t,x,u,n_comp,DWF_C,tstep);
  case {1,2,4,9}  
     sys=[];    
  otherwise
     error(['Unhandled flag = ',num2str(flag)]);
  end
%=============================================================================


%=============================================================================

function [sys,x0,str,ts]=mdlInitializeSizes(tstep,n_comp)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1+n_comp;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1; 

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [tstep 0];


%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u,n_comp,DWF_C,tstep)
% Output vector out
% out(1) = flow		        ...u(1): Input in mm per timestep
% out(2) - out(n_comp+1)    ...Component concentration



out=zeros(1,n_comp+1);
out(1)= u(1); %...Flow out of the catchment

if out(1)> 0
   for i=1:n_comp
     out(i+1)=DWF_C(i);
   end
end

sys=out;


