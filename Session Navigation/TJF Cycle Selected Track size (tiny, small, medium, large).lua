--@description TJF Cycle Select Track size Minimize Others
--@version 1.7
--@author Tim Farrell
--@about
--  # TJF Cycle Track Size
--  This will also minimize all non selected tracks
--@changelog
--  v1.3  will now work if no tracks are selected (will minimize all)
--  v1.4  will now prioritize zoom to Time Selection, then Items
--  v1.5  will change number of possible zooms based on how many tracks are selected
--  v1.6  added support for envelope lanes
--  v1.7  Bug Fixes

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
reaper.ClearConsole()

local new_height = 64
local tracks = reaper.CountSelectedTracks()
local minimun_height_track = 15
local minimum_height_folder = 25

--if reaper.GetSelectedMediaItem(0,0) then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"), 0) end  -- if items are selected, will select Tracks matching items
function main()
if reaper.GetSelectedTrack(0, 0) then
      
      height = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0),"I_TCPH"  )
      
      --if height < new_height then height = new_height end
      
      if height >= new_height then
            if tracks < 7 then new_height = 150 else new_height = minimun_height_track end
      end
       
      if height >= 150 then
            if tracks < 5 then new_height = 300 else new_height = minimun_height_track end
      end
      
      if height >= 300 then
            if tracks < 3 then new_height = 600 else new_height = minimun_height_track end
      end
      
      if height >= 600 then
            if tracks == 1 then new_height = 900 else new_height = minimun_height_track end
      end
      
      if height >= 900 then new_height = minimun_height_track end
      
 
end--if





--------------------------SET ALL TRACKS TO DEFAULT MINMIZED HEIGHTS

for i = 0, reaper.CountTracks(0) - 1 do

    local retval, name = reaper.GetTrackName( reaper.GetTrack(0,i) )

    if name == "PIX" and reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_SELECTED" ) == 0 then
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", 150)
    
    elseif reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_FOLDERDEPTH" ) == 1 then  -- IF TRACK IS A FOLDER PARENT then
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", minimum_height_folder)  -- SETS THE DEFAULT PIXEL HEIGHT OF FOLDER PARENT TRACKS
    else
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,i), "I_HEIGHTOVERRIDE", minimun_height_track)  -- SETS THE DEAFULT PIXEL HEIGHT OF ALL OTHER TRACKS
    end
end


--------------------------SET ALL SELECTED TRACKS TO NEW HEIGHTS (if not minimized)
for i = 0, reaper.CountSelectedTracks(0) - 1 do
 
 if new_height ~= minimun_height_track then
    
    reaper.SetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,i), "I_HEIGHTOVERRIDE", new_height)
    
  end

    
end



reaper.TrackList_AdjustWindows(0)  -- Updates the window view

reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view


end--main()


--reaper.PreventUIRefresh(1)
main()
--reaper.PreventUIRefresh(-1)
reaper.defer(function() end) --this prevents undo
