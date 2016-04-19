function [reactor]=load_wwtp(filename)
%fileformat:
%
%s='P V=50 0=1';
%s='R V=300 1=1 4R=1 3=2 O2=0.0';
%s='E 4E=1'
%s='S A=100 h=3.5 n=10 3=2'


fid=fopen(filename);
line = fgetl(fid);
linecount = 1;
n=-1;
r=-1;


% discard all empty lines
while ~isempty(line)
	t=-1;
	A=-1;
	h=-1;
	lay=-1;
	vol=-1;
	o2=-1;

	inflow=zeros(1,r+1);
			
	[type,rem]=strtok(line);
	switch type
		%wwtp
		case {'W','w'},
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				if name=='r' | name=='R'
					r=str2num(value);
				end				
				[tok,rem]=strtok(rem);
			end		
			inflow=zeros(1,r+1);
			reactor=[0 0 0 0 0 0 inflow];
		%reactor
		case {'R','r'},
			t=2;
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				if name=='V'
					vol=str2num(value);
				end
				if name=='o2' | name=='O2'
					o2=str2num(value);
				end
				
				if name(1)=='1'|name(1)=='2'|name(1)=='3'|name(1)=='4'|name(1)=='5'|name(1)=='6'|name(1)=='7'|name(1)=='8'|name(1)=='9'|name(1)=='0'
					if name(end)~='r' & name(end)~='R'
						inflow(str2num(name)+1)=str2num(value);		
					else 
						inflow(str2num(name(1:end-1))+1)=-str2num(value);
					end
				end
				
				[tok,rem]=strtok(rem);
			end		
			
			%settler	
		case {'S','s'},
			t=3;
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				if name=='A' | name=='a'
					A=str2num(value);
				end
				if name=='h' | name=='H'
					h=str2num(value);
				end
				if name=='n' | name=='N'
					lay=str2num(value);
				end
				
				if name(1)=='1'|name(1)=='2'|name(1)=='3'|name(1)=='4'|name(1)=='5'|name(1)=='6'|name(1)=='7'|name(1)=='8'|name(1)=='9'|name(1)=='0'
					if name(end)~='r' & name(end)~='R'
						inflow(str2num(name)+1)=str2num(value);		
					else 
						inflow(str2num(name(1:end-1))+1)=-str2num(value);
					end
				end
				
				[tok,rem]=strtok(rem);
			end	
			vol=A*h;
			
			%Prim. clarifier
		case {'P','p'},
			t=1;
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				if name=='V'
					vol=str2num(value);
				end
				
				if name(1)=='1'|name(1)=='2'|name(1)=='3'|name(1)=='4'|name(1)=='5'|name(1)=='6'|name(1)=='7'|name(1)=='8'|name(1)=='9'|name(1)=='0'
					if name(end)~='r' & name(end)~='R'
						inflow(str2num(name)+1)=str2num(value);		
					else 
						inflow(str2num(name(1:end-1))+1)=-str2num(value);
					end
				end
				[tok,rem]=strtok(rem);
			end	
			
			%Mixer
		case {'M','m'},
			t=4;
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				
				if name(1)=='1'|name(1)=='2'|name(1)=='3'|name(1)=='4'|name(1)=='5'|name(1)=='6'|name(1)=='7'|name(1)=='8'|name(1)=='9'|name(1)=='0'
					if name(end)~='r' & name(end)~='R'
						if name(end)=='e' | name(end)=='E'
							inflow(str2num(name(1:end-1))+1)=str2num(value);		
						else
							inflow(str2num(name)+1)=str2num(value);
						end
					else 
						inflow(str2num(name(1:end-1))+1)=-str2num(value);
					end
				end
				[tok,rem]=strtok(rem);
			end
			
			
			%Effluent
		case {'E','e'},
			t=5;
			[tok,rem]=strtok(rem);
			while ~isempty(tok)
				pos=strfind(tok,'=');
				name=tok(1:pos-1);
				value=tok(pos+1:end);
				
				if name(1)=='1'|name(1)=='2'|name(1)=='3'|name(1)=='4'|name(1)=='5'|name(1)=='6'|name(1)=='7'|name(1)=='8'|name(1)=='9'|name(1)=='0'
					if name(end)~='r' & name(end)~='R'
						if name(end)=='e' | name(end)=='E'
							inflow(str2num(name(1:end-1))+1)=str2num(value);		
						else
							inflow(str2num(name)+1)=str2num(value);
						end
					else 
						inflow(str2num(name(1:end-1))+1)=-str2num(value);
					end
				end
				[tok,rem]=strtok(rem);
			end	
		otherwise
			disp('Dateifehler');
			linecount
	end
	
	if type~='w' & type~='W'
		reactor=[reactor; t A h lay vol	o2 inflow];
	end
	n;
	linecount;
	
	line = fgetl(fid);
	linecount=linecount+1;
end
fclose(fid);

reactor=reactor(2:end,1:end);
