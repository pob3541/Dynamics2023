function [y,y2,t,SEM,convVec,centerRT]=plotConv(convMat,choice,C,RT,txt,b1,b2,txt2)%,steps)
%
%
%
%
hold on;
base=100;

switch(txt)
    case 'Coh'
        uniqC=unique(C);
        y2=0;
        for j=1:2
            if j==1
                LS='-';
            else
                LS='--';
            end
            if  strcmp(txt2,'Mov')==1
                b=b1(1);
                LineId = [];
                for i=length(uniqC):-1:1
                    ai=(length(uniqC)-i)+1;%adjust i
                    medianRT(ai)=round(median(RT(C==uniqC(i))))+50; %medianRT per coherence level
                    t{:,ai,j}=(-medianRT(ai):base);
                    y{:,ai,j}=mean(convMat(((abs(b)*1000-medianRT(ai)):(abs(b)*1000+base)),choice==j & C==uniqC(i,1)),2);
                    convVec{:,ai,j}= convMat(((abs(b)*1000-medianRT(ai)):(abs(b)*1000+base)),choice==j & C==uniqC(i,1));
                    SEM{:,ai,j}=sem(convVec{:,ai,j},'omitnan'); %include
                    ShadedError(t{:,ai,j},y{:,ai,j}',1*SEM{:,ai,j}');
                    LineId(ai) = plot(t{:,ai,j},y{:,ai,j},'LineWidth',1.5,'LineStyle',LS);%,'Color',colors{i});
                end
                setLineColors(LineId,'linewidth',3,'linestyle',LS);
            else
                b=b1(2);
                LineId = [];
                for i=length(uniqC):-1:1
                    ai=(length(uniqC)-i)+1;%adjust i
                    medianRT(ai)=round(median(RT(C==uniqC(i)))); %medianRT per coherence level
                    t{:,ai,j}=-base:medianRT(ai);
                    y{:,ai,j}=mean(convMat(((abs(b)*1000-base):(medianRT(ai)+abs(b)*1000)),choice==j & C==uniqC(i,1)),2,'omitnan'); %grouping based on coh level & not RT.NaNs less RT dependent this way. more coh, faster RT in general & more NaNs. however this would shorten what should be longer RTs as well.
                    convVec{:,ai,j}=convMat(((abs(b)*1000-base):(medianRT(ai)+abs(b)*1000)),choice==j & C==uniqC(i,1));
                    SEM{:,ai,j}=sem(convVec{:,ai,j},'omitnan');
                    ShadedError(t{:,ai,j},y{:,ai,j}',1*SEM{:,ai,j}');
                    LineId(ai) =plot(t{:,ai,j},y{:,ai,j},'LineWidth',1.5,'LineStyle',LS);
                end
                setLineColors(LineId,'linewidth',3,'linestyle',LS);
                
            end
        end
        
    case 'RT'
        
        [RTbins, centerRT]=RT_binning(RT);
        y=0;
        for j=1:2
            if j==1
                LS='-';
            else
                LS='--';
            end
            if  strcmp(txt2,'Mov')==1
                b=b1(1);
                LineId = [];
                for i=1:size(RTbins,2)
                    tmpRT=zeros(length(RT),1);
                    tmpRT(RTbins(:,i))=1;
                    cenRT=round(median(centerRT{i,1}))+50;
                    if cenRT >(b2(2)-.1)*1000; %b2(2)-.1*1000; %CHANGED FOR PLOTTING PURPOSES
                        cenRT=(b2(2)-.1)*1000;%b2(2)*1000-1;; %CHANGED FOR PLOTTING PURPOSES
                    else
                    end
                    t{:,i,j}=(-cenRT:base);
                    y2{:,i,j}=mean(convMat(((abs(b)*1000-cenRT):(abs(b)*1000+base)),choice==j & tmpRT==1),2);
                    convVec{:,i,j}= convMat(((abs(b)*1000-cenRT):(abs(b)*1000+base)),choice==j & tmpRT==1);
                    SEM{:,i,j}=sem(convVec{:,i,j},'omitnan'); %include
                    ShadedError(t{:,i,j},y2{:,i,j}',1*SEM{:,i,j}');
                    LineId(i) = plot(t{:,i,j},y2{:,i,j},'LineWidth',1.5,'LineStyle',LS);
                end
                setLineColors(LineId,'linewidth',3,'linestyle',LS);
            else
                b=b1(2);
                LineId = [];
                for i=1:size(RTbins,2)
                    tmpRT=zeros(length(RT),1);
                    tmpRT(RTbins(:,i))=1;
                    cenRT=round(median(centerRT{i,1}));%round(median(RTbins(:,i)));
                    if cenRT > b2(2)*1000
                        cenRT=b2(2)*1000-1;
                    else
                    end
                    t{:,i,j}=(-base:cenRT);
                    y2{:,i,j}=mean(convMat(((abs(b)*1000-base):(abs(b)*1000+cenRT)),choice==j & tmpRT==1),2); %don't omitnan here. will do avgs up to the weakest link. once 1st nan in 1st data set reached, rest data considered NaN and doesn't avg just half of time pts for example.
                    convVec{:,i,j}= convMat(((abs(b)*1000-base):(abs(b)*1000+cenRT)),choice==j & tmpRT==1);
                    SEM{:,i,j}=sem(convVec{:,i,j},'includenan'); %include
                    ShadedError(t{:,i,j},y2{:,i,j}',1*SEM{:,i,j}');
                    LineId(i) = plot(t{:,i,j},y2{:,i,j},'LineWidth',1.5,'LineStyle',LS);
                end
                setLineColors(LineId,'linewidth',3,'linestyle',LS);
            end
        end
        
end
title(txt);ylabel('Spikes /s');xlabel('Time (s)')
end