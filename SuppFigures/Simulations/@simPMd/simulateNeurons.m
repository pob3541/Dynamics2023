function r = simulateNeurons(r,type, varargin)
%
%
r.simType = type;

cprintf('cyan',sprintf('-----------------\n Simulating %d Neurons from %s, %d trials per neuron \n', ...
    r.params.nNeurons, r.simType, r.params.nTrials));

nF1 = r.FRparams.choice(1,:);
nF2 = r.FRparams.choice(2,:);

time = r.timeParams.time;

for neuronId = 1:r.params.nNeurons
    if rand < r.params.RTfraction
        baseFR = 3*rand+2;
        baseline = 0;
    else
        baseFR = 0;
        baseline = 5;
    end
    if mod(neuronId, 20) == 0
        cprintf('magenta',sprintf('%d.', neuronId));
    end
    for nChoice = 1:2
        for nTrialId = 1:length(r.RT)
            tLag = r.params.tStart + r.params.tLatency + 0.2*r.RT(nTrialId);
            tCorrected = time - tLag;
            CIS = max(r.FRparams.CISmult*tCorrected,0);
            choiceRamp = max(tCorrected./((r.RT(nTrialId))),0);
            
            switch(r.simType)
                case 'RT'
                    bFR = (baseFR)./r.RT(nTrialId);
                    
                    
                    switch(nChoice)
                        case 1
                            rate = baseline  + (bFR...
                                + nF1(neuronId)*choiceRamp...
                                + CIS);
                        case 2
                            rate = baseline +  (baseFR)./r.RT(nTrialId)...
                                - nF2(neuronId)*choiceRamp...
                                + CIS;
                            rate(rate < 0) = 0;
                    end
                    
                case 'BiasedChoice'
                    switch(nChoice)
                        case 1
                            rate = baseline + 4*rand + CIS + nF1(neuronId)*choiceRamp;
                        case 2
                            rate = baseline + 2*rand + CIS- nF2(neuronId)*choiceRamp;
                            rate(rate < 0) = 0;
                    end
                    
                case 'UnbiasedChoice'
                    
                    switch(nChoice)
                        case 1
                            rate = baseline + 2*rand + CIS + nF1(neuronId)*choiceRamp;
                        case 2
                            rate = baseline + 2*rand + CIS -nF2(neuronId)*choiceRamp;
                            rate(rate < 0) = 0;
                    end
                    
                    
            end
            
            %             spikes(nTrials).times = generateInhomRenewal(time,rate,'process','gamma','shape',4,'scale',1/4);
            spikes(nTrialId).times = generateInhomRenewal(r.timeParams.time,rate,'process','poisson');
        end
        
        [~,t,~,RR] = psthcc(spikes, 0.02, 'n',[0 r.params.psthTime(end)],2,r.params.psthTime);
        r.FRsim(neuronId, :,nChoice, :) = RR;
    end
end

r.tAxis = t;
r.time = t;



end
