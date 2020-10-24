--[[
@description TJF Trim and Fill to time selection Only if items are selected Selected
@version 1.1
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 28
@about
  # TJF Trim and Fill to time selection Only if items are selected Selected
  Useful for BGs.  Will Trim and Fill to your time selection, but only if items are select.
  Will prevent you from accidentally trimming your guide tracks.
--]]

reaper.Undo_BeginBlock()

if reaper.GetSelectedMediaItem(0,0) then  -- if there is an item selection

  reaper.Main_OnCommand(reaper.NamedCommandLookup( "_SWS_AWTRIMCROP"), 0) --  Trim or crop Items to edit Cursor
  reaper.Main_OnCommand(reaper.NamedCommandLookup( "_SWS_AWTRIMFILL"), 0) --  Fill items to time selection
end

reaper.Undo_EndBlock("Trim/Fill to time selection", 0)
