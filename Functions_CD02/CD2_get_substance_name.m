function name=CD2_get_substance_name(vect,pos)

rem=CD2_strip_edge_spaces(vect);

for i=1:pos 
	[tok,rem]=strtok(rem);
end
name=tok;
	