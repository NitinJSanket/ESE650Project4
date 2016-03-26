function PlotTriangle2D(Centroid, Yaw, ApexAngle, L, FlipFlag)
% Plots the robot as a triangle in 2D
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

if(nargin<5)
    FlipFlag = 1;
    if(nargin<4)
        L = 10;
        if(nargin<3)
            ApexAngle =  pi/6;
        end
    end
end

TrianglePts = [0,-L*sin(ApexAngle/2),L*sin(ApexAngle/2);...
    2*L*cos(ApexAngle)/3, -L*cos(ApexAngle)/3, -L*cos(ApexAngle)/3];
if(FlipFlag)
    TrianglePts = flipud(TrianglePts);
end
R = [cos(Yaw), -sin(Yaw); sin(Yaw), cos(Yaw)];
TrianglePts = bsxfun(@plus, R*TrianglePts, Centroid);
hold on;
fill(TrianglePts(1,:),TrianglePts(2,:),'g');
hold off;
end