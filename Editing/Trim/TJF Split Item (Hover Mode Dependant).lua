--[[
@description TJF Split Item at Time Selection, otherwise Mouse Cursor
@version 2.01
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
  Will also not split if no item is selected.
  Mimics "B" in protools
  Adds Hover Mode Support
  
--]]
reaper.Undo_BeginBlock()

local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

  if start_time ~= end_time   -- if there is a time selection
  then
          reaper.Main_OnCommand(40061, 0) -- Item: Split items at time selection
  else
      


          local cmd_id = reaper.NamedCommandLookup("_RS7c63ddf7171c4cad70a2a5aa14943b5188b93d74")  --get ID of Hover Mode
          local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
                
              if  state==1
              then
              
                       local current_pos =  reaper.GetCursorPosition()
                      
                       local window, segment, details = reaper.BR_GetMouseCursorContext()
                       local item = reaper.BR_GetMouseCursorContext_Item()
                       
                       
                        if item then
                      
                            selected = reaper.IsMediaItemSelected( item )
                            
                            if not  selected 
                            then    
                                    reaper.Main_OnCommand(40746, 0) -- Split Item under mouse cursor
                            else
                                    if    reaper.GetSelectedMediaItem(0,0)  --check if something is selected
                                    then  
                            
                                        reaper.Main_OnCommand(40514, 0)  -- View: Move edit cursor to mouse cursor (no snapping)
                                        reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
                                        --reaper.Main_OnCommand(40757, 0)  -- Item: Split items at edit cursor (no change selection)
                                        reaper.SetEditCurPos(current_pos, 1, 0)
                                    end--if
                            end--if
                            
                        end
                         
              
              else
              
                  reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
              
              end--if
      
    end--if
    

    
reaper.Undo_EndBlock("TJF Split", 0)
