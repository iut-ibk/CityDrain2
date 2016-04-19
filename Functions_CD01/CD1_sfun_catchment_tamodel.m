%=============================================================================
% File:			sfun_catchment_tamodel_v01
% Purpose:		Simple runoff model based on linear time area model
% Author:		W.R.
% Date:			14.10.99	
% Version		001
%=============================================================================
function [sys,x0,str,ts] = sfun_catchment_tamodel_v01(t,x,u,flag,n_ta)

%for i=1:n_ta
%   ta_area(i)=1/n_ta;
%end

ta_area=1/n_ta*ones(n_ta,1);    %Vector of linear time-area relation

% The following outlines the general structure of an S-function.
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_ta);
  case 2,
    sys=mdlUpdate(t,x,u,n_ta);   
  case 3,
    sys=mdlOutputs(t,x,u,n_ta,ta_area);
  case {1,4,9}  
     sys=[];   
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end
%=============================================================================

%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(n_ta)
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = n_ta;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;	
sizes.NumSampleTimes = 1;   
sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates,1);
str = [];
sys(7)=1;			% timestep inherited from driving block
ts  = [-1 0];		% timestep inherited from driving block
%=============================================================================


%=============================================================================
function sys=mdlUpdate(t,x,u,n_ta)

%for i=n_ta:-1:2
%   x(i)=x(i-1);
%end

x(2:length(x))=x(1:(length(x)-1));  %gliding rain data vector 
x(1)=u;
sys=x;
%=============================================================================


%=============================================================================
function sys=mdlOutputs(t,x,u,n_ta,ta_area)

%out=0;
%for i=1:n_ta
%   out=out+x(i)*ta_area(i);
%end
%sys=out;

sys=ta_area'*x;   %Use of Matrix functions (scalar product)
%=============================================================================
