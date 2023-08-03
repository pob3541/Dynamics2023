function r = RTbinnedFR(r)

RTp = prctile(r.RT, [0:15:100]);
% lower and upper bound of RT percentile
r.PCdata.RTl = RTp(1:end-1);
r.PCdata.RTr = RTp(2:end);


for cId = 1:length(r.RTl)
    r.FRbinned(:,:,cId,:) = squeeze(nanmean(r.FR(:,r.RT > r.RTl(cId) & r.RT < r.RTr(cId),:,:),2));
end

end