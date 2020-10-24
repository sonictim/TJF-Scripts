--@description TJF AAF Select all Split Stereo Tracks from AAF
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF TJF AAF Select all Split Stereo Tracks from AAF
--  After an AAF conversion, will look for Tracks with identical names and select them
--
--@changelog
--  v1.0 - nothing to report


reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
name1 = "tim"
name2 = "jill"
retval = "fred"


for i = 0, reaper.CountTracks()-2 do
 retval, name1 = reaper.GetTrackName( reaper.GetTrack(0, i) )
  retval, name2 = reaper.GetTrackName( reaper.GetTrack(0, i+1) )
  
  if name1 == name2 then
  
  reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i), "I_SELECTED", 1)
  reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i+1), "I_SELECTED", 1)
  
  end
  

end


