function plotVariance(r, varargin)
%
%
% plots variance for signal and signal plus noise as in Machens
% et al.
n = r.metaData.nComponents;
numComp=6;
assignopts(who, varargin);

%exclude 19 or if there are ones where the varExplained suddenly dips
% if there is a bootstrap diff. from others then exclude that bootstrap and
% include a replacement bootstrap
% includeBS=[1:18,20:50];


figure;
ShadedError(1:n,mean(r.signalerror.varExplained(:,1:n),'omitnan'),1*std(r.signalerror.varExplained(:,1:n),'omitnan')); %,'o-','markerfacecolor','m','markersize',12);
hold on
plot(1:n,mean(r.signalerror.varExplained(:,1:n),'omitnan'),'kd','markersize',10,'markerfacecolor',[0.9 0.9 0.9]);
plot(1:n,r.noise.varExplained(1:n),'ko-','markerfacecolor',[0.9 0.9 0.9]-0.4,'markersize',10);
hold on;
set(gca,'visible','off');
getAxesP([1 n],[1:numComp n],5,-2,'Component',[0 70],[0 10 20 30 40 50 60 70],1.5,0.5,'Variance (%)',[1 1]);
line([1 n],[1 1],'color','k','linestyle','--');
axis tight; axis square;


cprintf('magenta', ['Variance from the first ', num2str(numComp) ,' components: %3.2f%% \n'], sum(r.signalplusnoise.varExplained(1:numComp)))
cprintf('magenta', ['Variance from the first 10 components: %3.2f%% \n'], sum(r.signalplusnoise.varExplained(1:10)))



end