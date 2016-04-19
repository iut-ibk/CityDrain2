function n=CD2_get_substances_count()
global substances;

rem=substances;
n=0;

while ~isempty(rem)
	[temp,rem]=strtok(rem);
	n=n+1;
end

