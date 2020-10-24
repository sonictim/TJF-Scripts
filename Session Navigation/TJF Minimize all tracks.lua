--@description TJF Minimize All Tracks
--@version 1.0
--@author Tim Farrell
--@about
--  # TJF Minimize All Tracks
--  This will also minimize all tracks.
--  Folders will be set slightly larger than regular tracks for visibility
--  Must update RTCONFIG.INI in theme for this to work correctly

--@changelog
--  v1.3  will now work if no tracks are selected (will minimize all)
--  v1.4  will now prioritize zoom to Time Selection, then Items
--  v1.5  will change number of possible zooms based on how many tracks are selected


for i = 0, reaper.CountTracks(0) - 1 do

    local retval, name = reaper.GetTrackName( reaper.GetTrack(0,i) )

    if name == "PIX" and reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_SELECTED" ) == 0 then
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", 150)

    elseif reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_FOLDERDEPTH" ) == 1 then  -- IF TRACK IS A FOLDER PARENT then
        
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_FOLDERCOMPACT", 0) -- adjust children to non compact
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", 25)  -- SETS THE DEFAULT PIXEL HEIGHT OF FOLDER PARENT TRACKS

    else

        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", 15)  -- SETS THE DEAFULT PIXEL HEIGHT OF ALL OTHER TRACKS

    end
end



reaper.TrackList_AdjustWindows(0)

reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view

reaper.defer(function() end) --this prevents undo
