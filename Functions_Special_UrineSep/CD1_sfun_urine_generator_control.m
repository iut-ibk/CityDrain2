%=============================================================================
% File:			CD1_sfun_urine_generator_control.m
% Purpose:		controls the urine_generation             
% Author:		kat
% Date:			050901
% Version		1
%=============================================================================

function [sys,x0,str,ts] = sfun_urine_generator_control(t,x,u,flag,n_toil,fall,tstep,QDR,n_comp,pdf)

switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(n_toil,tstep,n_comp);

  case 3,
     sys=mdlOutputs(t,x,u,n_toil,fall,tstep,QDR,pdf);

  case {1,2,4,9}     
      sys=[];
     
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================

function [sys,x0,str,ts]=mdlInitializeSizes(n_toil,tstep,n_comp)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = n_toil;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;	
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [tstep 0];

rand('state',sum(100*clock));
gamrnd('state',sum(100*clock));

u_dat.pe=0;
set_param(gcb,'UserData',u_dat);
cont=zeros(n_toil,1);
pe=0;
fall=[0 0];

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u,n_toil,fall,tstep,QDR,pdf);


if fall==[2 1.2];
u_dat=get_param(gcb,'UserData');
pe=u_dat.pe;
end

%fall=[basic interception];
%basic:
%none...0
%fixed...1
%random...2
%pdf...3
%bestbildup...[4 1]

%interception:
%none...0
%rain...1 / (1.1 /1.2 random)
%rain+Qc...2
%rain+forecast...3

cont = zeros(n_toil,1);
fallstr=num2str(fall);

switch fallstr;
    
    %None
    case num2str([0 0]);
        cont = ones(n_toil,1);
        
    %Fixed time \ rain;forecast
    case num2str([1 3]);
        j = rem(t,86400)/tstep+1;
        rain=any([u(1) u(3)]);
        % u(1) and u (3) = 0 => rain=0; ohterwise rain=1;
 
        %interception
        if rain > 0;
            cont = zeros(n_toil,1);
        %no interception    
        else
            for i=1:n_toil;
                cont(i) = ceil(86400/tstep/n_toil*i) == j;
            end
        end                

    %Fixed time \ rain;Q=QDR,max  
    case num2str([1 2]);
        j = rem(t,86400)/tstep+1;
        rain=any([u(1) u(2)==QDR]);
        %interception
        if rain > 0;
            cont = zeros(n_toil,1);
        %no interception    
        else
            for i=1:n_toil;
                cont(i) = ceil(86400/tstep/n_toil*i) == j;
            end
        end
            
    %Fixed time \ rain    
    case num2str([1 1]);
        j = rem(t,86400)/tstep+1;
        rain=u(1);
        %interception
        if rain > 0;
            cont = zeros(n_toil,1);
        %no interception    
        else
            for i=1:n_toil;
                    cont(i) = ceil(86400/tstep/n_toil*i) == j;
            end
        end 
    
    %Fixed time \ none    
    case num2str([1 0]);
        j = rem(t,86400)/tstep+1;
        for i=1:n_toil;
            cont(i) = ceil(86400/tstep/n_toil*i) == j;
        end
    
    %random \ rain;Q=QDR,max
    case num2str([2 2]);
        p=ones(n_toil,1)*tstep/86400; %probability = ones per day
        r=rand(n_toil,1);
        rain=u(1);
        cso=u(2)==QDR;
                
        %interception
        if rain > 0;
            cont = zeros(n_toil,1);  
        else
            if cso==1;
                param=0.5;
            else
                param=1;
            end
            for i=1:n_toil;
                cont(i) = p(i)*param >= r(i);
            end
        end
                
            %random \ rain;emptying period    
    case num2str([2 1.2]);
        p=ones(n_toil,1)*tstep/86400; %probability = ones per day
        r=rand(n_toil,1);
        rain=u(1);
       
                if rain > 0;
                    pe=0.2;
                    for i=1:n_toil;
                        cont(i) = p(i).*pe >= r(i);
                    end
                else
                    if pe==0.2;
                        pe=0.5;
                    elseif pe<=1;
                        pe=pe+0.5/(2*86400/tstep);
                    else
                        pe=1;
                    end
                        for i=1:n_toil;
                            cont(i) = p(i).*pe >= r(i);
                        end
                end             
            
    %random \ rain    
    case num2str([2 1.1]);
        p=ones(n_toil,1)*tstep/86400; %probability = ones per day
        r=rand(n_toil,1);
        rain=u(1);
                %interception
                if rain > 0;
                    cont = zeros(n_toil,1);
                %no interception    
                else
                    for i=1:n_toil;
                        cont(i) = p(i) >= r(i);
                    end
                end
                
    %random \ none    
    case num2str([2 0]);
        p=ones(n_toil,1)*tstep/86400; %probability = ones per day
        r=rand(n_toil,1);
                for i=1:n_toil;
                    cont(i) = p(i) >= r(i);
                end
            
    %pdf \ rain;Q=QDR,max
    case num2str([3 2]);
        cont = zeros(n_toil,1);
        p=ones(n_toil,1)*10*tstep/86400; %probability = ten times per day
        r=rand(n_toil,1);
        j = rem(t,86400)/tstep+1;

        rain=u(1);
        cso=u(2)==QDR;
        %interception
                if rain > 0;
                    cont = zeros(n_toil,1); 
                else
                    if cso==1;
                        param=0.5;
                    else
                        param=1;
                    end
                    for i=1:n_toil;
                            cont(i) = p(i)*pdf(j)*tstep*param >= r(i);
                    end
                end
                
    %pdf \ rain    
    case num2str([3 1]);
        p=ones(n_toil,1)*10*tstep/86400; %probability = 10s per day
        r=rand(n_toil,1);
        j = rem(t,86400)/tstep+1;
        rain=u(1);
                %interception
                if rain > 0;
                    cont = zeros(n_toil,1);
                %no rain    
                else
                    for i=1:n_toil;
                        cont(i) = p(i)*pdf(j)*tstep >= r(i);
                    end
                end
                
    %pdf \ none    
    case num2str([3 0]);
        p=ones(n_toil,1)*10*tstep/86400; %probability = 10s per day
        r=rand(n_toil,1);
        j = rem(t,86400)/tstep+1;
             %no interception                       
                    for i=1:n_toil;
                        cont(i) = p(i)*pdf(j)*tstep >= r(i);
                    end
    %bestbildup    
    case {num2str([4 0.25]),num2str([4 0.5]),num2str([4 0.75])};
        
        j = rem(t,86400)/tstep+1;        
        rain=u(1);

        %Ausbaugrad
        a=fall(2);
        conta = zeros(fix(n_toil*a),1);        
        %interception
        if rain > 0;
            conta = zeros(fix(n_toil*a),1);
            contno = ones(ceil(n_toil*(1-a)),1);
            cont=[conta;contno];
        %no interception   
        else
            for i=1:fix(n_toil*a);
                conta(i) = ceil(86400/tstep/fix(n_toil*a)*i) == j;
            end
            contno = ones(ceil(n_toil*(1-a)),1);
            cont=[conta;contno];            
        end
        
end

if fall==[2 1.2];
    u_dat.pe=pe;
    set_param(gcb,'UserData',u_dat);
end

sys=cont;