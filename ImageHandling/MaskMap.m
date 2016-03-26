function OGColorMap = MaskMap(GMAP, OGColorMap)
% Masks the OGColorMap given the LogOddsOGMap
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

MaskNow = (GMAP.map~=0); % Explored Areas
OGColorMap(:,:,1) = OGColorMap(:,:,1).*MaskNow;
OGColorMap(:,:,2) = OGColorMap(:,:,2).*MaskNow;
OGColorMap(:,:,3) = OGColorMap(:,:,3).*MaskNow;
MaskNow = (GMAP.map>80); % Wall Areas
OGColorMapR = OGColorMap(:,:,1);
OGColorMapG = OGColorMap(:,:,2);
OGColorMapB = OGColorMap(:,:,3);

OGColorMapR(MaskNow) = 1;
OGColorMapG(MaskNow) = 0;
OGColorMapB(MaskNow) = 0;

OGColorMap = cat(3, OGColorMapR,OGColorMapG,OGColorMapB);
end