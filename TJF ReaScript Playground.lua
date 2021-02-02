--@noindex
--  NoIndex: true
--@description TJF Script Name
--@version 0.1
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
                GLOBAL VARIABLES               
    ---]]------------------------------]]--


    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    

function PinMapTesting()

    item = reaper.GetSelectedMediaItem(0,0)
    take = reaper.GetActiveTake(item)
    fx = 0
    isoutput = 0
    pin = 1
    
    
    retval, high32 = reaper.TakeFX_GetPinMappings( take, fx, isoutput, pin )
     
     --reaper.TakeFX_SetPinMappings( take, fx, isoutput, pin, low32bits, hi32bits )
     reaper.TakeFX_SetPinMappings( take, fx, isoutput, pin, 31, 0 )
    
end


function InsertFXBeforeReaSurround()

  if    reaper.GetSelectedMediaItem(0,0)
  then
        for i=0, reaper.CountSelectedMediaItems(0)-1
        do  
            local item = reaper.GetSelectedMediaItem(0,i)
            local take = reaper.GetActiveTake(item)
            local reasurr = reaper.TakeFX_AddByName(take, "ReaSurround2", 0)
            local position = reaper.TakeFX_AddByName( take, "FXADD:", -1000 - reasurr  )
        end
  else
        for i=0, reaper.CountSelectedTracks(0)-1
        do
            local track = reaper.GetSelectedTrack(0,i)
            local reasurr = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 0)
            local position = reaper.TrackFX_AddByName( track, "FXADD:", false, -1000 - reasurr  )
        
        end
  
  end

end


function AddReaSurround2ToEverything()

      for i=0, reaper.CountTracks(0)-1
      do
          local track = reaper.GetTrack(0,i)
          local fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 1)
          reaper.TrackFX_SetPreset( track, fx, "5.1 Default - 6 channels" )
      end
      
      for i=0, reaper.CountMediaItems(0)-1
      do
          local item = reaper.GetMediaItem(0, i)
          local take = reaper.GetActiveTake(item)
          local source = reaper.GetMediaItemTake_Source(take)
          local sourcechan = reaper.GetMediaSourceNumChannels(source)
          local takemode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
          
          local fx = reaper.TakeFX_AddByName(take, "ReaSurround2", 1)

          if    sourcechan == 1 or (takemode > 1 and takemode < 65)
          then  reaper.TakeFX_SetPreset( take, fx, "Mono -> 5.1" )
          else  reaper.TakeFX_SetPreset( take, fx, "Stereo -> 5.1" )
          end
          
      end


end


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()

--InsertFXBeforeReaSurround()
AddReaSurround2ToEverything()


end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
 reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Script Testing", -1)

--reaper.defer(function() end) --prevent Undo

    
   
