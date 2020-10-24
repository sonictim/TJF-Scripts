--[[
@description TJF Select PIX
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Select PIX
    Finds and selects any track named PIX
  
--]]


for i=0, reaper.CountTracks(0)-1 do
  local track = reaper.GetTrack(0,i)
  local retval, trackname = reaper.GetTrackName( track )
  trackname = string.upper(trackname)
  if trackname == "PIX" or trackname == "VIDEO" then
    reaper.SetTrackSelected( track, true)  
  end

end
