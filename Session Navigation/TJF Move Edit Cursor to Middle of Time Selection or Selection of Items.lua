--[[
@description Move Edit Cursor To Middle of Time Selection or Selected Items
@version 2.1
@author Claudiohbsantos and Tim Farrell



@about
  # Move Edit Cursor To Middle of Time Selection or Selected Items
  Moves edit cursor to middle of current time selection
@changelog
  - Initial Release
  v1.1 checks for time selection  -- TJF added this
  v2.0 will also move edit cursor to center of selected items if no time selection present.  
      Must have 2 items selected to funcion
--]]




--reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)


  local timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
  local cursorPos = reaper.GetCursorPosition(0)
  
  
  
  if timeSelStart ~= timeSelEnd then -- if there is a time selection
  
        cursorPos = (timeSelEnd - timeSelStart)/2 + timeSelStart
  
  else
  
    if reaper.CountSelectedMediaItems(0) > 1 then  -- if there are 2 or more items selected
    
        reaper.Main_OnCommand(40290, 0) --Set time to selected items
        timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
        cursorPos = (timeSelEnd - timeSelStart)/2 + timeSelStart
        reaper.Main_OnCommand(40635, 0) --remove time selection
    
    end
  
  
  
  end
  
  
 reaper.SetEditCurPos2(0,cursorPos,false,false) 

reaper.PreventUIRefresh(-1)
--reaper.Undo_EndBlock("Move to middle of time Selection", 0)

reaper.defer(function() end) --prevent Undo


