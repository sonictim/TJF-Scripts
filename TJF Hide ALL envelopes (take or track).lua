for i=0, reaper.CountTracks(0) -1 do
        local track = reaper.GetTrack(0,i)
        local _,  str = reaper.GetTrackStateChunk(track, "", false )
        str = string.gsub(str, "\nVIS %d", "\nVIS 0")
        reaper.SetTrackStateChunk(track, str, false)
end
