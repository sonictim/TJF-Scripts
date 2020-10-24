--@description TJF Razor Edit - Enclose Media Items (leave selection)
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Razor Edit - Enclose Media Items (leave selection)
--  Will Allow you to Keep your current Item Selection when you enclose with Razor Edit Boundry
--
--@changelog
--  v1.0 - nothing to report

      
      
      
      
      
      
      
--SAVE CURRENT ITEM SELECTION IN AN ARRAY
    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end
    
    
--SET RAZOR SELECTION TO ITEMS 
     reaper.Main_OnCommand(42409,0) --Razor edit: Enclose media items (will unselect all items)
 

--RESTORE ITEM SELECTION    
    for i=1, itemcount do reaper.SetMediaItemInfo_Value(item[i], "B_UISEL", 1) end


--PREVENT UNDO
    reaper.defer(function() end)
