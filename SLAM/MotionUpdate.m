function ParticleState = MotionUpdate(ParticleState, DeltaState, PrevYaw, Noise)
% Updates the Motion Model
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

    % Delta State is the change in odometry in the robot's unknown global
    % frame!
    % Convert into local Frame
    PoseXYLocalFrame = [cos(PrevYaw), sin(PrevYaw); -sin(PrevYaw), cos(PrevYaw)]*DeltaState(1:2)';
    PoseAngLocalFrame = DeltaState(3);
    % Convert back to our Global Frame
    PoseXYGlobalFrame = [cos(ParticleState(3)), -sin(ParticleState(3));...
                         sin(ParticleState(3)), cos(ParticleState(3))]*PoseXYLocalFrame;
    PoseAngGlobalFrame = PoseAngLocalFrame;
    ParticleState = ParticleState + [PoseXYGlobalFrame;PoseAngGlobalFrame]'+ Noise;
end
