function y=CD2_permute(x,r)
for i=1:length(x)
	y(i)=x(r(i));
end