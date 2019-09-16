function [y]=mtf_config(x,r_mid,Y,lamz)

global Cloc cell_thick bound thick

lam_a=x(1);
h=x(2);

lam_a_dist=(lam_a+(1-lam_a)./(1+exp(-bound.*((Y-cell_thick)./Y(end)))));

[lamr,lamt,lamz,lamrstar,lamtstar,lamzstar,r]=config(r_mid,h,Y,lamz,lam_a_dist);

[sigr,sigt,sigz]=stress(lam_a_dist,h,r,Y,lamrstar,lamtstar,lamzstar);

term1=trapz(r,(sigt-sigr)./r);
term2=1000.*trapz(r,sigt.*r);

y=term1.^2+term2.^2;

