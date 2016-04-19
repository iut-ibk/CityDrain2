function out=inflow(in)
% in  = [CODsol CODpar Ntot Ptot]
% out = [SI SS SNO SNH SP XH XA XS XI]

% init const
%FsSI=0.3;
%FsSS=0.2;
%FsXS=0.5;

FsSI=0.125;
FsSS=0.375;
FsXS=0.5;

FpXS=0.42;
FpXH=0.33;
FpXI=0.25;
iX=0.07;
iXi=0.02;
iP=0.01;


%resolve input
CODsol=in(1);
CODpar=in(2);
Ntot=in(3);
Ptot=in(4);


%calc output
XH  = CODpar*FpXH;
XA  = 0.0; %0.1???
XS  = CODsol*FsXS + CODpar*FpXS;
XI  = CODpar*FpXI;

SI  = CODsol*FsSI;
SS  = CODsol*FsSS;
SNO = 0;
SNH = Ntot-((SI+XI)*iXi+(XH+XS)*iX);
SP  = Ptot-(XH+XA+XS+XI)*iP;

if SNH<=0
	SNH=0.1;
%	disp('Warning inflow conv.: SNH < 0: Set to 0.1');
end

if SP<=0
	SP=0.1;
%	disp('Warning inflow conv.: SP < 0: Set to 0.1');
end

%create out vector
out= [SI SS SNO SNH SP XH XA XS XI];