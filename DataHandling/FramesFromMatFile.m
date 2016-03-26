function FramesFromMatFile(FramesPath)
% Code to convert multiple mat-files in RGB to Frame Images and respective
% timestamps
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

MatNames = dir('./RGB/*.mat');
count = 1;
for i = 1:length(MatNames)
    load(['./RGB/',MatNames(i).name]);
    disp([' Loaded ',['./RGB/',MatNames(i).name],'....']);
    for j = 1:length(RGB)
       tsCam(count) = RGB{j}.t;
       imwrite(RGB{j}.image, [FramesPath,num2str(count),'.jpg']); % jpg for space saving!
       disp([FramesPath,num2str(count),'.jpg Written....']);
       count = count+1;
    end
    clear RGB % Just to be more efficient
end
    save('tsCamTestSet.mat','tsCam');
    disp(['tsCamTestSet.mat Saved....']);
end