load train_lidar0.mat

theta = 0:0.25:270;
theta = theta*pi/180;

h_f = figure(1);
hold off;

i = 1;
h_a = polar(theta, lidar{i}.scan);

for i=10:10:numel(lidar)
    % remove noisy data out of valid range
    lidar{i}.scan(find(lidar{i}.scan > 30)) = 0;
    polar(theta, lidar{i}.scan);
    title(i);
    %set(h_a, 'YData', lidar{i}.scan);
    drawnow();
%     pause(0.025);
%     i
end
