function [ytg] = CD1_mfun_flowread_Q_old(filename)
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

[ti xi]=textread(filename,'%f %f',-1);


% Output of parameters
ytg=[ti,xi];

