function [lamr,lamt,lamz,lamrstar,lamtstar,lamzstar,r]=config(r_mid,h,Y,lamz,lam_a)

global Cloc Yprime


for k=1:length(Y)
    if k==1
        deltY(k)=0;
    else
        deltY(k)=Y(k)-Y(k-1);
    end
end

Yprime=cumsum(deltY);



if r_mid>0
    r1=r_mid-0.5.*h;
    r2=r_mid+0.5.*h;
    Ylocal=Yprime+r1;
    klam=2.*(Ylocal(1)-Ylocal(end))./(r1.^2-r2.^2);
    C=(Ylocal(1).*r2.^2-Ylocal(end).*r1.^2)./(Ylocal(1)-Ylocal(end));
    r=((2./klam).*Ylocal+C).^0.5;
else
%     r1=r_mid+0.5.*h;
%     r2=r_mid-0.5.*h;
%     Ylocal=-Yprime+r1;
    r1=r_mid-0.5.*h;
    r2=r_mid+0.5.*h;
    Ylocal=Yprime+r1;
    klam=2.*(Ylocal(1)-Ylocal(end))./(r1.^2-r2.^2);
    C=(Ylocal(1).*r2.^2-Ylocal(end).*r1.^2)./(Ylocal(1)-Ylocal(end));
    r=-((2./klam).*Ylocal+C).^0.5;
end


% lamr=(1./klam).*(2./klam.*Ylocal+C).^-.5;
lamr=(1./klam)./r;
lamt=klam./lamz.*r;
lamz=lamz;


lamrstar=lamr.*lam_a;
lamtstar=lamt./lam_a;
lamzstar=lamz.*lam_a;