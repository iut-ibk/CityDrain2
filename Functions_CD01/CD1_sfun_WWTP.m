%=============================================================================
% File:			CD1_sfun_WWTP.m
% Purpose:		WWTP under ideal conditions
%               reduces inflow concentrations by means of 
%                   - required removal efficiency "REmin" or
%                   - maximum allowable effluent quality "Cemin"
% Author:		S. Achleitner, IUT
% Date:			Origin: 20.04.2004, Last updated: ----	
% Version		001
%=============================================================================

function [sys,x0,str,ts] = CD1_sfun_WWTP(t,x,u,flag,n_comp,REmin,Cemax,tstep)

% WWTP structure
% Variable definitions
% REmin     [REmin(1) REmin(2) REmin(3)...REmin(n_comp)]
% Cemax     [Cemax(1) Cemax(2) Cemax(3)...Cemax(n_comp)]

% u(1)          ...Q inflow
% u(2..n_comp+1)...Component concentration in inflow

% n_comp        ...Number of pollutant components
% y(1)          ...Qe outflow
% y(2..n_comp+1)...Component concentrations in Outflow


% --> The reliability of user provided data for REmin is checked
% in the Block environment. REmin provided to the s-function is always 
% 0 <= REmin <= 1
% Setting of REmin:
% Ce=Cin*(1-REmin);
% 0 < REmin < 1 ...effective removal efficiency
% REmin < 0     ...no removal efficiency required --> Cemax is dominant, REmin=0 --> no removal
% REmin > 1     ...wrong input by user assumed --> warning printed and, REmin=1 --> full removal

% Setting of Cemax:

% Cemax < 0     ...Increase of component in the treatmentplant(e.g Oxygen) 
%                  Ce=Cemax.*(-1)

% Cemax > 0     ...considered as maximum effluent concentration; 
%                  if Ce > Cemax --> Ce=Cemax else Ce=Ce



% The following outlines the general structure of an S-function.
switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_comp,tstep);
    
  case 3,
     sys=mdlOutputs(t,x,u,Cemax,REmin,n_comp,tstep);
     
  case {1,2,4,9}  
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
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = n_comp+1;
sizes.NumInputs      = n_comp+1;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [tstep 0];


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u,Cemax,REmin,n_comp,tstep)

% Prepartion of vectors for new compnent concnetrations
Ce1=zeros(1,n_comp);
Ce2=zeros(1,n_comp);

% Applying removal efficiency Ce--> Ce1:

% Applying maximum effluent concentration Ce1--> Ce2
% Setting of Cemax:

% Cemax < 0     ...Increase of component in the treatmentplant(e.g Oxygen) 
%                  Ce=Cemax.*(-1)
% Cemax >= 0    ...considered as maximum effluent concentration; 
%                  if Ce > Cemax --> Ce=Cemax else Ce=Ce

for i=1:n_comp
    
Ce1(i)=u(i+1).*(1-REmin(i));    
    
    if Cemax(i) < 0
        Ce2(i)=Cemax(i).*(-1);
    else
        Ce2(i)=min(Cemax(i),Ce1(i)); 
    end
end


sys=[u(1) Ce2];
    
