--@noindex
--  NoIndex: false
--@description TJF Add/Adjust/Reset ReaSurround2 Settings for selected items or tracks
--@version 0.2
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Add/Adjust/Reset ReaSurround2 Settings for selected items or tracks
--  Will go through each Selected Items/Track, add ReaSurround2 if missing, and set the number of inputs/speakers according to the user input
--  Will run reset on each item/take (can be disabled via Global Variable).  If you do not have automation written it will adjust your puck positions
--  If You do not enter any Input for a field, it will not be adjusted in ReaSurround2. Leave both fields blank to simply run RESET PUCKS on all selected items/tracks
--  There are a few Global Variables you may want to adjust to you liking.  I strongly suggest you investigate these and their descriptions
--  Note: If you cancel at the input section, it will not add ReaSurround2 to your item/track
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--  
--@changelog
--  v0.2 - nothing to report

    --[[------------------------------[[---
              GLOBAL VARIABLES              
    ---]]------------------------------]]--    

ResetPucks = true        --if true will run ReaSurround2 Reset on each selected item or track
TracksOnly = false       --if true will only attempt to process only tracks and ignore any selected items
ProcessBoth = false      --if true, script will attempt to process both items and tracks
                         --if false will look first for selected items to process, if none are found, it will try to process tracks.
                                                

    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    

function UpdateItems(item)
            local take = reaper.GetActiveTake(item)
            local fx = reaper.TakeFX_AddByName(take, "ReaSurround2", 0)
            local _, channels = reaper.TakeFX_GetNamedConfigParm( take, fx, "NUMCHANNELS" )
            local _, speakers = reaper.TakeFX_GetNamedConfigParm( take, fx, "NUMSPEAKERS" )
        
        
            local retval, userinput = reaper.GetUserInputs( "ReaSurround2 Add/Adjust ITEMS", 2, "Number of Input Channels, Number of Speakers", channels..", "..speakers )
            if retval
            then
                      channels, speakers  = userinput:match("(.-),(.*)")
                      
                      for i=0, reaper.CountSelectedMediaItems(0)-1
                      do
                            item = reaper.GetSelectedMediaItem(0,i)
                            take = reaper.GetActiveTake(item)
                            fx = reaper.TakeFX_AddByName(take, "ReaSurround2", 1)
                            reaper.TakeFX_SetNamedConfigParm( take, fx, "NUMCHANNELS", channels)
                            reaper.TakeFX_SetNamedConfigParm( take, fx, "NUMSPEAKERS", string.upper(speakers) )
                            if ResetPucks then reaper.TakeFX_SetNamedConfigParm( take, fx, "RESETCHANNELS", channels ) end
                      end
            end 
end    


function UpdateTracks(track)
    
            local fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 0)
            local _, channels = reaper.TrackFX_GetNamedConfigParm( track, fx, "NUMCHANNELS" )
            local _, speakers = reaper.TrackFX_GetNamedConfigParm( track, fx, "NUMSPEAKERS" )
        
        
            local retval, userinput = reaper.GetUserInputs( "ReaSurround2 Add/Adjust TRACKS", 2, "Number of Input Channels, Number of Speakers", channels..", "..speakers )
            if retval
            then
                      channels, speakers  = userinput:match("(.-),(.*)")
                      
                      for i=0, reaper.CountSelectedTracks(0)-1
                      do
                      
                            track = reaper.GetSelectedTrack(0,i)
                            fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 1)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMCHANNELS", channels)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMSPEAKERS", string.upper(speakers) )
                            if ResetPucks then reaper.TrackFX_SetNamedConfigParm( track, fx, "RESETCHANNELS", channels ) end
                      end
                      reaper.UpdateArrange()
            end 
end
    


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
  
  local item = reaper.GetSelectedMediaItem(0,0)
  local track = reaper.GetSelectedTrack(0,0)
  
  
  
  
  if item and not TracksOnly then UpdateItems(item) end
  if (ProcessBoth or not item) and track then UpdateTracks(track) end
    
end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
reaper.Undo_EndBlock("TJF Adjust ReaSurround2", -1)
    
   
