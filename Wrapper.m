%% Wrapper for 3D-S 2D-LAM (SLAM) from Lidar and Kinect Data for a Humanoid Robot
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)
% NOTE: CODE CLEARS ALL VARIABLES IN THE WORKSPACE!
% Activate the required flags

clc
clear all
close all
warning off;

% First setup right paths
addpath(genpath('./'));
%% Setup the Flags Needed
LowVarianceFlag = 0; % Do you want to do low variance resampling? Default is Random Sampling
RPYFlag = 0; % Do you want to use RPY Data for Attitude? Default uses Odom Yaw
ImgFlag = 0; % Do you want to get a floor textured map at the output? (Switch off if you have no RGB Data!)
PCPath = 'F:\PC\';
PCFlag = 0; % Do you want a full 3D Point Cloud at the end? (VERY SLOW AND USES A LOT OF RAM AND STORAGE! BEWARE!)
% Saves a lot of files in PCPath (~4GB)
% Place the RGB mat files in ./RGB/ for a particular dataset only, this
% folder should not contain any other files
FramesPath = './Frames/'; % Create a Folder called frames here
FramesFromMatFlag = 0; % Convert Mat Files in the folder ./RGB/ to a Frames (saved in specified FramesPath folder)
VideoFlag = 0; % Record screencapture video, cannot do anything else when the code runs if this is on!

%% First convert Frames if necessary
if(FramesFromMatFlag && ImgFlag)
    FramesFromMatFile(FramesPath);
end

%% Load required data
SaveName = datestr(datetime('now'),'HH_MM_SS');
if(VideoFlag)
    Vid = VideoWriter(['VideoTestSet_',SaveName,'.avi']);
    open(Vid);
end
load('./JointLidar/test_joint.mat');
load('./JointLidar/test_lidar.mat');
tsJoint = ts';
clear ts
tsLidar = zeros(length(lidar),1);
for count = 1:length(lidar)
    tsLidar(count) = lidar{count}.t;
end
if(ImgFlag)
    load('tsCamTestSet.mat');
    load('Depth/DEPTH.mat');
    load('exParams.mat');
    IRcamera_Calib_Results;
    RGBcamera_Calib_Results;
    RCam = R;
    TCam = T;
end

disp('Loading Data Complete...');


%% Setup the SLAM Environment
InitSLAM;

disp('SLAM Environment Initialization Complete....');

%% Run the actual SLAM Code
tic
RunSLAM;
toc

%% Display Results
if(ImgFlag)
    imshow(OGColorMapMod);
    title('Wall areas are highlighted in RED, image will disappear after 5secs....');
    pause(5);
    close all
end

if(PCFlag && ImgFlag)
    % Plots the 3D Point Cloud
    % Second Argument to the Plot3DScene function (subsampling for a better
    % visualization!)
    %     TrainSet0: [1:2:170,210]
    %     TrainSet3: [1:5:300,350:50:900]
    %     TestSet  : [1:25:500,550:100:800,1050:10:1841]
    Plot3DScene(PCPath, [1:25:500,550:100:800,1050:10:1841]);
    % Save the 3D Point Cloud as a figure for future use!
    savefig(gcf,'PCTest.fig','compact'); % Compact saves a lot of space, though the point cloud is still about 500MB~1GB
    disp('PCTest.fig Saved....');
end
