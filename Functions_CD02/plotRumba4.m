function plotRumba4(res) 

subplot(2,2,1);
plot(res(:,3));title('CODsol');

subplot(2,2,2);
plot(res(:,4));title('CODpar');

subplot(2,2,3);
plot(res(:,5));title('Ntot');

subplot(2,2,4);
plot(res(:,6));title('Ptot');
