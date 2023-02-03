##  SPDX-License-Identifier: BSD-3-Clause
##  Copyright (c) 2023, Sören J. Gerke, 421016+git@mailbox.org
##
## -*- texinfo -*-
## @deftypefn  {} {}  print_calib_cb (@var{def_cb}, @var{printpath})
## Print checkerboard calibration grid with origin markers to be used for
## automatic calibration detection in Dantec DynamicStudio (v6.9). The geometry
## of the checkerboard calibration grid is defined with @var{def_cb} and the
## resulting image is printed to @var{printpath}.
##
## Some examples for @var{def_cb}:
##
## @var{def_cb} = [5 5 1 0 0 0 0]; # 5 x 5 board with (0,0) origin
##
## @var{def_cb} = [5 5 1 0 0 90 0]; # 5 x 5 board with (0,0) origin, rotated 90°
##
## @var{def_cb} = [9 7 1 0 -2 90 0]; # 9 x 7 board with (0,-2) origin, rotated
## 90°
##
## @var{def_cb} = [9 7 1 0 -2 90 1]; # 9 x 7 board with (0,-2) origin, rotated
## 90°, mirrored
##
## @seealso{print_calib_dots}
## @end deftypefn

function print_calib_cb (def_cb, printpath)

  ## using the polygon functions of matgeom to draw the geometry
  pkg load matgeom

  ##
  nx = 2 * (def_cb(1)); # horizontal # of squares
  ny = 2 * (def_cb(2)); # vertical # of squares
  s = (def_cb(3)); # side length of square
  x_coff = def_cb(4);
  y_coff = def_cb(5);
  rot = def_cb(6);
  mirr = def_cb(7);

  ##
  fh_cb = figure ("visible", false);
  axis off; axis equal;
  hold on;

  ## draw checkerboard
  for k = [0,s]
    for i = k:s*2:(ny-1)*s
      for j = k:s*2:(nx-1)*s
          xy = rectToPolygon ([j, i, s, s]);
          fillPolygon (xy(:, 1), xy(:, 2), "k");
      endfor
    endfor
  endfor

  ## add origin markers - specifically for detection in Dantec DynamicStudio (v6.9)
  x_c = (nx+1)/2 + 2*x_coff;
  y_c = (ny+1)/2 + 2*y_coff;
  x = [x_c, x_c, x_c+1]*s;
  y = [y_c, y_c+2, y_c]*s;
  colors = ["w", "w", "k"];
  for i = 1:length(x)
    xy = circleToPolygon ([x(i), y(i), s/4]);
    fillPolygon (xy(:, 1), xy(:, 2), colors(i));
  endfor

  ## rotate and mirror
  camroll (rot)
  if mirr
    set (gca, "ydir", "reverse")
  endif

  ##
  set (gca, "Units","normalized")
  set (gca, "position", [0 0 1 1])
  set (gca, "looseinset", [0 0 0 0])
  nameStr = ["calib_cb_x" num2str(nx/2) "_y" ...
    num2str(ny/2) "_xc" num2str(x_coff) "_yc" num2str(y_coff) "_deg" ...
    num2str(rot) "_m" num2str(mirr)];
  print (fh_cb, "-r600", [printpath "/" nameStr ".tif"]);
  hold off;
  close (fh_cb);

  ##
  pkg unload matgeom

endfunction


