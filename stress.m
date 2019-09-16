function [sigr,sigt,sigz]=stress(lam_a,h,r,Y,lamrstar,lamtstar,lamzstar)

global Cloc

Icell=lamrstar.^2+lamtstar.^2+lamzstar.^2;

dWdlamr=2.*Cloc.*lamrstar;
dWdlamt=2.*Cloc.*lamtstar;
dWdlamz=2.*Cloc.*lamzstar;

%============================================
% Incompressibility
%============================================
rrev=r(end:-1:1);
sigtrev=lamtstar(end:-1:1).*dWdlamt(end:-1:1);
sigrrev=lamrstar(end:-1:1).*dWdlamr(end:-1:1);
prev=-1.*cumtrapz(rrev,(sigtrev-sigrrev)./rrev);
p=lamrstar.*dWdlamr+prev(end:-1:1);
%============================================

sigr=lamrstar.*dWdlamr-p;
sigt=lamtstar.*dWdlamt-p;
sigz=lamzstar.*dWdlamz-p;
