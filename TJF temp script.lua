



function GetInfo(i) -- builds and returns 2 tables

      local info = {}
      info.ID = reaper.GetSelectedMediaItem( 0, i)
      info.length = reaper.GetMediaItemInfo_Value(info.ID, "D_LENGTH")
      
return info

end -- end of function


function Main()

      local items = {}

      local itemcount = reaper.CountSelectedMediaItems()
      
      if itemcount > 0 then
      
          for i=1, itemcount do
              local info = {}
              info.ID = reaper.GetSelectedMediaItem( 0, i-1) -- since selected items starts at 0, we adjust here
              info.length = reaper.GetMediaItemInfo_Value(info.ID, "D_LENGTH")
              table.insert(items, info)
              --items[i] =  info   <-- could also fill the table this way... you are filling the table entry 
          end
      
      end
      
      
      if #items > 0 then
      
        for i = 1, #items do   -- this loop starts at 1
            reaper.SetMediaItemInfo_Value(items[i].ID, "D_FADEOUTLEN", (items[i].length/2))
        end
      
      end
end


Main()
reaper.UpdateArrange()
