function stochiMatrix=initStochiMatrix(YH,YA,ix,ip,fp)
%Zero Matrix
stochiMatrix=zeros(7,10);

%Aerobic het. growth
stochiMatrix(1,3)=-1/YH;
stochiMatrix(1,5)=-ix;
stochiMatrix(1,6)=-ip;
stochiMatrix(1,7)=1;

%Anoxic het. growht
stochiMatrix(2,3)=-1/YH;
stochiMatrix(2,4)=-(1-YH)/2.86/YH;
stochiMatrix(2,5)=-ix;
stochiMatrix(2,6)=-ip;
stochiMatrix(2,7)=1;

%Aerobic aut. growth
stochiMatrix(3,4)=1/YA;
stochiMatrix(3,5)=-1/YA-ix;
stochiMatrix(3,6)=-ip;
stochiMatrix(3,8)=1;

%Decay het.
stochiMatrix(4,7)=-1;
stochiMatrix(4,9)=1-fp;
stochiMatrix(4,10)=fp;

%Decay aut.
stochiMatrix(5,8)=-1;
stochiMatrix(5,9)=1-fp;
stochiMatrix(5,10)=fp;

%Hydrolysis
stochiMatrix(6,3)=1;
stochiMatrix(6,5)=ix;
stochiMatrix(6,6)=ip;
stochiMatrix(6,9)=-1;

%P. precipatiation
stochiMatrix(7,6)=-1;
