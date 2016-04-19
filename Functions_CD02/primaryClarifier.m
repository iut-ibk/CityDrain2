function v=primaryClarifier(in,V,Qin)
%in concentration vector
%V clarifier volume in m^3
%Qin inflow in m^3/d


etaMax=0.65;
etaMin=0.25;
etaCoeff=13;


eta=etaMax-(etaMax-etaMin)*exp(-etaCoeff*V/Qin);

posXH=7;
posXA=8;
posXS=9;
posXI=10;

v=in;
for i=7:10+((length(in)-10)/2);
	v(i)=in(i)*(1-eta);
end
%v(posXH)=in(posXH)*(1-eta);
%v(posXA)=in(posXA)*(1-eta);
%v(posXS)=in(posXS)*(1-eta);
%v(posXI)=in(posXI)*(1-eta);