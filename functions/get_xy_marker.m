##  SPDX-License-Identifier: BSD-3-Clause
##  Copyright (c) 2023, Sören J. Gerke, 421016+git@mailbox.org
##
## -*- texinfo -*-
## @deftypefn  {} {@var{xy} =} get_xy_marker (@var{im}, tag)
## Basic graphical selection of x y coordinates on image @var{im}.
## @end deftypefn

function xy = get_xy_marker (im, tag)

  fh = figure ("name", ["marker #" tag], "windowstyle", "normal");
  pause (1e-6);
  set (fh, "position", get (0, "screensize"));
  imshow (im);

  [x, y, ~] = ginput (1);
  xy = [x, y];

  close (fh);

endfunction


