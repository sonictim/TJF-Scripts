--@noindex
--  NoIndex: true
--@description TJF Script Name
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Script Name
--
--  Information about the script
--
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

    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
      if reaper.CountSelectedMediaItems(0) < 1 then return end
      
      
      --local section = "TJF Item Clipboard"
      local key = 1
      local loop = reaper.HasExtState(section, key)
      local starttime, endtime = nil, nil
      
      while loop == true do
      
            reaper.DeleteExtState( section, key, true )
            key = key + 1
            loop = reaper.HasExtState(section, key)
      end
      
      for t=1, reaper.CountTracks()
      do
            local track = reaper.GetTrack(0,t-1)
            local section = "Track" .. t
            local counter = 0
            
            for i = 1, reaper.CountTrackMediaItems(0) do
                  local item = reaper.GetTrackMediaItem(0, i-1)
                  if reaper.IsMediaItemSelected(item) then
                        counter = counter + 1
                        local itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                        local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                        if starttime == nil or itemstart < starttime then starttime = itemstart end
                        if endtime == nil or itemend > endtime then endtime = itemend end
                        
                        local _, str = reaper.GetItemStateChunk( item, "", false )
                        str = string.gsub(str, "GUID .-\n", "GUID " .. reaper.genGuid("") .. "\n" )
                        reaper.SetExtState( section, "Item"..counter, str, false )
                  end
            end
            
            
      
      
      
      end
      
      
      
      
      reaper.SetExtState( section, "StartTime", starttime, false )
      reaper.SetExtState( section, "EndTime", endtime, false )
      
end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
--reaper.Undo_BeginBlock()
--reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
--reaper.PreventUIRefresh(-1) -- uncomment only once script works
--reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
--reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
