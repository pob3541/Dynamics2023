classdef simPMd < handle
    properties
        params;
        timeParams;
        FRparams;
        
        
        FRsim;
        FRperi;
        FRdecr;
        FR;
        
        
        RT;
        
        tAxis;
        time;
        tNew;
        tFinal;
        
        
        simType;
        
        PCdata
        
        
        
    end
    methods
        
        
        function r = simPMd(varargin)
            
            nN = 200;
            tVals = [0:1:200]/100;
            nT = 300;
            baseRT = 200;
            mult = 100;
            gShape = 5;
            gScale = 0.5;
            
            tStart = 0.6;
            tLatency = 0.1;
            CISmult = 15;
            RTfraction = 0.2;
            psthTime = [0:0.001:1.6];
            psthSmooth = 0.03;
            
            assignopts(who, varargin);
            
            % Create the object
            r.params.nTrials = nT;
            r.params.nNeurons = nN;
            r.params.tStart = tStart;
            r.params.tLatency = tLatency;
            r.params.psthTime = psthTime;
            r.params.psthSmooth = psthSmooth;
            r.FRparams.CISmult = CISmult;
            r.FRparams.choice(1,:) = 5 + 7*rand(1,r.params.nNeurons);
            r.FRparams.choice(2,:) = 2 + 1*rand(1,r.params.nNeurons);
            r.params.RTfraction = RTfraction;
            
            
            r.timeParams.time = tVals;
            r.RT = [baseRT + ...
                mult*gamrnd(gShape,gScale,r.params.nTrials,1)]./1000;
            
            RTp = prctile(r.RT, [0:15:100]);
            % lower and upper bound of RT percentile
            r.params.RTl = RTp(1:end-1);
            r.params.RTr = RTp(2:end);
            
            
        end
        
        simulateNeurons(r,type, varargin);
        simulateDecreasedNeurons(r);
        RTbinnedFR(r);
        
        
        function r = predictChoice(r)
            temp = cat(2,squeeze(r.FR(:,:,1,:)),squeeze(r.FR(:,:,2,:)));
            FRmatrix = permute(temp,[1,3,2]);
            
            whichNeurons = randperm(size(r.FR,1));
            binnedFRmatrix = FRmatrix(whichNeurons(1:30),[1:10:end-2],:);
            
            nTrials = r.params.nTrials;
            rt = [r.RT;r.RT];
            decision = [zeros(nTrials,1); ones(nTrials,1)];
            
            options.rtThreshold = prctile(r.RT,50);
            [accuracy_l] = predictChoice(binnedFRmatrix, rt, decision, options, 'less');
            [accuracy_g] = predictChoice(binnedFRmatrix, rt, decision, options, 'greater');
            
            keyboard
            
            
        end
        
        function r = plotRThist(r)
            c = histogram(r.RT);
            c.FaceColor = [0.4 0.4 0.4];
            c.EdgeColor = 'none';
            set(gca,'tickdir','out','box','off','fontsize',12);
            
            
        end
        
        function r = neuralPop(r, type)
            %
            %
            % Chand
            if isempty(r.FRsim)
                r.simulateNeurons(type);
            end
            
            if isempty(r.FRperi)
                r.simulatePerimovementNeurons();
            end
            
            if isempty(r.FRdecr)
                r.simulateDecreasedNeurons();
            end
            
            
            
        end
        
        function r = rearrange(r)
            r.FR = cat(1, r.FRsim, r.FRdecr, r.FRperi);
            FR = r.FR(:,:,:,100:end);
            r.tNew = r.tAxis(100:end) - r.params.tStart;
            
            totalN = size(FR,1);
            
            FRc = [];
            FRc(1:2:totalN,:,:,:) = FR(1:2:totalN,:,[2 1],:);
            FRc(2:2:totalN,:,:,:) = FR(2:2:totalN,:,[1 2],:);
            
            r.FR = FRc;
        end
        
        function plotNeurons(r)
            
            figure;
            plot(squeeze(nanmean(r.FR(:,:,1,:),2))','-r');
            hold on;
            plot(squeeze(nanmean(r.FR(:,:,2,:),2))','-g');
            set(gca,'tickdir','out','box','off');
            
        end
        
        function doPCA(r)
            tFinal = r.tNew > -0.2 & r.tNew < 0.6;
            r.tFinal = tFinal;
            
            % RT at different percentile
            FRnew = [];
            RTl = r.params.RTl;
            RTr = r.params.RTr;
            
            for cId = 1:length(RTl)
                FRnew(:,:,cId,:) = squeeze(nanmean(r.FR(:,r.RT > RTl(cId) & r.RT < RTr(cId),:,:),2));
            end
            
            bigMatrix = [];
            for choiceId = 1:2
                for RTid = 1:length(r.params.RTl)
                    if isempty(bigMatrix)
                        bigMatrix = squeeze(FRnew(:,choiceId, RTid, tFinal));
                    else
                        bigMatrix = cat(2, bigMatrix, squeeze(FRnew(:,choiceId, RTid, tFinal)));
                    end
                end
            end
            bigMatrix = bigMatrix'./repmat(sqrt(prctile(bigMatrix',99)),[size(bigMatrix,2) 1]);
            
            [coeff, score, V] = pca(bigMatrix);
            
            score = bigMatrix*coeff;
            figure;
            I1 = reshape(score, [sum(tFinal) length(RTl) 2 size(score,2)]);
            li1 = plot(r.tNew(tFinal), squeeze(I1(:,:,1,4)),'-');
            hold on
            li2 = plot(r.tNew(tFinal), squeeze(I1(:,:,2,4)),'-');
            hold on
            setLineColors(li1);
            setLineColors(li2);
            
            r.PCdata.score = score;
            r.PCdata.V = V;
            r.PCdata.reshaped = I1;
            
            
            
        end
        
        function r = plotPCs(r)
            
            figure;
            set(gcf,'position',[1000,1000,2000,600])
            
            params = getParams;
            colV = params.posterColors(ceil(linspace(1,size(params.posterColors,1),length(r.params.RTl))),:);
            
            t0 = find(r.tNew(r.tFinal) >=0,1,'first');
            I1 = r.PCdata.reshaped;
            I1(:,:,:,2:3) = -I1(:,:,:,2:3);
            
            iX = 1:30:size(I1,1);
            
            orderX = [1:3];
            
            
            
            subplot(1,3,1)
            for nR = 1:length(r.params.RTl)
                plot3(squeeze(I1(:,nR,1,orderX(1))), squeeze(I1(:,nR,1,orderX(2))), squeeze(I1(:,nR,1,orderX(3))),'-','color',colV(nR,:));
                hold on
                plot3(squeeze(I1(:,nR,2,orderX(1))), squeeze(I1(:,nR,2,orderX(2))), squeeze(I1(:,nR,2,orderX(3))),'--','color',colV(nR,:));
                
                hold on
                plot3(squeeze(I1(t0,nR,:,orderX(1))), squeeze(I1(t0,nR,:,orderX(2))),squeeze(I1(t0,nR,:,orderX(3))),'o','markerfacecolor','r','markeredgecolor','none','markersize',12);
                
                hold on
                plot3(squeeze(I1(end,nR,:,orderX(1))), squeeze(I1(end,nR,:,orderX(2))),squeeze(I1(end,nR,:,orderX(3))),'d','markerfacecolor',colV(nR,:),'markeredgecolor','none','markersize',12);
                
            end
            
            xlabel('PC_1');
            ylabel('PC_2');
            zlabel('PC_3');
            
            
            Tv = ThreeVector(gca);
            ax = gca;
            ax.SortMethod = 'ChildOrder';
            
            % view([-38 45])
            view([8 77])
            
            
        end
        
        function r = simulatePerimovementNeurons(r)
            
            FR2 = [];
            baseline = 5;
            
            for neuronId = 1:50
                OnsetTime = 20*rand-10;
                fprintf('.');
                if rand > 0.5
                    mult = [100 50];
                else
                    mult = [50 100];
                end
                for nChoice=1:2
                    for nTrials = 1:length(r.RT)
                        rate = baseline*ones(1,length(r.time));
                        onsetTime = floor(ceil([r.params.tStart + r.RT(nTrials)])*100-OnsetTime);
                        
                        rate(onsetTime-20:onsetTime+20) = baseline + mult(nChoice)*normpdf(-20:1:20,0,2);
                        rate = rate(1:length(r.time));
                        spikes(nTrials).times = generateInhomRenewal(r.time,rate,'process','poisson');
                    end
                    [~,t,~,RR] = psthcc(spikes, 0.03, 'n',[0 2],2,[0:.001:1.6]);
                    FR2(neuronId, :,nChoice, :) = RR;
                end
            end
            r.FRperi = FR2;
            
            
        end
        
        
        
        
    end
end
