
local mode = {}

for i=0, reaper.CountTracks(0)-1 do

    mode[i] =  reaper.GetTrackAutomationMode(reaper.GetTrack(0,i))

end--for

reaper.SetAutomationMode( 1, false )

for i=0, reaper.CountTracks(0)-1 do

    reaper.SetTrackAutomationMode(reaper.GetTrack(0,i), mode[i])

end--for
