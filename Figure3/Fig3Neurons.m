function Fig3Neurons(unit)

%Load in data for the neuron
% load(matFile)
load('HetNeurons.mat','Data')
Data=Data(unit).Unit;

%Figure creation
figure('units','normalized','outerposition',[0.1 0.1 0.6 0.6])
center_title=sgtitle(['Monkey ', Data.Monkey,'; ',Data.Date, '; Channel ' num2str(Data.Ch), ', Unit ', num2str(Data.Unit)]);
center_title.FontWeight = 'bold';
center_title.FontSize = 12;


%Top left plot
tLeftHand=subplot(2,2,1);[y]=plotConv(Data.CueAlignFR,Data.Choice,Data.Coherence,Data.RT,'Coh',Data.bound1,Data.bound2,'Cue');
hold on;
set(gca,'visible','off');
tc = getTextLabel(0,{'Cue'},{'b'});
c=colorbar('Ticks',[0 1],'TickLabels',{'High','Low'},'Location','northoutside',...
    'FontSize',10);
c.Label.String = 'Coherence';
c.Label.FontName = 'Arial';
c.Label.FontSize = 10;
c.Position = [0.1299 0.9372 0.2 0.015];
axis tight


%Top right plot
tRightHand=subplot(2,2,2);[~,y2]=plotConv(Data.CueAlignFR,Data.Choice,Data.Coherence,Data.RT,'RT',Data.bound1,Data.bound2,'Cue');
set(gca,'visible','off');
c=colorbar('Ticks',[0 1],'TickLabels',{'Fast','Slow'},'Location','northoutside'...
    ,'FontSize',10);
c.Label.String = 'RT';
c.Label.FontName = 'Arial';
c.Label.FontSize = 10;
c.Position = [0.7299 0.9372 0.2 0.015];
axis tight

%Bottom right plot
bLeftHand=subplot(2,2,3);[y3]=plotConv(Data.MovAlignFR,Data.Choice,Data.Coherence,Data.RT,'Coh',Data.bound1,Data.bound2,'Mov');
set(gca,'visible','off');
tm = getTextLabel(0,{'Move'},{'b'});
axis tight

%Bottom left plot
bRightHand=subplot(2,2,4);[~,y4]=plotConv(Data.MovAlignFR,Data.Choice,Data.Coherence,Data.RT,'RT',Data.bound1,Data.bound2,'Mov');
set(gca,'visible','off');
axis tight



%Determine y axes height and x label offset
y_max=ceil(max(max(cellfun(@max,[y,y2,y3,y4])))/10)*10;
if y_max == 20
    hlaboff = 3;
elseif y_max == 40 || y_max == 50
    hlaboff = 6;
else
    hlaboff = 9;
end



cxLims = [-100 600];
cxTicks = [-100 100 300 500];

mxLims = [-600 100];
mxTicks = [-600:200:-200 100];

%Place axes
set(gcf,'CurrentAxes',tLeftHand)
getAxesP(cxLims,cxTicks,hlaboff,-1, 'Time (ms)', [0 y_max],[0 y_max],10,-110, 'Firing rate (Spikes /s)',[1 1], tc);
drawRestrictedLines(0,[0 y_max]);

set(gcf,'CurrentAxes',tRightHand)
getAxesP(cxLims,cxTicks,hlaboff,-1, 'Time (ms)', [0 y_max],[0 y_max],10,-110, 'Firing rate (Spikes /s)',[1 1], tc);
drawRestrictedLines(0,[0 y_max]);


set(gcf,'CurrentAxes',bLeftHand)
getAxesP(mxLims,mxTicks,hlaboff,-1, 'Time (ms)', [0 y_max],[0 y_max],10,-610, 'Firing rate (Spikes /s)',[1 1], tm);
drawRestrictedLines(0,[0 y_max]);

set(gcf,'CurrentAxes',bRightHand)
getAxesP(mxLims,mxTicks,hlaboff,-1, 'Time (ms)', [0 y_max],[0 y_max],10,-610, 'Firing rate (Spikes /s)',[1 1], tm);
drawRestrictedLines(0,[0 y_max]);


%left/right reach legend

h = zeros(2, 1);
h(1) = plot(NaN,NaN,'k-','LineWidth',2);
h(2) = plot(NaN,NaN,'k--','LineWidth',2);
legend(h, 'Left Reach','Right Reach','Location','northwest','FontSize',12,'TextColor','black');
legend('boxoff')


end