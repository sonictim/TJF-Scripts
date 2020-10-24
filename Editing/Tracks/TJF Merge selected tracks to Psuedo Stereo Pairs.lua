--@description TJF Merge Selected Tracks to Pseudo Stereo Pairs
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Merge Selected Tracks to Pseudo Stereo Pairs
--  Takes every two selected tracks and combines them into "pseudo" stereo pairs.
--  Uses Xenakios Implode to takes and pan symmetrically
--
--@changelog
--  v1.0 - nothing to report




function Main()

track = {}
trackcount = reaper.CountSelectedTracks(0)


for i=1, trackcount  do
    track[i]=reaper.GetSelectedTrack(0,i-1)
end

processcount = trackcount

if processcount % 2 == 1 then processcount = processcount-1 end

processcount = processcount / 2

local t = 1

for i=1, processcount do
  reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
  reaper.SetMediaTrackInfo_Value(track[t], "I_SELECTED", 1)
  reaper.SetMediaTrackInfo_Value(track[t+1], "I_SELECTED", 1)
  
  reaper.Main_OnCommand(40421,0) -- Select all items on track
  reaper.Main_OnCommand( reaper.NamedCommandLookup("_XENAKIOS_IMPLODEITEMSPANSYMMETRICALLY"),0) -- Implode and pan symmetrically
  t=t+2
end

for i=1, trackcount do
reaper.SetMediaTrackInfo_Value(track[i], "I_SELECTED", 1)

end

--REMOVE EMPTY TRACKS
  local track_cnt = reaper.CountSelectedTracks(0)
  local total_h = 0
  for i = track_cnt-1, 0, -1  do
    local track = reaper.GetSelectedTrack(0, i)
    local tcp_h = reaper.GetMediaTrackInfo_Value(track, "I_WNDH")
    total_h = total_h + tcp_h
    if reaper.CountTrackMediaItems(track) == 0 then
      reaper.DeleteTrack(track)
    end
  end
  

  
end



reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
reaper.Undo_EndBlock("TJF AAF Merge tracks to stereo", -1)
