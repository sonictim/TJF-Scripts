--[[
@description TJF Trim Only Selected Items Right of Cursor
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Trim Only Selected Items Right of Cursor
  Stops you from accidentally trimming ALL non locked items
--]]


if reaper.GetSelectedMediaItem(0,0) then  --if there is an item selection

  reaper.Main_OnCommand(40631, 0) --  go to end of time selection
  reaper.Main_OnCommand(40512, 0) --  Trim Items Right of Cursor
--  reaper.Main_OnCommand(40630, 0) --  Trim Items Left of Cursor

end
