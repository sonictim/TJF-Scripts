--@description TJF Toggle Track SuperCollapsed
--@version 1.1
--@author Tim Farrell
--
--@about
--  # TJF Toggle Track SuperCollapsed
--  Toggles Selected Tracks Super Collapsed state.  All Tracks will match.  Accounts for parents/children
--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - better programming on GetChildren


----------------------------------
--          DEBUG               --
----------------------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end




----------------------------------
--          GET PARENT          --
----------------------------------

function GetParent(track)
            if      reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
            then    return  track
            elseif  reaper.GetTrackDepth(track) > 0 then return reaper.GetParentTrack(track)
            else    return false
            end
end--GetParent()



function GetChildren(parent)

        if parent then 
        
              local parentdepth = reaper.GetTrackDepth(parent)
              local parentnumber = reaper.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER")
              local children = {}
              
              for i=parentnumber, reaper.CountTracks(0)-1 do
                    local track = reaper.GetTrack(0,i)
                    local depth = reaper.GetTrackDepth(track)
                    
                    if depth > parentdepth then
                        table.insert(children, track)
                    else
                        break -- exit loop
                    end
              end--for
              
              return children
        end--if
        
end--GetChildren()
            

function GetParentTable()
            local parentlist = {}
            local oldparent
            for i=0, reaper.CountSelectedTracks(0)-1 do
                  local parent = GetParent(reaper.GetSelectedTrack(0,i))
                  if parent ~= oldparent then
                      table.insert(parentlist, parent)
                  end
                oldparent = parent
            end--for
            return parentlist

end--ParentTable




function AnyHidden(tracks)

  for i=1, #tracks do
     if not reaper.IsTrackVisible( tracks[i], false ) then return true end
  
  end--for
  
      return false

end--AnyHidden()




function SetVisibility(tracks, bool)

  for i=1, #tracks do
       reaper.SetMediaTrackInfo_Value( tracks[i], "B_SHOWINTCP", bool ) 
        
  end--for

end -- SetVisibility





----------------------------------
--           MAIN               --
----------------------------------

function Main()
      reaper.ClearConsole()
      
      parents = GetParentTable()
      
      local compacted

            for i=1, #parents do
            
            if parents[i] ~= false then
                local parent = parents[i]
                local kids = GetChildren(parent)
                
                if i==1 then
                      compacted = reaper.GetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT")
                      if compacted ~= 2 then
                          compacted = 2
                      else
                          compacted = 0
                      end--if
                end--if
                reaper.SetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT", compacted)
 
            end--for
            
      end--if
 
end--Main()



----------------------------------
--        CALL SCRIPT           --
----------------------------------

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)

reaper.defer(function() end)


