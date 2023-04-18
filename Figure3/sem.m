%SEM
function [SEM]=sem(x,txt)
n=length(x);
SEM=std(x,0,2,txt)./sqrt(n); % w=0, dim = 2, prefer to omitnan if possible
end

