function Scan = RemoveGroundHits(Scan, ScanAngles, Pitch, HLidar, HHead)
% Removes the lidar hits on the ground
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

if(nargin<5)
HLidar = 1.41; % m
HHead = 1.26; % m
end

%         Scan(Scan*sin(head_angles(2,IdxsJoint(count))).*cos(ScanAngles)>=(HLidar-(HLidar-HHead)*cos(head_angles(2,IdxsJoint(count))))) = 0;
Scan(Scan.*sin(Pitch).*cos(ScanAngles)>=(HHead+(HLidar-HHead)*cos(Pitch))) = 0;
end
