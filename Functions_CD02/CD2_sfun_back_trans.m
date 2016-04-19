function [sys,x0,str,ts] = CD2_sfun_trans(t,x,u,flag,n_comp,tstep)




switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(n_comp,tstep);
  case 3,                                                
    sys = mdlOutputs(t,x,u,n_comp,tstep);
  case {1,2,4,9}  
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
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = n_comp+1;
sizes.NumInputs      = 15;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = [];
str = [];
ts  = [tstep 0]; 


%=======================================================================
% mdlOutputs
% Return Return the output vector for the S-function
%=======================================================================
function sys = mdlOutputs(t,x,u,n_comp,tstep)

sys=zeros(1,n_comp+1)
sys(1)=u(1);
sys(2)=u(2);
sys(3)=
