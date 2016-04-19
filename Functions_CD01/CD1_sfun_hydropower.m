%=============================================================================
% File:			CD1_sfun_hydropower.m
% Purpose:		releases flow from hydropower station, including substance concnetrations
% Author:		A.S.
% Date:			12.07.04	
% Version		001
%=============================================================================
function [sys,x0,str,ts] = CD1_sfun_hydropower(t,x,u,flag,n_comp,C_Stream,tstep)


% The following outlines the general structure of an S-function.
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(tstep,n_comp);   
  case 3,
    sys = mdlOutputs(t,x,u,n_comp,C_Stream,tstep);
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
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1; 

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [tstep 0];


%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u,n_comp,C_Stream,tstep)


% out=zeros(1,n_comp+1);
% out(1)= u(1)+ u(2);
% if out(1)> 0
%    for i=1:n_comp
%      out(i+1)=;
%    end
% end

out = [(u(1)+u(2)) C_Stream]; 
sys=out;


