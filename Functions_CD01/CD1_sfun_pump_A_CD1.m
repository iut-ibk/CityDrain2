%=============================================================================
% File:			CD1_sfun_pump_A.m
% Purpose:		Discrete model of a storage structure operated with a user 
%               defined number of pumps for withdrawal of water volume 
% Author:		S. Achleitner, IUT
% Date:			Origin: 01.07.2005, Last updated: ----	
% Version		001
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_pump_A(t,x,u,flag,Vmax,NP,Qp,Von,Voff,n_comp,tstep)

% Parameter definition

% Vmax      ...basin volume Vmax=A.hmax
% NP        ...Number of pumps NP
% Qp        ...Vector of pumping rates                  [   Qp,1    ... Qp,k    ... Qp,NP   ]
% Von       ...Vector of ON - set points for the pumps  [   Von,1   ... Von,k   ... Von,NP  ]
% Voff      ...Vector of OFF - set points for the pumps [   Voff,1  ... Voff,k  ... Voff,NP ]
% n=n_comp  ...Number of pollutant components
% tstep     ...Timestep / sampling rate used in the simulation


% Definitions of simulink variables

% x(1)              ...V, Volume in Basin
% x(2..n+1)         ...Cv, associated component concnetrations in V
% x(n+2..n+1+NP)    ...Qpprime, Pumping rates from last time step


% u(1)              ...Qi inflow
% u(2..n+1)         ...Component concentration in inflow

% y(1)              ...Qp, total pumping rate withdrawn during time step = sum(Qp,k)
% y(2..n+1)         ...Cp, associated component concentrations in Qp

% y(n+2)            ...Qw, overflow rate withdrawnduring time step
% y(n+3..2(n+1))    ...Cw, associated component concentrations in Qw

% y(2n+3)           ...V, Volume in Basin
% y(2n+3..3(n+1))   ...Cv, associated component concnetrations in V




% The following outlines the general structure of an S-function.
switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_comp,NP,tstep);

  case 2,
    sys=mdlUpdate(t,x,u);
    
  case 3,
     sys=mdlOutputs(t,x,u,Vmax,NP,Qp,Von,Voff,n_comp,tstep);
     
  case {1,4,9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(n_comp,NP,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_comp+1+NP; % V (including concnetrations)
sizes.NumOutputs     = 3*(n_comp+1); % Qw, Qp and V (including concnetrations)
sizes.NumInputs      = n_comp+1; % Qi (including concentrations)
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [tstep 0];

% Writing data to workspace
% val=[];
% assignin('base','testout',val);

%=============================================================================
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%=============================================================================

function sys=mdlUpdate(t,x,u)


u_dat=get_param(gcb,'UserData');
xnew=u_dat.x;

sys=xnew;



%=============================================================================
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%=============================================================================

function sys=mdlOutputs(t,x,u,Vmax,NP,Qp,Von,Voff,n_comp,tstep)

% ===========
% Hydraulics:
% ===========

Qpplast=x((n_comp+2):(n_comp+1+NP)); %Pumping rates from last time step

qi=u(1); %Inflow during last timestep

Vi=x(1); % Volume stored from last timestep 

Qpp=zeros(1,NP); % Initial setting for pumping rate vector
Qpmod=[0 Qp]; %modified vector of Qp for simplification of looping 
Vik=zeros(1,NP); % Virtual volumes decreasing with pumping action

for k=1:NP
    Vik(k)=Vi+qi.*tstep-sum(Qpmod(1:k)).*tstep;
    
    % if pump is turned on within this time step (acceding Volume)
    % or was operated during last time step (desceding Volume)
    % 
    if (Vik(k)>Von(k)) | (Qpplast(k)==Qp(k)) 
        CB=1;
    else
        CB=0;
    end
    
    Qopt1=(((Vik(k)-Voff(k))/tstep)+abs((Vik(k)-Voff(k))/tstep))/2;
    
    Qopt2=Qp(k);
    
    Qpp(k)=CB.*min([Qopt1 Qopt2]);
        
end




% OUTPUT OF LOOPING: Qpp=[Qp'(1) ... Qp'(NP)]

Vpp=sum(Qpp).*tstep; % Volume pumped in this timestep

Vii=Vi+qi.*tstep-Vpp; % Volume after pumping

% Check for spillage off the structure

if Vii>Vmax
    Qw=(Vii-Vmax)./tstep;
    Vii=Vmax;
else
    Qw=0;
end

% ===============
% Concentrations:
% ===============

% Components mixing:

Vip=qi*tstep+Vi; % Virtual volume after inflow

C=x(2:(n_comp+1));
Cin=u(2:(n_comp+1));

Cprime=[];

 % Component concnetrations vector for Vi, Qe and Qw
if n_comp > 0
    if Vip > 0
        Cprime=(Cin.*qi.*tstep+C.*Vi)./Vip;
    else
        Cprime=zeros(1,n_comp);
    end 
end

% ===========================================================
% Preperation of data storage in u_dat for the update section
% ===========================================================

u_dat.x=[Vii Cprime Qpp];
set_param(gcb,'UserData',u_dat);

% ======================================
% Outputvector for outflow and overflow:
% ======================================

sys=[Qw Cprime sum(Qpp) Cprime Vii Cprime];
    
