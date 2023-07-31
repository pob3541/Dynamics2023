function [stats]=RTstats(CCEC_RT)

%ks- test indicates the non-normality of the difference between the two
%distributions
figure;histogram(CCEC_RT(:,1)-CCEC_RT(:,2));
figure;histogram(CCEC_RT(:,2)-CCEC_RT(:,4));
h1= kstest(CCEC_RT(:,2)-CCEC_RT(:,4));
h2=kstest(CCEC_RT(:,2)-CCEC_RT(:,4));
if h1 == 1 || h2==1
    disp("A distribution is not normal, performing ranksum");
    stats.p.CEC = ranksum(CCEC_RT(:,2),CCEC_RT(:,4));
    stats.p.CC = ranksum(CCEC_RT(:,1),CCEC_RT(:,2));
elseif h1 == 0 && h2 ==0
    disp("Distributions are normal performing t-tests");
    stats.p.CEC = ttest(CCEC_RT(:,2),CCEC_RT(:,4));
    stats.p.CC = ttest(CCEC_RT(:,1),CCEC_RT(:,2));
end

stats.Mean=round(mean(CCEC_RT,'omitnan'));
stats.Median=round(median(CCEC_RT,'omitnan'));
stats.SD=round(std(CCEC_RT,'omitnan'));

end