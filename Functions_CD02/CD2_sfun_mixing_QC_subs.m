function [sys,x0,str,ts] = CD1_sfun_mixing_QC_subs(t,x,u,flag,subs_vect,use,n_comp,tstep)

% Combination of 2 elements
% In/Output in Q and Concentrations (m3/s, g/m3) as vector  
% sample time: tstep
% vector	Q=1  C= 1..n_comp


switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(subs_vect,use,n_comp,tstep);
  case 3,                                                
    sys = mdlOutputs(t,x,u,subs_vect,use,n_comp,tstep);
  case {1,2,4,9}  
    sys = []; % do nothing
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end


%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(subs_vect,use,n_comp,tstep)

CD2_get_substance_count(subs_vect);
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = n_comp+1;
sizes.NumInputs      = (n_comp+1)+CD2_get_substance_count(subs_vect);
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
function sys = mdlOutputs(t,x,u,subs_vect,use,n_comp,tstep)

mode='set';

sys=u(1:n_comp+1);

if use
    for i=1:CD2_get_substance_count(subs_vect);
        subst_name=CD2_get_substance_name(subs_vect,i)
        sys=CD2_set_substance(sys,subst_name,u(n_comp+1+i))
    end
end

