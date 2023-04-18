function calcKinetBoots(r)
% Calculates bootstrap statistics for the angles in our data
%
% PB, Febuary 6th 2023

% plot(1:80,r.kinet.spaceAngle(1,:))

% sum(r.kinet.spaceAngle(:,20) > 1)
% choose a time point to do the bootstrap analysis
tp=20;
%Choose degree to test bootstapped data against
deg=90;
numBootStraps=size(r.kinet.spaceAngle,1);

sumSpaceBoots=sum(rad2deg(r.kinet.spaceAngle(:,tp))>deg);
sumVectorBoots=sum(rad2deg(r.kinet.meanVectorAngle(:,tp))>deg);

SpaceBootStat=sumSpaceBoots/numBootStraps;
VectorBootStat=sumVectorBoots/numBootStraps;

if SpaceBootStat == 0
    SpaceBootStat =1/numBootStraps;
    disp(['Subspace boot statistic is: ', num2str(SpaceBootStat)])
else
    disp(['Subspace boot statistic is: ', num2str(SpaceBootStat)])

end

if VectorBootStat == 0
    VectorBootStat =1/numBootStraps;
    disp(['Alignment boot statistic is: ', num2str(VectorBootStat)])
else
    disp(['Alignment boot statistic is: ', num2str(VectorBootStat)])

end
end