function [yy1,yy2]=graph_generator(xi1,yi1,xi2,yi2,type,ewg1,ewg2,tstep)


switch type
    case 'linear'
xx = linspace(0,24,(3600*24/tstep));

cs1 = interp1(xi1,yi1,xx);
int1=sum(cs1);
yy1=cs1./int1/tstep*ewg1;

cs2 = interp1(xi2,yi2,xx);
int2=sum(cs2);
yy2=cs2./int2/tstep*ewg2;
        
    case 'spline'
        
xx = linspace(0,24,(3600*24/tstep));

% Create Spline for workdays

cs1 = spline(xi1,[-0.1 yi1 -0.1]);
ycs1 = ppval(cs1,xx);
int1=sum(ycs1)*tstep;
yy1=ycs1/int1*ewg1;

% Create Spline for weekends

cs2 = spline(xi2,[-0.1 yi2 -0.1]);
ycs2 = ppval(cs2,xx);
int2=sum(ycs2)*tstep;
yy2=ycs2./int2.*ewg2;

end