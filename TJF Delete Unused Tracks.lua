function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


reaper.Undo_BeginBlock()
for i=reaper.CountTracks(0)-1, 0, -1 do
    track = reaper.GetTrack(0,i)
    if not reaper.GetTrackMediaItem( track, 0 ) then reaper.DeleteTrack( track ) end
end
reaper.Undo_EndBlock("Delete Unused Tracks", -1)

    
