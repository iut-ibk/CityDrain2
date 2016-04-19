%=============================================================================
% File:			sfun_cd2_rainread.m
% Purpose:		Read parameters from file. (Details in mfun_cd2_flowread)
% Author:		H. Kinzel, IUT
% Date:			Origin: 25.04.2005, Last updated: 6.06.2005	
% Version		003
%=============================================================================

function [sys, x0, str, ts] = CD1_sfun_rainread(t, x, u, flag, crep, table, tablestep, tstep)

% The following outlines not the general structure of an S-function.
% It works direct because of the size of table.


switch flag,
  case 0, % mdlInitializeSizes
	  %Check table for continuity and Q, C >= 0
	
	  tmp=size(table);
	  len=tmp(1);
	  wid=tmp(2);
	  
	  if wid>2
		  error('Only put time[s] and rainfall in file.');
	  end
		 
	  %If crep check if first and last line are the same.
	  if strcmp(crep,'on') & find(table(1,2:end)~=table(end,2:end))
		  error('For Cycling repetitition first and last line in file must be equal.');
	  end
	  
	  tim=table(1, 1);
	  if len<2
		  error('Table must have at least 2 lines.');
	  end
	  if table(1, 2)<0
		  warning('Q or C < 0 in Dataline: 1');
	  end	  
	  for i=2:len
		  if table(i, 1)<=tim
			  error('Times in table not ascending [Line: %i]',i);
		  else
			  tim=table(i, 1);
		  end
		  if table(i, 2)<0
			  warning('Q or C < 0 in Dataline: %i', i);
		  end
	  end
	  
	  % Standard s-funktion init
	  sizes = simsizes;
	  sizes.NumContStates  = 0;
	  sizes.NumDiscStates  = 2; %2006_09_06 starti endi in states
	  sizes.NumOutputs     = 1;
	  sizes.NumInputs      = 0;
	  sizes.DirFeedthrough = 0;	
	  sizes.NumSampleTimes = 1;   % at least one sample time is needed
	  
	  sys = simsizes(sizes);
	  x0  = zeros(sizes.NumDiscStates, 1);
	  str = [];
	  ts  = [tstep 0];
	  
  case 2, % mdlUpdate
      %sys=[0 0];
      u_dat=get_param(gcb,'UserData');
      sys=[u_dat.time];

%	  sys=[0 0]; %2006_09_06 starti endi in states
	
      
  case 3, % mdlOutput
	  
	  tmp=size(table);
	  len=tmp(1);
	  
	  % enlarge table by one entry to catch 
	  % handling for boundary conditions
	  table=[table; table(end,1)+tablestep -1]; %tablestep length of time step in table
	  
	  % calc eventStart for cyclic repitation
	  if strcmp(crep,'on')  
		  eventStart=mod(t, table(len, 1))-tstep; %eventStart start TIME in table
	  else
		  eventStart=t-tstep;
	  end
	  eventEnd=eventStart+tstep;
	  retval=0; %set return sum to zero
	 
	  starti=floor(eventStart/tablestep)+2;
	  endi=ceil(eventEnd/tablestep)+1;
      
      
%       if endi>len
%           error('unknown rainred error.');  
%           t
%           len
%           eventStart
%           eventEnd
%           starti
%           endi
%           
%       end
      
	  for i=starti:endi 
          
		  tableStart=table(i,1)-tablestep;
		  tableEnd=table(i,1);
		  
		  %add only from table entry start
		  if eventStart<=tableStart & eventEnd>tableStart & eventEnd<tableEnd
%			  disp('In 1');
%			  eventStart
%			  eventEnd
%			  tableStart
%			  tableEnd
			
			  tp=(eventEnd-tableStart)/tablestep;
			  retval=retval+table(i,2)*tp;
		  end
		  
		  %add only from table entry end
		  if eventStart>tableStart & eventStart<tableEnd & eventEnd>=tableEnd
%			  			disp('In 2');
%			  			eventStart
%			  			eventEnd
%		  			tableStart
%			  			tableEnd
			  
			  tp=(tableEnd-eventStart)/tablestep;
			  retval=retval+table(i,2)*tp;
		  end
		    
		  %add whole table entry
		  if eventStart<=tableStart & tableEnd<=eventEnd
%			  			disp('3');
%			  			eventStart
%			  			eventEnd
%			  			tableStart
%			  			tableEnd
			  
			  retval=retval+table(i,2);
		  end
		  
		  %add only middle part from table entry		
		  if eventStart>tableStart & tableEnd>eventEnd
%			  			disp('4');
%			  			eventStart
%			  			eventEnd
%			  			tableStart
%			  			tableEnd
			  tp=(eventEnd-eventStart)/tablestep;
			  retval=retval+table(i,2)*tp;
		  end 
	  end
	  
%	  disp('---------------------------------------');

      u_dat.time=[eventStart eventEnd];
      set_param(gcb,'UserData',u_dat);
	  sys=retval;
	  
  case {1, 4, 9}  
     sys=[];
     
  otherwise
    error(['Unhandled flag = ', num2str(flag)]);

end
