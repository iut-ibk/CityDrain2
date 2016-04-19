function out=outflow(input)
% in   = [SI SS SNO SNH SP XH XA XS XI]
% out  = [CODsol CODpar Ntot Ptot]

% init const
FsSI=0.125;
FsSS=0.375;
FsXS=0.5;
FpXS=0.42;
FpXH=0.33;
FpXI=0.25;
iX=0.07;
iXi=0.02;
iP=0.01;


SI=input(1); %2
SS=input(2); %3
SNO=input(3);%4
SNH=input(4);%5
SP=input(5); %6
XH=input(6); %7 
XA=input(7); %8
XS=input(8); %9
XI=input(9);%10

CODsol = SI + SS + XS * FsXS/(FsXS+FpXS);
CODpar = XH + XA + XS * FpXS/(FsXS+FpXS)+XI;
Ntot   = (SI+XI)*iXi + (XH+XA+XS)*iX + SNO + SNH;
Ptot   = (XH+XA+XS+XI)*iP + SP;



%Ntot   = SI*iXi + SNO + SNH + XH*iX + XA*iX + XS*iX + XI *iXi;
%Ptot   = SP + XH*iP + XA*iP + XS*iP + XI*iP;

out=[CODsol CODpar Ntot Ptot];
