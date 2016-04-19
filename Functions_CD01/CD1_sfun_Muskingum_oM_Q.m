%=============================================================================
% File:			CD1_sfun_Muskingum_oM_Q.m
% Purpose:		Flood routing using Muscingum routing method
%               Multiple reaches, Hydraulics only
% Author:		S. Achleitner, IUT
% Date:			Origin: 15.03.2004, Last updated: 16.04.2004	
% Version		002
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_Muskingum_oM_Q(t,x,u,flag,tstep,N,K,X,C0,C1,C2)

% Parameters


switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(tstep,N);

  case 2,                                                
    sys = mdlUpdate(t,x,u); 

  case 3,                                                
    sys = mdlOutputs(t,x,u,tstep,N,K,X,C0,C1,C2);
  
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
function [sys,x0,str,ts] = mdlInitializeSizes(tstep,N)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1+2.*N;
sizes.NumOutputs     = 1+2.*N; 
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);
str = [];

sys(7)=1;	
ts  = [tstep 0]; % driven by global timesteps defined

% Initial setting of values for previous time steps
u_dat.flow=zeros(N+1,1);
u_dat.volume=zeros(N,1);
set_param(gcb,'UserData',u_dat);

% mdlUpdate

function sys = mdlUpdate(t,x,u)

u_dat=get_param(gcb,'UserData');


Q=u_dat.flow;
V=u_dat.volume;


sys = [Q V];;

% mdlOutputs

function sys = mdlOutputs(t,x,u,tstep,N,K,X,C0,C1,C2)
   

  old_Q=x(1:N+1);
  old_V=x(N+2:N.*2+1);
    
% evaluation of timestep and Muskingum Constants
% !!! SHIFTED TO BLOCK LEVEL due to beeing a one-time calculation !!!
        % dt_full=get_param(gcb,'CompiledSampleTime');
        % dt=dt_full(1);

        % D=K.*(1-X)+0.5.*dt;   
        % C0=(0.5.*dt-K.*X)./D;
        % C1=(0.5.*dt+K.*X)./D;
        % C2=(K.*(1-X)-0.5.*dt)./D;

% calculation of QE,i+1 
Q=[]; V=[];
Q(1)=u;%new inflow

for j=2:N+1    
    Q(j)=C0.*Q(j-1)+C1.*old_Q(j-1)+C2.*old_Q(j);

% and Vi+1 for current time step
    j2=j-1;
    V(j2)=K.*(X.*Q(j-1)+(1-X).*Q(j));
end;

% renewing the storage vector u_dat for next step usage
u_dat.flow=Q;
u_dat.volume=V;
set_param(gcb,'UserData',u_dat);

out=[Q,V];
sys = out;



