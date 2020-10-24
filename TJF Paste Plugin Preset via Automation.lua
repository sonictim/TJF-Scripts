reaper.Main_OnCommand(40290, 0)
local track = reaper.GetSelectedTrack(0,0)

local mode =  reaper.GetTrackAutomationMode( track )

reaper.SetTrackAutomationMode( track, 5 )

local fx =   reaper.TrackFX_AddByName( track, "ReaSurround", false, 0 )

 reaper.TrackFX_SetPreset( track, fx, "2 Channel Default" )
 reaper.Main_OnCommand(41160,0) --  Write Values
 
 reaper.SetTrackAutomationMode( track, mode )
 

