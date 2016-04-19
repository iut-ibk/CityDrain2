%=============================================================================
% File:			CD1_sfun_Muskingum_Sewer.m
% Purpose:		sewer-transport-function
%               Flood routing using Muskingum routing method
%               Descrete formulas derived using simple implicit scheme 
%               Numerics applied for multiple reaches (N) including mixing
%               of substances, Parameters:K,X,N,n_comp
% Author:		kat
% Date:			050905	
% Version		001
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_Muskingum_Sewer(t,x,u,flag,tstep,K,X,CA,CB,n_comp,N)

% Parameters / All provided by block--> IMPORTANT
% tstep     ...Global (discrete) time step for sampling
% K         ...Muskingum Constant [s] (applied to one subreach)
% X         ...Muskingum Constant [-]
% CA,CB     ...Muskingum Constants [ ?? ]
% n=n_comp  ...Number of pollutant components / substances [-]

% N         ...Number of subreahces
N=round(N);

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
    [sys,x0,str,ts] = mdlInitializeSizes(n_comp,N,tstep);

  case 2,                                                
    sys = mdlUpdate(t,x,u); 

  case 3,                                                
    sys = mdlOutputs(t,x,u,tstep,K,X,CA,CB,n_comp,N);
  
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
function [sys,x0,str,ts] = mdlInitializeSizes(n_comp,N,tstep)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = N*(n_comp+1); % Volumes and concnetrations only
sizes.NumOutputs     = (N+1)*(n_comp+1); % Volumes and Flows including corresponding concnetrations
sizes.NumInputs      = n_comp+1; % Inflow and concentrations
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);

str = [];

sys(7)=1;	
ts  = [tstep 0]; % driven by global timesteps defined

% Initial setting of values for previous time steps

u_dat.volume=zeros(N*(n_comp+1));

set_param(gcb,'UserData',u_dat);

% mdlUpdate

function sys = mdlUpdate(t,x,u)

u_dat=get_param(gcb,'UserData');

VC=u_dat.volume;


sys = [VC];

% mdlOutputs

function sys = mdlOutputs(t,x,u,tstep,K,X,CA,CB,n_comp,N)

% calling data from inflow

QI=u;
QE=[];
V =[];
xnew=[];

for i=1:N
    
    % HYDRAULICS:
    
    % recalling Vi-1 from previous time step [Vi C1,i C2,i C3,i ... Cn_comp,i]
    Vold=[];
    for j=((i-1)*(1+n_comp)+1):(i*(1+n_comp))
        Vold=[Vold x(j)];
    end
    
    % Outflow for current time step
    QE(1)=(QI(1).*CA + Vold(1))./CB;
    % Vi for current time step
    V(1)=(QI(1)-QE(1)).*tstep+Vold(1);
       
    
    % Calculation of substance flows

    for i=1:n_comp
    
        c0=0.5.*QE(1)+V(1)./tstep;
        c1=QI(1).*QI(i+1)-Vold(i+1)*(0.5.*QE(1)-Vold(1)./tstep);
    
        if c0 <= 0 
            V(i+1)=0;
        else
            V(i+1)=c1/c0;
        end
        
        QE(i+1)=( V(i+1) + Vold(i+1) )./2;
        
    end
    
    % Writing new discrete states
    xnew=[xnew,V];
    
    % Replacing QI with QE for next subreach calculated 
    % where outflow of chamber is inflow for the subsequent chamber
    QI=QE;
    
end


% renewing the storage vector u_dat for next step usage

u_dat.volume=xnew;
set_param(gcb,'UserData',u_dat);




% Generating output for block

sys = [QE, xnew];