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


local function GetItems(section)
      
      local items = {}
      
      items.Razor = reaper.GetExtState( section, "Razor Edits")
      
      local key = 1
      local loop = reaper.HasExtState(section, "Item" .. key)
      
      while loop == true do
      
            items[key] =  reaper.GetExtState( section, "Item" .. key )
            if items[key] == "nil" then items[key] = nil end
            key = key + 1
            loop = reaper.HasExtState(section, "Item" .. key)
      end
      
      
      return items


end


function GetCopyData()

  local tracks = {}

  
  local key = 1
  local section = "Track" .. key
  local loop = reaper.HasExtState(section, "Item1")
  
  while loop == true do
  
        table.insert(tracks, GetItems(section))
        key = key + 1
        section = "Track" .. key
        loop = reaper.HasExtState(section, "Item1")
  end
  
   tracks.starttime = reaper.GetExtState( "TJF Copy", "StartTime" )
   tracks.endtime = reaper.GetExtState( "TJF Copy", "endTime" )


    return tracks
end




    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
local function Main()
      
       
       
      
      
      track = GetCopyData()
      
      
      
      
      local pdif =  reaper.GetCursorPositionEx( 0 ) - track.starttime
      --[[
      for i = 1, #items do
          local item = reaper.AddMediaItemToTrack( reaper.GetTrack(0,0) )
          reaper.SetItemStateChunk( item, items[i], false )
          local itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
          reaper.SetMediaItemInfo_Value( item, "D_POSITION", itemstart + pdif )

      
      end
      ]]
      
      
      
end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
--reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
--reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Paste Test", -1)

--reaper.defer(function() end) --prevent Undo

    
   
