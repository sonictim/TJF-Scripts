--[[
@description TJF Trim Left Side of Item (Hover Mode Dependent)
@version 2.6
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # Trim Left Side of Item to Mouse Cursor
  Depending on Hover mode will Trim Left Edge of items to mouse cursor or edit cursor
  Recommend Assigning to "A" key
@changelog
  v1.0 first version
  v2.0 updating behavior logic
  v2.5 added Hover Mode Support
  v2.6 Bug fixes

--]] 

reaper.Undo_BeginBlock()

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
                reaper.Main_OnCommand(41305, 0)  -- Trim Left Edge to Mouse Cursor
                reaper.Main_OnCommand(40511, 0)  -- Trim items Left of Cursor
                reaper.SetEditCurPos(current_pos, 1, 0)
            
            
            end
            
    else
    
                  if reaper.GetSelectedMediaItem(0,0) then  -- if there is an item selection
                  
                    reaper.Main_OnCommand(40630, 0) --  go to start of time selection
                    reaper.Main_OnCommand(40511, 0) --  Trim Items Left of Cursor
                  
                  end--if
              

    

    end--if




reaper.Undo_EndBlock("Trim left edge to mouse TJF", 0)
