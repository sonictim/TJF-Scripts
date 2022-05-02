--@description TJF LINK Razor Edit Selection with Folders, Item Grouping Affects Behavior (defered)
--@version 2.1
--@author BirdBird, Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

--@about
--   # TJF LINK Razor Edit Selection with Folders, Item Grouping Affects Behavior
--
--   This script takes a proof of concept script written by BirdBird and applies a little extra functionality
--   Namely, if grouping is enabled, the script will select all children track
--   If not, Razor edit will behave as normal, except on folder parents... then it will select children also
--   This is meant to mimic a similar functionality in Pro Tools

--   This is a deferred script.  Choose "Terminate" upon running a second time...
--  
--   This script may contain bugs as it is a proof of concept


--   DISCLAIMER:
--   This script was written for my own personal use and therefore I offer no support of any kind.
--   Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--   I strongly recommend never to run this or any other script I've written for any reason what so ever.
--   Ignore this advice at your own peril!
  

--@changelog
--   v1.0 - nothing to report
--   v1.1 - added to reapack (adjusted headers
--   v1.11- reapack test
--   v2.0 - reapack test
--   v2.1 - Bugfix (Thanks BethHarmon, for the bug and BIRD BIRD for the improved code and bugfix)

    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function GetParent(track)
            if      reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
            then    return  track
            elseif  reaper.GetTrackDepth(track) > 0 then return reaper.GetParentTrack(track)
            else    return false
            end
end--GetParent()



--Thanks Embass for the function!
function get_child_tracks(folder_track)
  local all_tracks = {}
  if reaper.GetMediaTrackInfo_Value(folder_track, "I_FOLDERDEPTH") ~= 1 then
    return all_tracks
  end
  local tracks_count = reaper.CountTracks(0)
  local folder_track_depth = reaper.GetTrackDepth(folder_track)  
  local track_index = reaper.GetMediaTrackInfo_Value(folder_track, "IP_TRACKNUMBER")
  for i = track_index, tracks_count - 1 do
    local track = reaper.GetTrack(0, i)
    local track_depth = reaper.GetTrackDepth(track)
    if track_depth > folder_track_depth then      
      table.insert(all_tracks, track)
    else
      break
    end
  end
  return all_tracks
end



function edit_is_envelope(edit)
  local t = {}
  for match in (edit .. ' '):gmatch("(.-)" .. ' ') do
    table.insert(t, match);
  end
  local is_env = true
  for i = 1, #t/3 do
    is_env = is_env and t[i*3] ~= '""'
  end 
  return is_env
end



function extend_razor_edits()
  local t_tracks = {}
  local track_count = reaper.CountTracks(0)
  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local rv, edits = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
    if edits ~= "" and not edit_is_envelope(edits) then
      if reaper.GetToggleCommandState(1156) == 1 then --Checks if ITEM grouping is enabled or bypassed
          track = GetParent(track)
      end  -- sets track to the track's parent
      
      local child_tracks = get_child_tracks(track)
      if #child_tracks > 0 then
        for i = 1, #child_tracks do
          local c_track = child_tracks[i]
          table.insert(t_tracks, {track = c_track, edits = edits})
        end
      end
      table.insert(t_tracks, {track = track, edits = edits})
    end
  end
  if #t_tracks > 0 then
    reaper.PreventUIRefresh(1)
    for i = 1, #t_tracks do
      local track = t_tracks[i].track
      local edits = t_tracks[i].edits
      if reaper.IsTrackVisible(track, false) then
        reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', edits, true)
      end
    end
    reaper.PreventUIRefresh(-1)
  end
end



local l_proj_count = -1
function main()
  local proj_count = reaper.GetProjectStateChangeCount(0)
  if l_proj_count ~= proj_count then
    local action = reaper.Undo_CanUndo2(0)
    if action and string.find(string.lower(action), "razor") then
      extend_razor_edits()
    end
  end
  l_proj_count = proj_count
  reaper.defer(main)
end


main()
