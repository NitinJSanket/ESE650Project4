% Runs the SLAM Code from Wrapper after the required data is loaded and all
% the necessary flags are set
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

PCInc = 1;
%% Sync Lidar and Joint times
[IdxsLidar, IdxsJoint] = SyncTimes(tsLidar,tsJoint);

%% Extract the Odom
Odom = zeros(length(IdxsLidar),3);
RPYYaw = zeros(length(IdxsLidar),1);
for count = 1:length(IdxsLidar)
    Odom(count,:) = lidar{IdxsLidar(count)}.pose;
    RPYYaw(count) = lidar{IdxsLidar(count)}.rpy(3);
end

%% SLAM Code
PrevSyncedIdx = 0;
for count = countMin:countInc:countMax
    if(count==countMin)
        ScanAngles = (-135:0.25:135).*pi/180;
        Pitch = head_angles(2,IdxsJoint(count));
        ScanNow = lidar{IdxsLidar(count)}.scan;
        ScanNow(ScanNow>30 | ScanNow<0.1) = 0; % Invalid Range of Lidar
        ScanNow = RemoveGroundHits(ScanNow, ScanAngles, Pitch, HLidar, HHead);
        ScanNowIdxs = (ScanNow~=0); % Remove Invalid Hits
        [ScanNowCart(1,:), ScanNowCart(2,:)] = pol2cart(ScanAngles, ScanNow);
        ScanNow = ScanNow(ScanNowIdxs);
        ScanAngles = ScanAngles(ScanNowIdxs);
        % Correct for tilt/skew
        ScanNowCart(1,:) = ScanNowCart(1,:).*cos(Pitch);
        % convert from meters to cells
        ScanNowCartCell = zeros(size(ScanNowCart));
        ScanNowCartCell(1,:) = ceil((ScanNowCart(1,:)) ./ LMAP.res);
        ScanNowCartCell(2,:) = ceil((ScanNowCart(2,:)) ./ LMAP.res);
        
        [XObserved, YObserved] = getMapCellsFromRay(0,0, ScanNowCartCell(1,:), ScanNowCartCell(2,:));
        LinearInd = sub2ind([LMAP.sizey,LMAP.sizex], YObserved + ceil(LMAP.sizey/2), XObserved + ceil(LMAP.sizex/2));
        LMAP.map(LinearInd) = -logOddFree;
        LinearInd = sub2ind([LMAP.sizey,LMAP.sizex],ScanNowCartCell(2,:)+ ceil(LMAP.sizey/2), ScanNowCartCell(1,:)+ ceil(LMAP.sizey/2));
        LMAP.map(LinearInd) = logOddOcc;
        
        PoseNow = Odom(count,:);
        % Translate LMAP now
        GMAP.map(ceil(GMAP.sizey/2 - LMAP.sizey/2 + PoseNow(2)/LMAP.res):ceil(GMAP.sizey/2 + LMAP.sizey/2 - 1 + PoseNow(2)/LMAP.res),...
            ceil(GMAP.sizex/2 - LMAP.sizex/2 + PoseNow(1)/LMAP.res):ceil(GMAP.sizex/2 + LMAP.sizex/2 - 1 + PoseNow(1)/LMAP.res)) = LMAP.map;
        
        % Saturate the readings
        GMAP.map(GMAP.map>SatHigh)=SatHigh;
        GMAP.map(GMAP.map<SatLow)=SatLow;
        
        % Initialize Particles
        ParticleState = zeros(Particle.NParticles, 3);
        continue;
    end
    
    
    % Compute change in state with respect to previous state
    DeltaState = Odom(count,:)-Odom(count-countInc,:);
    if(RPYFlag)
        DeltaState(3) = RPYYaw(count)-RPYYaw(count-countInc);
    end
    % Take next scan
    ScanAngles = (-135:0.25:135).*pi/180;
    Pitch = head_angles(2,IdxsJoint(count));
    ScanNow = lidar{IdxsLidar(count)}.scan;
    ScanNow(ScanNow>30 | ScanNow<0.1) = 0; % Invalid Range of Lidar
    
    ScanNow = RemoveGroundHits(ScanNow, ScanAngles, Pitch, HLidar, HHead);
    ScanNowIdxs = (ScanNow~=0); % Remove Invalid Hits
    [ScanNowCart(1,:), ScanNowCart(2,:)] = pol2cart(ScanAngles, ScanNow);
    
    ScanNow = ScanNow(ScanNowIdxs);
    ScanAngles = ScanAngles(ScanNowIdxs);
    % Correct for tilt/skew
    ScanNowCart(1,:) = ScanNowCart(1,:).*cos(Pitch);
    % convert from meters to cells
    ScanNowCartCell = zeros(size(ScanNowCart));
    ScanNowCartCell(1,:) = ceil((ScanNowCart(1,:)) ./ LMAP.res);
    ScanNowCartCell(2,:) = ceil((ScanNowCart(2,:)) ./ LMAP.res);
    
    % Reinitialize LMAP to zeros
    LMAP.map = zeros(LMAP.sizex,LMAP.sizey,'int8');  % char or int8
    [XObserved, YObserved] = getMapCellsFromRay(0,0, ScanNowCartCell(1,:), ScanNowCartCell(2,:));
    LinearInd = sub2ind([LMAP.sizey,LMAP.sizex], YObserved + ceil(LMAP.sizey/2), XObserved + ceil(LMAP.sizex/2));
    LMAP.map(LinearInd) = -logOddFree;
    LinearInd = sub2ind([LMAP.sizey,LMAP.sizex],ScanNowCartCell(2,:)+ ceil(LMAP.sizey/2), ScanNowCartCell(1,:)+ ceil(LMAP.sizey/2));
    LMAP.map(LinearInd) = logOddOcc;
    
    
    for particle = 1:Particle.NParticles
        % Motion Update
        ParticleState(particle,:) = MotionUpdate(ParticleState(particle,:), DeltaState, Odom(count-countInc,3),...
            (rand(1,3)-0.5).*[Motion.StdX,Motion.StdY,Motion.StdAng]);
        % Align Local Map for current particle and find the correlation
        % between the local and global map
        Particle.Wts(particle) = Particle.Wts(particle)*CompCorr(GMAP, XGMAP, YGMAP, double(ScanNowCart), head_angles(1,IdxsJoint(count)), ParticleState(particle,:));
    end
    
    % Normalize the particle weights
    Particle.Wts = Particle.Wts/sum(Particle.Wts);
    
    % Choose the best particle
    [~, BestIdx] = max(Particle.Wts);
    
    % Compute Local Map for Best Particle
    BestPose = ParticleState(BestIdx,:);
    
    % Update Map using the best particle
    GMAP = UpdateGMAP(GMAP, LMAP, ScanNowCart, [logOddFree, logOddOcc], BestPose+[0,0,head_angles(1,IdxsJoint(count))], SatLow, SatHigh);
    
    % Compute effective number of particles and decide wether to resample
    % or not
    NEffNow = (sum(Particle.Wts).^2/(sum(Particle.Wts.^2)));
    if(NEffNow<=Particle.Neff)
        % Resampling
        if(LowVarianceFlag)
            ParticleState = LowVarSampling(Particle, ParticleState);
        else
            ParticleState = UniformResampling(Particle, ParticleState);
        end
        Particle.Wts = 1/(Particle.NParticles).*ones(Particle.NParticles,1);
        disp(['Resampled as effective particles dropped to ', num2str(NEffNow)]);
    end
    
    if(ImgFlag)
        % Get the corresponding RGB and Depth Image!
        [~,SyncedIdx] = min(abs(bsxfun(@minus,tsLidar(count),tsCam)));
        if(SyncedIdx~=PrevSyncedIdx) % Update Now!
            D = medfilt2(DEPTH{SyncedIdx}.depth);
            D = double(D);
            D(D<DMin | D>DMax) = Inf;
            RGBImg = im2double(imread([FramesPath,num2str(SyncedIdx),'.jpg']));
            if(PCFlag)
                [xyzLocs,xyzColor] = Plot3DPointCloud(RGBImg, D, fcRGB, fcD, RCam, TCam, BestPose+[0,0,head_angles(1,IdxsJoint(count))], head_angles(2,IdxsJoint(count)));
                save([PCPath,SaveName,num2str(PCInc),'.mat'],'xyzLocs','xyzColor','-v7.3');
                disp(['Saved ',PCPath,SaveName,num2str(PCInc),'.mat']);
            end
            OGColorMap = GroundPlaneImage(RGBImg, D, fcRGB, fcD, RCam, TCam, OGColorMap, BestPose+[0,0,head_angles(1,IdxsJoint(count))], head_angles(2,IdxsJoint(count)), GMAP, 0.2);
            PrevSyncedIdx = SyncedIdx;
            PCInc = PCInc+1;
        end
    end
    
    if(ImgFlag)
        subplot 121
    end
    imagesc(-GMAP.map);
    colormap gray
    title(['GMAP ', num2str(BestPose), ', ', num2str(NEffNow)]);
    hold on;
    BestAng = (BestPose(3)+head_angles(1,IdxsJoint(count)));
    ScanNowCart = [cos(BestAng), -sin(BestAng); sin(BestAng), cos(BestAng)]*double(ScanNowCart);
    plot(GMAP.sizex/2+ScanNowCart(1,:)/LMAP.res+BestPose(1)/LMAP.res, GMAP.sizey/2+ScanNowCart(2,:)/LMAP.res+BestPose(2)/LMAP.res,'r.');
    PlotTriangle2D(BestPose(1:2)'/LMAP.res+[GMAP.sizex/2,GMAP.sizey/2]', BestPose(3)+head_angles(1,IdxsJoint(count)),pi/4,25,1);
    % Plot Robot Path!
    hold on;
    plot(BestParticleLog(1:(count-1)/countInc+1,1)/LMAP.res+GMAP.sizex/2,GMAP.sizey/2+BestParticleLog(1:(count-1)/countInc+1,2)/LMAP.res,'b.','MarkerSize',5);
    hold off;
    axis equal
    suptitle([num2str(count), ' of ', num2str(countMax)]);
    if(ImgFlag)
        subplot 122
        imshow(OGColorMap);
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    drawnow;
    if(VideoFlag)
        writeVideo(Vid, getframe(gcf));
    end
    
    % Log Stuff
    BestParticleLog((count-1)/countInc+1,:) = BestPose+[0,0,head_angles(1,IdxsJoint(count))];
    AllParticlesLog(:,:,(count-1)/countInc+1) = ParticleState;
    
end

if(VideoFlag)
    close(Vid);
end

save(['DataLogTest_',SaveName,'.mat'],'BestParticleLog','AllParticlesLog','GMAP','Motion','Particle','logOddOcc','logOddFree','countInc');
disp(['DataLogTest_',SaveName,'.mat Saved...']);

close all
imshow(-GMAP.map);
colormap gray;
saveas(gcf, ['GMAP',SaveName,'.jpg']);
disp(['GMAP',SaveName,'.jpg Saved...']);
toc

if(ImgFlag)
    OGColorMapMod = MaskMap(GMAP, OGColorMap);
    imwrite(OGColorMapMod,['OGColorMapLogTest_',SaveName,'.png']);
end