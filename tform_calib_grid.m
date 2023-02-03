##  SPDX-License-Identifier: BSD-3-Clause
##  Copyright (c) 2023, Sören J. Gerke, 421016+git@mailbox.org
##
## tform-calib-grid.m
##
## Octave script to create and transform idealized grid to match the actual
## (distorted) calibration recordings. The transformation is calculated from
## manually selected calibrations points (markers) on the actual calibration
## recording. The transformed idealized grid is written to disk and may be used
## to apply automatic marker detection algorithms (e.g. if those actual
## recordings are of too low quality for automatic detection).

close all; clear all;
pkg load image;

path_to_script = fileparts (mfilename ("fullpath"));
addpath ([path_to_script ":" path_to_script "/functions"]);

## call to create idealized calibration grid (the specific examples given can be
## used in Dantec DynamicStudio (v6.9))
##print_calib_cb ([7 5 1 0 -1 90 1], path_to_script)
##print_calib_dots ([50 20 12.5 100 100], path_to_script)

##
dir_calib = uigetdir ("", "Select folder of calibration records")
if !dir_calib
  error ("No folder selected!");
endif

##
[dir_im name_im_calib ext_im] = sel_file ([dir_calib], ...
  "calib_record___*.tif*", "Select calibration record:");
im_calib = double (imread ([dir_im "/" name_im_calib ext_im])) / (2^16-1);
## improve marker contrast
camtags = {"Neo", "Zyla"};
p_adj   = [ 0.05   0.10 ];
k = (index (name_im_calib, camtags(:)));
im_calib = imadjust (im_calib, stretchlim (im_calib, p_adj(k>1)));
##imshow (im_calib);
name_calib_record = name_im_calib (index (name_im_calib, "___" ):end);
[dir_im name_im_ref ext_im] = sel_file (path_to_script, "calib_*.tif*", ...
  "Select calibration grid:");
im_ref = double (imread ([dir_im "/" name_im_ref ext_im]));
##imshow ((im_ref));

##
#transformType = "polynomial"; NminMarker = 6;
transformType = "affine"; NminMarker = 3;

##
uiwait(msgbox(["Transformation type \"" transformType "\": select at least "...
  int2str(NminMarker) " corresponding marker positions."]));
stop = 0;
marker_calib = [];
marker_ref = [];
i = 1;
while stop == 0
  marker_calib(i,:) = get_xy_marker (im_calib, int2str(i));
  marker_ref(i,:) = get_xy_marker (im_ref, int2str(i));
  if (i > NminMarker - 1)
    choice = questdlg ("Select more markers?", "", "Yes", "No");
    if (strcmp (choice, "No") || strcmp (choice, "Cancel"))
        stop = 1;
    end
  end
  i++;
end

##
if strcmp (transformType, "polynomial")
  proj = cp2tform (marker_ref, marker_calib, transformType, 2);
endif
if strcmp (transformType, "affine")
  proj = cp2tform (marker_ref, marker_calib, transformType);
endif
im_ref_proj = (imtransform ((im_ref), proj, "fillvalues", 255));

## shift and trim projected grid according to domain of original calib record
uiwait (msgbox (["Select the last marker again in projected ref image."]));
origin_ref = (get_xy_marker (im_ref_proj, "origin")); close all;
origin_calib = (marker_calib(end,:));
##
dim_x = size (im_calib, 2);
dim_y = size (im_calib, 1);
dim_ref_proj_x = size (im_ref_proj, 2);
dim_ref_proj_y = size (im_ref_proj, 1);
## origin in coordinate system of original calibration record
xr = (origin_calib(1) - origin_ref(1));
yr = (origin_calib(2) - origin_ref(2));
## calculate trim limits of overlaping area
x0 = int16 (max (1, xr+1));
xe = int16 (min (xr+dim_ref_proj_x, dim_x));
y0 = int16 (max (1, yr+1));
ye = int16 (min (yr+dim_ref_proj_y, dim_y));
##
xx0 = int16 (max (1, 1-xr));
xxe = int16 (min (dim_ref_proj_x, dim_x-xr));
yy0 = int16 (max (1, 1-yr));
yye = int16 (min (dim_ref_proj_y, dim_y-yr));
## extract calibration area
im_ref_proj_calib = ones (dim_y, dim_x);
im_ref_proj_calib(y0:ye,x0:xe) = im_ref_proj(yy0:yye,xx0:xxe);

## write transformed grid
imwrite (im_ref_proj_calib, [dir_calib "/" "projCalib" name_calib_record ...
  ".tiff"], "Compression", "none", "Quality", 100);

## image overlay check
im_check = zeros (dim_y, dim_x, 3);
im_check(:,:,1) = imadjust (im_calib);
im_check(:,:,2) = im_check(:,:,1);
im_check(:,:,3) = im_check(:,:,1);
maxi = max (max (max (im_check)));
im_check = im_check / maxi;
im_check(:,:,3) = im_check(:,:,3) + (1-imadjust((im_ref_proj_calib)));
##
fh_out = figure ("name", ["result"], "windowstyle", "normal");
pause (1e-6);
set (fh_out, "Position", get(0,"Screensize"));
imshow (im_check)
## write image to check the positioning of transformed grid
imwrite (im_check, [dir_calib "/" "projCalibCheck" name_calib_record ...
  ".tiff"], "compression", "jpeg", "quality", 100);


