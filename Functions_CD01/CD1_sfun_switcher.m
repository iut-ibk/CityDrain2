%=============================================================================
% File:			
% Purpose:		
% Author:		kat
% Date:			
% Version		
%=============================================================================
function [sys,x0,str,ts] = CD1_sfun_switcher(t,x,u,flag,wechsler,n_comp,tstep)

switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(tstep,n_comp);
  case 3,
     sys=mdlOutputs(t,x,u,wechsler,n_comp);    
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
sizes.NumInputs      = 2+2*n_comp;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1; 

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [tstep 0];

%=============================================================================
function sys=mdlOutputs(t,x,u,wechsler,n_comp)

port_01=u(1:1+n_comp);
port_02=u(2+n_comp:end);
out=port_01.*wechsler+port_02.*(not(wechsler));

sys=[out];
%=============================================================================