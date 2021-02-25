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

function Nsg(param) reaper.ShowConsoleMsg(param.."\n") end



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
          --reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMCHANNELS", 6 )
          --reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMSPEAKERS", 6)
      end
      
      --[[for i=0, reaper.CountMediaItems(0)-1
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
      ]]

end


function RS2test()
    
    local track = reaper.GetSelectedTrack(0,0)
    
    if track
    then
            local fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 1)
            local _, channels = reaper.TrackFX_GetNamedConfigParm( track, fx, "NUMCHANNELS" )
            local _, speakers = reaper.TrackFX_GetNamedConfigParm( track, fx, "NUMSPEAKERS" )
        
        
            local retval, userinput = reaper.GetUserInputs( "ADJUST REASUROUND2", 2, "Number of Input Channels, Number of Speakers", channels..", "..speakers )
            if retval
            then
                      channels, speakers  = userinput:match("(.-),(.*)")
                      
                      for i=0, reaper.CountSelectedTracks(0)-1
                      do
                      
                            track = reaper.GetSelectedTrack(0,i)
                            fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 1)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMCHANNELS", channels)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMSPEAKERS", speakers )
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "RESETCHANNELS", channels )
                      end
                      reaper.UpdateArrange()
            end 
      end
end


function RS2test2()
    
    local item = reaper.GetSelectedMediaItem(0,0)
    local take = reaper.GetActiveTake(item)
    local fx = reaper.TakeFX_AddByName(take, "ReaSurround2", 1)
    reaper.TakeFX_SetNamedConfigParm( take, fx, "NUMCHANNELS", 6)
    reaper.TakeFX_SetNamedConfigParm( take, fx, "NUMSPEAKERS", 6 )
    reaper.TakeFX_SetNamedConfigParm( take, fx, "RESETCHANNELS", 6 )
    
    if item
    then
            local take = reaper.GetActiveTake(item)
            local fx = reaper.TakeFX_AddByName(take, "ReaSurround2", 1)
             _, channels = reaper.TakeFX_GetNamedConfigParm( take, fx, "NUMCHANNELS" )
             _, speakers = reaper.TakeFX_GetNamedConfigParm( take, fx, "NUMSPEAKERS" )
        
        
            local retval, userinput = reaper.GetUserInputs( "ADJUST REASUROUND2", 2, "Number of Input Channels, Number of Speakers", channels..", "..speakers )
            if retval
            then
                      channels, speakers  = userinput:match("(.-),(.*)")
                      
                      for i=0, reaper.CountSelectedTracks(0)-1
                      do
                      
                            track = reaper.GetSelectedTrack(0,i)
                            fx = reaper.TrackFX_AddByName(track, "ReaSurround2", false, 1)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMCHANNELS", channels)
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "NUMSPEAKERS", speakers )
                            reaper.TrackFX_SetNamedConfigParm( track, fx, "RESETCHANNELS", channels )
                      end
                      reaper.UpdateArrange()
            end 
      end
end

function SelectTrackofLastTouchFX()
      local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
        Msg(tracknumber)    
      if retval then
      
           if (tracknumber >> 16) == 0 -- Track FX or Input FX
           then
                   local track = reaper.CSurf_TrackFromID(tracknumber, false)
                   reaper.SetOnlyTrackSelected( track )
           end
      end
end



function VolEnvelopeMath()

    samplerate = reaper.GetSetProjectInfo( 0, "PROJECT_SRATE", 0, false )

    Msg(reaper.SNM_GetDoubleConfigVar( "projgriddiv", 0 ))
    

    envelope = reaper.GetSelectedEnvelope(0)
    
    if envelope then
            
            env_scale = reaper.GetEnvelopeScalingMode(envelope)
            
            for i=0,  reaper.CountEnvelopePoints( envelope )-1 do
                  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, i )
                  
                  
                  Nsg(value)
                  
                  if env_scale == 1 then value = reaper.ScaleFromEnvelopeMode(1, value) end
                  
                  
                  Nsg(value)
                  
                  
                  --retval, Evalue, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( envelope, time, samplerate, 0 )
                  
                  
                  --Msg(Evalue)
                  
                  
                  valueDB = 20*(math.log(value, 10))
                  
                  Nsg(valueDB)
                  
                  value2 = math.exp(valueDB*0.115129254)
                  
                  --Msg(value2)
         
            
            
            end
    end
            
    


end


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()

--InsertFXBeforeReaSurround()
--AddReaSurround2ToEverything()
--RS2test2()
--SelectTrackofLastTouchFX()
 VolEnvelopeMath()
 
 
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

    
   
