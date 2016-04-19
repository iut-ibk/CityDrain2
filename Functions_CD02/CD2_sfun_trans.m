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
sizes.NumInputs      = n_comp+1;
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

sys=u;
pCODtot=CD2_get_sub_no('CODtot')+1;
pNH4=CD2_get_sub_no('NH4')+1;
pNtot=CD2_get_sub_no('Ntot')+1;
pCODsol=CD2_get_sub_no('CODsol')+1;
pCODpar=CD2_get_sub_no('CODpar')+1;
pCODtot=CD2_get_sub_no('CODtot')+1;

CODtot=u(pCODtot);
NH4=u(pNH4);
sys(pNtot)=NH4+CODtot*0.0595;
sys(pCODsol)=CODtot*0.33;
sys(pCODpar)=CODtot*0.67;