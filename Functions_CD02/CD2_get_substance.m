function concentration=CD2_get_substance(substances_vector,substance)

global substances;
needle=strcat('_',CD2_strip_edge_spaces(substance),' ');
needle(1)=' ';
stack=strcat('_',substances,' ');
stack(1)=' ';
pos=strfind(stack,needle);

if (length(pos)<1)
	errstr=srtcat('Substance ',substance,' not found in substances vector.');
	error(errstr);
end

if (length(pos)>1)
	error('Substances Vector Corrupt.');
end
pos=1+length(strfind(substances(1:pos),' '));
disp(substances_vector);
concentration=substances_vector(pos);