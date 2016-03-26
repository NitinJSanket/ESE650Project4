% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fcRGB = [ 1049.331752604831308 ; 1051.318476285322504 ];

%-- Principal point:
ccRGB = [ 956.910516428015740 ; 533.452032441484675 ];

%-- Skew coefficient:
alpha_cRGB = 0.000000000000000;

%-- RGBistortion coefficients:
kcRGB = [ 0.026147836868708 ; -0.008281285819487 ; -0.000157005204226 ; 0.000147699131841 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_errorRGB = [ 2.164397369394806 ; 2.020071561303139 ];

%-- Principal point uncertainty:
cc_errorRGB = [ 3.314956924207777 ; 2.697606587350414 ];

%-- Skew coefficient uncertainty:
alpha_c_errorRGB = 0.000000000000000;

%-- RGBistortion coefficients uncertainty:
kc_errorRGB = [ 0.005403085916854 ; 0.015403918092499 ; 0.000950699224682 ; 0.001181943171574 ; 0.000000000000000 ];

%-- Image size:
nxRGB = 1920;
nyRGB = 1080;

