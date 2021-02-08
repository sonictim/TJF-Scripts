--@noindex
--  NoIndex: true   
   local fxname = "Surround Pan 3.0 Nick"
   local presetname = "5.1 -> 5.1"


-------------------------------------------
--   X RayM Code for deleting envelopes  --
-------------------------------------------
function DeleteEnvPart2(env)
  retval, xml_env = reaper.GetEnvelopeStateChunk(env, "", false)
  xml_env = xml_env:gsub("\n", "¤¤")
  retval, xml_env = reaper.SetEnvelopeStateChunk(env, xml_env, false)
return xml_env

end

function DeleteEnv(env, track)

          retval, xml_track = reaper.GetTrackStateChunk(track, "", false)
          xml_track = xml_track:gsub("\n", "¤¤")
          xml_env =   DeleteEnvPart2(env)
end



function EnableAndArmAllParam(track, fx)

   for k = 0, reaper.TrackFX_GetNumParams( track, fx )-1 do  --Enable all Envelopes (Except Bypass) for chosen FX
   
   
       local envelope = reaper.GetFXEnvelope(track, fx, k, 1)
       local BRenvelope = reaper.BR_EnvAlloc( envelope, true )
       
       active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, etype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties( BRenvelope )
       reaper.BR_EnvSetProperties( BRenvelope, true, false, true, inLane, laneHeight, defaultShape, faderScaling)
       
       reaper.BR_EnvFree( BRenvelope, true )
       
  
       --Remove Envelope if it is for Bypass
       retval, value = reaper.GetEnvelopeName( envelope )  --TJF Add - gets name of created envelope
       if string.find(value, "Bypass") then                --if has Bypass in the name
        DeleteEnv(envelope, track) end 
       
        
   end--for




end


-------------------------------------------
--              MAIN                     --
-------------------------------------------

function Main()
   
   
   for i=0, reaper.CountSelectedTracks(0)-1 do
       local track = reaper.GetSelectedTrack(0,i)
       local fx =  reaper.TrackFX_AddByName( track, fxname, false, 1 )
       
       EnableAndArmAllParam(track, fx)
       
       reaper.TrackFX_SetPreset( track , fx, presetname )
       
       
   end--for
   
        
 end
 
 
 reaper.Undo_BeginBlock()
 Main()
 reaper.UpdateArrange()
 reaper.TrackList_AdjustWindows(false)
 reaper.Undo_EndBlock("Set Surround Panner to " .. presetname, 0)

          
          
          
