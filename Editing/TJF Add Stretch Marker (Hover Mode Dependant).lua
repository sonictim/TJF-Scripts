--[[
@description TJF Add Strech Marker (Hover Mode Dependant)
@version 2.1
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Add Strech Marker (Hover Mode Dependant)
  Will add Stretch Markers at Mouse Cursor or Edit Curser depending on Hover Mode Status
  Recommend Assign to "W" key
@changelog
  v1.0 initial release
  v2.1 bug fixes
  
--]]
reaper.Undo_BeginBlock()

reaper.Main_OnCommand(40570, 0) --disable locking


local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

  if start_time ~= end_time then -- if there is a time selection
          reaper.Main_OnCommand(41843, 0) -- Item: Add stretch markers at time selection

  else



          local cmd_id = reaper.NamedCommandLookup("_RS7c63ddf7171c4cad70a2a5aa14943b5188b93d74")  --get ID of Hover Mode
          local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
                
              if state==1 then
              
                      local current_pos =  reaper.GetCursorPosition()
                      
                      local x,y = reaper.GetMousePosition()
                      local item = reaper.GetItemFromPoint(x,y,false) -- boolean is "allow locked items"
                       
                      if item then
                      
                          if not reaper.IsMediaItemSelected( item ) then 
                              reaper.Main_OnCommand(40528, 0)  -- select item under mouse cursor
                          end
                      end 
                      
                      
                      if reaper.GetSelectedMediaItem(0,0) then --check if something is selected
                      
                          reaper.Main_OnCommand(40514, 0)  -- View: Move edit cursor to mouse cursor (no snapping)
                          reaper.Main_OnCommand(41842, 0)  -- Item: Add stretch marker at cursor
                          reaper.SetEditCurPos(current_pos, 1, 0)
                      
                      
                      end
                         
              
              else
              
                  reaper.Main_OnCommand(41842, 0) -- Item: Add stretch marker at cursor
              
              end--if
    end--if
    

    
reaper.Undo_EndBlock("TJF Split", 0)
