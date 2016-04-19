function [sys,x0,str,ts] = CD1_sfun_sum_QC_t(t,x,u,flag,n_comp,tstep)

% Summation of input over time
% Input here in Q and Concentrations (m3/s, g/m3) as vector  
% Output in total mass (m3, mm, g, etc)as vector
% sample time: tstep
% vector	Q=1  C= 1..n_comp



switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep);
  case 2,                                                
    sys = mdlUpdate(t,x,u,n_comp,tstep); 
  case 3,                                                
    sys = mdlOutputs(t,x,u,n_comp,tstep);
  case 9,                                                
    sys = []; % do nothing
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end


%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_comp+1;
sizes.NumOutputs     = n_comp+1;
sizes.NumInputs      = n_comp+1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [tstep 0]; 

%=======================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=======================================================================
function sys = mdlUpdate(t,x,u,n_comp,tstep)


% New cumulated volume
V=u(1)*tstep;


% New cumulated masses
M=u(2:n_comp+1).*V;

% Updating cumulated Volume and Pollutant mass
x=x+[V M]';

sys = x;

%=======================================================================
% mdlOutputs
% Return Return the output vector for the S-function
%=======================================================================
function sys = mdlOutputs(t,x,u,n_comp,tstep)


sys = x;

