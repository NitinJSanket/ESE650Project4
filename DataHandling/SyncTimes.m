function [Idxs1, Idxs2] = SyncTimes(ts1,ts2)
% Synchronizes the 2 timestamps
% Code by: Nitin J. Sanket, nitinsan@seas.upenn.edu

% First get the slower sequence

if(length(ts1)<=length(ts2))
    Idxs1 = 1:length(ts1);
    for i = 1:length(ts1)
        [~,Idxs2(i)] = min(abs(bsxfun(@minus,ts1(i),ts2)));
    end
else
    Idxs2 = 1:length(ts2);
    for i = 1:length(ts2)
        [~,Idxs1(i)] = min(abs(bsxfun(@minus,ts2(i),ts1)));
    end
end
end