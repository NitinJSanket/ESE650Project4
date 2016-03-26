function PlotParticles(ParticleState, OrientationFlag)
% Plots the particles given the pose
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

if(nargin<2)
   OrientationFlag = 0; 
end


hold on;
plot(ParticleState(:,1), ParticleState(:,2), 'r.');
if(OrientationFlag)
    hold on;
    quiver(ParticleState(:,1),ParticleState(:,2),cos(ParticleState(:,3)), sin(ParticleState(:,3)));
end
hold off;
end