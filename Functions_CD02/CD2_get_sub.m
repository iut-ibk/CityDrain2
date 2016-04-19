function c=CD2_get_sub(elec,u)
c=zeros(1,length(elec))
v=CD2_get_sub_no(elec)
for i=1:length(elec)
	c(i)=u(v(i)+1)
end
