%=============================================================================
% File:			CD1_sfun_Muskingum_sS_QC.m
% Purpose:		Flood routing using Muscingum routing method
%               Descrete formulas derived using simple implicit scheme 
%               Single reach including mixing of substances, Param:K,X
% Author:		S. Achleitner, IUT
% Date:			Origin: 15.032004, Last updated: 16.04.2004	
% Version		003
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_Muskingum_sS_QC(t,x,u,flag,tstep,K,X,CA,CB,n_comp)

% Parameters / All provided by block--> IMPORTANT
% tstep     ...Global (discrete) time step for sampling
% K         ...Muskingum Constant [s]
% X         ...Muskingum Constant [-]
% CA,CB     ...Muskingum Constants [ ?? ]
% n=n_comp  ...Number of pollutant components / substances [-]

% Internal Variables (Input, State and Output variables)

% x(1)          ...V, Volume in reach [m³]
% x(2..n)       ...C, Component concentration in reach [g/m³]

% u(1)          ...QI, inflow [m³/s]
% u(2..n)       ...CI, Component concentration in inflow [g/m³]

% y(1)          ...QE, outflow [m³/s]
% y(2..n+1)     ...CE, Component concentrations in outflow [g/m³]
% y(n+2)        ...V, Volume in reach [m³]
% y(n+3..2(n+1))...C, Component concentration in reach [g/m³]

switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep);

  case 2,                                                
    sys = mdlUpdate(t,x,u); 

  case 3,                                                
    sys = mdlOutputs(t,x,u,tstep,K,X,CA,CB,n_comp);
  
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
function [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_comp+1;
sizes.NumOutputs     = 2*(n_comp+1);; 
sizes.NumInputs      = n_comp+1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);
str = [];

sys(7)=1;	
ts  = [tstep 0]; % driven by global timesteps defined

% Initial setting of values for previous time steps

u_dat.volume=zeros(n_comp+1);

set_param(gcb,'UserData',u_dat);

% mdlUpdate

function sys = mdlUpdate(t,x,u)

u_dat=get_param(gcb,'UserData');

VC=u_dat.volume;


sys = [VC];;

% mdlOutputs

function sys = mdlOutputs(t,x,u,tstep,K,X,CA,CB,n_comp)

% recalling data from previous discrete state
Vold=x(1);
    
% calculation of QE,i 
QI=u(1);
QE=(QI.*CA + Vold)./CB;

% and Vi for current time step
V=(QI-QE).*tstep+Vold;


% Calculation of substance flows

C=zeros(1,n_comp); % Component concnetrations vector for V
CE=zeros(1,n_comp); % Component concnetrations vector for outflow
for i=1:n_comp
    
    c0=0.5.*QE+V./tstep;
    c1=QI.*u(i+1)-x(i+1)*(0.5.*QE-Vold./tstep);
    
    if c0 <= 0 
        C(i)=0;
    else
        C(i)=c1/c0;
    end
    
    CE(i)=( C(i) + x(i+1) )./2;
end

% renewing the storage vector u_dat for next step usage
VC=[V,C];
u_dat.volume=VC;
set_param(gcb,'UserData',u_dat);

% Generating output for block
out=[QE,CE,V,C];
sys = out;



