function [sys,x0,str,ts] = CD2_sfun_rumba_wwtp(t,x,u,flag,frac,n_comp,wwtpfile,dtwwtp,tstep)
% RUMBA 1.0 WWTP

switch flag,
	case 0,
		[sys,x0,str,ts] = mdlInitializeSizes(frac,n_comp,wwtpfile,tstep);	
		
	case 2,                                                
		sys = mdlUpdate(t,x,u,n_comp,tstep); 
		
	case 3,                                                
		sys = mdlOutputs(t,x,u,frac,n_comp,dtwwtp,tstep);
		
	case {1,2,4,9}  
		sys = []; % do nothing
	otherwise
		error(['unhandled flag = ',num2str(flag)]);
end



%=======================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=======================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(frac,n_comp,wwtpfile,tstep)

%Stoch. Mat. Param
YH=0.67;
YA=0.24;
ix=0.07;
ip=0.01;
fp=0.08;
u_dat.stochiMatrix=initStochiMatrix(YH,YA,ix,ip,fp);
set_param(gcb,'UserData',u_dat);


no_c=10+2*(n_comp-5); %no of maters incl. temp CODpar CODsol Ntot Ptot
init_c=zeros(1,no_c); %set init reactor concentration
init_c(1:10)=[20 20 1 10 1 1 1500 100 200 1500];

%r=load_wwtp('C:\\heiko\\CityDrain\\CityDrain1.07\\wwtp_vils.txt');
r=load_wwtp(wwtpfile);
[y,x]=size(r);
no_r=y;

%searc max layer in settlers
max_lay=0;
for(i=1:no_r)	
	if r(i,1)==3 & r(i,4)>max_lay
			max_lay=r(i,4);
	end
end	

size_r=6 + no_r + 2*no_c + max_lay; %calc size of a reactor in state vector
no_states=size_r*no_r+3; %calc length of state vector


sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = no_states;

sizes.NumOutputs     = n_comp+1+11; %CD2_get_substance_count(subs_vect)+1; +8 asm1+P

sizes.NumInputs      = n_comp+1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
%sizes
sys = simsizes(sizes);

%init states [6 param][no_r routing][no_c c eff][no_c c recy][max_lay layers]
x0=zeros(1,no_states);
for(i=1:no_r)	
	for (j=1:6+no_r)
		x0(((i-1)*size_r)+j)=r(i,j);
	end
	
	for (j=1:no_c)
		x0(((i-1)*size_r)+j+6+no_r)=init_c(j);
	end
	for (j=1:no_c)
		x0(((i-1)*size_r)+j+6+no_r+no_c)=init_c(j);
	end
	
	for (j=1:max_lay)
		x0(((i-1)*size_r)+j+ 6 + no_r + 2*no_c)=1000;
	end	
end

%set aditional information at end of state vector
x0(end-2)=no_c;
x0(end-1)=max_lay;
x0(end)=no_r;

str = [];
ts  = [tstep 0]; 

 

%=======================================================================
% mdlUpdate
% Return state vector for the S-function
%=======================================================================
function sys = mdlUpdate(t,x,u,n_comp,tstep)
u_dat=get_param(gcb,'UserData');
sys=[u_dat.reactorstates];





%=======================================================================
% mdlOutputs
% Return Return the output vector for the S-function
%=======================================================================
function sys = mdlOutputs(t,x,u,frac,n_comp,dtwwtp,tstep)

[s,r]=CD2_get_sub_no('Temp CODsol CODpar Ntot Ptot');


u2=CD2_permute(u(2:end),[s r]);

[temp,back]=sort([s r]);%back is needed for back permute at end of mdloutput

x2=x; %copy states to backup

no_c=x(end-2);
pos_par_start=7;
pos_par_end=10+((no_c-10)/2);
max_lay=x(end-1);
no_r=x(end);
lr=6+no_r+2*no_c+max_lay;

if length(u)>6
	%fraction of substances in sol and par
	parvec=frac; 
	solvec=1.-parvec;
	par=u2(6:end).*parvec;
	sol=u2(6:end).*solvec;
	plantCInflow=[u2(1) inflow(u2(2:5)) sol par];
else
	plantCInflow=[u2(1) inflow(u2(2:5))];
end

plantFlow=u(1); %in m^3 / s

if plantFlow<=0
	plantFlow=0.001;
	disp('Warning inflow is <=0. Set to 0.001 m^3/s');
end


rStart=zeros(1,no_r); rA=zeros(1,no_r);
rH=zeros(1,no_r); rlay=zeros(1,no_r);
rV=zeros(1,no_r); rO2=zeros(1,no_r);
mixStart=zeros(1,no_r); mixEnd=zeros(1,no_r);
ceffStart=zeros(1,no_r); ceffEnd=zeros(1,no_r);
crecStart=zeros(1,no_r); crecEnd=zeros(1,no_r);
clayStart=zeros(1,no_r); clayEnd=zeros(1,no_r);
for j=1:no_r
	rStart(j)=(j-1)*lr+1;
	rA(j)=rStart(j)+1;
	rH(j)=rStart(j)+2;
	rlay(j)=rStart(j)+3;
	rV(j)=rStart(j)+4;
	rO2(j)=rStart(j)+5;
	
	mixStart(j)=(j-1)*lr+6+1;
	mixEnd(j)=mixStart(j)+no_r-1;
	ceffStart(j)=mixEnd(j)+1;
	ceffEnd(j)=ceffStart(j)+no_c-1;
	crecStart(j)=ceffEnd(j)+1;
	crecEnd(j)=crecStart(j)+no_c-1;
	clayStart(j)=crecEnd(j)+1;
	clayEnd(j)=clayStart(j)+x(rStart(j)+3)-1;
end
		
u_dat=get_param(gcb,'UserData');
stochiMatrix=[u_dat.stochiMatrix];
				

tstepWWTP=dtwwtp;
for st=0:tstepWWTP:tstep
	for i=1:no_r
		type=x(rStart(i));
		switch type
			case 1,
				%primclar

				%mix inflow
				r_mix=x(mixStart(i):mixEnd(i));
				inMass=plantCInflow*tstepWWTP*plantFlow*r_mix(1); %from plant inflow. could not recycle Stream
				for j=2:no_r
                    if r_mix(j)<0                     % r_mix(j)<0 => 2. outflow (reactor conc.); r_mix(j)>0 => 1. outflow (effl. conc.)
						ac=x(crecStart(j-1):crecEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
					
					if r_mix(j)>0
						ac=x(ceffStart(j-1):ceffEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
				end				
				inV=tstepWWTP*plantFlow*sum(abs(r_mix));
				inC=inMass/inV;
				
				%clarify inflow
				inCnew = primaryClarifier(inC,x(rV(i)),inV*86400/tstepWWTP);
				
				%mix inflow in basin				
				x2(ceffStart(i):ceffEnd(i))=(inCnew'*inV + x(ceffStart(i):ceffEnd(i))*x(rV(i)))./(inV+x(rV(i)));

				
			case 2,
				%reactor
				
				%mix inflow
				r_mix=x(mixStart(i):mixEnd(i));
				inMass=plantCInflow*tstepWWTP*plantFlow*r_mix(1); %from plant inflow could not recycle Stream
				for j=2:no_r
					if r_mix(j)<0
						ac=x(crecStart(j-1):crecEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
					
					if r_mix(j)>0
						ac=x(ceffStart(j-1):ceffEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
				end				
				inV=tstepWWTP*plantFlow*sum(abs(r_mix));
				inC=inMass/inV;
				
				%mix inflow and basin
				rC=(inC'*inV + x(ceffStart(i):ceffEnd(i))*x(rV(i)))./(inV+x(rV(i)));
				
				%calc process parameters(temp)
				temp=rC(1);
				myH20=4.0;
				myH_T=0.069;
				myH=myH20*exp(myH_T*(temp-20));
				bH20=0.4;
				bH_T=0.069;
				bH=bH20*exp(bH_T*(temp-20));
				kH20=3.0;
				kH_T=0.11;
				kH=kH20*exp(kH_T*(temp-20));
				KX20=0.03;
				KX_T=0.11;
				KX=KX20*exp(KX_T*(temp-20));
				myA20=0.9;
				myA_T=0.098;
				myA=myA20*exp(myA_T*(temp-20));
				KNH20=0.5;
				KNH_T=0.069;
				KNH=KNH20*exp(KNH_T*(temp-20));
				bA20=0.15;
				bA_T=0.08;
				bA=bA20*exp(bA_T*(temp-20));
			
				%set process parameters
				KS=5.0;
				KOH=0.2;
				KNO=0.5;
				KOA=0.4;
				kP=4.0;
				etag=0.8;
				
				%calc reactor rates
				So=x(rO2(i));
				rRates(1)=myH*(rC(3)/(KS+rC(3)))*(So/(KOH+So))*(rC(5)/(0.01+rC(5)))*(rC(6)/(0.01+rC(6)))*rC(7); 
				rRates(2)=myH*(rC(3)/(KS+rC(3)))*(KOH/(KOH+So))*(rC(4)/(KNO+rC(4)))*(rC(5)/(0.01+rC(5)))*(rC(6)/(0.01+rC(6)))*etag*rC(7);
				rRates(3)=myA*(rC(5)/(KNH+rC(5)))*(So/(KOA+So))*(rC(6)/(0.01+rC(6)))*rC(8); 
				rRates(4)=bH*rC(7); 
				rRates(5)=bA*rC(8); 
				rRates(6)=kH*(rC(9)/rC(7)/(KX+rC(9)/rC(7)))* rC(7); 
				rRates(7)=kP*rC(6); 

				%clac biol. growth in reactor
				rGrowth=zeros(1,no_c);
				rGrowth(1:10)=tstepWWTP*(stochiMatrix'*rRates')/86400;
				
				%set new concentrations
				x2(ceffStart(i):ceffEnd(i))=rC+rGrowth';
				
                for j=ceffStart(i):ceffEnd(i)
                    if x2(j)<0
                        x2(j)=0.01;
                    end
                end
                        
                        
			case 3,
				%settler
				
				%calc flow
				Qi=0;
				Qe=0;
				Qr=0;
				for j=2:no_r
					r_mix_j=x(mixStart(j):mixEnd(j));
				
					if r_mix_j(i+1)<0	
						Qr=Qr+abs(r_mix_j(i+1));
					else
						Qe=Qe+r_mix_j(i+1);
						
					end
				end
				Qr=Qr*86400*plantFlow;
				Qe=Qe*86400*plantFlow;

				%mix inflow
				r_mix=x(mixStart(i):mixEnd(i));
				inMass=plantCInflow*tstepWWTP*plantFlow*r_mix(1); %from plant inflow could not recycle Stream
				for j=2:no_r
					if r_mix(j)<0
						ac=x(crecStart(j-1):crecEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
					
					if r_mix(j)>0
						ac=x(ceffStart(j-1):ceffEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
				end								
				inQ=plantFlow*sum(abs(r_mix));
				inV=tstepWWTP*inQ;
				Qi=inQ*86400; %hack for old code
				inC=inMass/inV;
				
				%combine all X in inflow
				Xml=0;
				for j=pos_par_start:pos_par_end
					Xml=Xml+inC(j);
				end
								
				%settler param
				fns=0.0025;
				vsmax=200;
				vsmeff=130;
				rh=0.0004;
				rp=0.003;
				Xthresh=3000;
				sludgeAge=12;
	
				%calc Flux
				Ts=x(clayStart(i):clayEnd(i));
				
				for j=1:x(rlay(i))
					Xslred=Ts(j)-Xml*fns;
					
					vsl(j)=vsmax*(exp(-rh*Xslred)-exp(-rp*Xslred));
					if vsl(j)<0
						vsl(j)=0;
					end
					if vsl(j)>vsmeff
						vsl(j)=vsmeff;
					end
					Fsl(j)=vsl(j)*Ts(j);
					if j~=1
						if (((vsl(j-1)*Ts(j-1))<Fsl(j) || Ts(j) < Xthresh))
							Fsl(j)=vsl(j-1)*Ts(j-1);
						end
					end
				end
				
				vlay=x(rV(i))/x(rlay(i));
				hlay=x(rH(i))/x(rlay(i));
				nLayers=x(rlay(i));
				feedLayer=4;
				
				%calc diff in settler layers
				dTs=zeros(1,x(rlay(i)));
				dTs(1)=Qe/vlay*(Ts(2)-Ts(1))-Fsl(2)/hlay;
				dTs(nLayers)=Qr/vlay*(Ts(nLayers-1)-Ts(nLayers))+Fsl(nLayers)/hlay;
				dTs(feedLayer)=Qi/vlay*(Xml-Ts(feedLayer))+(Fsl(feedLayer)-Fsl(feedLayer+1))/hlay;
				for j=2:feedLayer-1
					dTs(j)=Qe/vlay*(Ts(j+1)-Ts(j))+(Fsl(j)-Fsl(j+1))/hlay;
				end
				for j=feedLayer+1:nLayers-1
					dTs(j)=Qr/vlay*(Ts(j-1)-Ts(j))+(Fsl(j)-Fsl(j+1))/hlay;
				end
				
				dTs=dTs*tstepWWTP/86400;
				Ts=Ts+dTs';
				x2(clayStart(i):clayEnd(i))=Ts;

				%calc Concentrations in layer 1 and 10
				Cs1=inC;
				Cs10=inC;
				%		for j=pos_par_start:pos_par_end
				%			Cs1(j)  = Ts(1)*inC(j)/sum(inC(pos_par_start:pos_par_end));
				%			Cs10(j) = Ts(10)*inC(j)/sum(inC(pos_par_start:pos_par_end));
				%		end
				Cs1(pos_par_start:pos_par_end)  = Ts(1)*inC(pos_par_start:pos_par_end)/sum(inC(pos_par_start:pos_par_end));
				Cs10(pos_par_start:pos_par_end) = Ts(10)*inC(pos_par_start:pos_par_end)/sum(inC(pos_par_start:pos_par_end));
				
				%calc sludge remove
				Xeff=sum(Cs10(pos_par_start:pos_par_end));
				Xtot=sum(Ts(1:10))*vlay;
				for (j=pos_par_start:pos_par_end)	
					%S=Vr1*sum(Cr1(j))+Vr2*sum(Cr2(j))+Xtot*sum(Cs10(j))/Xeff;
					S=0;
					for k=1:no_r
						if x(rStart(k))==2
							tmpC=x(ceffStart(k):ceffEnd(k));
							S=S+x(rV(k))*tmpC(j);
						end
					end
					S=S+Xtot*Cs10(j)/Xeff;
				

					Srem=S/sludgeAge-Qe*Cs1(j);
					if Srem<0
						Srem=0;
					end
					
					Cs10(j)=Cs10(j)-Srem/Qe/(Qr/Qe);%settlerRecycle; %check this!!!!!!!!!!!!!!!!!!!!!!!!!
				end
				
				x2(ceffStart(i):ceffEnd(i))=Cs1;
				x2(crecStart(i):crecEnd(i))=Cs10;
                
                for j=ceffStart(i):ceffEnd(i)
                    if x2(j)<0
                        x2(j)=0.01;
                    end
                end
                for j=crecStart(i):crecEnd(i)
                    if x2(j)<0
                        x2(j)=0.01;
                    end
                end
                        
				
			case 4,
				%mixer
				
				%mix inflow
				r_mix=x(mixStart(i):mixEnd(i));
				inMass=plantCInflow*tstepWWTP*plantFlow*r_mix(1); %from plant inflow could not recycle Stream
				for j=2:no_r
					if r_mix(j)<0
						ac=x(crecStart(j-1):crecEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
					
					if r_mix(j)>0
						ac=x(ceffStart(j-1):ceffEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
				end			
				inQ=plantFlow*sum(abs(r_mix));
				inV=tstepWWTP*inQ;
				inC=inMass/inV;
				newC=(inMass'+x(ceffStart(i):ceffEnd(i))*100)./(inV+100);
				
				x2(ceffStart(i):ceffEnd(i))=newC;
				x2(crecStart(i):crecEnd(i))=newC;
				
				
			case 5,
				%outflow
				
				%mix inflow
				r_mix=x(mixStart(i):mixEnd(i));
				inMass=plantCInflow*tstepWWTP*plantFlow*r_mix(1); %from plant inflow could not recycle Stream
				for j=2:no_r
					if r_mix(j)<0
						ac=x(crecStart(j-1):crecEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
					
					if r_mix(j)>0
						ac=x(ceffStart(j-1):ceffEnd(j-1))';
						inMass=inMass+plantFlow*tstepWWTP*abs(r_mix(j))*ac;
					end
				end
				inQ=plantFlow*sum(abs(r_mix));
				inV=tstepWWTP*inQ;
				inC=inMass/inV;
				
				
				%set output
				no_s=length(inC(11:end))/2;
				
				out=[inC(1) outflow(inC(2:10))  inC(11:10+no_s)+inC(11+no_s:10+no_s*2)]; 
				out=[inQ CD2_permute(out,back) inQ inC(1:10)]; %permute out vector back in input order	
				
					
		end %switch
	end %reactor loop
		x=x2;	
end %timestep

u_dat.reactorstates=x;
set_param(gcb,'UserData',u_dat);

sys=out;
