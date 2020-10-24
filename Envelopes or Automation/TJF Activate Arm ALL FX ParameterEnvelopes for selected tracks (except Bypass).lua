-- Lua Script for Reaper 5.0 and up
-- Activate and arm all FX parameters on selected tracks (Except Bypass)
--
-- Written by Anthony "Airon" Oetzmann With Help from Tim Farrell and X-RayM
-- This script is public domain
-- Post your feedback and alternate versions at
-- http://forum.cockos.com/showthread.php?t=167880


----X RayM Code for deleting envelopes
function Action(env)
  retval, xml_env = reaper.GetEnvelopeStateChunk(env, "", false)
  xml_env = xml_env:gsub("\n", "¤¤")
  retval, xml_env = reaper.SetEnvelopeStateChunk(env, xml_env, false)
return xml_env

end

function DeleteEnv(env, track)

          retval, xml_track = reaper.GetTrackStateChunk(track, "", false)
          xml_track = xml_track:gsub("\n", "¤¤")
          xml_env =  Action(env)
end



--Airon's Script
function main()
  reaper.Undo_BeginBlock()

  selected_tracks_count = reaper.CountSelectedTracks(0) -- Get number of selected tracks
  if selected_tracks_count == 0 then
    return --dbug ("No track selected\n")
  end
  for i = 0, selected_tracks_count-1  do                -- Loop over every selected track
    track = reaper.GetSelectedTrack(0, i)               -- Get a track
    track_fx_count = reaper.TrackFX_GetCount(track)     -- how many fx on that track ?
    for j = 0, track_fx_count-1  do
      track_fxparam_count = reaper.TrackFX_GetNumParams(track, j) -- Get number of fx in track
      for k = 0, track_fxparam_count-1  do -- Loop over each parameter of this track
        -- This will create(& thus activate) and arm the FX envelope
        envelope = reaper.GetFXEnvelope(track, j, k, 1)
      
        retval, name = reaper.GetEnvelopeName( envelope )  --TJF Add - gets name of created envelope
        if string.find(name, "Bypass") then                --if has Bypass in the name
         DeleteEnv(envelope, track) end   
         --Run XrayM's Delte Envelope code
         
         
        
        
      end -- ENDLOOP through FX parameters
    end -- ENDLOOP through FX
  end -- ENDLOOP through selected tracks
  reaper.Main_OnCommand(40889,0) -- Hide all Envelopes on Selected Tracks

  reaper.Undo_EndBlock("Activate and Arm all FX Parameter envelopes on selected tracks (Except Bypass)", 0)
end

main() -- Execute your main function
reaper.UpdateArrange() -- Update the arrangement
reaper.TrackList_AdjustWindows(false) -- update tracklist (XrayM suggestion)
