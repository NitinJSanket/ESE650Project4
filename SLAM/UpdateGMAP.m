function GMAP = UpdateGMAP(GMAP, LMAP, ScanNowCart, LogOdds, PoseNow, SatLow, SatHigh)
% Updates the global map given the global map, local map and pose
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

% Rotate the map
% Reinitialize LMAP to zeros    
LMAP.map = zeros(LMAP.sizex,LMAP.sizey,'int8');  % char or int8
ScanNowCartRot = double([cos(PoseNow(3)), -sin(PoseNow(3)); sin(PoseNow(3)), cos(PoseNow(3))])*double(ScanNowCart);
[XObserved, YObserved] = getMapCellsFromRay(0,0, ceil(ScanNowCartRot(1,:)/LMAP.res), ceil(ScanNowCartRot(2,:)/LMAP.res));
LinearInd = sub2ind([LMAP.sizey,LMAP.sizex], YObserved + ceil(LMAP.sizey/2), XObserved + ceil(LMAP.sizex/2));
LMAP.map(LinearInd) = -LogOdds(1);
LinearInd = sub2ind([LMAP.sizey,LMAP.sizex],ceil(ScanNowCartRot(2,:)/LMAP.res) + ceil(LMAP.sizey/2),...
                                            ceil(ScanNowCartRot(1,:)/LMAP.res) +ceil( LMAP.sizey/2));
LMAP.map(LinearInd) = LogOdds(2);

% Translate LMAP now
GMAP.map(ceil(GMAP.sizey/2 - LMAP.sizey/2 + PoseNow(2)/LMAP.res):ceil(GMAP.sizey/2 + LMAP.sizey/2 - 1 + PoseNow(2)/LMAP.res),...
    ceil(GMAP.sizex/2 - LMAP.sizex/2 + PoseNow(1)/LMAP.res):ceil(GMAP.sizex/2 + LMAP.sizex/2 - 1 + PoseNow(1)/LMAP.res)) = ...
    GMAP.map(ceil(GMAP.sizey/2 - LMAP.sizey/2 + PoseNow(2)/LMAP.res):ceil(GMAP.sizey/2 + LMAP.sizey/2 - 1 + PoseNow(2)/LMAP.res),...
    ceil(GMAP.sizex/2 - LMAP.sizex/2 + PoseNow(1)/LMAP.res):ceil(GMAP.sizex/2 + LMAP.sizex/2 - 1 + PoseNow(1)/LMAP.res)) + LMAP.map;

% Saturate the readings
GMAP.map(GMAP.map>SatHigh)=SatHigh;
GMAP.map(GMAP.map<SatLow)=SatLow;
end
     
       