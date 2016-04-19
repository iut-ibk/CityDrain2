function [ytg] = CD1_mfun_flowread_QC_old(filename,n_comp)
%IUT - Insitute of Environmental Engineering
%
%
% Author, Date, Version
%
%S. Achleitner;  Simulation of Biocos according to predefined
%                boundary conditions by COST Benchmarking

% loading of data from the text file
% Numbers a delimited by tabs

% Reading parameters from textfile (filename)


if n_comp==0
[ti xi]=textread(filename,'%f %f',-1);
ytg=[ti,xi];

elseif n_comp==1
[ti xi c1]=textread(filename,'%f %f %f',-1);
ytg=[ti,xi,c1];

elseif n_comp==2
[ti xi c1 c2]=textread(filename,'%f %f %f %f',-1);
ytg=[ti,xi,c1,c2];

elseif n_comp==3
[ti xi c1 c2 c3]=textread(filename,'%f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3];

elseif n_comp==4
[ti xi c1 c2 c3 c4]=textread(filename,'%f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4];

elseif n_comp==5
[ti xi c1 c2 c3 c4 c5]=textread(filename,'%f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5];

elseif n_comp==6
[ti xi c1 c2 c3 c4 c5 c6]=textread(filename,'%f %f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5,c6];

elseif n_comp==7
[ti xi c1 c2 c3 c4 c5 c6 c7]=textread(filename,'%f %f %f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5,c6,c7];

elseif n_comp==8
[ti xi c1 c2 c3 c4 c5 c6 c7,c8]=textread(filename,'%f %f %f %f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5,c6,c7,c8];

elseif n_comp==9
[ti xi c1 c2 c3 c4 c5 c6 c7,c8,c9]=textread(filename,'%f %f %f %f %f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5,c6,c7,c8,c9];

elseif n_comp==10
[ti xi c1 c2 c3 c4 c5 c6 c7,c8,c9,c10]=textread(filename,'%f %f %f %f %f %f %f %f %f %f %f',-1);
ytg=[ti,xi,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10];

end



