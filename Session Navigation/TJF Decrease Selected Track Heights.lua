--@description TJF Decrease Selected Track Heights
--@version 1.0
--@author Tim Farrell
--@about
--  # TJF Decrease Selected Track Heights
--  Decreases Track size in nice Jumps
--@changelog
-- v1.0 initial version


function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

local new_height = 64
local tracks = reaper.CountSelectedTracks()
local minimun_height_track = 15
local minimum_height_folder = 25

--if reaper.GetSelectedMediaItem(0,0) then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"), 0) end  -- if items are selected, will select Tracks matching items
function main()
if reaper.GetSelectedTrack(0, 0) then
      
      height = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0),"I_WNDH"  )
      
      if height > 900 then height = 900
      
      elseif height > 600 then height = 600
      
      elseif height > 300 then height = 300
      
      elseif height > 150 then height = 150
      
      elseif height > 64 then height = 64
      
      else height = minimun_height_track
      
      end
      
      
      --[[
      if height <= new_height then
            new_height = minimun_height_track
      end
       
      if height > 150 then
            new_height = 150
      end
      
      if height > 300 then
            new_height = 300
      end
      
      if height > 600 then
            new_height = 600
      end
      ]]--
      
 
end--if


for i = 0, reaper.CountSelectedTracks(0) - 1 do

    if height == minimun_height_track and reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_FOLDERDEPTH" ) == 1 then

       reaper.SetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,i), "I_HEIGHTOVERRIDE", minimum_height_folder)
       
    else
    
        reaper.SetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,i), "I_HEIGHTOVERRIDE", height) 
    end

end




reaper.TrackList_AdjustWindows(0)  -- Updates the window view

reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view


end--main()


--reaper.PreventUIRefresh(1)
main()
--reaper.PreventUIRefresh(-1)
reaper.defer(function() end) --this prevents undo
