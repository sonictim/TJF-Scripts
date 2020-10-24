function SetSurroundBypass(param)

    
    for i=0, reaper.CountTracks(0)-1 do
      local track = reaper.GetTrack(0,i)
      local fx =  reaper.TrackFX_AddByName( track, "ReaSurround", false, 0)
      if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, param ) end
      fx =  reaper.TrackFX_AddByName( track, "Surround Pan 2.1", false, 0)
      if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, param ) end
    end
    
end --SetSurroundBypass()
