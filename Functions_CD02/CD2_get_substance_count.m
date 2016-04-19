function n=CD2_get_substance_count(vect)
rem=CD2_strip_edge_spaces(vect);
n=0;

while ~isempty(rem)
	[temp,rem]=strtok(rem);
	n=n+1;
end

