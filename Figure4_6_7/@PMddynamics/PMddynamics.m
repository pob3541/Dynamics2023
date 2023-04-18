classdef PMddynamics < handle
%
%
%
%
%   
    properties
        
        rtFR;
        
        signalplusnoise
%         signalplusnoiseCoh
        perCoh
        signalerror
        noise
        
        excursion
        
        project
        
        distance 
        
        kinet
        
        metaData;
        
        processingFlags;
    end
    
    methods
        
        function [r, temp] = PMddynamics(M)
            r.initializeMetaData(M);
            r.initializeProcessingFlags();
            
            r.rtFR = M.rt.FR;
            [r.signalplusnoise] = r.calculatePCs(M.rt.FR);
            [r.noise] = r.calculatePCs(M.rt.FRnoise);
%             [r.signalplusnoiseCoh] = r.calculatePCs(M.coherence.FR);


             [r.project] = r.calculatePCs(M.rt.FR);

 
            whichDim = 1:6;
            
            fprintf('\n------');
            for p=1:size(M.rt.bsFR,4)
                
                [temp] = r.calculatePCs(permute(squeeze(M.rt.bsFR(:,:,:,p,:)),[2 3 1 4]));
                r.signalerror.varExplained(p,:) = temp.varExplained;
                
                
                kinetV = r.calcSpeed(temp);
                r.kinet.V(p,:,:) = kinetV.V;
                r.kinet.tVect = kinetV.tVect;
                r.kinet.distancesAll(p,:,:) = kinetV.distancesAll;
                r.kinet.speed(p,:,:) = kinetV.speed;
                r.kinet.tSpeed = kinetV.tSpeed;
                
                r.kinet.spaceAngle(p,:) = kinetV.addData.spaceAngle;
                r.kinet.meanVectorAngle(p,:) = kinetV.addData.meanVectorAngle;
                
                for z=1:length(temp.TrajIn)
                    r.distance(z).V(p,:) = sqrt(sum([temp.TrajIn{z}(:,whichDim) - temp.TrajOut{z}(:,whichDim)].^2,2));
                end
                
               
            end
            
            r.calculateExcursion(M)
        end
        
        % Calculation functions
        calcKinetStatistics(r)
        reportKinetStats(r) 
        dataV = calcSpeed(r, PCoutput)
        PCoutput = calculatePCs(r,FR, varargin)
        calcKinetBoots(r)
        
        % Plotting functions
        plotKinet(r)
        plotTrajectories(r,varargin)
        plotVariance(r, varargin)
        plotComponents(r, varargin)
        
        
        function calculateExcursion(r,M)
            tS = M.rt.tS;%getParams
            tM = M.rt.tM;
            
            tSix = tS > -0.2 & tS < -0.1;
            tMix = tM > -0.2 & tM < 0.1;
            
            distV1 = nanmean(M.rt.bsFR(:,:,:,:,tSix),5);
            distV2 = nanmean(M.rt.bsFRm(:,:,:,:,tMix),5);
% 
%             distV1new = nanmean(M.rt.AllFR(:,:,:,:,tSix),5);
%             distV2new = nanmean(M.rt.AllFRm(:,:,:,:,tMix),5);  

            K = nanmean(nansum(abs(distV1 - distV2),1),3); %sum across neurons and average across reaches
%             Knew=nanmean(nansum(abs(distV1new - distV2new),1),4);
            %esentially the 'Euclidean/L1 distance'
            r.excursion = squeeze(K);
%             r.excursion = squeeze(Knew);

        end
        
        function plotExcursion(r)
            
            params = getParams;
            RTl = params.RTpcL(1:11)
            RTh = params.RTpcH(1:11)
            
            errorbar([RTl + RTh]/2,nanmean(r.excursion,2),nanstd(r.excursion,[],2),'ko-','markerfacecolor',[0.4 0.4 0.4],'markersize',12);
            hold on

%             RTcolors=params.posterColors;
%             CohColors=flipud([1 1 1; .9 .9 .9; .8 .8 .8; .7 .7 .7; .6 .6 .6;.5 .5 .5;.4 .4 .4]);
%             bins=[RTl + RTh]/2;
% 
%             for c=1:7
%                 plot(bins,r.excursion(c,:),'-','Color',CohColors(c,:));hold on
%                 for RT=1:11
%                     plot(bins(RT),r.excursion(c,RT),'o','markerfacecolor',RTcolors(RT,:),'markersize',12);hold on
%                 end
%             end

        end
            
        
        
        function initializeMetaData(r, M)
            params = getParams; close;
            r.metaData.condColors = params.posterColors;
%             r.metaData.RTlims = M.rt.RTlims;
            r.metaData.RTlims = [params.RTpcL; params.RTpcH]; % quick fix
            r.metaData.tMin = -0.4;
            r.metaData.whichConds = [1:11];
            r.metaData.t = M.rt.tS;
            r.metaData.nComponents = 20;
            r.metaData.nDims = 6;
            r.metaData.removeTime = 25;
            r.metaData.tMax = 0;
            r.metaData.kinetTimePt = 20;
            r.metaData.dt = 10;
            r.metaData.camPosition = [485.6722 -650.3079 104.7287];
            r.metaData.dimsToShow = [1 2 4];
        end
        
       
        
        function initializeProcessingFlags(r)
            r.processingFlags.subtractCCmean = false;
            r.processingFlags.meanSubtract = false;
            r.processingFlags.zScore = false;
            r.processingFlags.tColor = 'blue';
        end
        
      
        
        function assignColors(r, colorMatrix)
            r.metaData.condColors = colorMatrix;
            
        end
        
        function plotColors(r)
            
            set(gcf,'color',[1 1 1]);
            for k=1:size(r.metaData.condColors,1)
                plot(k*ones(1,10),1:10,'color',r.metaData.condColors(k,:),'linewidth',8);
                hold on;
            end
            set(gca,'visible','off');
            
        end
        

    function [r]=calcWinCoh(r, M)
          for coh= 1:7
             [r.perCoh(coh).pcaData] = r.calculatePCs(permute(squeeze(M.rt.AllFR(:,coh,:,:,:)),[2 3 1 4]),'removeTime',25, 'projectFromMean', true);
          end

    end

    function [r]=calcSubProj(r,varargin)
            numComps=6;
            assignopts(who,varargin)

            eV = OutPCA_eigenVs(:,1:numComps);
            C=r.signalplusnoise.covMatrix;
            R = trace(eV'*C*eV);
            sumLatent=sum(r.signalplusnoise.latentActual);
            r.signalplusnoise.varExplainedbyproj =  R/sumLatent;
        end
    
    
end
   
%  methods(Static)
%        plotComponents(r, varargin)
%        end
   
end


