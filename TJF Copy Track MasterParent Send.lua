
 local track = reaper.GetSelectedTrack(0,0)
 if track then
    local value = reaper.GetMediaTrackInfo_Value( track, "B_MAINSEND" )
    reaper.SetProjExtState( 0, "TJF", "Track Main Send", value )
 end
 
