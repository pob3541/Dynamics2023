cd('/home/pierreb/Documents/Code/UrgencyPaper')
load('Olafius.mat')
load('decoderbyRTBins.mat')
Olaf=validOlafSessions; 
Olaf(1:5)=[]; % delete first 5 rows as there are no neurons
vOlaf={Olaf.name}';

names=vertcat({classifier.name})';
%find 51 sessions
exp='_';
for i =1:27% 28:51 for Tibs
    str=names{i,1};
    loc=regexp(str,exp);
    shortNames{i,1}=names{i,1}(loc(1)+1:loc(2)-1);
end


store=[];
for i =1:length(shortNames)
    for vO=1:length(vOlaf)

        if strcmp(vOlaf{vO},shortNames{i})
            store(vO,i)=1;
        else
            %
        end

    end
end
OlafSessions51=find(sum(store,2));
TibsSessions51=118:141; %52:75 + 66 since Tibs comes after

sessions51= [OlafSessions51;TibsSessions51'];

% same 51 sessions as in Tian's decoder

C=AllSess.C(sessions51);
RT=AllSess.b(sessions51);

for sess =1:size(C,1)

        % per session & ST RT and C extraction
%         tmpC=log(vertcat(C{sess,1}{:}));
        tmpC=vertcat(C{sess,1}{:});

        A=[ones(length(tmpC),1),tmpC];
        b=vertcat(RT{sess,1}{:});
        
        %Limit RTs
        logic = b>200 & b < 2000;
        b=b(logic,:);
        A=A(logic,:);
        tmpC=tmpC(logic,:);
        % solve the lin reg per session
        x=A\b;

        % create equation - generate predicted RT per session
        predRT=x(2)*tmpC+x(1);

        % calculate the R^2 per session
        R_sq(sess,1)= 1-(sum((b-predRT).^2))/(sum((b-mean(b)).^2));
        [x2,~,~,~,stats] = regress(b,A); 
        R_sq2(sess,1)=stats(1);
end

mean(R_sq)
mean(R_sq2)

std(R_sq2)


% coherence regression for LFADS session

      tmpC=AllSess.C{118,1}{:};

        A=[ones(length(tmpC),1),tmpC];
        b=AllSess.b{118,1}{:};
        
        %Limit RTs
        logic = b>200 & b < 2000;
        b=b(logic,:);
        A=A(logic,:);
        tmpC=tmpC(logic,:);
        % solve the lin reg per session
        x=A\b;

        % create equation - generate predicted RT per session
        predRT=x(2)*tmpC+x(1);

        % calculate the R^2 per session
        R_sq= 1-(sum((b-predRT).^2))/(sum((b-mean(b)).^2));
        [x2,~,~,~,stats] = regress(b,A); 
        R_sq2=stats(1);



% Statistical testing - from Figure5combined

    %
median(mean(r2,1)')
median(R_sq)

p=signrank(R_sq,mean(r2,1)');

for i = 1:length(r2)
    p_tp(i)=signrank(R_sq,r2(i,:)');
end

%lets choose the prestimulus bin, closest to IC
%90 bins at 20 ms each. 600 ms prestim. 600/20=30. ~30th bin
time=linspace(-600,1200,90)
p_tp(30)

mean(mean(r2(30,:),1))*100
std(mean(r2(30,:),1))*100

mean(R_sq)*100
std(R_sq)*100

% prestimulus spiking R^2 compared to 99th % of shuffled
    %Normality
    hist(prctile(shuffledMean,99)')
    figure;
    hist(trueMean')
    x=prctile(shuffledMean,99)'-trueMean';
    [h,p]=kstest(x)
    
    %Non-parametric test
    p=signrank(prctile(shuffledMean,99)', trueMean')

    mean(trueMean)*100
    std(trueMean')*100


    mean(prctile(shuffledMean,99))*100
    std(prctile(shuffledMean,99))*100

% prestimulus spiking decoder compared to 99th % of shuffled

 %Normality
    hist(prctile(shuffledMean,99)')
    figure;
    hist(trueMean')
    x=prctile(shuffledMean,50)'-trueMean';
    x=mean(shuffledMean)'-trueMean';

    hist(x)
    [h,p]=kstest(x)
    


    %Non-parametric test
    
%     p=signrank(prctile(shuffledMean,50)', trueMean')

        p=signrank(mean(shuffledMean), trueMean')

        mean(trueMean)*100
        std(trueMean')*100


    mean(mean(shuffledMean))
    std(mean(shuffledMean))*100




% %load variables
% C=AllSess.C;
% RT=AllSess.b;
% 
% 
% 
% for sess =1:size(C,1)
%     for st = 1:size(C{sess,1})
% 
%         % per session & ST RT and C extraction
%         tmpC=log10(C{sess,1}{st,1});
%         A=[ones(length(tmpC),1),tmpC];
%         b=RT{sess,1}{st,1};
% 
%          %Limit RTs
%         logic = b>200 & b < 2000;
%         b=b(logic,:);
%         A=A(logic,:);
%         tmpC=tmpC(logic,:);
% 
%         % solve the lin reg per session
%         x=A\b;
% 
%         % create equation - generate predicted RT per session
%         predRT=x(2)*tmpC+x(1);
% 
%         % calculate the R^2 per session
%         R_sq{sess,1}{st,1}= 1-(sum((b-predRT).^2))/(sum((b-mean(b)).^2));
% %         [x2,~,~,~,stats] = regress(b,A); 
%     end
% end
% 
% new=vertcat(R_sq{:});
% mean(vertcat(new{:}))
% 
% OlafR_sq=vertcat(R_sq{1:66});
% OlafR_sq2=mean(vertcat(OlafR_sq{:}))
% 
% TibsR_sq=vertcat(R_sq{67:141});
% TibsR_sq2=mean(vertcat(TibsR_sq{:}))
% 
% 
% 
% C=AllSess.C;
% RT=AllSess.b;
% 
% for sess =1:size(C,1)
% 
%         % per session & ST RT and C extraction
%         tmpC=log(vertcat(C{sess,1}{:}));
%         A=[ones(length(tmpC),1),tmpC];
%         b=vertcat(RT{sess,1}{:});
%         
%         %Limit RTs
%         logic = b>200 & b < 2000;
%         b=b(logic,:);
%         A=A(logic,:);
%         tmpC=tmpC(logic,:);
%         % solve the lin reg per session
%         x=A\b;
% 
%         % create equation - generate predicted RT per session
%         predRT=x(2)*tmpC+x(1);
% 
%         % calculate the R^2 per session
%         R_sq(sess,1)= 1-(sum((b-predRT).^2))/(sum((b-mean(b)).^2));
%         [x2,~,~,~,stats] = regress(b,A); 
%         R_sq2(sess,1)=stats(1);
% end
% 
% mean(R_sq)
% mean(R_sq2)
% 
% OlafR_sq=mean(R_sq2(1:66))
% TibsR_sq=mean(R_sq2(67:141))






