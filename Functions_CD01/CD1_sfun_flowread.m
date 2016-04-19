%=============================================================================
% File:			sfun_cd2_flowread.m
% Purpose:		Read parameters from file. (Details in mfun_cd2_flowread)
% Author:		H. Kinzel, IUT
% Date:			Origin: 25.04.2005, Last updated: 15.07.2005	
% Version		003
%=============================================================================

function [sys, x0, str, ts] = CD1_sfun_flowread(t, x, u, flag, dtype, crep, table, tstep)

% The following outlines not the general structure of an S-function.
% It works direct because of the size of table.


switch flag,
  case 0, % mdlInitializeSizes
	  
	  %set start point for tablesearch to 1
	  u_dat.sp=1;
	  set_param(gcb,'UserData',u_dat);

	  %get table size
	  tmp=size(table);
	  len=tmp(1);
	  wid=tmp(2);
	  ncomp=wid-2;
	  
	  %If crep check if first and last line are the same.
	  if strcmp(crep,'on') & find(table(1,2:end)~=table(end,2:end))
		  error('For Cycling repetitition first and last line in file must be equal.');
	  end
	  
	  %Check table for continuity and Q, C >= 0	  
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
	  sizes.NumDiscStates  = 0;%ncomp+1;
	  sizes.NumOutputs     = ncomp+1;
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
	  ncomp=tmp(2)-2;
	  
	  
	  % calc eventStart for cyclic repitation
	  if strcmp(crep,'on')  
		  eventStart=mod(t, table(len, 1))-tstep;
	  else
		  eventStart=t-tstep;
	  end
	  eventEnd=eventStart+tstep;

	  if  strcmp(dtype,'Grab sample') % use interpolation or raw data
		  %calc q and c for grapsample mode 
		  retval(1:ncomp+1)=0; %prepare return vector
		  ff=0;
		  u_dat=get_param(gcb,'UserData');
%		  u_dat.sp
		  for i=u_dat.sp:len %todo calc exact boundaries for table entrys. (speedup)
			  dst=0;
			  %set startvector
			  if i~=1
				  tableStart=table(i-1,1);
				  tableEnd=table(i,1);
				  tableStartVec=table(i-1,1:end);
				  tableStopVec=table(i,1:end);
			  else
				  tableStart=table(1,1)-(table(2,1)-table(1,1));
				  tableEnd=table(1,1);
				  tableStartVec(1:ncomp+2)=0;
				  tableStartVec(1)=tableStart;
				  tableStopVec=table(1,1:end);
			  end
			  
			  tablestep=tableEnd-tableStart;
			  
			  %calc overlap[a b] of [tableStart tableEnd] [evendStart eventEnd]
			  a=-1;
			  b=-1;
	
			  if (eventStart<=tableStart & tableStart<=eventEnd)
				  a=tableStart;
			  end
			  
			  if tableStart<=eventStart & eventStart<=tableEnd
				  a=eventStart;
			  end
			  
			  if tableStart<=eventEnd & eventEnd<=tableEnd
				  b=eventEnd;
			  end
			  
			  if eventStart<=tableEnd & tableEnd<=eventEnd
				  b=tableEnd;
			  end
			  
			  if a~=-1 & b~=-1 & a~=b
				  % if overlap calc integral for q and load
				  
%				  a
%				  b
				  t1=a-tableStart;
				  t2=b-tableStart;
				  q1=tableStartVec(2);
				  q2=tableStopVec(2);
				  d=tablestep;
				  for i=2:ncomp+1
					  c1=tableStartVec(i+1);
					  c2=tableStopVec(i+1);
					  retval(i)=retval(i)+concentration(t1,t2,q1,q2,c1,c2,d);
				  end
				  retval(1)=retval(1)+flow(t1,t2,q1,q2,d);
				  dst=1;
				  ff=1;
			  end
			  
			  if ff==1 & dst==0
				  u_dat.sp=i-1;
				  set_param(gcb,'UserData',u_dat);
				  break;
			  end
			  
			  
%			  disp('-------------------------------');
			  
		  end
		  
		  if retval(1)~=0
			  retval(2:end)=retval(2:end)/retval(1);
		  else
			  retval(2:end)=0;
		  end
		  retval(1)=retval(1)/(eventEnd-eventStart);
	  else
		  %calc q and c for composite sample mode 
		  sum_vf(1:ncomp+1)=0; %prepare return vector
		  retval(1:ncomp+1)=0; %prepare return vector
		  
		  ff=0;
		  u_dat=get_param(gcb,'UserData');
		  
		  for i=u_dat.sp:len %todo calc exact boundaries for table entrys. (speedup)
			  dst=0; %did something in last step
			  if i~=1
				  tableStart=table(i-1,1);
				  tableEnd=table(i,1);
			  else
				  tableStart=table(1,1)-(table(2,1)-table(1,1));
				  tableEnd=table(1,1);
			  end
			  tablestep=tableEnd-tableStart;
			  
			  %add only from table entry start
			  if eventStart<=tableStart & eventEnd>tableStart & eventEnd<tableEnd		  		
				  tp=(eventEnd-tableStart)/tablestep;
				  sum_vf(2:end)=sum_vf(2:end)+table(i,2)*tablestep*tp*table(i,3:end);
				  sum_vf(1)=sum_vf(1)+table(i,2)*tablestep*tp;
				  dst=1;
				  ff=1;
			  end
			  
			  %add only from table entry end
			  if eventStart>tableStart & eventStart<tableEnd & eventEnd>=tableEnd	
				  tp=(tableEnd-eventStart)/tablestep;

				  sum_vf(2:end)=sum_vf(2:end)+table(i,2)*tablestep*tp*table(i,3:end);
				  sum_vf(1)=sum_vf(1)+table(i,2)*tablestep*tp;

				  %				  sum_vf(2:end)=(sum_vf(2:end)*sum_vf(1)+table(i,3:end)*table(i,2)*tp);
				  %				  sum_vf(1)=sum_vf(1)+table(i,2)*tablestep*tp;
				  dst=1;
				  ff=1;
			  end
			  
			  %add whole table entry
			  if eventStart<=tableStart & tableEnd<=eventEnd	
				  sum_vf(2:end)=sum_vf(2:end)+table(i,2)*tablestep*table(i,3:end);
				  sum_vf(1)=sum_vf(1)+table(i,2)*tablestep;
				  dst=1;
				  ff=1;
			  end
			  
			  %add only middle part from table entry		
			  if eventStart>tableStart & tableEnd>eventEnd
				  tp=(eventEnd-eventStart)/tablestep;
				  sum_vf(2:end)=sum_vf(2:end)+table(i,2)*tablestep*tp*table(i,3:end);
				  sum_vf(1)=sum_vf(1)+table(i,2)*tablestep*tp;
				  dst=1;
				  ff=1;
			  end 
%			  t
%			  u_dat.sp 
%			  i
%			  dst
%			  ff
%			  disp('-------------'); 

			  if dst==0 & ff==1
				  u_dat.sp=i-1;
				  set_param(gcb,'UserData',u_dat);
%				  disp('break');
				  break;		  
			  end
		  end
%		  disp('-------------'); 
		  
		  if sum_vf(1)~=0
			  retval(1)=sum_vf(1)/(eventEnd-eventStart);
			  retval(2:end)=sum_vf(2:end)./sum_vf(1);
		  else
			  retval(1:end)=0;
		  end
	  end
		  
	  sys=retval;
	
	  
	  
  case {1, 4, 9}  
	  sys=[];
	  
  otherwise
	  error(['Unhandled flag = ', num2str(flag)]);
	  
end

function y=flow(t1,t2,q1,q2,d)
% t1,t2 start end time of calc q
% q1,q2 q val at 0 and at d
% d intervl length
% y q in interval [t1 t2]

y=(t1^2*(q1-q2))/(2*d)-q1*t1+(t2^2*(q2-q1))/(2*d)+q1*t2;
%y=(q2+q1)/2;

function y=concentration(t1,t2,q1,q2,c1,c2,d)
% t1,t2 start end time of calc load
% q1,q2 q val at 0 and at d
% c1,c2 c val at 0 and at d
% d intervl length
% y load in interval [t1,t2]

y=-(2*t1^3*(q1-q2)*(c1-c2)+3*d*t1^2*(c1*q2-q1*(2*c1-c2))+6*q1*c1*d^2*t1-t2*(2*t2^2*(q1-q2)*(c1-c2)+3*d*t2*(c1*q2-q1*(2*c1-c2))+6*q1*c1*d^2))/(6*d^2);
