function [sys,x0,str,ts] = CD1_sfun_out_subs(t,x,u,flag,subs_vect,n_comp,tstep)

% Combination of 2 elements
% In/Output in Q and Concentrations (m3/s, g/m3) as vector  
% sample time: tstep
% vector	Q=1  C= 1..n_comp


switch flag,
  case 0,
    [sys,x0,str,ts] = mdlInitializeSizes(subs_vect,n_comp,tstep);
  case 3,                                                
    sys = mdlOutputs(t,x,u,subs_vect,n_comp,tstep);
  case {1,2,4,9}  
    sys = []; % do nothing
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end


%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(subs_vect,n_comp,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = CD2_get_substance_count(subs_vect)+1;
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
function sys = mdlOutputs(t,x,u,subs_vect,n_comp,tstep)


sys=zeros(CD2_get_substance_count(subs_vect)+1,1);

	for i=1:CD2_get_substance_count(subs_vect)
		subst_name=CD2_get_substance_name(subs_vect,i);		
		subst_val=CD2_get_substance(u(2:end),subst_name);
		sys(i+1)=subst_val;		
	end

sys(1)=u(1);
