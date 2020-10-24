


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
          else reaper.SetMediaItemInfo_Value(item, "B_UISEL", 0)
              
                 -- for i = 1, itemcount do
                  
                     -- reaper.SetMediaItemInfo_Value( SelItems[i], "B_UISEL", 0)
                  
                 -- end--for
          
          end--if
    end--if


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
--reaper.Undo_BeginBlock()
--reaper.Main_OnCommand(40455,0) --Load Window Set 02
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.Undo_EndBlock("TJF Script Name", -1)

reaper.defer(function() end) --prevent Undo

    
   
