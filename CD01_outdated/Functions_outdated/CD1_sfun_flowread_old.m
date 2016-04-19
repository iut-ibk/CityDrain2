%=============================================================================
% File:			sfun_cd2_flowread.m
% Purpose:		Read parameters from file. (Details in mfun_cd2_flowread)
% Author:		H. Kinzel, IUT
% Date:			Origin: 25.04.2005, Last updated: 29.04.2005	
% Version		002
%=============================================================================

function [sys, x0, str, ts] = CD1_sfun_flowread_old(t, x, u, flag, dtype, crep, table, tstep)

% The following outlines not the general structure of an S-function.
% It works direct because of the size of table.


switch flag,
  case 0, % mdlInitializeSizes
	  
	  %Check table for continuity and Q, C >= 0
	  tmp=size(table);
	  len=tmp(1);
	  wid=tmp(2);
	  ncomp=wid-1;
	  
	  %If crep check if first and last line are the same.
	  if strcmp(crep,'on') & find(table(1,2:end)~=table(end,2:end))
		  error('For Cycling repetitition first and last line in file must be equal.');
	  end
	  
	  tim=table(1, 1);
	  if len<2
		  error('Table must have at least 2 lines.');
	  end
	  if table(1, 2:wid)<0
		  warning('Q or C < 0 in Dataline: 1');
	  end	  
	  for i=2:len
		  if table(i, 1)<=tim
			  error('Times in table not ascending.');
		  else
			  tim=table(i, 1);
		  end
		  if table(i, 2:wid)<0
			  warning('Q or C < 0 in Dataline: %i', i);
		  end
	  end
	  
	  % Standard s-funktion init
	  sizes = simsizes;
	  sizes.NumContStates  = 0;
	  sizes.NumDiscStates  = 0;
	  sizes.NumOutputs     = ncomp;
	  sizes.NumInputs      = 0;
	  sizes.DirFeedthrough = 0;	
	  sizes.NumSampleTimes = 1;   % at least one sample time is needed
	  
	  sys = simsizes(sizes);
	  x0  = zeros(sizes.NumDiscStates, 1);
	  str = [];
	  ts  = [tstep 0];
	  
	  
  case 2, % mdlUpdate
	  sys=[];
	
  case 3, % mdlOutput
	 tmp=size(table);
	 len=tmp(1);
	 ncomp=tmp(2)-1;
	 retval(1:ncomp)=0;
		
	 
	 % calc tabletime for cyclic repitation
	 if strcmp(crep,'on')  
		 tabletime=mod(t, table(len, 1));
	 else
		 tabletime=t;
	 end

	 % check if values for this time are availabel
	 fit=-1;
	 if (table(1,1)==tabletime)
		 retval=table(1, 2:end);
	 else
		 for i=2:len
			 if table(i-1, 1)<tabletime & tabletime<=table(i, 1)
				 fit=i;
				 i=len+1; %end loop
			 end
		 end
		 
		 %interpolate values
		 if fit==-1
			 warning('Time table to short (timestep: %i sec). Sending zeros.', t);
		 else
			 if strcmp(dtype,'Grab sample') % use interpolation or raw data
				 stime=table(fit-1, 1);
				 etime=table(fit, 1);
				 for i=1:ncomp % linear interpolation for all components
					 retval(i)=table(fit-1, i+1)+(tabletime-stime)/(etime-stime)*(table(fit, i+1)-table(fit-1, i+1));
				 end
			 else % return interval values
				 retval=table(fit, 2:end);
				 %disp(tabletime);
				 %disp(table(fit, 1:end));
			 end	 	 
		 end
	 end
		 
	 sys=retval;
	  
  case {1, 4, 9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ', num2str(flag)]);

end
