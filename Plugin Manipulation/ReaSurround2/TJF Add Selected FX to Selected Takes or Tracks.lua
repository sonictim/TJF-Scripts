--@noindex
--  NoIndex: false
--@description TJF Add Selected FX to Selected Takes or Tracks
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Add Selected FX to Selected Takes or Tracks
--
--  Adds selected FX to Selected takes.  If no takes are selected, then it will run on selected tracks.
--  FX WILL BE ADDED IN THE CHAIN JUST BEFORE ReaSurround2.  This will keep reasurround at the final spot in the chain, unless you've added/moved things after it
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

    
local undotype = ""
local undoname = ""

    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()

  if    reaper.GetSelectedMediaItem(0,0)
  then
        undotype = "Take"
        for i=0, reaper.CountSelectedMediaItems(0)-1
        do  
            local item = reaper.GetSelectedMediaItem(0,i)
            local take = reaper.GetActiveTake(item)
            local reasurr = reaper.TakeFX_AddByName(take, "ReaSurround2", 0)
            local position = reaper.TakeFX_AddByName( take, "FXADD:", -1000 - reasurr  )
            _, undoname = reaper.TakeFX_GetFXName( take, position, "" )
            
        end
  else
        undotype = "Track"
        for i=0, reaper.CountSelectedTracks(0)-1
        do
            local track = reaper.GetSelectedTrack(0,i)
            local reasurr = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 0)
            local position = reaper.TrackFX_AddByName( track, "FXADD:", false, -1000 - reasurr  )
            _, undoname = reaper.TrackFX_GetFXName( track, position, "" )
        
        end
  
  end


end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
reaper.Undo_EndBlock("Add " .. undotype .. "FX - " .. undoname, -1)

 
   
