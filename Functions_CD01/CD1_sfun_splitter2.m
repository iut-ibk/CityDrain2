%=============================================================================
% File:			sfun_cd2_splitter.m
% Purpose:		Splitts Q in two steams.
% Author:		H. Kinzel, IUT
% Date:			Origin: 27.04.2005, Last updated: 04.05.2005	
% Version		002
%=============================================================================

function [sys, x0, str, ts] = CD1_sfun_splitter2(t, x, u, flag, n_comp, mode, tstep)

% The following outlines the general structure of an S-function.
switch flag,

  case 0,
    [sys, x0, str, ts]=mdlInitializeSizes(t, x, u, flag, n_comp, mode, tstep);

  case 2,
    sys=mdlUpdate(t, x, u, n_comp, mode, tstep);
    
  case 3,
     sys=mdlOutputs(t, x, u, n_comp, mode, tstep);
     
  case {1, 4, 9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ', num2str(flag)]);

end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys, x0, str, ts]=mdlInitializeSizes(t, x, u, flag, n_comp, mode, tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumInputs      = n_comp+2;
sizes.NumOutputs     = 2*(n_comp+1);

sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates, 1);
str = [];
ts  = [tstep 0];


%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
function sys=mdlUpdate(t, x, u, n_comp, mode, tstep)
sys=[];

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t, x, u, n_comp, mode, tstep)
value=u(end);
y=[u(1:end-1);u(1:end-1)];

if mode==1 | mode ==2 % percent / fract mode
	if mode==1
		value=value*100;
	end
	if value<0 | value>100
		error('Value out of range.');
	end
	value=value/100;
	y(1)=y(1)*value;
	if value==0
		y(2:n_comp+1)=0;
	end
	y(n_comp+2)=y(n_comp+2)*(1-value);
	if (1-value)==0
		y(n_comp+3:2*(n_comp+1))=0;
	end	
else % amount mode
	if value<0
		error('Value out of range.');
	end
	if y(1)>=value
		y(n_comp+2)=y(1)-value;
		y(1)=value;
	else
		y(n_comp+2)=0;
		y(n_comp+3:2*(n_comp+1))=0;		
	end
end

sys=y;
      