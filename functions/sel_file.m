##  SPDX-License-Identifier: BSD-3-Clause
##  Copyright (c) 2023, Sören J. Gerke, 421016+git@mailbox.org
##
## -*- texinfo -*-
## @deftypefnx {} {[fileDir, fileName, fileExt] =} sel_file (path, mask, msg)
## Simple graphical selection of file in path matching mask.
##
## @end deftypefn

function [fileDir, fileName, fileExt] = sel_file (path, mask, msg)

  ## path and mask with globbing
  files = glob ([path "/" mask]);
  ## only list name
  fileNames = cell (length (files), 1);
  for i = 1:length (files)
    [~, fileNames{i}, ~] = fileparts (files{i});
  endfor
  ## select image from list
  [sel, ok] = listdlg ('Name', msg, 'PromptString',
  ["Listing images with mask " mask " :"],
  "ListString", fileNames, "SelectionMode", "Single", "ListSize", [400,450]);
  ## get file infos
  if ok
    [fileDir, fileName, fileExt] = fileparts (files{sel});
  else
    error ("No file selected.");
  endif

endfunction


