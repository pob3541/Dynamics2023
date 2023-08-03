function r = simulateNeurons(r,type, varargin)
%
%
r.simType = type;

cprintf('cyan',sprintf('-----------------\n Simulating %d Neurons from %s, %d trials per neuron \n', ...
    r.params.nNeurons, r.simType, r.params.nTrials));

nF = r.choice1Mult;
nF2 = r.choice2Mult;
for neuronId = 1:r.params.nNeurons
    if rand < r.RTfraction
        baseFR = 3*rand+2;
        baseline = 0;
    else
        baseFR = 0;
        baseline = 5;
    end
    if mod(neuronId, 10) == 0
        cprintf('magenta',sprintf('%d.', neuronId));
    end
    for nChoice = 1:2
        for nTrialId = 1:length(r.RT)
            tLag = r.params.tStart + r.params.tLatency + 0.2*r.RT(nTrialId);
            
            switch(r.simType)
                case 'RT'
                    switch(nChoice)
                        case 1
                            rate = baseline  + ((baseFR)./r.RT(nTrialId) + nF(neuronId)*max((r.time-tLag)./(r.RT(nTrialId)),0) + max(r.CISmult*(r.time-tLag),0));
                        case 2
                            rate = baseline +  (baseFR)./r.RT(nTrialId) - nF2(neuronId)*max((r.time-tLag)./((r.RT(nTrialId))),0) + max(r.CISmult*(r.time-tLag),0);
                            rate(rate < 0) = 0;
                    end
                    
                case 'BiasedChoice'
                    
                    switch(nChoice)
                        case 1
                            rate = baseline + 4*rand + max(r.CISmult*(r.time-tLag),0) + nF(neuronId)*max((r.time-tLag)./r.RT(nTrialId),0);
                        case 2
                            rate = baseline + 2*rand + max(r.CISmult*(r.time-tLag),0)- nF2(neuronId)*max((r.time-tLag)./r.RT(nTrialId),0);
                            rate(rate < 0) = 0;
                    end
                    
                case 'UnbiasedChoice'
                    
                    switch(nChoice)
                        case 1
                            rate = baseline + 2*rand + max(r.CISmult*(r.time-tLag),0) + nF(neuronId)*max((r.time-tLag)./r.RT(nTrialId),0);
                        case 2
                            rate = baseline + 2*rand + max(r.CISmult*(r.time-tLag),0)- nF2(neuronId)*max((r.time-tLag)./r.RT(nTrialId),0);
                            rate(rate < 0) = 0;
                    end
                    
                    
            end
            
            %             spikes(nTrials).times = generateInhomRenewal(time,rate,'process','gamma','shape',4,'scale',1/4);
            spikes(nTrialId).times = generateInhomRenewal(r.time,rate,'process','poisson');
        end
        
        [~,t,~,RR] = psthcc(spikes, 0.02, 'n',[0 1.6],2,[0:.001:1.6]);
        r.FRsim(neuronId, :,nChoice, :) = RR;
    end
end

r.tAxis = t;



end
