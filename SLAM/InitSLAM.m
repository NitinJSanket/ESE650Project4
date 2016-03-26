% Initializes Parameters for SLAM
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

% Local Map Parameters
LMAP.res   = 0.1;% m
LMAP.xmin  = -30;% m
LMAP.ymin  = -30;% m
LMAP.xmax  =  30;% m
LMAP.ymax  =  30;% m
LMAP.sizex  = ceil((LMAP.xmax - LMAP.xmin) / LMAP.res + 1); % cells
LMAP.sizey  = ceil((LMAP.ymax - LMAP.ymin) / LMAP.res + 1);
LMAP.map = zeros(LMAP.sizex,LMAP.sizey,'int8');  % char or int8
LXIm = LMAP.xmin:LMAP.res:LMAP.xmax; % x-positions of each pixel of the map
LYIm = LMAP.ymin:LMAP.res:LMAP.ymin; % y-positions of each pixel of the map

% Global Map Parameters
GMAP.res   = LMAP.res;% m
GMAP.xmin  = -50;% m
GMAP.ymin  = -50;% m
GMAP.xmax  =  50;% m
GMAP.ymax  =  50;% m
GMAP.sizex  = ceil((GMAP.xmax - GMAP.xmin) / GMAP.res + 1); % cells
GMAP.sizey  = ceil((GMAP.ymax - GMAP.ymin) / GMAP.res + 1);
GMAP.map = zeros(GMAP.sizex,GMAP.sizey,'int8');  % char or int8
GXIm = GMAP.xmin:GMAP.res:GMAP.xmax; % x-positions of each pixel of the map
GYIm = GMAP.ymin:GMAP.res:GMAP.ymax; % y-positions of each pixel of the map
OGColorMap = zeros(GMAP.sizex,GMAP.sizey,3); % Let this be double!

% Inverse Sensor Model
% (TUNABLE)!!!!
pZ1Givenm1 = 0.9;
pZ1Givenm0 = 0.1; % But this is not (1-pZ1Givenm1)

logOddOcc = 2.5;%log(pZ1Givenm1/(1-pZ1Givenm1));
logOddFree = logOddOcc/4;%log((1-pZ1Givenm0)/pZ1Givenm0);

% Some LIDAR Parameters
ScanAngles = (-135:0.25:135).*pi/180;
HLidar = 1.41; % m
HHead = 1.26; % m

% Saturation for LogOdds
SatHigh = 100;
SatLow = -SatHigh;

% Particle Parameters
Particle.NParticles = 100; % Number of particles
Particle.StdX = 1; % m
Particle.StdY = Particle.StdX; % m
Particle.StdAng = pi/2; % rad
Particle.Neff = Particle.NParticles*0.4; % Effective number of particles (when to resample!)
Particle.Wts = 1/(Particle.NParticles).*ones(Particle.NParticles,1);
WtsNow = ones(Particle.NParticles,1);

% SLAM Loop Parameters
countMin = 1;
countMax = min(100000,length(tsLidar));
countInc = 10;

% Motion Parameters
Motion.StdX = 0.01*countInc; % 1cm error in X in 1/40s
Motion.StdY = Motion.StdX; % 1cm error in Y in 1/40s
Motion.StdAng = deg2rad(0.5*countInc);  % 1.8degrees error in orientation in 1/40s  pi/300*

% GMAP Positions
XGMAP = GMAP.xmin:GMAP.res:GMAP.xmax; % x-positions of each pixel of the map
YGMAP = GMAP.ymin:GMAP.res:GMAP.ymax; % y-positions of each pixel of the map

% Variables to Store Stuff
BestParticleLog = zeros(length(countMin:countInc:countMax),3);
AllParticlesLog = zeros(Particle.NParticles,3,length(countMin:countInc:countMax));

% Some stuff for images
DMin = 300;
DMax = 3000;

disp(['Using a resolution of ', num2str(GMAP.res),'m for both global and local maps....']);
disp(['Skipping ',num2str(countInc), ' frames per iteration....']);
disp(['Motion Model parameters for (x,y,angle) are set as (', num2str([Motion.StdX,Motion.StdY,Motion.StdAng]),')....']);
disp(['Using ', num2str(Particle.NParticles),' number of particles....']);
if(LowVarianceFlag)
    disp('Using Low Variance Re-sampling....');
else
    disp('Using Random Re-sampling....');
end
if(RPYFlag)
    disp('Using IMU Yaw for Motion Update....');
else
    disp('Using Odom Yaw for Motion Update....');
end
    
