
local  _, value = reaper.GetProjExtState( 0, "TJF", "Track Main Send" )

if value ~= "" then
      for i=0, reaper.CountSelectedTracks(0)-1 do
          track = reaper.GetSelectedTrack(0,i)
          reaper.SetMediaTrackInfo_Value( track, "B_MAINSEND", value )
      end
else
    reaper.MB( "Please Use TJF Copy Track MasterParent Send to store value", "NO VALUE STORED", 0 )
end
