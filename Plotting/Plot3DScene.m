function Plot3DScene(FilePath, SamplingIdxs)
% Plots the 3D Point Cloud, needs MATLAB R2015b or higher!, Uses a Lot of
% RAM, atleast 12GB recommended
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

FileNames = dir([FilePath,'*.mat']);
figure,
hold on;
for i = SamplingIdxs
    load([FilePath,FileNames(i).name]);
    pcshow(xyzLocs,xyzColor);
    drawnow;
    clear xyzLocs xyzColor
    disp(i);
end
end