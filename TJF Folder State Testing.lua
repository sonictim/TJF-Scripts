function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function ParentChildren(track)
        local count = reaper.CountTracks(0)
        local track = reaper.GetSelectedTrack(0,0)
        local depth = reaper.GetTrackDepth(track)
        local parent

        
            if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
            then parent = track
            elseif depth > 0 then parent = reaper.GetParentTrack(track)
            else return false
            end
            
        if parent then 
        
              local parentdepth = reaper.GetTrackDepth(parent)
              local parentnumber = reaper.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER")
              local number = parentnumber
              depth = depth + 1
              local children = {}
              i=1
              
              while depth ~= parentdepth and number <= reaper.CountTracks(0) do
                
                track = reaper.GetTrack(0,number)
                if track then
                    depth = reaper.GetTrackDepth(track)
                    children[i] = track
                    number = number + 1
                    i = i + 1
                else depth = parentdepth
                end
              end--while
              
              return parent, children
        
        end--if
      

end--ParentChildrenTrackF

function GetVisibility(tracks)

  for i=1, #tracks do
     if not reaper.IsTrackVisible( tracks[i], false ) then return false end
  
  end--for
  
      return true

end--GetVisibilityKids()

function SetVisibility(tracks, bool)

  for i=1, #tracks do
       reaper.SetMediaTrackInfo_Value( tracks[i], "B_SHOWINTCP", bool ) 
        
  end--for

end -- SetVisibility





function Main()
      reaper.ClearConsole()

      
      local parent, kids = ParentChildren(reaper.GetSelectedTrack(0,0))
      
      
      if parent then
      
          local compacted = reaper.GetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT")
          if compacted ~= 2 then
              reaper.SetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT", 2)
              SetVisibility(kids, 1)
          else
              hide = GetVisibility(kids)
              if hide then 
                  SetVisibility(kids, 0)
              else 
                  SetVisibility(kids, 1)
                  reaper.SetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT", 0)
              end
              
                
          
          end--if
          
          --local hide = GetVisibility(kids) 
          --SetVisibility(kids, hide)
          reaper.SetOnlyTrackSelected(parent )
      end--if
      
      reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
end--Main()

Main()



