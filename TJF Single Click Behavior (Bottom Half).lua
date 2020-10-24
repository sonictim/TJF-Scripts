--@description TJF Single Click Behavior
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Single Click Behavior
--  Mimics Default item click behavior... updates edit cursor to mouse cursor and selects item if unselected
--  Selecting an unselected Item will clear any previous item selection.
--  HOWEVER, if item or group of items is already selected, it will not clear the selection
--
--@changelog
--  v1.0 - nothing to report


----------------------------------COMMON FUNCTIONS or FUNCTIONS I WANT TO REMEMBER

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



--------------------------------SET COMMON VARIABLES

    local SelItems = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do SelItems[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
----------------------------------MAIN FUNCTION
function Main()



    local item, mousepos = reaper.BR_ItemAtMouseCursor()
    
    --reaper.SetEditCurPos(mousepos, 1, 0)
    
    
 
    if item then 
    
          selected = reaper.GetMediaItemInfo_Value(item,"B_UISEL" )
       
          if selected == 0 then
          
              reaper.SetMediaItemInfo_Value(item, "B_UISEL", 1)
              
                  for i = 1, itemcount do
                  
                      reaper.SetMediaItemInfo_Value( SelItems[i], "B_UISEL", 0)
                  
                  end--for
          
          end--if
    end--if


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
--reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.Undo_EndBlock("TJF Script Name", -1)

reaper.defer(function() end) --prevent Undo

    
   
