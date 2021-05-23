function GetRazorEditStart()
          local retval = false  
          local position = nil

          for i=0, reaper.CountTracks(0)-1 do
              _, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then 
                  retval = true
                  x = x:match "%d+.%d+"
                  
                  if position == nil or position > x then position = x
                  end
              
              end
              
          end
          
          return retval, position

end

function Main()

    --local restore = reaper.GetCursorPosition()

    local retval, position = GetRazorEditStart()

    if    retval
    then
          reaper.SetEditCurPos( position, true, true )
          reaper.Main_OnCommand(40699, 0) -- Cut Items
          reaper.ApplyNudge(0, 0, 6, 2, .5, true, 0) -- Nudge edit cursor to the right by half grid unit
          reaper.Main_OnCommand(42398, 0) -- Paste Items
    
    
    
    elseif reaper.GetSelectedMediaItem(0,0)
    then
          reaper.ApplyNudge(0, 0, 0, 2, .5, true, 0) -- Nudge items to the right by one grid unit
          reaper.Main_OnCommand(41173, 0)  -- Item navigation: Move cursor to start of items
    else
    
          reaper.ApplyNudge(0, 0, 6, 2, .5, true, 0) -- Nudge edit cursor to the right by half grid unit
    end
    
end


    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

reaper.Undo_EndBlock("TJF Nudge", -1)
