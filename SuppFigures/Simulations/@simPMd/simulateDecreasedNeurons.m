function r = simulateDecreasedNeurons(r)
r.FRdecr = max(10-r.FRsim(1:r.params.nNeurons/2,:,:,:),0);
end