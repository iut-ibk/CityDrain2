%=============================================================================
% File:			CD1_sfun_cso_A.m
% Purpose:		CSO structure with const. max outflow and overflow
%               based on mass balance at the end of time step
% Author:		S. Achleitner, IUT
% Date:			Origin: 20.04.2004, Last updated: ----	
% Version		002
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_cso_A(t,x,u,flag,Vmax,Qemax,n_comp,tstep)

% CSO structure
% Variable definitions
% x1 = Volume in Basin
% x2..n = Component mass in Basin

% u(1) = Q inflow
% u(2..n) = Component concentration in inflow

% n...Number of pollutant components
% y(1) = Qe outflow
% y(2..n+1) = Component concentrations in Outflow
% y(n+2) = Qw overflow
% y(n+3..2(n+1)) = Component concentration in CSO

% The following outlines the general structure of an S-function.
switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_comp,tstep);

  case 2,
    sys=mdlUpdate(t,x,u,Vmax,Qemax,n_comp,tstep);
    
  case 3,
     sys=mdlOutputs(t,x,u,Vmax,Qemax,n_comp,tstep);
     
  case {1,4,9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(n_comp,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_comp+1;
sizes.NumOutputs     = 3*(n_comp+1);
sizes.NumInputs      = n_comp+1;
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
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
function sys=mdlUpdate(t,x,u,Vmax,Qemax,n_comp,tstep)

Vii=(u(1)-Qemax)*tstep+x(1); % New volume in CSO structure

% Hydraulics:

% Case 1
if Vii < 0
    Vi=0;
% Case 2    
elseif Vii > Vmax
    Vi=Vmax;
% Case 3
else
    Vi=(u(1)-Qemax)*tstep+x(1);
end

Vprime=u(1)*tstep+x(1);

Cprime=zeros(1,n_comp); % Component concnetrations vector for Vi

if Vprime > 0
    for i=1:n_comp
        Cprime(i)=( u(i+1)*u(1)*tstep + x(i+1)*x(1)) / Vprime;
    end
end 

% Outputvector for outflow and overflow:

sys=[Vi Cprime];




%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u,Vmax,Qemax,n_comp,tstep)

Vii=(u(1)-Qemax)*tstep+x(1); % New volume in CSO structure


% Hydraulics:

% Case 1
if Vii < 0
    Vi=0;
    Qei=x(1)/tstep+u(1);
    Qwi=0;
    
    % Writing data to workspace  
%     f=1;
%     valold=evalin('base','testout');
%     val=[valold ; t u(1) Qemax Vii f Vi Qei Qwi x(1)];
%     assignin('base','testout',val);
    
% Case 2    
elseif Vii > Vmax
    Vi=Vmax;
    Qei=Qemax;
    Qwi=u(1)-Qemax-(Vmax-x(1))/tstep;

    % Writing data to workspace
%     f=2;
%     valold=evalin('base','testout');
%     val=[valold ; t u(1) Qemax Vii f Vi Qei Qwi x(1)];
%     assignin('base','testout',val);
    
% Case 3
else
    Vi=(u(1)-Qemax)*tstep+x(1);
    Qei=Qemax;
    Qwi=0;

    % Writing data to workspace
%     f=3;
%     valold=evalin('base','testout');
%     val=[valold ; t u(1) Qemax Vii f Vi Qei Qwi x(1)];
%     assignin('base','testout',val);
end

% Components mixing:

Vprime=u(1)*tstep+x(1);

Cprime=zeros(1,n_comp); % Component concnetrations vector for Vi, Qe and Qw

if Vprime > 0
    for i=1:n_comp
        Cprime(i)=( u(i+1)*u(1)*tstep + x(i+1)*x(1)) / Vprime;
    end
end 

% Outputvector for outflow and overflow:

sys=[Qwi Cprime Qei Cprime Vi Cprime];
    
