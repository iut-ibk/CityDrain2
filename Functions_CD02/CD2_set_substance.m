function substances_out_vector=CD2_set_substance(substances_in_vector,substance,concentration)
global substances;

if substance=='Q'
	substances_out_vector=substances_in_vector;
	substances_out_vector(1)=concentration;
else
	needle=strcat('_',CD2_strip_edge_spaces(substance),' ');
	needle(1)=' '; %hack strcat strip first space
	
	stack=strcat('_',substances,' ');
	stack(1)=' ';
	
	pos=strfind(stack,needle);
	
	if (length(pos)<1)
		substances
		substance
		errstr=strcat('Substance ',substance,' not found in substances vector.');
		error(errstr);
	end
	
	if (length(pos)>1)
		error('Substances Vector Corrupt.');
	end
	pos=2+length(strfind(substances(1:pos),' '));
	substances_out_vector=substances_in_vector;
	
	%substances_out_vector(pos)=concentration;
	substances_out_vector(pos)=concentration;
end