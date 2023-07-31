function [SEM]=sem(x,txt)
%Calculates SEM for plots

<<<<<<< HEAD
n=size(x,2);
=======
n=size(x,2)
>>>>>>> 5e6b115de56dc27c1df971e92e00930a9c32d723
SEM=std(x,0,2,txt)./sqrt(n); % w=0, dim = 2

end

