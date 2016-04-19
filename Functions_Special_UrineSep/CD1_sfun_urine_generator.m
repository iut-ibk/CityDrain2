%=============================================================================
% File:	        CD1_sfun_urine_generator.m		
% Purpose:		stochastic urine generation               
% Author:		kat
% Date:			050901
% Version		1
%=============================================================================

function [sys,x0,str,ts] = sfun_urine(t,x,u,flag,Vmax,n_toil,tstep,yy)

switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_toil,tstep);
  case 2,
   sys=mdlUpdate(t,x,u);
  case 3,
     sys=mdlOutputs(t,x,u,Vmax,n_toil,tstep,yy);
  case {1,4,9}    
     sys=[];
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================

function [sys,x0,str,ts]=mdlInitializeSizes(n_toil,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_toil;
sizes.NumOutputs     = 1;
sizes.NumInputs      = n_toil;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [tstep 0];

rand('state',sum(100*clock));
gamrnd('state',sum(100*clock));

Qei=zeros(1,n_toil);
u_dat.volume=zeros(1,n_toil);
Qe=0;

set_param(gcb,'UserData',u_dat);

%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step requirements.
%=============================================================================

function sys=mdlUpdate(t,x,u)

u_dat=get_param(gcb,'UserData');
out=[u_dat.volume];
sys=[out];

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================

function sys=mdlOutputs(t,x,u,Vmax,n_toil,tstep,yy)

%n_toil=round(ew*0.5947)

Vmax=Vmax*ones(1,n_toil);

%Probability of toilet use
pwc=gamrnd(2.35,0.29,1,n_toil)+1;
up=(gamrnd(5.315,0.25,1,n_toil)+0.5);
mu=gamrnd(2.2,0.06,1,n_toil)+0.19;
% mean suse=8.9536
dayuse=pwc.*up./mu;

% pdf for day time
iuse = rem(t,86400)/tstep+1;
use = yy(iuse).*dayuse.*tstep;

% Evaluate urien production
b=rand(1,n_toil);
comp = use >= b;
Qin = comp.*mu/1000/tstep;
Vvirt = Qin*tstep+x';

% Basin balonce
param2 = Vvirt >= Vmax;
    Vi=param2.*Vmax+not(param2).*Vvirt;
    Qei=param2.*(Vvirt-Vmax)/tstep;

% Case 4: Emptying
param1 = u' == ones(1,n_toil);
    Vi=not(param1).*Vi;
    Qei=not(param1).*Qei+param1.*Vvirt/tstep;

Qe=sum(Qei);

%Global blockvariable to save states in update
u_dat.volume=Vi;
set_param(gcb,'UserData',u_dat);

%output
sys=[Qe];