classdef PMDdecoding < handle
    %
    %
    %
    %
    %
    properties
        
        lfads
        reg
        dec
        
    end
    
    methods
        function D = PMDdecoding(decode)
            
            D.lfads=InitLFADS(D,decode);
            D.reg=InitReg(D,decode);
            D.dec=InitDec(D,decode);
            
        end
        
        function lfads=InitLFADS(D,decode)
            
            %LFADS variables
            factors = decode.lfadsR.factors;
            test = reshape(factors, [size(factors,1), size(factors,2)*size(factors,3)])';
            [~, score, ~] = pca(test);
            
            orthF = [];
            for thi = 1 : size(factors, 3)
                orthF(:,:,thi) = (score( (1:180) + (thi-1)*180, :))';
            end
            
            trials_data = decode.raw.dat;
            temp = struct2table(trials_data);
            %             sortedTemp = sortrows(temp, 'condId');
            
            % RT LFADS
            
            % choose the 30% fast and slow reaction
            percentile = 30;
            % choose condition num
            cond = 1;
            
            %             selectedTrials = (temp.condId == cond);
            selectedRT = temp.RT(temp.condId == cond, :);
            sortedRT = sort(unique(selectedRT));
            
            % 20% RT
            fastPoint = sortedRT(round(length(sortedRT)*percentile/100));
            % 80% RT
            slowPoint = sortedRT(round(length(sortedRT)*(100 - percentile)/100));
            
            % trials that belong to fast 20% (label1) and slow 20% (label2)
            label1 = (temp.condId == cond) & (temp.RT <= fastPoint);
            label2 = (temp.condId == cond) & (temp.RT >= slowPoint);
            
            % store each trial reaction time
            lfads.label1RT = temp.RT(label1);
            lfads.label2RT = temp.RT(label2);
            
            % extract slow and fast trajs
            lfads.fast_traj = orthF(1:3,:,label1);
            lfads.slow_traj = orthF(1:3,:,label2);
            
            % Choice LFADS
            
            % define percentage of all trials plotted
            portion = 0.5;
            
            % define the conditions plotted
            condition = [1,8];
            
            for id = 1 : length(condition)
                cond = condition(id);
                % extract the RT and trajs with target condition
                trajs = orthF(1:3,:,temp.condId == cond);
                trajRT = temp.RT(temp.condId == cond, :);
                % randomly select 50% data
                idx = randperm(size(trajRT,1));
                extract = sort(idx(1:round(length(idx)*portion)));
                % update trajs and corresponding RT
                trajs = trajs(:,:,extract);
                trajRT = trajRT(extract);
                % store the data into a struct
                lfads.Traj(id).cond = cond;
                lfads.Traj(id).trajs = trajs;
                lfads.Traj(id).trajRT = trajRT;
                
            end
        end
        
        function reg=InitReg(D,decode)
            regression=decode.regression;
            
            % define session number
            s = 40;
            % choice 1
            bounds1 = regression(s).shuffledBoundC1R2;
            r21 = regression(s).c1R2;
            % choice 2
            bounds2 = regression(s).shuffledBoundC2R2;
            r22 = regression(s).c2R2;
            % combine choices
            reg.SessBounds = (bounds1 + bounds2)./2;
            reg.SessR2 = (r21 + r22)./2;
            
            
            reg.AvgR2 = [];
            for ip2 = 1 : length(regression)
                reg.AvgR2(:,ip2) = (regression(ip2).c1R2 + regression(ip2).c2R2)./2 ;
            end
            
        end
        
        
        function dec=InitDec(D,decode)
            classifier=decode.classifier;
            
            % define session number
            s = 40;
            dec.SessBounds = classifier(s).shuffled_bound_accuracy;
            dec.SessAcc = classifier(s).accuracy;
            
            dec.AvgAcc = [];
            for ip2 = 1 : length(classifier)
                dec.AvgAcc(:,ip2) = classifier(ip2).accuracy;
            end
            
        end
        
        
        
        function plotRTLFADS(D)
            
            label1RT=D.lfads.label1RT;
            label2RT=D.lfads.label2RT;
            
            fast_traj= D.lfads.fast_traj;
            slow_traj= D.lfads.slow_traj;
            binWidth = 10;
            
            
            figure;
            
            for ii = 1 : size(fast_traj,3)
                % endPoint
                lastPt = 60 + round(label1RT(ii)/binWidth);
                % plot trajectories from -200 of stimulus onset
                plot3(fast_traj(1,40:lastPt,ii), fast_traj(2,40:lastPt,ii),fast_traj(3,40:lastPt,ii), 'color', [0,0,1]);
                hold on
                % stimulus onset
                plot3(fast_traj(1,60,ii), fast_traj(2,60,ii),fast_traj(3,60,ii), 'bo', 'markerfacecolor', 'b', 'markersize', 8);
                % end dot
                plot3(fast_traj(1,lastPt,ii), fast_traj(2,lastPt,ii),fast_traj(3,lastPt,ii), 'd', 'markeredgecolor', 'none', 'markerfacecolor', 'b', 'markersize', 10);
                
            end
            
            
            for ii = 1 : size(slow_traj,3)
                % endPoint
                lastPt = 60 + round(label2RT(ii)/binWidth);
                % plot trajectories from -200 of stimulus onset
                plot3(slow_traj(1,40:lastPt,ii), slow_traj(2,40:lastPt,ii), slow_traj(3,40:lastPt,ii), 'color', [1,0,0]);
                hold on
                % stimulus onset
                plot3(slow_traj(1,60,ii), slow_traj(2,60,ii),slow_traj(3,60,ii), 'ro', 'markerfacecolor', 'r', 'markersize', 8);
                % end dot
                plot3(slow_traj(1,lastPt,ii), slow_traj(2,lastPt,ii),slow_traj(3,lastPt,ii),'d', 'markeredgecolor', 'none', 'markerfacecolor', 'r', 'markersize', 10);
                
            end
            
            
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            
            set(gca, 'LooseInset', [ 0 0 0 0 ]);
            xlabel('X_1');
            ylabel('X_2');
            zlabel('X_3');
            axis vis3d;
            
            view([-18,16])
            tv = ThreeVector(gca);
            tv.axisInset = [0.2 0.2]; % in cm [left bottom]
            tv.vectorLength = 2; % in cm
            tv.textVectorNormalizedPosition = 1.8;
            tv.fontSize = 15; % font size used for axis labels
            tv.fontColor = 'k'; % font color used for axis labels
            tv.lineWidth = 2; % line width used for axis vectors
            tv.lineColor = 'k'; % line color used for axis vectors
            tv.update();
            rotate3d on;
            
            ax = gca;
            ax.SortMethod = 'childorder';
        end
        
        function plotChoiceLFADS(D)
            
            binWidth = 10;
            
            % plot cond 1
            trajs = D.lfads.Traj(1).trajs;
            trajRT = D.lfads.Traj(1).trajRT;
            for ii = 1 : size(trajs,3)
                % endPoint
                lastPt = 60 + round(trajRT(ii)/binWidth);
                % plot trajectories from -200 of stimulus onset
                plot3(trajs(1,40:lastPt,ii), trajs(2,40:lastPt,ii),trajs(3,40:lastPt,ii), 'color', [0.5,0,1]);
                hold on
                % stimulus onset
                plot3(trajs(1,60,ii), trajs(2,60,ii),trajs(3,60,ii), 'o', 'markeredgecolor', 'none', 'markerfacecolor', [0.5,0,1], 'markersize', 8);
                % plot end dot
                plot3(trajs(1,lastPt,ii), trajs(2,lastPt,ii),trajs(3,lastPt,ii), 'd', 'markeredgecolor', 'none', 'markerfacecolor', [0.5,0,1], 'markersize', 10);
            end
            
            % plot cond 8
            trajs = D.lfads.Traj(2).trajs;
            trajRT = D.lfads.Traj(2).trajRT;
            for ii = 1 : size(trajs,3)
                % endPoint
                lastPt = 60 + round(trajRT(ii)/binWidth);
                % plot trajectories from -200 of stimulus onset
                plot3(trajs(1,40:lastPt,ii), trajs(2,40:lastPt,ii),trajs(3,40:lastPt,ii), 'color', [0,0.7,0.2]);
                hold on
                % stimulus onset
                plot3(trajs(1,60,ii), trajs(2,60,ii),trajs(3,60,ii), 'o', 'markeredgecolor', 'none', 'markerfacecolor', [0,0.7,0.2], 'markersize', 8);
                % plot end dot
                plot3(trajs(1,lastPt,ii), trajs(2,lastPt,ii),trajs(3,lastPt,ii), 'd', 'markeredgecolor', 'none', 'markerfacecolor', [0,0.7,0.2], 'markersize', 10);
            end
            
            % title('Choice LFADS Trajectories', 'fontsize', 30);
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            
            set(gca, 'LooseInset', [ 0 0 0 0 ]);
            xlabel('X_1');
            ylabel('X_2');
            zlabel('X_3');
            axis vis3d;
            % view([-172,60])
            view([131, 37])
            
            tv = ThreeVector(gca);
            tv.axisInset = [0 0]; % in cm [left bottom]
            tv.vectorLength = 2; % in cm
            tv.textVectorNormalizedPosition = 1.3;
            tv.fontSize = 15; % font size used for axis labels
            tv.fontColor = 'k'; % font color used for axis labels
            tv.lineWidth = 3; % line width used for axis vectors
            tv.lineColor = 'k'; % line color used for axis vectors
            tv.update();
            rotate3d on;
            
            ax = gca;
            ax.SortMethod = 'childorder';
        end
        
        function plotR2(D)
            %Session R2 plot
            
            subplot(1,2,1); hold on
            %time
            t = linspace(-580,1200,90);
            
            ylimit = ceil(max(D.reg.SessR2)*100)+5;
            xpatch = [-300 -300 0 0];
            ypatch = [0 1 1 0].*ylimit;
            p1 = patch(xpatch, ypatch, 'cyan');
            p1.FaceAlpha = 0.2;
            p1.EdgeAlpha = 0;
            
            plot(t, D.reg.SessBounds(1,:)'*100, '--', 'linewidth', 2,'Color',[0 255 109]./255);
            plot(t, D.reg.SessBounds(2,:)'*100, '--', 'linewidth', 2,'Color',[231 0 212]./255);
            plot(t, D.reg.SessR2*100, 'linewidth', 2, 'color', [236 112  22]./255)
            plot([-600,1200], [12,12], 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            
            
            plot([0,0], [0,1].*ylimit, 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            
            
            % cosmetic code
            hLimits = [-600,1200];
            hTickLocations = -600:300:1200;
            hLabOffset = 5;
            hAxisOffset =  -0.014;
            hLabel = "Time (ms)";
            
            vLimits = [0,ylimit];
            vTickLocations = [0 ylimit/2 ylimit];
            vLabOffset = 180;
            vAxisOffset =  -650;
            vLabel = "R^{2} (%)";
            title('LFADS session')
            
            plotAxis = [10 10];
            
            [hp,vp] = getAxesP(hLimits,...
                hTickLocations,...
                hLabOffset,...
                hAxisOffset,...
                hLabel,...
                vLimits,...
                vTickLocations,...
                vLabOffset,...
                vAxisOffset,...
                vLabel, plotAxis);
            
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            text(1220,12,sprintf('%3.0f%%',12),'Color',[0 0 0]);
            text(1220,5,'99 perc. shuff.','Color',[231 0 212]./255);
            text(1220,1,'1 perc. shuff.','Color',[0 255 109]./255);
            
            
            % Avg R2 plot
            
            subplot(1,2,2); hold on
            
            ylimit = 40;
            xpatch = [-300 -300 0 0];
            ypatch = [0 1 1 0].*ylimit;
            p1 = patch(xpatch, ypatch, 'cyan');
            p1.FaceAlpha = 0.2;
            p1.EdgeAlpha = 0;
            
            options.x_axis = t;
            options.alpha      = 0.5;
            options.line_width = 5;
            options.error      = 'sem';
            %             options.handle     = subplot(2,3,3);
            options.color_area = [243 169 114]./255;    % Orange theme
            options.color_line = [236 112  22]./255;
            
            plot_areaerrorbar(D.reg.AvgR2'*100, options);
            
            plot([0,0], [0,1].*ylimit, 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            
            %             line for variance explained by coherence
            plot([-600,1200], [6.32,6.32], 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            
            plot([0,0], [0,1].*ylimit, 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            
            
            
            %             cosmetic code
            hLimits = [-600,1200];
            hTickLocations = -600:300:1200;
            hLabOffset = 2.5;
            hAxisOffset =  -0.011;
            hLabel = "Time (ms)";
            
            vLimits = [0,ylimit];
            vTickLocations = [0 ylimit/2 ylimit];
            vLabOffset = 180;
            vAxisOffset =  -650;
            vLabel = "R^{2} (%)";
            title('Average across sessions')
            
            plotAxis = [1 1];
            
            [hp,vp] = getAxesP(hLimits,...
                hTickLocations,...
                hLabOffset,...
                hAxisOffset,...
                hLabel,...
                vLimits,...
                vTickLocations,...
                vLabOffset,...
                vAxisOffset,...
                vLabel, plotAxis);
            
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            text(1220,6.32,sprintf('%3.2f%%',6.32),'Color',[0 0 0]);
        end
        
        function plotAcc(D)
            
            %Session Acc plot
            
            subplot(1,2,1); hold on
            t = linspace(-580,1200,90);
            ylimit = 40;
            xpatch = [-300 -300 0 0];
            ypatch = [ylimit 100 100 ylimit];
            p1 = patch(xpatch, ypatch, 'cyan');
            p1.FaceAlpha = 0.2;
            p1.EdgeAlpha = 0;
            
            plot(t, D.dec.SessBounds(1,:)'*100, '--', 'linewidth', 2,'Color',[0 255 109]./255);
            plot(t, D.dec.SessBounds(2,:)'*100, '--', 'linewidth', 2,'Color',[231 0 212]./255);
            plot(t, D.dec.SessAcc*100, 'linewidth', 2, 'color', [236 112  22]./255)
            plot([0,0], [ylimit,100], 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            yline(50, 'k--', 'linewidth', 2);
            % title('Accuracy of LFADS session', 'fontsize', 30)
            
            % cosmetic code
            hLimits = [-600,1200];
            hTickLocations = -600:300:1200;
            hLabOffset = 5;
            hAxisOffset =  ylimit;
            hLabel = "Time (ms)";
            
            vLimits = [ylimit,100];
            vTickLocations = [ylimit ylimit+30 100];
            vLabOffset = 180;
            vAxisOffset =  -650;
            vLabel = "Accuracy (%)";
            
            plotAxis = [10 10];
            
            [hp,vp] = getAxesP(hLimits,...
                hTickLocations,...
                hLabOffset,...
                hAxisOffset,...
                hLabel,...
                vLimits,...
                vTickLocations,...
                vLabOffset,...
                vAxisOffset,...
                vLabel, plotAxis);
            
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            text(1220,50,sprintf('%3.0f%%',50),'Color',[0 0 0]);
            text(1220,53.5,'99 perc. shuff.','Color',[231 0 212]./255);
            text(1220,46.5,'1 perc. shuff.','Color',[0 255 109]./255);
            title('Single session accuracy')
            
            
            
            % Avg Acc plot
            
            subplot(1,2,2); hold on
            
            yLower = 40;
            yUpper = 80;
            xpatch = [-300 -300 0 0];
            ypatch = [yLower yUpper yUpper yLower];
            p1 = patch(xpatch, ypatch, 'cyan');
            p1.FaceAlpha = 0.2;
            p1.EdgeAlpha = 0;
            
            options.x_axis = t;
            options.alpha      = 0.5;
            options.line_width = 5;
            options.error      = 'sem';
            %             options.handle     = subplot(2,3,6);
            options.color_area = [243 169 114]./255;    % Orange theme
            options.color_line = [236 112  22]./255;
            
            plot_areaerrorbar(D.dec.AvgAcc'*100, options);
            plot([0,0], [yLower,yUpper], 'color', [0 0 0], 'linestyle', '--', 'linewidth',2)
            yline(50, 'k--', 'linewidth', 2);
            % title('Average Accuracy', 'fontsize', 30)
            
            
            % cosmetic code
            hLimits = [-600,1200];
            hTickLocations = -600:300:1200;
            hLabOffset = 3;
            hAxisOffset =  yLower - 1;
            hLabel = "Time (ms)";
            
            vLimits = [yLower,yUpper];
            vTickLocations = [yLower (ylimit + yUpper)/2 yUpper];
            vLabOffset = 180;
            vAxisOffset =  -650;
            vLabel = "Accuracy (%)";
            
            plotAxis = [10 10];
            
            [hp,vp] = getAxesP(hLimits,...
                hTickLocations,...
                hLabOffset,...
                hAxisOffset,...
                hLabel,...
                vLimits,...
                vTickLocations,...
                vLabOffset,...
                vAxisOffset,...
                vLabel, plotAxis);
            
            set(gcf, 'Color', 'w');
            axis off;
            axis square;
            axis tight;
            text(1220,50,sprintf('%3.0f%%',50),'Color',[0 0 0]);
            title('Across session accuracy')
        end
        
        
    end
end