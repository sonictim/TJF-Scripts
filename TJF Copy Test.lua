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
local function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
          return false
    
end--RazorEditSelectionExists()


local function ClearSection(section)

    reaper.DeleteExtState( section, "Razor Edits", true )

    local key = 1
    local loop = reaper.HasExtState(section, "Item" .. key)
    
    while loop == true do
    
          reaper.DeleteExtState( section, "Item" .. key, true )
          key = key + 1
          loop = reaper.HasExtState(section, "Item" .. key)
    end

end


local function GetTrackSelectedMediaItems(track)

    local items = {}
    
    for i=1, reaper.CountTrackMediaItems(track) do
            local item = reaper.GetTrackMediaItem(track, i-1)
            if reaper.IsMediaItemSelected(item) then table.insert(items, item) end
    end

    if #items > 0 then return items end
    
    return false

end


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
local function Main()
      
      if reaper.CountSelectedMediaItems(0) < 1 and not RazorEditSelectionExists() then return end
      
      local starttime, endtime = nil, nil
      
      for t=1, reaper.CountTracks()
      do
            ClearSection("Track"..t)
            
            local track = reaper.GetTrack(0,t-1)
            
            local _, area = reaper.GetSetMediaTrackInfo_String( track, "P_RAZOREDITS", "", false )
            
            reaper.SetExtState( "Track" .. t, "Razor Edits", area, false )
            
            
            
            local items = GetTrackSelectedMediaItems(track)
            
            if items then
                    
                    for i = 1, #items do
                    
                                local itemstart = reaper.GetMediaItemInfo_Value( items[i], "D_POSITION" )
                                local itemend = itemstart + reaper.GetMediaItemInfo_Value( items[i], "D_LENGTH" )
                                if starttime == nil or itemstart < starttime then starttime = itemstart end
                                if endtime == nil or itemend > endtime then endtime = itemend end
                                
                                
                                local _, str = reaper.GetItemStateChunk( items[i], "", false )
                                str = string.gsub(str, "GUID .-\n", "GUID " .. reaper.genGuid("") .. "\n" )
                                reaper.SetExtState( "Track" .. t, "Item"..i, str, false )
                    end
            
            else
            
                          
                    reaper.SetExtState( "Track" .. t, "Item1", "nil", false )
            
            
            end
      
      
      
      end
      
      ClearSection("Track"..reaper.CountTracks()+1)
      
      
      
      
      reaper.SetExtState( "TJF Copy", "StartTime", starttime, false )
      reaper.SetExtState( "TJF Copy", "EndTime", endtime, false )
      
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

    
   
