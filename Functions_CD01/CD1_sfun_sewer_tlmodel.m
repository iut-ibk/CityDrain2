function [sys,x0,str,ts] = CD1_sfun_sewer_tlmodel(t,x,u,flag,n_elem,n_comp,tstep)

% Simple Translation model
%   WR + AS
%   28.9.00


% The following outlines the general structure of an S-function.
switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_elem,n_comp,tstep);

  case 2,
    sys=mdlUpdate(t,x,u,n_elem,n_comp,tstep);
    
  case 3,
     sys=mdlOutputs(t,x,u,n_elem,n_comp,tstep);
     
  case {1,4,9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(n_elem,n_comp,tstep)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = (n_elem+1) * (n_comp+1);
sizes.NumOutputs     = n_comp+1;
sizes.NumInputs      = n_comp+1;
sizes.DirFeedthrough = 0;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [tstep 0];


%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
function sys=mdlUpdate(t,x,u,n_elem,n_comp,tstep)

%for i=n_elem+1:-1:2
%   for ii=1:n_comp+1
%      x((i-1)*(n_comp+1)+ii)=x((i-2)*(n_comp+1)+ii);
%   end
%end
x((n_comp+2):length(x))=x(1:(length(x)-(n_comp+1)));  %Use of Matrix functions

%for ii=1:n_comp+1
%   x(ii)=u(ii);
%end
x(1:(n_comp+1))=u;  %Use of Matrix functions

sys=x;


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u,n_elem,n_comp,tstep)

%for ii=1:n_comp+1
%   out(ii)=x(n_elem*(n_comp+1)+ii);
%end
%sys=out;

sys=x((n_elem*(n_comp+1)+1):length(x));