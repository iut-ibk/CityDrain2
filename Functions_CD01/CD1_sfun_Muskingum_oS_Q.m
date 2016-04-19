%=============================================================================
% File:			CD1_sfun_Muskingum_oS_Q.m
% Purpose:		Flood routing using Muscingum routing method
%               Single reach, Hydraulics only, Param:K,X
% Author:		S. Achleitner, IUT
% Date:			Origin: 15.032004, Last updated: 16.04.2004	
% Version		003
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_Muskingum_oS_Q(t,x,u,flag,tstep,K,X,C0,C1,C2)

% Parameters / All provided by block--> IMPORTANT
% tstep     ...Global (discrete) time step for sampling
% K         ...Muskingum Constant
% X         ...Muskingum Constant
% C0,C1,C2  ...Muskingum Constants



switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(tstep);

  case 2,                                                
    sys = mdlUpdate(t,x,u); 

  case 3,                                                
    sys = mdlOutputs(t,x,u,tstep,K,X,C0,C1,C2);
  
  case 9,                                                
    sys = []; % do nothing
 
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end


%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(tstep)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 3;
sizes.NumOutputs     = 2; 
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);
str = [];

sys(7)=1;	
ts  = [tstep 0]; % driven by global timesteps defined

% Initial setting of values for previous time steps

u_dat.inflow=0;
u_dat.outflow=0;
u_dat.volume=0;

set_param(gcb,'UserData',u_dat);

% mdlUpdate

function sys = mdlUpdate(t,x,u)

u_dat=get_param(gcb,'UserData');

I=u_dat.inflow;
O=u_dat.outflow;
V=u_dat.volume;


sys = [I O V];;

% mdlOutputs

function sys = mdlOutputs(t,x,u,tstep,K,X,C0,C1,C2)

% recalling data from previous discrete state
  old_QI=x(1);
  old_QE=x(2);
  old_V=x(3);
    
% evaluation of timestep and Muskingum Constants
    % dt_full=get_param(gcb,'CompiledSampleTime');
    % dt=dt_full(1);

% Calculation of Muskingum parameter --> Now in Block implemented
    % D=K.*(1-X)+0.5.*dt;   
    % C0=(0.5.*dt-K.*X)./D;
    % C1=(0.5.*dt+K.*X)./D;
    % C2=(K.*(1-X)-0.5.*dt)./D;

% calculation of QE,i+1 
QI=u;
QE=C0.*QI+C1.*old_QI+C2.*old_QE;

% and Vi+1 for current time step
V=K.*(X.*QI+(1-X).*QE);

% renewing the storage vector u_dat for next step usage
u_dat.inflow=QI;
u_dat.outflow=QE;
u_dat.volume=V;
set_param(gcb,'UserData',u_dat);

% Generating output for block
out=[QE,V];
sys = out;



