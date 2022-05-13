
function main() 
      local item, position = reaper.BR_ItemAtMouseCursor()
      
      if item then
            local itemcount = reaper.CountSelectedMediaItems(0)
            
            if (reaper.IsMediaItemSelected(item) or itemcount == 0) then
                  reaper.Main_OnCommand(41307, 0) -- Item edit: Move right ende of item to edit cursor
            
            else
                  for i=0, itemcount-1 do
                      local p = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,i), "D_POSITION" )
                      if i == 0 or p < position then
                              position = p
                      end--if
                  end--for
                  
                  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position - reaper.GetMediaItemInfo_Value(item, "D_LENGTH" ) )
                  reaper.SetMediaItemSelected( item, true )
                  
            end--if
      end

            
            


     
 end -- main()
 
 
 
 
 
     
 reaper.Undo_BeginBlock()
 reaper.PreventUIRefresh(1) -- uncomment only once script works
 main()
 reaper.PreventUIRefresh(-1) -- uncomment only once script works
 reaper.UpdateArrange()
 --reaper.UpdateTimeline()
 --reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
 reaper.Undo_EndBlock("Nudge Items", -1)
 
 --reaper.defer(function() end) --prevent Undo
