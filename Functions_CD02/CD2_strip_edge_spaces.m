function ret=CD2_strip_edge_spaces(str)

if length(str)~=0 & ~min(isspace(str))
	start=1;
	stop=length(str);
	while (str(start)==' ' | str(start)=='\t') & start<=length(str)
		start=start+1;
	end
	
	while (str(stop)==' ' | str(stop)=='\t') & stop>=1
		stop=stop-1;
	end

	ret=str(start:stop);
else
	ret='';
end