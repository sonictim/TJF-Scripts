--@description TJF Unselect Every Other Item
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

--@about
--   # TJF Unselect Every Other Item
--
--   This script was made by request for Dave Farmer
--   It Unselects every other item if you have a number of items selected


--   DISCLAIMER:
--   This script was written for my own personal use and therefore I offer no support of any kind.
--   Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--   I strongly recommend never to run this or any other script I've written for any reason what so ever.
--   Ignore this advice at your own peril!
  

--@changelog
--   v1.0 - nothing to report


    
    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
    
    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
    for i = 1, #item do 
        if i % 2 == 0 then
            reaper.SetMediaItemSelected( item[i], false )
        end
    end
    

end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
reaper.Undo_EndBlock("TJF Unselect Every other Item", -1)

    
   
