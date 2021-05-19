--@description TJF Move Edit Cursor and Selection to Mouse Cursor (hack for faster video updates)
--@version 1.1
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Move Edit Cursor and Selection to Mouse Cursor (hack for faster video updates)
--
--  This moves the edit cursor and any selected items to the mouse position.
--  Assign to a hotkey and hold it down to more accurately slide selected regions around timeline to video
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--  
--@changelog
--  v1.0 - nothing to report
--  v1.1 - added snap offset support.  Will look for left most snap offset in your timeline.

    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--
reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--  


function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
          return false
    
end--RazorEditSelectionExists()


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
        
        
        
        
        local action = reaper.Undo_CanUndo2(0)
        action = tostring(action)
        if action ~= "TJF Move Edit Cursor and Selection to Mouse Cursor"
        then
            reaper.Undo_BeginBlock()
            reaper.Undo_EndBlock("TJF Move Edit Cursor and Selection to Mouse Cursor", -1)
              
        end

        
        
        
        local items = {}
        local syncitems = {}
        
          for i = 1, reaper.CountSelectedMediaItems(0) 
          do 
                local item = reaper.GetSelectedMediaItem(0,i-1)
                local position = reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                local offset = reaper.GetMediaItemInfo_Value( item, "D_SNAPOFFSET")
                if offset > 0 then table.insert(syncitems, item) end
                
                if items[0] == nil or position < items[0] then items[0] = position + offset end
                items[i] = item
          end
        
        
          if #syncitems > 0 then
          
                for i = 1, #syncitems do
                        local position = reaper.GetMediaItemInfo_Value( syncitems[i], "D_POSITION")
                        local offset = position + reaper.GetMediaItemInfo_Value( syncitems[i], "D_SNAPOFFSET")
                        if i == 1 or offset < items[0] then items[0] = offset end
                end
          
          
          end
          
          
          --Get and adjust for item under mouse
          --[[
          local retval, pos = reaper.BR_ItemAtMouseCursor()
          
          if retval then
              if  reaper.IsMediaItemSelected( retval )  then
              
                      local position = reaper.GetMediaItemInfo_Value( retval, "D_POSITION")
                      local offset = reaper.GetMediaItemInfo_Value( retval, "D_SNAPOFFSET")
                      items[0] = position + offset
              end
          end
        ]]--
        
        
        reaper.Main_OnCommand(40513, 0) -- move edit cursor to mouse cursor
        reaper.Main_OnCommand(41110, 0) -- select track under mouse
        
        
        if #items > 0 --or RazorEditSelectionExists()
        then
                
               
               local pdif =  reaper.GetCursorPositionEx( 0 ) - items[0]
               
               local sel_track = reaper.GetSelectedTrack(0,0)
               if sel_track == nil then
                  sel_track =  reaper.GetTrack(0,0)
               end
               local sel_tracknum = reaper.GetMediaTrackInfo_Value( sel_track, "IP_TRACKNUMBER" )
               
               local track = reaper.GetMediaItemInfo_Value(items[1], "P_TRACK")
               local tracknum = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
              
               
                     track = reaper.GetMediaItemInfo_Value(items[#items], "P_TRACK")
               
               local offset = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" ) - tracknum
               
                     offset = sel_tracknum + offset - reaper.CountTracks(0)
               
               if offset > 0 then
                  
                  sel_tracknum = sel_tracknum - offset
                  
               end
              
        
               local tdif = sel_tracknum - tracknum
               
               for i=1, #items
               do
                     local position = reaper.GetMediaItemInfo_Value( items[i], "D_POSITION")
                     track = reaper.GetMediaItemInfo_Value(items[i], "P_TRACK")
                     tracknum = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
               
                     reaper.SetMediaItemInfo_Value( items[i], "D_POSITION", position + pdif )
                     reaper.MoveMediaItemToTrack( items[i], reaper.GetTrack(0, tracknum + tdif - 1) )
               end
              
        end


end



reaper.PreventUIRefresh(-1)
Main()
reaper.PreventUIRefresh(1)


reaper.defer(function() end) --prevent Undo
