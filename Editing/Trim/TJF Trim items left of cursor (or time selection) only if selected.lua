--[[
@description TJF Trim Only Selected Items Left of Cursor
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Trim Only Selected Items Left of Cursor
  Stops you from accidentally trimming ALL non locked items
--]]

if reaper.GetSelectedMediaItem(0,0) then  -- if there is an item selection

  reaper.Main_OnCommand(40511, 0) --  Trim Items Left of Cursor

end
