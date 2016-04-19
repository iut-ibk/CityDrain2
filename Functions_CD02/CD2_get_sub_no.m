function [s,r]=CD2_get_sub_no(elec)
global substances;
no_subs=length(find(CD2_strip_edge_spaces(substances)==' '))+1;
sc=cell(1,no_subs);
rem=substances;
for i=1:no_subs
	[sc{1,i},rem]=strtok(rem,' ');
end

no_elec=length(find(CD2_strip_edge_spaces(elec)==' '))+1;
ec=cell(1,no_elec);
rem=elec;
s=zeros(1,no_elec);
r=ones(1,no_subs);
for i=1:no_elec
	[ec{1,i},rem]=strtok(rem,' ');
	for j=1:no_subs
		if length(ec{1,i})==length(sc{1,j}) & ec{1,i}==sc{1,j} %lazy eval
	
			s(1,i)=j;
			r(1,j)=0;
		end
	end
end
r=find(r==1);