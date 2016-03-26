function [xyzLocs,xyzColor] = Plot3DPointCloud(RGB, D, RGBParams, DParams, R, T, PoseNow, PitchNow)
% Computes 3D Point Cloud
% Code by: Nitin J. Sanket

% DepthImage (D) is rectified has invalid values made as Inf and is of type double!
% RGB Image (RGB) is rectified and is double!

% Project the points into 3D
[uD,vD] = meshgrid(1:size(D,2),1:size(D,1)); % x,y or c,r
OffsetvD = max(max(vD))/2;
OffsetuD = max(max(uD))/2;
vD = round(vD-OffsetvD);
uD = round(uD-OffsetuD);
xAll = uD(:).*D(:)./DParams(1);
yAll = vD(:).*D(:)./DParams(2);
zAll = D(:);


% Transform the 3D Points to 2D (in RGB Camera), applying the projection
% equation!
xyzRGB = [R,T]*[xAll';yAll';zAll';ones(size(xAll))'];

% Get the pixel co-ordinates in the RGB Image
uRGB = ceil(RGBParams(1)*xyzRGB(1,:)./xyzRGB(3,:) + size(RGB,2)/2); % x
vRGB = ceil(RGBParams(2)*xyzRGB(2,:)./xyzRGB(3,:) + size(RGB,1)/2); % y

ValidIdxs = uRGB<size(RGB,2) & uRGB>0 & vRGB<size(RGB,1) & vRGB>0;
uRGB = uRGB(ValidIdxs);
vRGB = vRGB(ValidIdxs);

if(numel(ValidIdxs)<=1)
    disp('No Floor Found, Skipping....');
   return; 
end

CamToOGFrame = [0,0,1;-1,0,0;0,-1,0];
xyzOGFrame = CamToOGFrame*xyzRGB(:,ValidIdxs);
% Convert to mm to m
xyzOGFrame = xyzOGFrame./1000;

% Rotate the points
xyzOGFrameRot = eul2rotm([PoseNow(3),PitchNow,0])*xyzOGFrame;%[cos(PoseNow(3)), -sin(PoseNow(3)), 0;sin(PoseNow(3)), cos(PoseNow(3)), 0; 0, 0, 1]
% Translate to map
xyzOGFrameRot = bsxfun(@plus, xyzOGFrameRot, [PoseNow(1:2),0]');
% Get Linear indexes to get color information
LinearIndRGB = sub2ind([size(RGB,1),size(RGB,2)], vRGB, uRGB);
Red = im2double(RGB(:,:,1));
Green = im2double(RGB(:,:,2));
Blue = im2double(RGB(:,:,3));
Red = Red(:);
Green = Green(:);
Blue = Blue(:);

xyzLocs = xyzOGFrameRot';
xyzColor = [Red(LinearIndRGB),Green(LinearIndRGB),Blue(LinearIndRGB)];
% hold on;
% pcshow(xyzLocs,xyzColor);
% hold off;
end


