function C = CompCorr(GMAP, XGMAP, YGMAP, ScanNowCart, HeadYaw, PoseNow)
% Computes the correlation between Global Map and the Local Map given Pose and Saturation Thresholds
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

% Align the LocalMap to Global Map with Yaw Correction
RotatedScan = [cos(PoseNow(3)+HeadYaw), -sin(PoseNow(3)+HeadYaw);...
    sin(PoseNow(3)+HeadYaw), cos(PoseNow(3)+HeadYaw)]*ScanNowCart;
% Correct for translation!
RotatedScan = bsxfun(@plus,RotatedScan,[PoseNow(1),PoseNow(2)]');

% Compute the correlation between the algined LMAP and GMAP
GMAPBinary = GMAP.map;
C = map_correlation(int8(GMAPBinary>0),XGMAP,YGMAP,[flipud(RotatedScan);zeros(1,length(RotatedScan))],...
    0,0)+1e-5;
end