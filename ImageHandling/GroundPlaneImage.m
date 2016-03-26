function OGColorMap = GroundPlaneImage(RGB, D, RGBParams, DParams, R, T, OGColorMap, PoseNow, PitchNow, GMAP, GroundThld)
% Pastes the ground plane image onto OG Map
% Code by: Nitin J. Sanket

% DepthImage (D) is rectified has invalid values made as Inf and is of type double!
% RGB Image (RGB) is rectified and is double!

if(nargin<11)
    GroundThld = 0.1; % Default Value!
end

% Project the points into 3D
[uD,vD] = meshgrid(1:size(D,2),1:size(D,1)); % x,y or c,r
OffsetvD = max(max(vD))/2;
OffsetuD = max(max(uD))/2;
vD = round(vD-OffsetvD);
uD = round(uD-OffsetuD);
xAll = uD(:).*D(:)./DParams(1);
yAll = vD(:).*D(:)./DParams(2);
zAll = D(:);

% Try finding the ground
GroundNormal = [1, 0, 0; 0, cos(PitchNow), -sin(PitchNow);0, sin(PitchNow), cos(PitchNow)]*[0,-1,0]';
GroundNormal(4) = 1260 + 70*cos(PitchNow);

GroundPts = sum(bsxfun(@times, GroundNormal,[xAll,yAll,zAll,ones(size(uD(:)))]'),1)<=GroundThld;


% Transform the 3D Points to 2D (in RGB Camera), applying the projection
% equation!
xyzRGB = [R,T]*[xAll(GroundPts)';yAll(GroundPts)';zAll(GroundPts)';ones(size(xAll(GroundPts)))'];

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
% Convert to m from mm
xyzOGFrame = xyzOGFrame./1000;

% Rotate the points
xyzOGFrameRot = [cos(PoseNow(3)), -sin(PoseNow(3));sin(PoseNow(3)), cos(PoseNow(3))]*xyzOGFrame(1:2,:);
% Translate to map
xyzOGFrameRot = bsxfun(@plus, xyzOGFrameRot, PoseNow(1:2)');
% Convert to resolution
xyzOGFrameRot = xyzOGFrameRot./GMAP.res;
% Translate it to GMAP 
xyzOGFrameRot = ceil(bsxfun(@plus,xyzOGFrameRot(1:2,:),[GMAP.sizex/2;GMAP.sizey/2]));
LinearInd = sub2ind([size(OGColorMap,1),size(OGColorMap,2)], xyzOGFrameRot(2,:), xyzOGFrameRot(1,:));

LinearIndRGB = sub2ind([size(RGB,1),size(RGB,2)], vRGB, uRGB);
Red = im2double(RGB(:,:,1));
Green = im2double(RGB(:,:,2));
Blue = im2double(RGB(:,:,3));
Red = Red(:);
Green = Green(:);
Blue = Blue(:);

C1R = OGColorMap(:,:,1);
C1G = OGColorMap(:,:,2);
C1B = OGColorMap(:,:,3);
C1R(LinearInd) = Red(LinearIndRGB);
C1G(LinearInd) = Green(LinearIndRGB);
C1B(LinearInd) = Blue(LinearIndRGB);
OGColorMap = cat(3, C1R, C1G, C1B);
end


