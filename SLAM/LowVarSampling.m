function ParticleState = LowVarSampling(Particle, ParticleState)
% Performs low-variance sampling given the normalized weights and particle
% states
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

%rand(Particle.NParticles,1)
Idxs = mod((rand + [1:Particle.NParticles]'./Particle.NParticles),1);
for particle = 1:Particle.NParticles
ParticleState(particle,:) = ParticleState(find(Idxs(particle)<=cumsum(Particle.Wts),1),:);
end
end