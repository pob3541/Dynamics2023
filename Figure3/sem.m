function [SEM]=sem(x,txt)
%Calculates SEM for plots

n=length(x);
SEM=std(x,0,2,txt)./sqrt(n); % w=0, dim = 2

end

