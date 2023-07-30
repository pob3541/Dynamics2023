function [errInd,PES_RT]=RTPES(Y,RT,U,buff,type,AllSess)
%buffer # correct around error,should be even
%number, 2,4,6,8, etc

%within 1 Session

switch(type)
    case 'single'
        
Y=double(txt2logic(Y));

%find error pattern with appropriate "buffer"
count=0;
cmp= ones(buff+1,1);
mid=ceil(length(cmp)/2);
cmp(mid)=0;
for i=1:length(Y)-buff
     tmp= Y(i:i+buff,1);
        if sum(tmp==cmp)==length(cmp)
            count=count+1;
        PERTS(count,1)=i;
    else
    end
end

%RT of CRs around Es
RT_PE=[];
for i=1:length(PERTS)
RT_PE(i,:)=RT(PERTS(i,1):PERTS(i,1)+buff,:)';
end


    case 'many'
%Across multiple sessions - have a case switch
%Case - multiple sessions -> cells


for c = 1:length(Y)
    Y{c,1}=double(txt2logic(Y{c,1}));
    R{c,1}=U{c,1}';
    G{c,1}=abs(R{c,1}-(max(U{c,1})+min(U{c,1})));
    Coh{c,1}=(abs(R{c,1}-G{c,1})./(R{c,1}+G{c,1}))*100;
end

%find error pattern with appropriate "buffer"
% count=0;
cmp= ones(buff+1,1);
mid=ceil(length(cmp)/2);
cmp(mid)=0;

for c = 1:length(Y)
    count=0;
    for i=1:length(Y{c,1})-buff
        test= Y{c,1}(i:i+buff,1); % test - current section to compare to cmp to find template for PES
        if sum(test==cmp)==length(cmp)
            count=count+1;
            PERTS{c,1}(count,1)=i; % PERTS captures i's where the desired sequence begins
        else
        end
    end
end

%RT of CRs around Es
PES_RT=[];
for c = 1:length(RT)
    for i=1:length(PERTS{c,1})
        PES_RT{c,1}(i,:)=RT{c,1}(PERTS{c,1}(i,1):PERTS{c,1}(i,1)+buff)';
        Coh_err{c,1}(i,1)=Coh{c,1}(i+(buff/2),1);
        Coh_PE{c,1}(i,1)=Coh{c,1}(i+((buff/2)+1),1);
    end
end


    case 'session'
        
        for sess=1:length(Y)
            for c = 1:length(Y{sess,1})
              Y_logic{sess,1}{c,1}=txt2logic(Y{sess,1}{c,1});
            end
        end
        
    %find error pattern with appropriate "buffer"
        % count=0;
        cmp= ones(buff+1,1);
        mid=ceil(length(cmp)/2);
        cmp(mid)=0;
        PERTS=[];
        
        for sess=1:length(Y_logic)
            for c = 1:length(Y_logic{sess,1})
                count=0;
                for i=1:length(Y_logic{sess,1}{c,1})-buff
                    test= Y_logic{sess,1}{c,1}(i:i+buff,1); % test - current section to compare to cmp to find template for PES
                    if sum(test==cmp)==length(cmp)
                        count=count+1;
                        PERTS{sess,1}{c,1}(count,1)=i; % PERTS captures i's where the desired sequence begins
                    else
                    end
                end
            end
        end
        
        %RT of CRs around Es
        Coh=U;
        PES_RT=[];
        for sess=1:length(PERTS)
            for c = 1:length(PERTS{sess,1})
                for i=1:length(PERTS{sess,1}{c,1})
                    seqSt=PERTS{sess,1}{c,1}(i,1);
                    fullSeq=seqSt:seqSt+buff;
                    errInd.PES_RT{sess,1}{c,1}(i,:)=RT{sess,1}{c,1}(fullSeq)';
%                     err=seqSt+(buff/2);
                    errInd.errSeq{sess,1}{c,1}(i,:)=fullSeq;
%                     Coh_err{sess,1}{c,1}(i,1)=Coh{sess,1}{c,1}(err,1);
%                     Coh_PE{sess,1}{c,1}(i,1)=Coh{sess,1}{c,1}(err+1,1);
                end
            end
        end
        


    case 'session_power'
        Coh_err=[];
        Coh_PE=[];
        for sess=1:length(Y)
            for c = 1:length(Y{sess,1})
              Y_logic{sess,1}{c,1}=txt2logic(Y{sess,1}{c,1});
            end
        end
        
         %find error pattern with appropriate "buffer"
        % count=0;
        cmp_err= [0;1];
        cmp_corr=[1;1];
        errInd.Err=[];
        errInd.Corr=[];

   
        % Find all EC's and all CC's
        for sess=1:length(Y_logic)
            for c = 1:length(Y_logic{sess,1})
                cnt_err=0;
                cnt_corr=0;
                for i=1:length(Y_logic{sess,1}{c,1})-1
                    test= Y_logic{sess,1}{c,1}(i:i+1,1); % test - current section to compare to cmp to find template for PES
                    if all(test==cmp_err)
                        cnt_err=cnt_err+1;
                        errInd.Err{sess,1}{c,1}(cnt_err,1)=i; % PERTS captures i's where the desired sequence begins
                    elseif all(test==cmp_corr)
                        cnt_corr=cnt_corr+1;
                        errInd.Corr{sess,1}{c,1}(cnt_corr,1)=i; %
                    else
                    end
                end
            end
        end
        
 %Find CC's to match with EC's        
   for sess=1:length(errInd.Err)
       for c=1:length(errInd.Err{sess,1})
           i=1;
           errInd.errCorrMatch{sess,1}{c,1}=[];
           buff=2;
           back=0;
           while length(errInd.errCorrMatch{sess,1}{c,1})<length(errInd.Err{sess,1}{c,1})
               test=errInd.Err{sess,1}{c,1}(i)-buff;
               if any(test==errInd.Corr{sess,1}{c,1}) & ~any(test==errInd.errCorrMatch{sess,1}{c,1})
                   errInd.errCorrMatch{sess,1}{c,1}(i,1)=test;
                   buff=2;
                   i=i+1;
               else
                   buff=buff+1;
                   if buff>max(errInd.Err{sess,1}{c,1})
                       corrSort=sort(errInd.Corr{sess,1}{c,1},'descend');
                       errInd.errCorrMatch{sess,1}{c,1}(i,1)=corrSort(1+back);
                       i=i+1;
                       buff=2;
                       back=back+1;
                   else
                   end
               end
           end
       end
   end
  
   errInd.errCorrMatchAll=[];
   for sess=1:length(errInd.Err)
       for c=1:length(errInd.Err{sess,1})
           errInd.errCorrMatchAll{sess,1}{c,1}=[errInd.errCorrMatch{sess,1}{c,1},errInd.errCorrMatch{sess,1}{c,1}+1 ...
               errInd.Err{sess,1}{c,1},errInd.Err{sess,1}{c,1}+1];
       end
   end


        %RT of CRs around Es
        Coh=U;
        PES_RT=[];
        for sess=1:length(errInd.Err)
            for c = 1:length(errInd.Err{sess,1})
                    errInd.PES_CCEC_RT{sess,1}{c,1}=RT{sess,1}{c,1}(errInd.errCorrMatchAll{sess,1}{c,1});
                end
            end
        

case 'CCE_ECC'
%Find all CCEs and ECCs for neural data
Errs_neur = AllSess.errInd.Err;
for sess=1:141
    for st= 1: length(Errs_neur{sess,1})
        cntECC=0;
        cntCCE=0;
        for tr=1: length(Errs_neur{sess,1}{st,1})
            errLoc=Errs_neur{sess,1}{st,1}(tr,1);
            if errLoc+2 > length(AllSess.Y_logic{sess,1}{st,1})
                %do nothing
            else
                ECC_tmp=AllSess.Y_logic{sess,1}{st,1}(errLoc:errLoc+2)';
                if ECC_tmp == [0,1,1]
                    cntECC=cntECC+1;
                    ECC{sess,1}{st,1}(cntECC,:)=errLoc;
                    ECC_NeurLocs{sess,1}{st,1}(cntECC,:)=errLoc:errLoc+2;

                else
                    %do nothing
                end
                if errLoc-2 < 1
                    %do nothing
                else
                    CCE_tmp=AllSess.Y_logic{sess,1}{st,1}(errLoc-2:errLoc)';
                    if CCE_tmp == [1,1,0]
                        cntCCE=cntCCE+1;
                        CCE{sess,1}{st,1}(cntCCE,:)=errLoc;
                        CCE_NeurLocs{sess,1}{st,1}(cntCCE,:)=errLoc-2:errLoc;
                    else
                        %do nothing
                    end
                end
            end
        end
    end
end

%intersection of CCE and ECC and left overs

for sess =1:141
    for st = 1: length(ECC{sess,1})
        interECC_CCE=intersect(ECC{sess,1}{st,1},CCE{sess,1}{st,1});
        diff=length(ECC{sess,1}{st,1})-length(CCE{sess,1}{st,1});
        if diff > 0
            moreECC=setdiff(ECC{sess,1}{st,1},CCE{sess,1}{st,1});
            lessCCE=setdiff(CCE{sess,1}{st,1},interECC_CCE);
            extra=[lessCCE-2, lessCCE-1, moreECC(1:length(lessCCE)),moreECC(1:length(lessCCE))+1];
            CCE_ECC{sess,1}{st,1}=[[interECC_CCE-2,interECC_CCE-1,interECC_CCE,interECC_CCE+1];extra];
        elseif diff < 0
            moreCCE=setdiff(CCE{sess,1}{st,1},ECC{sess,1}{st,1});
            lessECC=setdiff(ECC{sess,1}{st,1},interECC_CCE);
            extra=[moreCCE(1:length(lessECC))-2, moreCCE(1:length(lessECC))-1, lessECC,moreECC+1];
            CCE_ECC{sess,1}{st,1}=[[interECC_CCE-2,interECC_CCE-1,interECC_CCE,interECC_CCE+1];extra];
        elseif diff == 0
            %Still have to find extra trials
            diffECC=setdiff(ECC{sess,1}{st,1},interECC_CCE);
            diffCCE=setdiff(CCE{sess,1}{st,1},interECC_CCE);
            extra=[diffCCE-2, diffCCE-1, diffECC,diffECC+1];
            CCE_ECC{sess,1}{st,1}=[[interECC_CCE-2,interECC_CCE-1,interECC_CCE,interECC_CCE+1];extra];
        end
    end
end
end