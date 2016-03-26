function ParticleState = UniformResampling(Particle, ParticleState)
% Performs uniform sampling given the normalized weights and particle
% states
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

CumSum = cumsum(Particle.Wts);
for particle = 1:Particle.NParticles
    ParticleState(particle,:) = ParticleState(find(rand<=CumSum,1),:);
end
end