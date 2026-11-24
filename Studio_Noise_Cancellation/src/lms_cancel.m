function [e,y] = lms_cancel(d,r,M,mu)
% Reference-based LMS: d is the primary signal, r is correlated noise.
d=d(:); r=r(:); assert(numel(d)==numel(r));
w=zeros(M,1); u=zeros(M,1); e=zeros(size(d)); y=e;
for n=1:numel(d)
    u=[r(n);u(1:end-1)];
    y(n)=w.'*u; e(n)=d(n)-y(n);
    w=w+mu*e(n)*u;
end
end
