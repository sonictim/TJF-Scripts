--@description TJF Remve Any Empty Tracks Among Selected Tracks
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF TJF Remve Any Empty Tracks Among Selected Track
--  Will find any empty tracks among selected tracks an remove them
--
--@changelog
--  v1.0 - nothing to report




----------------------------------MAIN FUNCTION
function Main()

local track_cnt = reaper.CountSelectedTracks(0)

  for i = track_cnt-1, 0, -1  do
  
    local track = reaper.GetSelectedTrack(0, i)
    
    if reaper.CountTrackMediaItems(track) == 0 then
      reaper.DeleteTrack(track)
    end

  end
  
end--Main()



----------------------------------CALL THE SCRIPT

reaper.Undo_BeginBlock()

Main()

reaper.UpdateArrange()

reaper.Undo_EndBlock("TJF Remove Empty Tracks", -1)






