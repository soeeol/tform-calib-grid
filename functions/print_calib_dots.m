##  SPDX-License-Identifier: BSD-3-Clause
##  Copyright (c) 2023, Sören J. Gerke, 421016+git@mailbox.org
##
## -*- texinfo -*-
## @deftypefn  {} {}  print_calib_dots (@var{def_dots}, @var{printpath})
## Print dotted calibration grid with origin markers to be used for automatic
## calibration detection in Dantec DynamicStudio (v6.9). The geometry of the
## dotted calibration grid is defined with @var{def_dots} and the resulting
## image is printed to @var{printpath}.
##
## Example for @var{def_dots}:
##
## @var{def_dots} = [50 20 12.5 100 100]; # 5 x 2 mm plate with 0.025 mm dots,
## 0.100 mm spacing for detection in Dantec DynamicStudio (v6.9)
##
## @seealso{print_calib_cb}
## @end deftypefn

function print_calib_dots (def_dots, printpath)

  ## using the polygon functions of matgeom to draw the geometry
  pkg load matgeom

  ##
  nx = (def_dots(1));
  ny = (def_dots(2));
  r = def_dots(3);
  dx = def_dots(4);
  dy = def_dots(5);

  ##
  fh_dots = figure ("visible", false);
  axis off; axis equal;
  hold on;

  ## draw dots
  for i = 0:1:ny-2
    for j = 0:1:nx-2
        xy = circleToPolygon ([(j+0.5)*dx, (i+0.5)*dy, r]);
        fillPolygon (xy(:, 1), xy(:, 2), "k");
    endfor
  endfor

  ## add origin markers
  x_c = ((nx - 1) / 2);
  y_c = ((ny - 1) / 2);
  x = [x_c x_c x_c x_c+1 x_c-1] * dx;
  y = [y_c y_c+1 y_c-1 y_c y_c] * dy;
  ## origin marker geometry - specifically for detection in Dantec DynamicStudio (v6.9)
  rC = [2 1/2 1/2 1/2 1/2] * r;
  for i = 1:length (x)
    xy = circleToPolygon ([x(i), y(i), 2*r]);
    fillPolygon (xy(:, 1), xy(:, 2), 'w');
    xy = circleToPolygon ([x(i), y(i), rC(i)]);
    fillPolygon (xy(:, 1), xy(:, 2), 'k');
  endfor

  ##
  set (gca, "Units","normalized");
  set (gca, "position", [0 0 1 1]);
  set (gca, "looseinset", [0 0 0 0]);
  nameStr = ["calib_dots_x" num2str(nx-1) "_y" ...
    num2str(ny-1) "_D" num2str(2*r) "_dx" num2str(dx) "_dy" num2str(dy)];
  print (fh_dots,"-r600",[printpath "/" nameStr ".tif"]);
  hold off; close (fh_dots);

  ##
  pkg unload matgeom

endfunction


